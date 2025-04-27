#!/usr/bin/env python3
# FIXME: slixmpp functions are untyped, but are called from a typed
#        context.
# mypy: ignore-errors

import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from datetime import datetime
from math import floor

import psutil
from slixmpp import ClientXMPP
from slixmpp.exceptions import IqError, IqTimeout


def geo_lookup(body: str) -> dict[str, str]:
    geo_url = (
        "https://geocoding-api.open-meteo.com/v1/search?name="
        + urllib.parse.quote_plus(body)
        + "&count=1&language=en&format=json"
    )
    with urllib.request.urlopen(urllib.request.Request(geo_url)) as geo_resp:
        # FIXME: return an error to the user if geo lookup fails
        geo_json = json.loads(geo_resp.read())["results"][0]
        coordinates = {
            "city": geo_json["name"],
            "country": geo_json["country"],
            "timezone": geo_json["timezone"],
            "latitude": geo_json["latitude"],
            "longitude": geo_json["longitude"],
        }
        try:
            coordinates["province"] = geo_json["admin1"]
        except KeyError:
            coordinates["province"] = ""
    return coordinates


def wmo_code(weather_code: int) -> str:
    # WMO Weather interpretation codes
    match weather_code:
        case 0:
            return "Clear skies."
        case 1:
            return "Mostly clear."
        case 2:
            return "Partly cloudy."
        case 3:
            return "Overcast."
        case 45:
            return "Foggy."
        case 48:
            return "Freezing (rime) fog."
        case 51:
            return "Light drizzle."
        case 53:
            return "Moderate drizzle."
        case 55:
            return "Heavy drizzle."
        case 56:
            return "Light freezing drizzle."
        case 57:
            return "Heavy freezing drizzle."
        case 61:
            return "Light rain."
        case 63:
            return "Moderate rain."
        case 65:
            return "Heavy rain."
        case 66:
            return "Light freezing rain."
        case 67:
            return "Heavy freezing rain."
        case 71:
            return "Light snowfall."
        case 73:
            return "Moderate snowfall."
        case 75:
            return "Heavy snowfall."
        case 77:
            return "Snow grains."
        case 80:
            return "Light rain showers."
        case 81:
            return "Moderate rain showers."
        case 82:
            return "Violent rain showers."
        case 85:
            return "Light snow showers."
        case 86:
            return "Heavy snow showers."
        case 95, 96, 99:
            return "Thunderstorm."
    fallthrough = (
        "An unknown weather phenomenon is in progress. "
        + f"Everything's fine. Probably. (WMO Code {weather_code})"
    )
    return fallthrough


def get_weather(
    latitude: str, longitude: str, city: str, province: str, country: str
) -> str:
    cur_url = (
        f"https://api.open-meteo.com/v1/forecast?latitude={latitude}"
        + f"&longitude={longitude}"
        + "&current=temperature_2m,"
        + "relative_humidity_2m,"
        + "apparent_temperature,"
        + "precipitation,"
        + "wind_speed_10m"
        + "&hourly=uv_index"
    )
    aqi_url = (
        "https://air-quality-api.open-meteo.com/v1/air-quality"
        + f"?latitude={latitude}"
        + f"&longitude={longitude}"
        + "&current=us_aqi,uv_index"
    )
    with urllib.request.urlopen(urllib.request.Request(cur_url)) as current:
        current_json = json.loads(current.read())["current"]
    with urllib.request.urlopen(urllib.request.Request(aqi_url)) as aqi:
        aqi_json = json.loads(aqi.read())["current"]
    weather = {
        "temperature": current_json["temperature_2m"],
        "relative_humidity": current_json["relative_humidity_2m"],
        "apparent_temperature": current_json["apparent_temperature"],
        "precipitation": current_json["precipitation"],
        "wind_speed": current_json["wind_speed_10m"],
        "aqi": aqi_json["us_aqi"],
        "uv_index": aqi_json["uv_index"],
    }
    message = (
        f"Current weather in {city}, {province}, {country}\n"
        + "~~~\n"
        + f"AQI: {weather['aqi']}; UV: {weather['uv_index']}\n"
        + f"Feels like: {weather['apparent_temperature']}ºC "
        + f"({weather['temperature']}ºC, "
        + f"{weather['relative_humidity']}% humidity, "
        + f"{weather['wind_speed']} km/h)"
    )

    return message


def get_forecast(latitude: str, longitude: str, timezone: str) -> str:
    fut_url = (
        f"https://api.open-meteo.com/v1/forecast?latitude={latitude}"
        + f"&longitude={longitude}"
        + "&hourly=temperature_2m,"
        + "relative_humidity_2m,"
        + "apparent_temperature,"
        + "precipitation_probability,"
        + "wind_speed_10m,"
        + "wind_direction_10m,"
        + "weather_code"
        + f"&timezone={re.sub('/', '%2F', timezone)}"
        + "&forecast_days=1"
    )
    with urllib.request.urlopen(urllib.request.Request(fut_url)) as forecast:
        forecast_json = json.loads(forecast.read())["hourly"]
    os.environ["TZ"] = timezone
    current_hour = int(time.strftime("%k"))
    message = "Hourly forecast\n~~~\n"
    for hour in range(current_hour, current_hour + min(6, 24 - current_hour)):
        message += (
            f"{hour}:00: "
            + f"{forecast_json['apparent_temperature'][hour]}ºC, "
            + f"{forecast_json['precipitation_probability'][hour]}% precip. "
            + f"{wmo_code(int(forecast_json['weather_code'][hour]))}\n"
        )
    return message


def get_wikipedia(query: str) -> str:
    wiki_url = (
        "https://en.wikipedia.org/w/api.php?format=json&action=query"
        "&prop=extracts&exintro&explaintext&redirects=1"
        f"&titles={urllib.parse.quote_plus(query)}"
    )
    with urllib.request.urlopen(urllib.request.Request(wiki_url)) as wiki:
        wiki_json = json.loads(wiki.read())["query"]["pages"]
    for key in wiki_json:
        try:
            summary = re.sub("\n", "\n\n", wiki_json[key]["extract"])
            message = f"Wikipedia: {wiki_json[key]['title']}\n" + "~~~\n" + f"{summary}"
            return message
        except KeyError:
            return "article not found"
    return "article not found"


def get_miniflux(query: str) -> str:
    miniflux_url = (
        f"{miniflux_server}/v1/entries"
        + f"?search={urllib.parse.quote_plus(query)}"
        + "&order=published_at&direction=desc&limit=10"
    )
    headers = {"X-Auth-Token": miniflux_token}
    with urllib.request.urlopen(
        urllib.request.Request(miniflux_url, headers=headers)
    ) as flux:
        flux_json = json.loads(flux.read())["entries"]
    message = ""
    try:
        for iter in range(0, len(flux_json)):
            message += (
                f"Title: {flux_json[iter]['title']}\n"
                + f"Date: {flux_json[iter]['published_at']}\n"
                + f"URL: {flux_json[iter]['url']}\n\n"
            )
    except IndexError:
        return "not found"
    return message


def get_sysinfo() -> str:
    cpu_count = os.cpu_count()
    uptime_seconds = time.clock_gettime(time.CLOCK_BOOTTIME)  # type: ignore; clock_boottime is valid, so why does mypy think it isn't?
    if uptime_seconds > 86400:
        uptime = f"{floor(uptime_seconds / 86400)} day(s)"
    elif uptime_seconds > 3600:
        uptime = f"{floor(uptime_seconds / 3600)} hour(s)"
    elif uptime_seconds > 60:
        uptime = f"{floor(uptime_seconds / 60)} minute(s)"
    else:
        uptime = f"{floor(uptime_seconds)} seconds"
    loadavg = os.getloadavg()
    message = (
        f"os:\t\t{os.uname().sysname} "
        f"{os.uname().release} ({os.uname().machine})\n"
        f"uptime:\t{uptime}\n"
        f"memory:\t{psutil.virtual_memory().percent}% of "
        f"{round(psutil.virtual_memory().total / (1024 * 1024 * 1024))}G\n"
        f"load:\t{round(loadavg[0], 2)} {round(loadavg[1], 2)} "
        f"{round(loadavg[2], 2)} ({cpu_count}cpu)\n"
    )
    return message


def vanguard_parse_date(timestamp: str) -> str:
    date = datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%S%z")
    return date.strftime("%Y-%m-%d")


def get_vanguard(fund: str) -> str:
    url = f"https://investor.vanguard.com/vmf/api/{fund}/price"
    try:
        with urllib.request.urlopen(urllib.request.Request(url)) as fund_info:
            fund_json = json.loads(fund_info.read())
    except Exception:
        return f"Fund {fund} not found."
    current = fund_json["currentPrice"]["dailyPrice"]["regular"]
    historical_json = fund_json["historicalPrice"]["nav"][0]["item"]
    historical = ""
    max_lookback = 6
    if max_lookback < len(historical_json):
        vanguard_lookback = max_lookback
    else:
        vanguard_lookback = len(historical_json)
    for iter in range(1, vanguard_lookback):
        historical += (
            f" - {vanguard_parse_date(historical_json[iter]['asOfDate'])}: "
            + f"${historical_json[iter]['price']}\n"
        )
    fund = (
        f"{fund} price as of "
        + f"{vanguard_parse_date(current['asOfDate'])}: "
        + f"{current['price']} ({current['priceChangePct']}%)\n\n"
        + "Trends\n"
        + f"{historical}\n"
    )
    return fund


class EchoBot(ClientXMPP):
    def __init__(self, jid, password):
        ClientXMPP.__init__(self, jid, password)

        self.add_event_handler("session_start", self.session_start)
        self.add_event_handler("message", self.message)

        self.register_plugin("xep_0030")  # Service Discovery
        self.register_plugin("xep_0199")  # XMPP Ping

    def session_start(self, event):
        self.send_presence()
        self.get_roster()

        try:
            self.get_roster()
        except IqError:
            self.disconnect()
        except IqTimeout:
            self.disconnect()

    def message(self, msg):
        if msg["type"] in ("chat", "normal"):
            cmd = "{body}".format(**msg).casefold()
            if cmd.startswith("help"):
                message = (
                    "usage:\n"
                    + "\tforecast [identifier]\n"
                    + "\tnews [topic]\n"
                    + "\twiki [article]\n"
                )
            elif cmd.startswith("forecast") or cmd.startswith("weather"):
                query = re.sub("^(forecast|weather) ", "", cmd)
                geo = geo_lookup(query)
                message = get_weather(
                    geo["latitude"],
                    geo["longitude"],
                    geo["city"],
                    geo["province"],
                    geo["country"],
                )
                message += "\n\n"
                message += get_forecast(
                    geo["latitude"], geo["longitude"], geo["timezone"]
                )
            elif cmd.startswith("news"):
                query = re.sub("^news ", "", cmd)
                message = get_miniflux(query)
            elif cmd.startswith("vanguard"):
                query = re.sub("^vanguard ", "", cmd).upper()
                message = get_vanguard(query)
            elif cmd.startswith("wikipedia") or cmd.startswith("wiki"):
                query = re.sub("^(wiki|wikipedia) ", "", cmd)
                message = get_wikipedia(query)
            elif cmd == "sys" or cmd == "sysinfo":
                message = get_sysinfo()
            else:
                message = "command not recognised"

            msg.reply(f"{message}").send()


if __name__ == "__main__":
    try:
        with open("/etc/xmppbot/config.json") as f:
            config = json.load(f)
    except OSError:
        print("ERROR: Configuration file not found.")
        sys.exit(1)
    xmpp_account = config.get("xmpp_account")
    xmpp_password = config.get("xmpp_password")
    miniflux_server = config.get("miniflux_server")
    miniflux_token = config.get("miniflux_token")

    xmpp = EchoBot(xmpp_account, xmpp_password)
    xmpp.connect()
    xmpp.process(forever=True)  # type: ignore

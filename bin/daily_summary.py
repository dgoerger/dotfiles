#!/usr/bin/env python3

import json
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from time import strftime


def argparse(args: list[str]) -> list[str]:
    usage = f"Usage:\n\t{args[0]} latitude longitude"
    if len(args) != 3:
        print(usage)
        sys.exit(1)

    latitude = args[1]
    longitude = args[2]

    coordinate_pattern = re.compile("^(\+)?(\-)?[0-9]+\.[0-9]+$")

    if not coordinate_pattern.match(latitude) or not coordinate_pattern.match(
        longitude
    ):
        print(usage)
        sys.exit(1)

    return [latitude, longitude]


def hour_of_day() -> int:
    return int(strftime("%k"))


def today() -> str:
    return " ".join(strftime("%A, %e %B %Y").split())


def calendar() -> str:
    return subprocess.run(["calendar", "-A0"], capture_output=True, text=True).stdout


def sunstat(latitude: str, longitude: str) -> str:
    return subprocess.run(
        ["sunstat", latitude, longitude], capture_output=True, text=True
    ).stdout


def geo_query(latitude: str, longitude: str) -> dict[str, str]:
    geo_url = (
        "https://api.weather.gov/points/"
        + latitude.strip("+")
        + ","
        + longitude.strip("+")
    )
    with urllib.request.urlopen(urllib.request.Request(geo_url)) as geo_response:
        geo_json = json.loads(geo_response.read())["properties"]
    geo_data = {
        "forecast_url": geo_json["forecast"] + "?units=si",
        "observation_stations_url": geo_json["observationStations"],
        "city": geo_json["relativeLocation"]["properties"]["city"],
        "state": geo_json["relativeLocation"]["properties"]["state"],
    }
    return geo_data


def current_weather(observation_stations_url: str) -> dict[str, int]:
    with urllib.request.urlopen(
        urllib.request.Request(observation_stations_url)
    ) as stations_response:
        stations_json = json.loads(stations_response.read())["features"]
    stationIdentifier = stations_json[0]["properties"]["stationIdentifier"]
    current_conditions_url = (
        "https://api.weather.gov/stations/" + stationIdentifier + "/observations/latest"
    )
    with urllib.request.urlopen(
        urllib.request.Request(current_conditions_url)
    ) as current_conditions_response:
        current_conditions_json = json.loads(current_conditions_response.read())[
            "properties"
        ]
    if current_conditions_json["temperature"]["value"] is None:
        # fall back to the next-nearest station if the closest weather station
        # .. doesn't return valid data, for example during station maintenance
        stationIdentifier = stations_json[1]["properties"]["stationIdentifier"]
        with urllib.request.urlopen(
            urllib.request.Request(current_conditions_url)
        ) as current_conditions_response:
            current_conditions_json = json.loads(current_conditions_response.read())[
                "properties"
            ]

    apparent_temperature = (
        current_conditions_json["windChill"]["value"]
        or current_conditions_json["heatIndex"]["value"]
        or current_conditions_json["temperature"]["value"]
        or -273
    )
    current_data = {
        "temperature": round(current_conditions_json["temperature"]["value"] or -273),
        "relativeHumidity": round(
            current_conditions_json["relativeHumidity"]["value"] or 0
        ),
        "apparent_temperature": round(apparent_temperature),
    }
    return current_data


def air_quality(latitude: str, longitude: str, geo_data: dict[str, str]) -> str:
    aqi_params = {
        "latitude": latitude,
        "longitude": longitude,
        "stateCode": geo_data["state"],
        "maxDistance": "50",
    }

    aqi_url = "https://airnowgovapi.com/reportingarea/get"

    aqi_request = urllib.parse.urlencode(aqi_params).encode("ascii")
    with urllib.request.urlopen(
        urllib.request.Request(aqi_url, aqi_request)
    ) as aqi_response:
        aqi_json = json.loads(aqi_response.read())[0]

    aqi = (
        str(aqi_json["aqi"])
        + " ("
        + aqi_json["category"]
        + ", "
        + aqi_json["parameter"]
        + ")"
    )
    return str(aqi)


def uv_index(geo_data: dict[str, str], hour_of_day: int) -> str:
    uv_index_url = (
        "https://data.epa.gov/efservice/getEnvirofactsUVHOURLY/CITY/"
        + urllib.parse.quote(str(geo_data["city"]))
        + "/STATE/"
        + urllib.parse.quote(str(geo_data["state"]))
        + "/json"
    )
    # index 0 starts at 7am? pretend that any time between 00-07 is
    # .. really 7h, it's likely all 0 anyway. The alternative would
    # .. be to query the previous day's data, as each day's dataset
    # .. appears to run from 7h -> 3h the next day, which would
    # .. still leave a gap between 3h and 7h in any case. It's a bit
    # .. gross, but c'est la vie.
    uv_json_index = hour_of_day - 7
    if uv_json_index < 0:
        uv_json_index = 0
    with urllib.request.urlopen(urllib.request.Request(uv_index_url)) as uv_response:
        uv_json = json.loads(uv_response.read())[uv_json_index]
    return str(uv_json["UV_VALUE"] or 0)


def weather_forecast(forecast_url: str, forecast_lookahead_in_days: int) -> list[str]:
    with urllib.request.urlopen(
        urllib.request.Request(forecast_url)
    ) as forecast_response:
        forecast_json = json.loads(forecast_response.read())["properties"]["periods"]

    return [
        f"{forecast_json[index]['name']}: {forecast_json[index]['detailedForecast']}"
        for index in range(forecast_lookahead_in_days * 2)
    ]


if __name__ == "__main__":
    latitude, longitude = argparse(sys.argv)
    long_forecast = [6]
    geo_data = geo_query(latitude, longitude)
    if hour_of_day() in long_forecast:
        forecast_lookahead_in_days = 3
        print(today())
        print(calendar())
        print(f"Forecast for {geo_data['city']}, {geo_data['state']}")
        print("~~~")
        print(sunstat(latitude, longitude).rstrip("\n"))
        print("~~~\n")
    else:
        forecast_lookahead_in_days = 0
        print(f"Current weather in {geo_data['city']}, {geo_data['state']}")
        print("~~~")
    print(
        "AQI: "
        + air_quality(latitude, longitude, geo_data)
        + "; UV: "
        + uv_index(geo_data, hour_of_day())
    )
    current_data = current_weather(geo_data["observation_stations_url"])
    print(
        f"Feels like: {current_data['apparent_temperature']}ºC "
        f"({current_data['temperature']}ºC, "
        f"{current_data['relativeHumidity']}% humidity)\n"
    )
    if hour_of_day() in long_forecast:
        print(
            "\n\n".join(
                weather_forecast(geo_data["forecast_url"], forecast_lookahead_in_days)
            )
        )

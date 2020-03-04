//////////////////////////////////////////
//////// Mozilla User Preferences ////////
//////////////////////////////////////////
////                                  ////
////     /etc/firefox/pref/user.js    ////
////               OR                 ////
////  /usr/local/lib/firefox/browser  ////
////    /defaults/preferences/user.js ////
////                                  ////
////  (applies to new profiles only)  ////
////                                  ////
//////////////////////////////////////////

// neuter the hazard of ctrl+q
pref("browser.showQuitWarning", true);

// set spellcheck language to Canadian English moz#836230
pref("browser.search.countryCode", "CA");
pref("browser.search.region", "CA");
pref("spellchecker.dictionary", "en-CA");

// disable loading system colours
pref("browser.display.use_system_colors", false);

// resolves OpenBSD OOM error when asm.js tries to alloc 8gb
pref("javascript.options.asmjs", false);

// https://wiki.mozilla.org/Security/Fingerprinting
// NB: sets timezone to UTC
pref("privacy.resistFingerprinting", true);

// https://wiki.mozilla.org/Security/FirstPartyIsolation
// NB: appears to break Atlassian login
pref("privacy.firstparty.isolate", true);

// NB: XOriginPolicy=1 seems to break Atlassian.net login..?
pref("network.http.referer.XOriginPolicy", 1);
pref("network.http.referer.XOriginTrimmingPolicy", 2);
pref("network.http.referer.userControlPolicy", 2);

// disable address/search bar "one-off" custom searches
pref("browser.urlbar.oneOffSearches", false);
pref("browser.urlbar.searchSuggestionsChoice", false);

// disable misc nonsense
pref("app.normandy.enabled", false);
pref("browser.bookmarks.showRecentlyBookmarked", false);
pref("browser.ctrlTab.recentlyUsedOrder", false);
pref("browser.download.manager.addToRecentDocs", false);
pref("browser.onboarding.enabled", false);
pref("dom.serviceWorkers.enabled", false);
pref("media.autoplay.default", 1);
pref("network.dnsCacheExpiration", 0);
pref("offline-apps.allow_by_default", false);

// backspace goes back a page
pref("browser.backspace_action", 0);

// disable a href ping
pref("browser.send_pings", false);
pref("browser.send_pings.require_same_host", true);
pref("beacon.enabled", false);

// stop the goog
pref("browser.safebrowsing.enabled", false);
pref("browser.safebrowsing.downloads.enabled", false);
pref("browser.safebrowsing.downloads.remote.enabled", false);
pref("browser.safebrowsing.malware.enabled", false);
pref("browser.safebrowsing.phishing.enabled", false);
// ref: https://bugzilla.redhat.com/show_bug.cgi?id=1507967
pref("browser.safebrowsing.provider.mozilla.updateURL", '');
pref("browser.safebrowsing.provider.mozilla.gethashURL", '');
// ref: https://www.ghacks.net/2017/07/13/privacy-blunder-firefox-getaddons-page-google-analytics
pref("extensions.webservice.discoverURL", '');

// security
pref("security.mixed_content.block_active_content", true);
pref("security.mixed_content.block_display_content", true);
pref("security.fileuri.strict_origin_policy", true);
pref("security.cert_pinning.enforcement_level", 2);
pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
pref("webgl.disabled", true);
pref("webgl.disable-wgl", true);
pref("webgl.enable-webgl2", false);
pref("security.data_uri.block_toplevel_data_uri_navigations", true);
pref("security.insecure_connection_icon.enabled", true);

// https://bugzilla.mozilla.org/show_bug.cgi?id=1334485#c18
pref("security.nocertdb", true);

// don't leak text selection and copy/paste
pref("dom.event.clipboardevents.enabled", false);
pref("dom.allow_cut_copy", false);

// don't try to "fix up" url typos -> localhost means localhost not www.localhost.com
pref("browser.fixup.alternate.enabled", false);

// private browsing mode by default
pref("browser.privatebrowsing.autostart", true);
pref("extensions.allowPrivateBrowsingByDefault", true);

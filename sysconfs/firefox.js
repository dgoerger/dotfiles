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

//// neuter the hazard of ctrl+q
pref("browser.showQuitWarning", true);

//// disable sponsored tiles
pref("browser.newtab.preload", false);
pref("browser.newtabpage.enhanced", false);
pref("browser.newtabpage.directory.ping", "");
pref("browser.newtabpage.directory.source", "");
pref("browser.newtabpage.activity-stream.enabled", false);
pref("browser.newtabpage.activity-stream.disableSnippets", true);
pref("browser.newtabpage.activity-stream.feeds.topsites", false);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
pref("browser.newtabpage.activity-stream.showTopSites", false);
pref("browser.newtabpage.activity-stream.showSponsored", false);
pref("browser.newtabpage.activity-stream.telemetry", false);

//// set DONOTTRACK header
pref("privacy.donottrackheader.enabled", true);

//// set spellcheck language as Canadian English moz#836230
pref("spellchecker.dictionary", "en-CA");
pref("browser.search.countryCode", "CA");
pref("browser.search.region", "CA");

//// disable loading system colours - hazardous gtk dark
pref("browser.display.use_system_colors", false);

//// disable disk cache
pref("browser.cache.disk.enable", false);
pref("browser.cache.disk_cache_ssl", false);
pref("browser.cache.offline.enable", false);

//// resolves OpenBSD OOM error
pref("javascript.options.asmjs", false);

//// by default open to blank page
pref("browser.startup.page", 0);

//// enable tracking protection
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.pbmode.enabled", true);
// ref: https://wiki.mozilla.org/Security/Fingerprinting
pref("privacy.resistFingerprinting", true);
// ref: https://wiki.mozilla.org/Security/FirstPartyIsolation
// NB: appears to break Atlassian login
pref("privacy.firstparty.isolate", true);
// disables "a MediaStream capturing in real-time the surface of an HTMLCanvasElement"
pref("canvas.capturestream.enabled", false);
// disable Firefox's built-in "Trusted Recursive Resolver" - if we can't trust localhost, game over
pref("network.trr.mode", 0);

//// discard third-party cookies
pref("network.cookie.cookieBehavior", 1);

//// disable geolocation services
pref("geo.enabled", false);
pref("geo.wifi.uri", "");
pref("browser.search.geoSpecificDefaults", true);
pref("browser.search.geoSpecificDefaults.url", "");
pref("browser.search.geoip.url", "");

//// disable address/search bar "one-off" custom searches
pref("browser.urlbar.oneOffSearches", false);
pref("browser.urlbar.suggest.searches", false);
pref("browser.urlbar.searchSuggestionsChoice", false);

//// why would anyone need access to these
pref("dom.battery.enabled", false);
pref("device.sensors.enabled", false);

//// disable GSSAPI integration - doesn't work under firejail
pref("network.negotiate-auth.trusted-uris", '');

//// enable U2F support rhbz#1513968
pref("security.webauth.u2f", true);

//// disable misc nonsense
pref("media.getusermedia.screensharing.enabled", false);
pref("media.getusermedia.screensharing.allowed_domains", "");
pref("extensions.pocket.enabled", false);
pref("extensions.pocket.api", "");
pref("browser.bookmarks.showRecentlyBookmarked", false);
pref("browser.download.manager.addToRecentDocs", false);
pref("extensions.screenshots.disabled", true);
pref("browser.onboarding.enabled", false);
pref("media.autoplay.enabled", false);
pref("dom.serviceWorkers.enabled", false);
pref("offline-apps.allow_by_default", false);
pref("network.dnsCacheExpiration", 0);
pref("network.ftp.enabled", false);
pref("media.autoplay.default", 2);
pref("app.normandy.enabled", false);
// disable Firefox Sync
pref("identity.fxaccounts.enabled", false);
pref("places.history.enabled", false);

//// disable captive portal detection - GNOME provides this
pref("network.captive-portal-service.enabled", false);

//// backspace goes back a page
pref("browser.backspace_action", 0);

//// disable a href ping
pref("browser.send_pings", false);
pref("browser.send_pings.require_same_host", true);
pref("beacon.enabled", false);

//// stop the goog
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

//// duckduckgo as default search
pref("browser.search.defaultenginename", "data:text/plain,browser.search.defaultenginename=DuckDuckGo");
pref("browser.search.hiddenOneOffs", "Amazon.com,Twitter");

//// disable health report
pref("datareporting.healthreport.service.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled.v2", false);
pref("toolkit.telemetry.enabled", false);

//// disable media plugins
pref("media.eme.apiVisible", false);
pref("media.eme.enabled", false);
pref("media.gmp-provider.enabled", false);
pref("media.gmp-eme-adobe.enabled", false);
pref("media.gmp-widevinecdm.enabled", false);
pref("media.gmp-gmpopenh264.enabled", false);
pref("media.gmp-gmpopenh264.provider.enabled", false);
pref("media.gmp-manager.url", "");
pref("plugins.notifyMissingFlash", false);

//// disable Hello
pref("loop.enabled", false);

//// disable search suggestions
pref("browser.search.suggest.enabled", false);

//// disable Firefox Heartbeat Rating Widget
pref("browser.selfsupport.url", "");
// ref: https://wiki.mozilla.org/Firefox/Shield
pref("extensions.shield-recipe-client.enabled", false);
pref("extensions.shield-recipe-client.api_url", "");

//// disable formfill
pref("browser.formfill.enable", false);

//// disable password manager
pref("signon.rememberSignons", false);

//// disable referrer for cross-site requests
// ref: https://wiki.mozilla.org/Security/Referrer
// NB: XOriginPolicy=1 seems to break Atlassian.net login..?
pref("network.http.referer.XOriginPolicy", 1);
pref("network.http.referer.XOriginTrimmingPolicy", 2);
pref("network.http.referer.userControlPolicy", 2);

//// disable prefetching
pref("network.prefetch-next", false);
pref("network.dns.disablePrefetch", true);
pref("network.dns.disablePrefetchFromHTTPS", true);
pref("network.http.speculative-parallel-limit", 0);
pref("network.predictor.enabled", false);

//// security
pref("security.mixed_content.block_active_content", true);
pref("security.mixed_content.block_display_content", true);
pref("security.xpconnect.plugin.unrestricted", false);
pref("security.fileuri.strict_origin_policy", true);
pref("network.negotiate-auth.allow-insecure-ntlm-v1", false);
pref("security.cert_pinning.enforcement_level", 2);
pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
pref("security.insecure_password.ui.enabled", true);
pref("webgl.disabled", true);
pref("webgl.disable-wgl", true);
pref("webgl.enable-webgl2", false);
pref("security.data_uri.block_toplevel_data_uri_navigations", true);
pref("security.insecure_connection_icon.enabled", true);
pref("accessibility.force_disabled", 1);

//// try to upgrade http -> https using hsts
// ref: https://bugzilla.mozilla.org/show_bug.cgi?id=1246540#c145
pref("security.mixed_content.use_hsts", true);
pref("security.mixed_content.send_hsts_priming", false);

// disable miscellaneous prompts
pref("permissions.default.camera", 2);
pref("permissions.default.desktop-notification", 2);
pref("permissions.default.geo", 2);
pref("permissions.default.microphone", 2);

//// block non-perfect forward secrecy legacy ciphers
pref("security.tls.version.min", 3);
pref("security.ssl3.rsa_aes_128_sha", false);
pref("security.ssl3.rsa_aes_256_sha", false);
pref("security.ssl3.rsa_des_ede3_sha", false);
pref("security.ssl3.rsa_rc4_128_md5", false);
pref("security.ssl3.rsa_rc4_128_sha", false);
pref("security.ssl3.dhe_rsa_aes_128_sha", false);
pref("security.ssl3.dhe_rsa_aes_256_sha", false);

//// useful for socks5
pref("network.proxy.socks", "localhost");
pref("network.proxy.socks_port", 1080);
pref("network.proxy.socks_remote_dns", true);

//// block webrtc IP leak: https://ipleak.net/#webrtcleak
// ref: https://wiki.mozilla.org/Media/WebRTC/Privacy
pref("media.peerconnection.enabled", false);
pref("media.peerconnection.use_document_iceservers", false);
pref("media.peerconnection.ice.no_host", true);
pref("media.navigator.enabled", false);

//// block leak of intermediate cached certs
// ref: https://bugzilla.mozilla.org/show_bug.cgi?id=1334485#c18
pref("security.nocertdb", true);

//// don't leak text selection and copy/paste
pref("dom.event.clipboardevents.enabled", false);
pref("dom.allow_cut_copy", false);

//// don't try to "fix up" url typos -> localhost means localhost not www.localhost.com
pref("browser.fixup.alternate.enabled", false);

//// display punycode
pref("network.IDN_show_punycode", true);

//// private browsing mode by default
pref("browser.privatebrowsing.autostart", true);
pref("extensions.allowPrivateBrowsingByDefault", true);

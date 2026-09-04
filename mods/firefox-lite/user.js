// ============================================================
// Firefox Lite — portable user.js
// Lightweight + privacy-hardened. Hardware-agnostic.
// Drop into <profile>/user.js and restart Firefox.
//
// Reading guide:
//   user_pref(NAME, VALUE) lines override prefs.js on every launch.
//   Removing a line here does NOT undo the change — you must reset
//   the pref via about:config (right-click → Reset).
// ============================================================


// --- 1. Telemetry & data collection -------------------------
// Stops Firefox from reporting usage stats, health pings, and
// participating in Mozilla studies. Pure bloat removal.
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);


// --- 2. Pocket, sponsored content, new-tab bloat ------------
// Strips the new-tab page back to a clean grid of your visited
// sites. No "stories", no sponsored tiles, no Pocket button.
user_pref("extensions.pocket.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);


// --- 3. Animations & motion ---------------------------------
// Pure CPU/GPU savings. Animated GIFs still load but loop once.
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("browser.tabs.animate", false);
user_pref("browser.fullscreen.animate", false);
user_pref("image.animation_mode", "once");
user_pref("ui.prefersReducedMotion", 1);


// --- 4. Speculative network activity ------------------------
// Firefox normally pre-resolves DNS, pre-connects to predicted
// destinations, and prefetches linked resources. Noisy and
// privacy-leaky. Off across the board.
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);


// --- 5. Memory & process behavior ---------------------------
// dom.ipc.processCount intentionally NOT set — Firefox auto-tunes.
// We only disable the prelaunch (empty content processes) and
// shrink the back/forward cache.
user_pref("dom.ipc.processPrelaunch.enabled", false);
user_pref("browser.sessionhistory.max_total_viewers", 2);
user_pref("browser.cache.disk.enable", false);


// --- 6. Privacy hardening (Securefox-style) -----------------
// These are the "less Mozilla / less site tracking" prefs.
// All chosen to NOT break common sites (no first-party isolation,
// no resistFingerprinting — those break too much).

// Tracking protection: strict mode + social trackers
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);

// Partition network state per top-level site (defeats cache-based tracking)
user_pref("privacy.partition.network_state", true);

// Total Cookie Protection (each site gets its own cookie jar)
user_pref("network.cookie.cookieBehavior", 5);

// Trim cross-origin referer to scheme+host+port (less site fingerprinting)
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

// HTTPS-only mode (Firefox shows a button to override per-site if needed)
user_pref("dom.security.https_only_mode", true);

// Disable navigator.sendBeacon (used almost exclusively for analytics)
user_pref("beacon.enabled", false);

// Disable battery status API (fingerprinting vector, no real use case)
user_pref("dom.battery.enabled", false);

// WebRTC: only expose the default network route (hides LAN/VPN IPs)
user_pref("media.peerconnection.ice.default_address_only", true);

// Disable hyperlink ping attribute (sites can't notify trackers on click)
user_pref("browser.send_pings", false);

// URL-bar / search suggestions off — saves a request per keystroke
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);

// Don't store addresses or credit cards (form autofill off)
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

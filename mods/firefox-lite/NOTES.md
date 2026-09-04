# Firefox Lite

Hardware-agnostic, lightweight + privacy-hardened Firefox profile. Designed
to drop into any machine without tuning.

## Design rules

- **No hardware-specific overrides.** No process count, no cache sizes tied to
  disk type, no WebRender forced on/off. Firefox auto-detects these per-machine.
- **Only universal answers.** Telemetry, Pocket, animations, speculative
  network, privacy hardening — same answer everywhere.
- **Don't break sites.** No first-party isolation, no `resistFingerprinting`,
  no WebGL/EME/DRM disable. Privacy hardening picked to be invisible to
  ordinary site usage.

## Files

- `user.js` — the canonical config. Sectioned + commented.
- `apply.sh` — copies `user.js` into a target profile (auto-detects default).
- `NOTES.md` — this file.

## Status
- [x] Pick portable config strategy
- [x] Author `user.js` (5 perf sections + 1 privacy section)
- [x] Author `apply.sh` with profile auto-detect + backup
- [x] Apply to `lite` profile on this machine
- [x] Switch default to `lite` profile system-wide
- [ ] Smoke-test (load 5 common sites, confirm no breakage)
- [ ] Optional follow-up: `firefox-userchrome` mod for UI minimalism

## How to apply on a fresh machine

```sh
~/dotfiles/mods/firefox-lite/apply.sh           # → default profile
~/dotfiles/mods/firefox-lite/apply.sh lite      # → specific profile
```

Restart Firefox after applying.

## Switching default profile to `lite` on this machine

Two options:

1. **Profile manager (GUI):** `firefox -P` → select `lite` → untick
   "Use the selected profile without asking at startup" if it's checked
   → start Firefox.
2. **Edit `installs.ini`:** in `~/.mozilla/firefox/installs.ini` change
   `Default=<old-profile-path>` to `Default=lite`. This is what the
   profile manager edits under the hood.

## What we removed from the previous draft (and why)

The earlier `lite/user.js` (Apr 20 draft) was tuned for an AMD E1-2500 with
5GB RAM and an HDD. We removed:

- `gfx.webrender.software=true` / `gfx.webrender.all=false` — software
  compositing override. Wrong for any modern iGPU.
- `layers.acceleration.disabled=false` — already the default.
- `dom.ipc.processCount=2` / `processCount.webIsolated=1` — too aggressive
  for ≥8GB RAM machines. Let Firefox auto-tune.
- Specific cache sizes (`browser.cache.disk.capacity` etc.) — replaced with
  `browser.cache.disk.enable=false` (memory-only cache). Universal win:
  fewer disk writes, kinder to HDDs and SSDs alike.

## Privacy choices made (and explicitly NOT made)

**Made:**
- Strict tracking protection + social trackers
- Network state partitioning (Total Cookie Protection)
- Cross-origin referer trimming
- HTTPS-only mode
- WebRTC default-route only (hides LAN/VPN IPs)
- Beacon, battery API, hyperlink ping disabled
- Search suggestions off (saves a request per keystroke)
- Form autofill (addresses + credit cards) off

**NOT made (because they break too much for too little gain):**
- `privacy.firstparty.isolate` — breaks SSO, federated logins, embedded media.
- `privacy.resistFingerprinting` — forces RFP letterboxing, English UA,
  fixed timezone. Visible behaviour change, breaks streaming.
- `webgl.disabled` — breaks Maps, WebGL games, many graphics tools.
- `media.eme.enabled=false` — disables Widevine DRM, breaks Netflix etc.

If you want stricter privacy, add a separate `firefox-privacy` mod that
includes those — they're a different user trade-off.

## Gotchas (learned the hard way)

- **`profiles.ini` section indices must be contiguous from 0.** Firefox stops
  enumerating at the first missing index. A `[Profile99]` after `[Profile0]`
  + `[Profile1]` will be silently invisible in the profile manager (`firefox -P`).
  Fix: renumber to the next contiguous slot (`[Profile2]`).
- **Two places hold the "default profile" answer.** Modern Firefox uses
  `installs.ini` `Default=<path>` per install. The `Default=1` flag inside a
  `[ProfileN]` block in `profiles.ini` is the legacy mechanism. They can
  disagree silently — install-level wins. Drop the legacy flag to avoid
  confusion.
- **`apply.sh` only does half the job.** It writes `user.js`; it does NOT make
  the target profile the active one. Always verify by checking
  `~/.mozilla/firefox/<profile>/prefs.js` exists after a Firefox launch.

## Other gotchas

- Removing a line from `user.js` does NOT undo its effect on the profile.
  Firefox keeps the override in `prefs.js` until you reset the pref via
  `about:config` (right-click → Reset).
- HTTPS-only mode shows a "Continue to HTTP Site" button when needed; sites
  with no HTTPS get a clickable warning rather than silent failure.
- After first run with `lite`, the new-tab page may briefly look like the
  old one until pinned shortcuts are cleared.

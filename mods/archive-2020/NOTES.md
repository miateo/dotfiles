# Archive (2020) — system-wide look

A full retheme inspired by the lab terminals and ambient UI in Gavin Rothery's
*Archive* (2020): **smoke white on near-black**, monospace everywhere, flat
surfaces, square corners, concrete-and-tungsten warmth. Amber is reserved
strictly for warning / alert states (battery low, mute, recording, error
notifications). Affects every UI layer that ships with the dotfiles, so this
is one coherent visual pass — not a per-app tweak.

## Design rules

These are the rules the rest of the choices should be checked against:

- **Two-tone, role-separated.** Smoke white (`#e8e6e1`) is the everyday
  foreground for all chrome and text. Amber (`#ffb000`) is reserved for
  *warning / alert / active-signal* states only — battery low, mute,
  recording, capslock, urgent dunst, hyprland active border on the focused
  workspace if it needs to "speak". The discipline is: if it isn't trying to
  get your attention, it is not amber. No blues, no greens, no red. (Variant
  idea: `archive-2020-green` spinoff for the J3 console look — out of scope
  for v1.)
- **Flat, square, sparse.** No rounded corners (or ≤2px where required by the
  toolkit), no blur, no glassy effects, no drop shadows. Hyprland gaps stay
  small — empty black space, not "art" space.
- **Monospace everywhere user-visible.** Bar text, notifications, launcher,
  clock — all the same mono family. Body text in apps (browser, PDF) is left
  alone; this is a *system chrome* mod, not a content mod.
- **CRT cosmetics ≤ readability.** A subtle scanline / phosphor bloom is
  in-scope for the terminal only (and toggleable). No full-screen CRT shader,
  no fish-eye, no flicker — the film's terminals are stylised but legible.
- **Portable.** No font sizes or shader parameters tuned to this specific
  monitor / DPI. Same answer should land on any Arch box (per the
  `firefox-lite` design rule).
- **One commit / one apply.** Because every layer shifts together, the mod
  applies as a single batched step with backups; partial application looks
  worse than the current rice.

## What's in scope (one coherent pass)

| Layer            | File(s) touched                                    | What changes                                                  |
| ---------------- | -------------------------------------------------- | ------------------------------------------------------------- |
| Palette source   | `archive-2020/palette.sh` (new)                    | Canonical hex values, sourced by `apply.sh`                   |
| Kitty            | `kitty/kitty.conf`, optional `kitty/crt.glsl`      | Colours, font, cursor, optional toggleable CRT shader         |
| Fonts (global)   | `~/.local/share/fonts/Aldrich-Regular.ttf`, `~/.config/fontconfig/conf.d/99-archive-2020-mono.conf`, `~/.config/gtk-{3,4}.0/settings.ini` | Install Aldrich; force generic `monospace` → JetBrains Mono Nerd; set GTK UI font + dark theme |
| Quickshell       | `~/.config/quickshell/modules/stats/Theme.qml`, `~/.config/quickshell/shell.qml` | Recolour Theme.qml singleton to palette; bar bg, clock fg, clock font.family → Aldrich |
| Waybar           | `waybar/style.css`, `waybar/config.jsonc`          | Palette, mono font, flatten radius, strip blur                |
| Hyprland         | `hypr/hyprland.conf`                               | `general:col.active_border` / inactive — **borders only**, see note below |
| Hyprlock         | `hypr/hyprlock.conf`                               | Amber clock + bg, mono font                                   |
| Hypridle / dim   | `hypr/hypridle.conf`                               | (review only — likely no change)                              |
| Rofi             | `~/.config/rofi/archive-2020.rasi` (new), `~/.config/rofi/config.rasi` (`@theme` import only) | Flat smoke-on-black launcher with **inverted-highlight** selected entry, Aldrich prompt, JetBrains Mono entries |
| Dunst            | `~/.config/dunst/dunstrc` (new — system was using `/etc/dunst/dunstrc`) | Smoke on near-black for normal, amber for `urgency_critical`, square corners, top-right, no icons |
| GTK chrome       | `gtk-3.0/settings.ini`, `gtk-4.0/settings.ini`     | Dark Adwaita base via `nwg-look`; pick a dark amber-friendly  |
| Cursor           | XCursor theme via nwg-look                         | Small monochrome (Bibata-Modern-Classic or similar)           |
| Wallpaper        | *(unchanged)*                                      | Left as-is — current `hyprpaper` config stays                 |
| ~~Neovim~~       | ~~`nvim/lua/.../colors.lua`~~                      | **Out of scope** — user keeps existing nvim colours          |

## Explicitly out of scope (for v1)

- **Neovim colourscheme.** User keeps their existing nvim look. Decision
  taken 2026-06-01 during phase implementation. The mod doesn't touch
  `nvim/`.
- **Spicetify / Spotify theme.** Worth a sibling mod (`archive-2020-spotify`),
  but Spicetify themes have their own structure and break on Spotify updates;
  keeps the main mod stable.
- **Firefox UI.** The `firefox-lite` mod is content/privacy/perf. A
  `firefox-userchrome` sibling is already noted as a follow-up in `todo.md`
  — that's where the amber Firefox chrome belongs.
- **Electron apps (Discord, VSCode-OSS, etc.).** GTK theme doesn't reach
  them; each needs its own theme file. Defer.
- **SDDM lockscreen.** Already an open item in `todo.md`; that mod will
  pick the same palette from `palette.sh` when it's written.
- **System-wide font fallback for body text.** This mod doesn't touch
  `fontconfig`. Web pages, PDFs, etc. render in their own fonts.

## On "global" fonts on Wayland (2026-06-01)

There is no single global font knob. After phase-1 the user noted that
quickshell and Firefox "didn't change". Quickshell already used
`JetBrainsMono Nerd Font` in its stats modules — so the kitty Fira Code →
JetBrains Mono transition was the only visible change. The four real
knobs and what each covers:

- **fontconfig** — what `monospace`/`sans-serif`/`serif` resolve to
  system-wide. Honoured by Firefox content, Chromium, many GTK/Qt apps.
- **GTK 3 + 4 `settings.ini`** — UI text font for every GTK app
  (Firefox menus, Nemo, etc.) + dark theme preference.
- **Qt (qt5ct/qt6ct)** — UI text font for Qt apps. Deferred for now;
  user has Spotify but no Qt-heavy apps in daily use.
- **Per-app config** — quickshell QML, dunst, rofi each read their own.

The `fonts` layer touches the first two. The `quickshell` layer covers
the third for the most visible chrome (bar + clock). Sans-serif is
deliberately left alone so body text in browsers and PDFs stays
readable — this is a system-chrome mod, not a content-typography mod.

## Scope notes that emerged during phase-1 implementation

- **Hyprland: borders only.** The user's current `hyprland.conf` already
  has `rounding = 0`, `border_size = 0`, and a deliberate
  `active_opacity 0.98 / inactive_opacity 0.75`. Those are user choices,
  not gaps the mod should fill. The mod limits itself to changing the two
  border colours so the rest of the user's layout aesthetic survives the
  retheme.
- **Kitty: full retheme via include file.** The current `kitty.conf` is
  ~99% the upstream sample with three real overrides (Fira Code font +
  size). Safe to generate a single `kitty/archive-2020.conf` snippet and
  append one `include archive-2020.conf` line to the main file. Revert is
  one delete + one `.bak` restore.
- **Hyprlock: text + input only, wallpaper/blur untouched.** Hyprlock
  reads a wallpaper image and blurs it as the lockscreen background. The
  wallpaper-unchanged decision applies here too — only the input field
  outline / inner fill / font colour and the two label colours are
  retuned to the palette.

## Reference observations (2026-06-01)

From four stills shared by the user (kept in `preview/refs/` once saved):

- **Smoke white dominates.** No amber visible in any of the four refs. Confirms amber-is-warning-only.
- **Inverted highlight blocks** are the signature "this is active" affordance: smoke-white bg + black fg on small labels (e.g. `RAL08`, `004-C/02`). Stronger than tonal contrast.
- **Two type roles, not one.** Small index / data text is monospace (fits JetBrains Mono fine). Big headers (`REMOVING COMPRESSION`, `SUITABLE CANDIDATE`, `REBUILD`, `VR SUITE`) are a chunky wide-grotesque — Eurostile/Microgramma family. Free look-alikes: **Aldrich** (closest), **Michroma**, **Saira Extended**.
- **CRT cosmetics are committed in the film** — clear scanlines, phosphor bleed, dirt. We still can't CRT-shade GTK chrome, but when the kitty shader is on it should *feel* filmic.
- **Information density is a prop trick.** Cluster IDs / bank numbers / frame numbers exist to look futuristic on camera. Do NOT try to translate this into real waybar modules — it becomes noise.
- **Hatched diagonal "clutter" zones** appear as decoration. Out of scope for chrome (too noisy at small sizes); possible hyprlock or wallpaper decoration later.

## Decisions so far

- **Primary mono font: `JetBrains Mono Nerd`.** Already shipped in
  `install.sh`, zero new dep. Revisit only if the smoke-white-on-black
  contrast reads worse than expected at small sizes.
- **Primary chrome colour: smoke white `#e8e6e1`.** Warm-leaning off-white;
  not clinical `#ffffff`. Alternates if it reads wrong on this panel:
  `#d8d6d2` (dimmer), `#dcd8cf` (warmer, parchment).
- **Warning colour: amber `#ffb000`** (IBM 3270 amber). Used only for
  alert states — see "two-tone, role-separated" above.
- **Surface: near-black `#0a0a0a`** rather than pure `#000000`, so the
  amber doesn't vibrate against an absolute-black background.
- **CRT shader: off by default**, available via `kitty/crt.glsl` and a
  keybind toggle. Subtle scanlines + faint phosphor glow only — no
  barrel distortion, no flicker.

- **Wallpaper: unchanged.** Out of scope for this mod. Whatever
  `hyprpaper.conf` currently points at stays the wallpaper.
- **Active affordance pattern: inverted highlight block** (smoke-white bg +
  black fg), not tonal contrast. Applied to: focused waybar workspace,
  selected rofi entry, dunst urgent header pill. The "this is active /
  this is the label" gesture from the refs.
- **Focused workspace** therefore = inverted smoke-white pill, not just
  smoke-white text. Inactive = dim smoke text on bg. Amber discipline
  unchanged (warnings only).

- **Two-font stack.** JetBrains Mono Nerd for body / terminal / small
  text. **Aldrich** (free, OFL, closest free Microgramma look-alike) for
  the waybar clock and rofi prompt only. Aldrich install path: ship the
  `.ttf` under `archive-2020/fonts/Aldrich.ttf` and have `apply.sh` drop
  it into `~/.local/share/fonts/` + `fc-cache -f`. Portable, no AUR
  dependency, survives offline installs.
- **Surface: `#0a0a0a`.** Slight lift off pure black so the (rare) amber
  warning doesn't vibrate. Marginal compromise vs. the refs' pure-black
  feel, but the right call for daily use.
- **Kitty CRT shader: subtle preset, off by default.** `scanline_intensity
  0.05`, faint phosphor bloom, no aperture mask, no vignette, no curve.
  Toggle via keybind (likely `$mainMod SHIFT, C` — confirm doesn't
  conflict before binding).

## Still open

*(none — proceed to `palette.sh`)*

## Status

- [x] Scope mod / write this NOTES.md
- [x] Pick primary mono font → JetBrains Mono Nerd (already installed)
- [x] Lock palette roles → smoke white primary `#e8e6e1`, amber warning `#ffb000`, surface `#0a0a0a`
- [x] Wallpaper decision → unchanged, out of scope
- [x] Focused workspace decision → smoke white (focus is chrome, not warning)
- [x] Author `preview.sh` (ANSI truecolor mockup of palette + bar + term + notification + border)
- [x] Author `crt-preview.sh` (OFF / SUBTLE / FILMIC comparison)
- [x] Lock CRT shader preset → subtle, off by default, keybind toggle
- [x] Lock two-font stack → JetBrains Mono + Aldrich (waybar clock, rofi prompt)
- [x] Save reference stills under `preview/refs/`
- [x] Author `palette.sh` (canonical hex + font names, sourceable + 4 emit modes)
- [x] Author `apply.sh` (kitty, hyprland borders, hyprlock; idempotent + per-file backups)
- [x] Author `revert.sh` (restores `.bak` files, removes generated kitty snippet)
- [x] Phase-1 applied (kitty + hyprland borders + hyprlock) — confirmed kitty font visible; quickshell unchanged because it already used JetBrains Mono
- [x] Ship `fonts/Aldrich-Regular.ttf` (OFL) + licence in mod folder
- [x] Add `fonts` layer to apply.sh (Aldrich install, fontconfig mono pref, GTK 3+4 settings)
- [x] Add `quickshell` layer to apply.sh (Theme.qml retheme, shell.qml bar + clock + Aldrich)
- [x] Mirror revert paths for `fonts` and `quickshell` in revert.sh
- [x] Fonts + quickshell applied — confirmed; Firefox serif left as-is per design rules
- [x] Add `rofi` layer (theme file + `@theme` import; inverted-highlight selected entry)
- [x] Rofi v1 had background leak + stock icons + "drun" mode label → v2 added aggressive bg overrides on every container, `show-icons: false`, prompt `❯` in Aldrich
- [x] Add `dunst` layer (smoke normal, amber critical, square, top-right)
- [x] All layers applied and accepted — **mod complete 2026-06-01**
- [~] Waybar layer left in scope table only as reference (user's bar is `qs`, not waybar — relevant only on a fresh machine boot if `qs` isn't available)
- [~] GTK theme proper + cursor theme — deferred (font + dark pref are set; coloured GTK theme is a separate, larger project)
- [ ] Kitty: optional CRT shader behind a keybind
- [ ] Waybar: palette + font + flatten radius
- [ ] Hyprland: borders + rounding + gaps + blur off
- [ ] Hyprlock: clock + bg + font
- [ ] Rofi: theme + add to dotfiles install `APPS=`
- [ ] Dunst: theme + add to dotfiles install `APPS=`
- [ ] GTK theme + cursor via nwg-look
- [ ] Wallpaper chosen + hyprpaper wired
- [ ] Neovim colorscheme
- [ ] Write `apply.sh` (batched apply + per-app backup of overwritten files)
- [ ] Smoke test: long-text read in terminal, video playback (no scanline
      bleed into mpv), screenshot of full session
- [ ] Update `~/Documents/todo.md` with mod state

## Files this mod will create

- `archive-2020/NOTES.md` — this file
- `archive-2020/palette.sh` — canonical colours, sourced by `apply.sh`
- `archive-2020/apply.sh` — batched apply, per-target backup, idempotent
- `archive-2020/revert.sh` — restore `.bak` files from a previous apply
- `archive-2020/crt.glsl` — optional kitty shader
- `archive-2020/preview/` — screenshots after smoke test (for future-me)

## Files this mod will modify in-place (under `~/dotfiles/`)

- `hypr/hyprland.conf`, `hypr/hyprlock.conf`, `hypr/hyprpaper.conf`
- `kitty/kitty.conf`
- `waybar/style.css`, `waybar/config.jsonc`
- `nvim/...` (one new colorscheme include line)
- `install.sh` — extend `APPS=(...)` with `rofi` and `dunst`

Every edit lands as a single `apply.sh` run with a per-file `.bak` next to
the original, so revert is a one-liner.

## Re-applying on a fresh machine

```sh
# After the main dotfiles install.sh has run:
~/dotfiles/mods/archive-2020/apply.sh
# Verify:
#   - kitty: new palette + font on next session
#   - waybar: flat, amber accents
#   - hyprland: amber active border, square corners
# Revert if it lands wrong:
~/dotfiles/mods/archive-2020/revert.sh
```

## Anticipated gotchas

- **Waybar uses GTK CSS, not web CSS.** No `backdrop-filter`, no real
  gradients beyond `linear-gradient`. Scanline overlay on the bar is
  effectively impossible without a compositor trick — don't try.
- **Hyprland border colours are `rgba()` or `0xAARRGGBB`-style.** Easy to
  get the byte order wrong; preview after every change.
- **GTK theming does not reach Electron / Spotify / Discord.** A coherent
  bar + window border + launcher will still sit around a blue Discord. Note
  in NOTES.md after applying so future-me isn't surprised.
- **Kitty custom shaders need `kitty +kitten` reload or restart**, and
  high-contrast scanlines crush small font weights — the shader must be
  testable with a single keybind toggle, not always-on.
- **`hyprpaper` keeps the previous wallpaper in memory** until reload; the
  apply step must `hyprctl hyprpaper reload`.
- **Cursor themes set via nwg-look write to `~/.config/gtk-3.0/settings.ini`
  AND `~/.icons/default/index.theme`.** Both need updating for the cursor
  to actually change across XWayland apps.
- **`firefox-lite` already shipped — don't regress it.** This mod must not
  touch any `user.js`.

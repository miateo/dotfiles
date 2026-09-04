# Volume & Brightness OSD

Global on-screen popup when volume or brightness changes. Only the popup —
no permanent bar widget, since these keys aren't used often.

## Status
- [x] Pick tool (SwayOSD)
- [ ] Install package (`sudo pacman -S swayosd`)
- [x] Autostart daemon in `hyprland.conf`
- [x] Replace volume keybinds to use `swayosd-client`
- [x] Add brightness keybinds (XF86MonBrightnessUp/Down)
- [ ] Test in session (relogin or `swayosd-server &` once)
- [ ] Optional: theme via `~/.config/swayosd/style.css`

## What changed
- `hypr/hyprland.conf`
  - `exec-once = swayosd-server` (autostart daemon)
  - `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` → `swayosd-client --output-volume +5 / -5`
  - `XF86AudioMute` → `swayosd-client --output-volume mute-toggle`
  - `XF86AudioMicMute` → `swayosd-client --input-volume mute-toggle` (new)
  - `XF86MonBrightnessUp` / `XF86MonBrightnessDown` → `swayosd-client --brightness +5 / -5` (new)
- `hypr/set_volume.sh` left in place but no longer wired up. Safe to delete
  later once we're sure SwayOSD works on every machine the dotfiles land on.

## Why SwayOSD
Daemon-based, ships popup UI, themable via GTK CSS, packaged in Arch `extra`.
Avizo and wob were the alternatives; SwayOSD has the cleanest defaults and
brightness support built in (no helper script needed).

## Backend
Brightness uses `brightnessctl` under the hood (already installed). Volume
uses PulseAudio/PipeWire via `pactl`. Backlight device: `intel_backlight`.

## Re-applying on a fresh machine
1. `sudo pacman -S swayosd brightnessctl`
2. Symlink `~/dotfiles/hypr/hyprland.conf` → `~/.config/hypr/hyprland.conf`
   (or whatever the install script does).
3. Relogin to Hyprland — `swayosd-server` autostarts.

## Gotchas
- If brightness popup works but doesn't change brightness, the user must be
  in the `video` group: `sudo usermod -aG video $USER` then relogin.
- Old `set_volume.sh` referenced `/home/mello/.config/hypr/set_volume.sh`
  (hardcoded path). Worth replacing with `$HOME` if we ever revive it.

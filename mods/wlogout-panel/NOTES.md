# Wlogout panel

## Status checklist

- [x] Restyle Super+Shift+E power menu with a cleaner technical look.
- [x] Keep direct keybind hints visible via `wlogout -s`.
- [x] Back up previous layout/style/launcher.
- [ ] Decide after testing whether margins/button size need per-monitor adjustment.

## Change log

- `~/.config/wlogout/style.css`
  - Replaced the old rounded block style with a matte dark, square-edged, high-contrast panel.
  - Uses cool-blue focus for safe actions and amber focus for destructive/power actions.
- `~/.config/wlogout/layout`
  - Changed shutdown label to `poweroff` and keybind from `s` to `p`.
- `~/.config/wlogout/launch.sh`
  - Launches with `-b 5 -c 16 -r 16 -m 260 -s` to show binds and create a centered command-panel layout.

Backups:

- `~/.config/wlogout/style.css.pi-bak`
- `~/.config/wlogout/layout.pi-bak`
- `~/.config/wlogout/launch.sh.pi-bak`

## Re-applying on a fresh machine

1. Copy `style.css`, `layout`, and `launch.sh` into `~/.config/wlogout/`.
2. Ensure the script is executable:
   ```bash
   chmod +x ~/.config/wlogout/launch.sh
   ```
3. Ensure Hyprland bind exists:
   ```conf
   bind = $mainMod SHIFT, E, exec, $HOME/.config/wlogout/launch.sh
   ```

## Gotchas

- Wlogout button geometry is controlled partly by CLI margins and partly by CSS.
- The current margin (`-m 260`) is tuned for 1080p-ish displays; on very small or huge screens it may need adjustment.
- Wlogout CSS is GTK CSS, not browser CSS; some modern CSS features are unavailable.

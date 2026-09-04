# Portable workstation

## Status checklist

- [x] Add a top-bar cheatsheet entry for common Linux/workstation commands.
- [x] Add cheatsheet search and Neovim command section.
- [x] Add portable status fields to the existing Quickshell control panel.
- [x] Add `portable-status` CLI health summary.
- [x] Add `portable-lite` / `portable-full` service profile helpers.
- [x] Add SSD-style udev tuning for the external Realtek USB bridge.
- [x] Make Ghostty the main terminal and add a matching minimal terminal style.
- [x] Install agreed workstation packages for embedded, CAD, dev, AI/data, robotics, notes, and backups.
- [x] Create `~/Workbench` and `~/Knowledge` structures.
- [x] Diagnose direct-boot Hyprland login loop on NVIDIA desktop hardware.
- [x] Add NVIDIA/DRM startup handling for Hyprland direct boot.
- [ ] Decide final visual pass for the top bar/control panel after daily use.
- [ ] Consider moving Quickshell config into `~/dotfiles/quickshell/` and adding it to `install.sh`.

## Change log

Touched live config outside the main dotfiles symlink set:

- `~/.config/quickshell/shell.qml`
  - Adds `CheatsButton` to the top bar.
  - Adds `CheatsPanel` popup.
- `~/.config/quickshell/modules/stats/CheatsButton.qml`
  - New top-bar cheatsheet button.
- `~/.config/quickshell/modules/stats/CheatsPanel.qml`
  - New categorized Linux cheatsheet popup.
  - Adds search field and Neovim command section.
  - Adds embedded/electronics, CAD/3D, robotics/drones, AI/data, Docker, and backup/recovery sections.
- `~/.config/quickshell/modules/stats/Stats.qml`
  - Adds portable status polling: boot mode, keyboard layout, root disk, USB speed, power profile.
- `~/.config/quickshell/modules/stats/StatsPanel.qml`
  - Adds a `Portable` section to the existing control panel.
- `~/.local/bin/portable-status`
  - New CLI status summary for portable boot health.
- `~/.local/bin/portable-lite`
  - Stops/disables heavier optional services: Syncthing, JARVIS, Samba, Tailscale.
- `~/.local/bin/portable-full`
  - Enables full workstation services: Syncthing, JARVIS, Tailscale, SSHD. Samba remains manual.
- `/etc/udev/rules.d/60-portable-ssd-tuning.rules`
  - Marks the Realtek USB storage bridge as non-rotational and sets `none` scheduler/read-ahead.
- Disabled `NetworkManager-wait-online.service`.
- Installed packages/tools:
  - Embedded/electronics: `arduino-cli`, `platformio-core`, `platformio-core-udev`, `openocd`, `sigrok-cli`, `pulseview`, `esptool`, `dfu-util`, `avrdude`, `picocom`, `minicom`, `arm-none-eabi-gcc`, `arm-none-eabi-newlib`.
  - Arduino cores: `arduino:avr`, `esp32:esp32`, `rp2040:rp2040`.
  - CAD/3D: `freecad`, `openscad`, `blender`.
  - Dev: `github-cli`, `docker`, `docker-compose`, `pnpm`, `direnv`, `mise`, `uv`; Rust was already installed as distro `rust` so `rustup` was not installed due package conflict.
  - AI/data: `jupyterlab`, `ollama`, `python-pandas`, `python-scikit-learn`.
  - Robotics/drones: `qgroundcontrol-bin` from AUR.
  - Notes/ops/recovery: `obsidian`, `rclone`, `restic`, `borg`, `testdisk`, `gparted`.
- Added user `mello` to `docker`, `uucp`, and `lock` groups for Docker and serial-device access.
- Created `~/Workbench/` and `~/Knowledge/` directory structures.
- `~/dotfiles/ghostty/config`
  - New Ghostty config with matte black / smoke / cool-blue / amber palette.
- `~/.config/ghostty`
  - Replaced local config dir with symlink to `~/dotfiles/ghostty`.
- `~/dotfiles/hypr/hyprland.conf`
  - Main terminal changed from `kitty` to `ghostty`.
- `~/dotfiles/install.sh`
  - Added `ghostty` to `APPS=(...)` so it symlinks on fresh installs.
- `/usr/local/bin/start-hyprland-logged`
  - Adds NVIDIA-specific Hyprland environment variables only when NVIDIA hardware is detected.
  - Sets `AQ_DRM_DEVICES` to DRM cards with connected displays, avoiding headless compute GPUs where possible.
  - Logs DRM connector status and selected GPU environment for future SDDM login-loop debugging.
- `/etc/modprobe.d/nvidia-portable.conf`
  - Blacklists Nouveau and enables NVIDIA DRM KMS (`nvidia_drm.modeset=1 fbdev=1`).
- `/etc/default/grub`, `/boot/grub/grub.cfg`
  - Adds `nvidia_drm.modeset=1 nvidia_drm.fbdev=1 nouveau.modeset=0` to kernel args.
- `/etc/mkinitcpio.conf`
  - Adds NVIDIA modules to initramfs module list, then rebuilds initramfs.

Related earlier fixes kept:

- Quickshell Bluetooth polling leak fixed in `~/.config/quickshell/modules/stats/Bluetooth.qml`.
- SDDM login keyboard selector/show-keys additions.
- Hyprland 0.56 config compatibility fix: `togglesplit` now uses `layoutmsg` and removed old `dwindle:pseudotile` setting.

## Re-applying on a fresh machine

1. Copy the Quickshell files into `~/.config/quickshell/`.
2. Ensure helper scripts are executable:
   ```bash
   chmod +x ~/.local/bin/portable-status ~/.local/bin/portable-lite ~/.local/bin/portable-full
   ```
3. Install useful packages as needed:
   ```bash
   sudo pacman -S jq usbutils pciutils tlp
   ```
4. Add the udev rule if the external disk appears as the same Realtek bridge:
   ```bash
   sudo cp 60-portable-ssd-tuning.rules /etc/udev/rules.d/
   sudo udevadm control --reload
   ```
5. For NVIDIA desktops/laptops using Hyprland, install NVIDIA driver support and rebuild boot files:
   ```bash
   sudo pacman -Syu nvidia-open nvidia-utils nvidia-settings egl-wayland
   sudo cp nvidia-portable.conf /etc/modprobe.d/   # if kept as a mod asset
   sudo mkinitcpio -P
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```
6. Restart Quickshell:
   ```bash
   pkill qs; qs &
   ```

## Gotchas

- The external SSD was connected at USB2 speed (`480M`) on the Lenovo laptop, causing I/O pressure and sluggishness. Use USB3/USB-C and verify with `lsusb -t` or `portable-status`.
- `systemd-detect-virt` may print `none`; the status script maps that to `direct`.
- Quickshell is currently in `~/.config/quickshell`, not under `~/dotfiles/`, so this mod is not fully portable until that config is moved/symlinked.
- The `portable-lite`/`portable-full` scripts intentionally do not auto-toggle Samba in full mode; LAN sharing should be explicit.
- The NVIDIA desktop login loop was not caused by `.zprofile`: Hyprland crashed during EGL/DRM renderer init under Nouveau (`MESA: ZINK: vkEnumeratePhysicalDevices failed`, `eglInitialize failed`).
- Avoid Arch partial upgrades: installing NVIDIA after `pacman -Syy` pulled modules for the new kernel while the running/installed kernel was still old. A full `pacman -Syu` fixed the kernel/module mismatch.

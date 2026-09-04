-- Hyprland Lua config for portable workstation
-- Source of truth: ~/dotfiles/hypr/hyprland.lua
-- Reference: /usr/share/hypr/hyprland.lua and /usr/share/hypr/stubs/hl.meta.lua

----------------
-- Programs
----------------

local terminal = "ghostty"
local fileManager = "nemo"
local menu = "rofi -show drun"
local browser = "firefox"
local music = "spotify-launcher"
local mainMod = "SUPER"

----------------
-- Monitors
----------------

-- Portable fallback for laptops/VMs/unknown desktops.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Desktop direct-boot monitor. Harmless if absent.
hl.monitor({ output = "DP-3", mode = "2560x1440", position = "auto", scale = 1 })

----------------
-- Autostart
----------------

hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("qs")
  hl.exec_cmd("swayosd-server")
  hl.exec_cmd("sleep 1 && awww img /home/mello/Pictures/miyamoto-musashi-3840x2160-15204.jpg --transition-type none")
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
end)

----------------
-- Environment
----------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

----------------
-- Look and feel
----------------

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 10,
    border_size = 0,
    col = {
      active_border = "rgba(e8e6e1ff)",
      inactive_border = "rgba(787670ff)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 0,
    active_opacity = 0.98,
    inactive_opacity = 0.75,
    shadow = {
      enabled = false,
      range = 35,
      render_power = 15,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 8,
      passes = 1,
      ignore_opacity = true,
      vibrancy = 0.1696,
      new_optimizations = true,
    },
  },

  animations = {
    enabled = false,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    focus_on_activate = true,
  },

  input = {
    follow_mouse = 1,
    sensitivity = 0,
    kb_layout = "us,it",
    kb_options = "grp:alt_shift_toggle",
    touchpad = {
      natural_scroll = true,
    },
  },
})

-- Kept defined even while animations are disabled, for easy future toggling.
hl.curve("myBezier", { type = "bezier", points = { { 0.15, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.device({
  name = "epic-mouse-v1",
  sensitivity = 1,
})

----------------
-- Helper functions
----------------

local function bind(keys, dispatcher, opts)
  hl.bind(keys, dispatcher, opts)
end

local function exec(keys, cmd, opts)
  bind(keys, hl.dsp.exec_cmd(cmd), opts)
end

----------------
-- Keybindings
----------------

exec(mainMod .. " + T", terminal)
bind(mainMod .. " + X", hl.dsp.window.close())
bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
exec(mainMod .. " + F", fileManager)
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
exec(mainMod .. " + R", menu)
bind(mainMod .. " + B", hl.dsp.layout("togglesplit"))
exec(mainMod .. " + Z", browser)
exec(mainMod .. " + M", music)
exec(mainMod .. " + SHIFT + Q", "systemctl suspend")

-- Screenshot region → clipboard
exec("ALT + Print", "hyprshot -m region --clipboard-only")

-- Vim-style focus movement
bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1..10; key 0 maps to workspace 10.
for i = 1, 10 do
  local key = i % 10
  bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspaces / scratchpads
bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
bind(mainMod .. " + A", hl.dsp.workspace.toggle_special("term"))
bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ workspace = "special:term" }))
bind(mainMod .. " + D", hl.dsp.workspace.toggle_special("social"))
bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:social" }))

-- Workspace scrolling
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + mouse drag
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume + brightness — popup OSD via swayosd-server
local mediaOpts = { locked = true, repeating = true }
exec("XF86AudioRaiseVolume", "swayosd-client --output-volume raise", mediaOpts)
exec("XF86AudioLowerVolume", "swayosd-client --output-volume lower", mediaOpts)
exec("XF86AudioMute", "swayosd-client --output-volume mute-toggle", { locked = true })
exec("XF86AudioMicMute", "swayosd-client --input-volume mute-toggle", { locked = true })
exec("XF86MonBrightnessUp", "swayosd-client --brightness raise", mediaOpts)
exec("XF86MonBrightnessDown", "swayosd-client --brightness lower", mediaOpts)

-- Media keys
exec("XF86AudioPrev", "playerctl previous")
exec("XF86AudioNext", "playerctl next")
exec("XF86AudioPlay", "playerctl play-pause")

-- Power menu + lock
exec(mainMod .. " + SHIFT + E", os.getenv("HOME") .. "/.config/wlogout/launch.sh")

----------------
-- Layer rules
----------------

hl.layer_rule({ name = "stats-panel-blur", match = { namespace = "stats-panel" }, blur = true })
hl.layer_rule({ name = "stats-panel-alpha", match = { namespace = "stats-panel" }, ignore_alpha = 0.3 })
hl.layer_rule({ name = "quickshell-blur", match = { namespace = "quickshell" }, blur = true })
hl.layer_rule({ name = "wlogout-blur", match = { namespace = "wlogout" }, blur = true })
hl.layer_rule({ name = "wlogout-alpha", match = { namespace = "wlogout" }, ignore_alpha = 0.3 })

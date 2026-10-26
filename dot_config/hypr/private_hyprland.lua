-- mugzx Hyprland config in the official Lua format (Hyprland 0.56+).
-- The legacy hyprland.conf is kept as a fallback; this file takes precedence.

local mainMod  = "SUPER"
local terminal = "/home/neomelt/.local/bin/mugzx-term"
local menu     = "/home/neomelt/.local/bin/mugzx-launcher"

----------------
--  MONITORS  --
----------------

hl.monitor({ output = "eDP-1",    mode = "3072x1920@120", position = "0x0",    scale = 1.6 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1600@60",  position = "1920x0", scale = 2 })
hl.monitor({ output = "",         mode = "preferred",     position = "auto",   scale = "auto" })

---------------------
--  ENVIRONMENT    --
---------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_STYLE_OVERRIDE", "Breeze")
-- Default terminal for apps that honour $TERMINAL; others use xdg-terminal-exec.
hl.env("TERMINAL", "kitty")

-------------------
--  AUTOSTART     --
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/home/neomelt/.local/bin/hyprland-uwsm-finalize")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("/home/neomelt/.local/bin/mugzx-startup")
    hl.exec_cmd("/home/neomelt/.local/bin/hypridle")
end)

-----------------------
--  LOOK AND FEEL    --
-----------------------

hl.config({
    general = {
        gaps_in      = 4,
        gaps_out     = 8,
        border_size  = 1,
        col = {
            active_border   = "rgba(f2f2f2ff)",
            inactive_border = "rgba(414141cc)",
        },
        layout        = "dwindle",
        allow_tearing = false,
    },

    decoration = {
        rounding         = 7,
        active_opacity   = 0.98,
        inactive_opacity = 0.94,
        dim_inactive     = true,
        dim_strength     = 0.12,
        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = "rgba(00000055)",
        },
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 3,
            vibrancy = 0.17,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        focus_on_activate       = true,
        -- Any input wakes a panel that lock-and-sleep or hypridle turned off.
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },

    input = {
        kb_layout      = "us",
        follow_mouse   = 1,
        sensitivity    = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
    },
})

-- Frosted glass behind the shell (bar, dock, panels), notifications and the
-- drop-down terminal. ignore_alpha keeps soft shadows and empty space unblurred.
hl.layer_rule({
    name         = "shell-blur",
    match        = { namespace = "^(mugzx-.*|swaync-.*|kitty-quick-access)$" },
    blur         = true,
    ignore_alpha = 0.5,
})

hl.curve("easeOut", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "easeOut" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4, bezier = "easeOut", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeOut", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "easeOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOut", style = "slide" })

-----------------
--  KEYBINDS    --
-----------------

-- applications / session
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mainMod .. " + M",      hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + Space",  hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + Tab",    hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + Tab",    hl.dsp.window.bring_to_top())

-- focus / swap / resize
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0 }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 40,  y = 0 }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0,   y = -40 }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0,   y = 40 }))

-- workspaces (1–9 + 0 for workspace 10)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- hardware keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),         { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-brightness up"),       { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-brightness down"),     { locked = true, repeating = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                               { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                     { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                                 { locked = true })

-- voice input (single binding)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("/home/neomelt/bin/qwen-voice-toggle.sh"))

-- clipboard history / drop-down terminal
hl.bind(mainMod .. " + C",     hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-clipboard"))
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("kitten quick-access-terminal"))

-- mouse move / resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- lock / power / help
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("/home/neomelt/.local/bin/lock-and-sleep"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-power"))
hl.bind("F1",                      hl.dsp.exec_cmd(terminal .. " /home/neomelt/.local/bin/mugzx-keys"))

-- screenshots: PRINT = menu, SUPER+P = region, SUPER+SHIFT+S = fullscreen
hl.bind("Print",                   hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-shot"))
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-screenshot region"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-screenshot full"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("/home/neomelt/.local/bin/mugzx-record"))

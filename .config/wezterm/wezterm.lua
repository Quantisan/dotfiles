-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = "Tokyo Night"
config.font_size = 13.0

config.leader = { key = "Space", mods = "CTRL" }

config.keys = {
    { key = "p", mods = "CTRL", action = act.PaneSelect },
}

-- and finally, return the configuration to wezterm
return config

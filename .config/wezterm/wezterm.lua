-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = "Tokyo Night"
config.font_size = 13.0

config.window_close_confirmation = "NeverPrompt"

config.leader = { key = "Space", mods = "CTRL" }

config.keys = {
    { key = "p", mods = "LEADER", action = act.PaneSelect },
    -- TODO: key combo conflict
    {
        key = "-",
        mods = "LEADER",
        action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    -- TODO: key combo conflict
    {
        key = "|",
        mods = "LEADER",
        action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        key = "w",
        mods = "CMD",
        action = act.CloseCurrentPane({ confirm = false }),
    },
}

-- and finally, return the configuration to wezterm
return config

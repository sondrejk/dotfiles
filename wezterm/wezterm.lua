-- Pull in the wezterm API
local wezterm = require 'wezterm'

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This table will hold the configuration.
local config = {}
config.wsl_domains = {
  {
    -- The name of this specific domain.  Must be unique amonst all types
    -- of domain in the configuration file.
    name = 'WSL:Ubuntu',

    -- The name of the distribution.  This identifies the WSL distribution.
    -- It must match a valid distribution from your `wsl -l -v` output in
    -- order for the domain to be useful.
    distribution = 'Ubuntu',
    default_cwd = "/home/sondrejk/"
  },
}
config.default_domain = 'WSL:Ubuntu'

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages

config.font = wezterm.font 'JetBrains Mono'

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox Dark (Gogh)'

-- and finally, return the configuration to wezterm
return config
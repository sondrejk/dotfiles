-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = {}

-- Use the config builder
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Check if windows
if wezterm.target_triple:find("windows") ~= nil then
	config.wsl_domains = {
		{
			-- The name of this specific domain.  Must be unique amongst all types
			-- of domain in the configuration file.
			name = "WSL:Ubuntu",

			-- The name of the distribution.  This identifies the WSL distribution.
			-- It must match a valid distribution from your `wsl -l -v` output in
			-- order for the domain to be useful.
			distribution = "Ubuntu",
			default_cwd = "/home/sondrejk/", -- Sets default directory
		},
	}
	config.default_domain = "WSL:Ubuntu"
end

-- Font
config.font = wezterm.font("JetBrains Mono")

-- Color scheme
config.color_scheme = "Gruvbox Dark (Gogh)"

return config


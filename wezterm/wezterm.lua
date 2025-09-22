-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local config = {}

-- Use the config builder
if wezterm.config_builder then
	config = wezterm.config_builder()
end

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	gui_window:maximize()
end)

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
		{
			-- The name of this specific domain.  Must be unique amongst all types
			-- of domain in the configuration file.
			name = "WSL:archlinux",

			-- The name of the distribution.  This identifies the WSL distribution.
			-- It must match a valid distribution from your `wsl -l -v` output in
			-- order for the domain to be useful.
			distribution = "archlinux",
			default_cwd = "/home/sondrejk/", -- Sets default directory
		},
	}
	config.default_domain = "WSL:archlinux"
end

-- Font
config.font = wezterm.font("JetBrains Mono Nerd Font")

-- Color scheme
config.color_scheme = "Gruvbox Dark (Gogh)"

config.hide_tab_bar_if_only_one_tab = true

return config

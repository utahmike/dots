-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Melange color scheme (official colors from melange-nvim)
-- Warm, dark colorscheme with vintage feel
-- See: https://github.com/savq/melange-nvim
config.colors = {
	foreground = "#ECE1D7",
	background = "#292522",
	cursor_bg = "#ECE1D7",
	cursor_fg = "#292522",
	cursor_border = "#ECE1D7",
	selection_bg = "#403A36",
	selection_fg = "#ECE1D7",

	-- ANSI colors (0-7): Melange official palette
	ansi = {
		"#34302C", -- black
		"#BD8183", -- red
		"#78997A", -- green
		"#E49B5D", -- yellow
		"#7F91B2", -- blue
		"#B380B0", -- magenta
		"#7B9695", -- cyan
		"#C1A78E", -- white
	},
	-- Bright colors (8-15): Melange official palette
	brights = {
		"#867462", -- bright black
		"#D47766", -- bright red
		"#85B695", -- bright green
		"#EBC06D", -- bright yellow
		"#A3A9CE", -- bright blue
		"#CF9BC2", -- bright magenta
		"#89B3B6", -- bright cyan
		"#ECE1D7", -- bright white
	},

	-- Tab bar colors
	tab_bar = {
		background = "#292522",
		active_tab = {
			bg_color = "#403A36",
			fg_color = "#ECE1D7",
		},
		inactive_tab = {
			bg_color = "#292522",
			fg_color = "#867462",
		},
		inactive_tab_hover = {
			bg_color = "#34302C",
			fg_color = "#C1A78E",
		},
		new_tab = {
			bg_color = "#292522",
			fg_color = "#867462",
		},
		new_tab_hover = {
			bg_color = "#34302C",
			fg_color = "#C1A78E",
		},
	},
}
config.font_size = 16.0

config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Bold" })

-- Shift+Enter sends Escape+Enter (for Neovim compatibility)
config.keys = {
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}

-- Use portable path for background image
local home = os.getenv("HOME")
local config_dir = home .. "/.config/wezterm"
local bg_image = config_dir .. "/background.tif"

-- Only set background if file exists
local file = io.open(bg_image, "r")
if file ~= nil then
	io.close(file)
	config.window_background_image = bg_image
	config.window_background_image_hsb = {
		brightness = 0.05,
		hue = 1.0,
		saturation = 1.0,
	}
end

-- and finally, return the configuration to wezterm
return config

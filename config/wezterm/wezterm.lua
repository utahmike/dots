-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Everforest color scheme
-- Comfortable & pleasant green forest theme
-- See: https://github.com/sainnhe/everforest
config.colors = {
	foreground = "#D3C6AA",  -- Everforest foreground
	background = "#2D353B",  -- Everforest background (medium)
	cursor_bg = "#D3C6AA",
	cursor_fg = "#2D353B",
	cursor_border = "#D3C6AA",
	selection_bg = "#503946",
	selection_fg = "#D3C6AA",

	-- ANSI colors: Everforest palette
	ansi = {
		"#4B565C", -- black
		"#E67E80", -- red
		"#A7C080", -- green
		"#DBBC7F", -- yellow
		"#7FBBB3", -- blue
		"#D699B6", -- magenta
		"#83C092", -- cyan
		"#D3C6AA", -- white
	},
	brights = {
		"#5C6A72", -- bright black
		"#E67E80", -- bright red
		"#A7C080", -- bright green
		"#DBBC7F", -- bright yellow
		"#7FBBB3", -- bright blue
		"#D699B6", -- bright magenta
		"#83C092", -- bright cyan
		"#D3C6AA", -- bright white
	},

	-- Tab bar colors
	tab_bar = {
		background = "#2D353B",
		active_tab = {
			bg_color = "#475258",
			fg_color = "#D3C6AA",
		},
		inactive_tab = {
			bg_color = "#2D353B",
			fg_color = "#859289",
		},
		inactive_tab_hover = {
			bg_color = "#3D484D",
			fg_color = "#A7C080",
		},
		new_tab = {
			bg_color = "#2D353B",
			fg_color = "#859289",
		},
		new_tab_hover = {
			bg_color = "#3D484D",
			fg_color = "#A7C080",
		},
	},
}
config.font_size = 16.0

config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Bold" })

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

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Custom darkearth color scheme to match nvim
config.colors = {
	foreground = "#D4C5A9",
	background = "#1A1A1A",
	cursor_bg = "#D4C5A9",
	cursor_fg = "#1A1A1A",
	cursor_border = "#D4C5A9",
	selection_bg = "#3A3A3A",
	selection_fg = "#D4C5A9",
	ansi = {
		"#2A2A2A", -- black
		"#D08770", -- red
		"#A3BE8C", -- green
		"#E6B450", -- yellow
		"#7FADD6", -- blue
		"#C59FC9", -- magenta
		"#83B6AF", -- cyan
		"#D4C5A9", -- white
	},
	brights = {
		"#4A4A4A", -- bright black
		"#E89580", -- bright red
		"#B3CE9C", -- bright green
		"#F6C460", -- bright yellow
		"#8FBDE6", -- bright blue
		"#D5AFD9", -- bright magenta
		"#93C6BF", -- bright cyan
		"#E4D5B9", -- bright white
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

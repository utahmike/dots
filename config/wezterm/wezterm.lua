-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Nord color scheme
-- Arctic, north-bluish color palette
-- See: https://www.nordtheme.com/
config.colors = {
	foreground = "#D8DEE9",  -- Snow Storm
	background = "#2E3440",  -- Polar Night (darkest)
	cursor_bg = "#D8DEE9",
	cursor_fg = "#2E3440",
	cursor_border = "#D8DEE9",
	selection_bg = "#434C5E",
	selection_fg = "#D8DEE9",

	-- ANSI colors: Nord palette
	ansi = {
		"#3B4252", -- black (Polar Night - dark)
		"#BF616A", -- red (Aurora - red)
		"#A3BE8C", -- green (Aurora - green)
		"#EBCB8B", -- yellow (Aurora - yellow)
		"#81A1C1", -- blue (Frost - blue)
		"#B48EAD", -- magenta (Aurora - purple)
		"#88C0D0", -- cyan (Frost - bright cyan)
		"#E5E9F0", -- white (Snow Storm - lighter)
	},
	brights = {
		"#4C566A", -- bright black (Polar Night - light)
		"#BF616A", -- bright red (Aurora - red)
		"#A3BE8C", -- bright green (Aurora - green)
		"#EBCB8B", -- bright yellow (Aurora - yellow)
		"#81A1C1", -- bright blue (Frost - blue)
		"#B48EAD", -- bright magenta (Aurora - purple)
		"#8FBCBB", -- bright cyan (Frost - cyan)
		"#ECEFF4", -- bright white (Snow Storm - lightest)
	},

	-- Tab bar colors
	tab_bar = {
		background = "#2E3440",
		active_tab = {
			bg_color = "#434C5E",
			fg_color = "#D8DEE9",
		},
		inactive_tab = {
			bg_color = "#2E3440",
			fg_color = "#4C566A",
		},
		inactive_tab_hover = {
			bg_color = "#3B4252",
			fg_color = "#88C0D0",
		},
		new_tab = {
			bg_color = "#2E3440",
			fg_color = "#4C566A",
		},
		new_tab_hover = {
			bg_color = "#3B4252",
			fg_color = "#88C0D0",
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

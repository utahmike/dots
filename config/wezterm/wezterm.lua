-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Afterglow (Gogh)"
-- config.color_scheme = 'Apprentice (base16)'
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

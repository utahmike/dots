-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Autumn Minimal color scheme
-- Following Nikita Prokopov's syntax highlighting principles
-- Matches neovim autumn-minimal theme
-- See: https://tonsky.me/blog/syntax-highlighting/
config.colors = {
	foreground = "#d4c5a9",  -- Warm tan (dried grass)
	background = "#1a1814",  -- Dark brown-black (tree bark/shadows)
	cursor_bg = "#d4c5a9",
	cursor_fg = "#1a1814",
	cursor_border = "#d4c5a9",
	selection_bg = "#4a4034",
	selection_fg = "#d4c5a9",

	-- ANSI colors: strategic palette from autumn landscape
	ansi = {
		"#1a1814", -- black (background)
		"#c97a4a", -- red (rust orange - for errors)
		"#9db668", -- green (lime - for success/definitions)
		"#e8b339", -- yellow (golden - for strings/warnings)
		"#7a9fb5", -- blue (muted blue-gray from sky)
		"#b08968", -- magenta (brown-purple, subdued)
		"#8faa8f", -- cyan (sage green)
		"#d4c5a9", -- white (warm tan foreground)
	},
	brights = {
		"#4a4034", -- bright black (line numbers)
		"#e67e22", -- bright red (bright orange - for comments!)
		"#b8d98a", -- bright green (brighter lime)
		"#f0c952", -- bright yellow (brighter golden)
		"#8fb5d1", -- bright blue (brighter blue-gray)
		"#c9a87a", -- bright magenta (lighter brown)
		"#a8c4a8", -- bright cyan (brighter sage)
		"#e8dcc0", -- bright white (lighter tan)
	},

	-- Tab bar colors
	tab_bar = {
		background = "#0f0d0b",
		active_tab = {
			bg_color = "#1a1814",
			fg_color = "#d4c5a9",
		},
		inactive_tab = {
			bg_color = "#0f0d0b",
			fg_color = "#6b5d4f",
		},
		inactive_tab_hover = {
			bg_color = "#221f1a",
			fg_color = "#9a8873",
		},
		new_tab = {
			bg_color = "#0f0d0b",
			fg_color = "#6b5d4f",
		},
		new_tab_hover = {
			bg_color = "#221f1a",
			fg_color = "#9a8873",
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

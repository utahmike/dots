# Personal Dotfiles

Personal configuration files for macOS/Linux development environment, managed with GNU Stow.

## Overview

This repository manages configuration for:
- **Neovim** - Text editor (Kickstart-based config)
- **Tmux** - Terminal multiplexer with seamless nvim integration
- **Alacritty** - Terminal emulator
- **WezTerm** - Alternative terminal emulator
- **Git** - Version control settings
- **Shell** - Environment variables and aliases (bash/zsh)

## Prerequisites

### Required
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- Git - Version control

### Optional (for development)
- shellcheck - Shell script linting
- luacheck - Lua linting
- Neovim >= 0.10
- Tmux >= 3.0 - Terminal multiplexer
- Nerd Font (recommended: Hack Nerd Font)

### Installation

#### macOS
```bash
brew install stow git tmux
brew install --cask font-hack-nerd-font
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt install stow git tmux
```

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Set up credential files:**
   ```bash
   cp templates/.credentials.sh.template ~/.credentials.sh
   cp templates/env.local.sh.template ~/.config/env.local.sh

   # Edit these files with your personal values
   vim ~/.credentials.sh
   vim ~/.config/env.local.sh
   ```

3. **Install dotfiles:**
   ```bash
   make install
   ```

4. **Add to your shell RC file** (`~/.zshrc` or `~/.bashrc`):
   ```bash
   source ~/.config/env.sh
   ```

5. **Reload your shell:**
   ```bash
   exec $SHELL
   ```

## Usage

### Available Commands

| Command | Description |
|---------|-------------|
| `make help` | Show help message with all available commands |
| `make install` | Install configurations (creates backup automatically) |
| `make uninstall` | Remove symlinks |
| `make backup` | Create backup of existing configs |
| `make restore` | Restore from most recent backup |
| `make test` | Run configuration tests |
| `make check-dependencies` | Verify required tools are installed |
| `make clean` | Remove old backups (keep last 5) |

### Updating Configurations

1. Make changes in the repository
2. Changes are immediately reflected (via symlinks)
3. Commit and push when satisfied

### Adding New Configurations

1. Add files to appropriate directory (`config/`, `home/`)
2. Test with `stow -n` (dry run) to preview
3. Run `make install`

## Structure

```
.
├── config/          # ~/.config/* files
│   ├── alacritty/   # Terminal emulator config
│   ├── nvim/        # Neovim configuration
│   ├── tmux/        # Tmux configuration
│   ├── wezterm/     # WezTerm config
│   └── env.sh       # Shell environment
├── home/            # ~/* files (use dot- prefix for dotfiles)
│   └── dot-gitconfig
├── .claude/         # Claude Code settings
├── plan/            # Design documents
├── scripts/         # Helper scripts (backup, test)
├── templates/       # Configuration templates
├── backups/         # Automatic backups (not in git)
├── makefile         # Installation automation
├── CLAUDE.md        # Project instructions
└── README.md        # This file
```

## Customization

### Personal Overrides

Create `~/.config/env.local.sh` for machine-specific configuration:
```bash
# Custom paths
export MY_PROJECT_DIR=$HOME/dev/myproject

# Custom aliases
alias mycommand='echo "Hello"'

# Company-specific settings
export GOPATH=$HOME/dev/go
```

### Credential Management

Store sensitive values in `~/.credentials.sh`:
```bash
export API_KEY="secret-key"
export GITHUB_TOKEN="ghp_xxxxx"
export DATABASE_PASSWORD="secret-password"
```

**Never commit credential files to git!** They are excluded via `.gitignore`.

## Neovim Configuration

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

### Included Plugins
- Telescope (fuzzy finder)
- LSP support (lua_ls configured)
- Treesitter (syntax highlighting)
- Git integration (fugitive, gitsigns)
- Trouble (diagnostics)
- Which-key (keybinding help)
- Oil (file explorer)

### Key Bindings
- `<Space>` - Leader key
- `<Space>sf` - Find files
- `<Space>sg` - Live grep
- `<Space>sh` - Search help
- `<Space>ee` - Toggle file tree (Oil)

See `:help` in Neovim for complete documentation.

## Tmux Configuration

Terminal multiplexer with darkearth colorscheme and seamless nvim integration.

### Features
- **Seamless Navigation**: `C-h/j/k/l` navigates both nvim splits and tmux panes
- **Darkearth Colors**: Status bar and borders match nvim theme (#1A1A1A background)
- **Vi-mode**: Copy mode uses vi keybindings
- **Mouse Support**: Enabled for pane resizing and selection
- **Better Keybindings**: `C-a` prefix, `|` for vertical split, `-` for horizontal split

### Key Bindings
- `C-a` - Prefix (instead of default `C-b`)
- `C-a |` - Split pane vertically
- `C-a -` - Split pane horizontally
- `C-h/j/k/l` - Navigate between panes and nvim windows seamlessly
- `C-a r` - Reload tmux config
- `C-a [` - Enter copy mode (use vi keys, `v` to select, `y` to yank)

### Navigation Between Nvim and Tmux
The vim-tmux-navigator plugin provides seamless navigation:
- When in nvim, `C-h/j/k/l` moves between nvim splits
- At the edge of a split, continues to adjacent tmux pane
- When not in nvim, `C-h/j/k/l` navigates tmux panes
- Use `C-a C-l` to clear the screen (since `C-l` is used for navigation)

### True Color Support
Tmux is configured for true color (24-bit) support. Requires a compatible terminal:
- ✅ Alacritty (built-in)
- ✅ WezTerm (built-in)
- ✅ iTerm2 (v3.0+)
- ⚠️  Terminal.app (limited support)

To verify true color support:
```bash
printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
```
You should see "TRUECOLOR" in orange.

### Optional: Tmux Plugin Manager (TPM)
Configuration includes commented TPM setup for advanced plugins. To enable:

```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Uncomment the TPM section in config/tmux/tmux.conf
# Press C-a I (capital I) to install plugins
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:
```bash
# See what would be done
stow -n -v -t ~/.config config

# Force adoption of existing files (use with caution)
stow --adopt -t ~/.config config
git diff  # Review changes
```

### Restore Original Configs

```bash
make restore
```

Restores from the most recent backup in `backups/`.

### Shell Not Sourcing env.sh

Ensure this line is in your shell RC file:
```bash
source ~/.config/env.sh
```

For zsh, add to `~/.zshrc`. For bash, add to `~/.bashrc`.

### Neovim Plugins Not Loading

On first launch, Neovim will download and install plugins via lazy.nvim. This may take a few minutes. If issues persist:

```bash
# Remove plugin cache and restart
rm -rf ~/.local/share/nvim
nvim
```

### Background Image Not Showing in WezTerm

The background image is optional. If you want to use one:

1. Copy your image to `~/.config/wezterm/background.tif`
2. Restart WezTerm

Or edit `config/wezterm/wezterm.lua` to customize.

## Security Notes

### Exposed SDK Key

**WARNING:** A previous version of this repository contained an exposed Optimizely SDK key in `config/env.sh`. This key has been removed, but remains in git history:

- Exposed key: `UYioHayz4pqa2EXuLyRgP9`
- **Action required:** Rotate this key if it was used in production

### Credential Management

This repository now uses a template-based credential system:

1. Secrets go in `~/.credentials.sh` (not tracked)
2. Company-specific config goes in `~/.config/env.local.sh` (not tracked)
3. Templates are provided in `templates/` directory
4. `.gitignore` prevents accidental commits

Always review changes before committing:
```bash
git diff
```

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements via PRs

## License

MIT License - See LICENSE file

## Acknowledgments

- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Neovim configuration foundation
- [GNU Stow](https://www.gnu.org/software/stow/) - Dotfile management tool
- [Hack Nerd Font](https://www.nerdfonts.com/) - Terminal font with icon support

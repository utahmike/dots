# Dotfiles Repository Improvements - Recommendations

## Overview

This document provides actionable recommendations to improve the security, portability, maintainability, and usability of this dotfiles repository.

---

## 1. Security Improvements

### 1.1 Secret Management

**Problem:** SDK key and potentially other secrets are committed to version control.

**Solution:**

Create a template for credential management:

**File: `.credentials.sh.template`**
```bash
#!/bin/bash
# Copy this file to ~/.credentials.sh and fill in your values
# This file should NEVER be committed to git

# Optimizely
export OPTIMIZELY_SDK_KEY_DEVEL="your-key-here"

# AWS credentials (if needed)
# export AWS_ACCESS_KEY_ID="your-key"
# export AWS_SECRET_ACCESS_KEY="your-secret"

# Other sensitive tokens
# export GITHUB_TOKEN="your-token"
```

**Action Items:**
1. Remove SDK key from `config/env.sh:46`
2. Create `.credentials.sh.template` in repository root
3. Add to README: "Copy `.credentials.sh.template` to `~/.credentials.sh` and fill in values"
4. Rotate the exposed Optimizely SDK key
5. Add `.credentials.sh` to `.gitignore` (already sourced in env.sh)

### 1.2 Git Credentials

**Problem:** Using `credential.helper = store` in git config stores passwords in plaintext.

**Recommendation:**
```gitconfig
[credential]
    # macOS: use keychain
    helper = osxkeychain
    # Linux: use system keyring
    # helper = /usr/share/git/credential/libsecret/git-credential-libsecret
```

---

## 2. Portability Improvements

### 2.1 Path Parameterization

**Problem:** Hardcoded absolute paths break portability.

**Solution:**

**File: `config/wezterm/wezterm.lua` (lines 16-27)**

Replace:
```lua
config.window_background_image = "/Users/mjc/Desktop/untitled-1.tif"
```

With:
```lua
-- Use XDG_CONFIG_HOME or default to ~/.config
local home = os.getenv("HOME")
local bg_image = home .. "/.config/wezterm/background.tif"

-- Only set if file exists
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
```

**Action Items:**
1. Move background image to `config/wezterm/background.tif`
2. Update wezterm config to use relative path
3. Document custom background image setup in README

### 2.2 Company-Specific Configuration

**Problem:** Beyond Identity/zeropw paths are hardcoded in env.sh.

**Solution:**

Create a local override system:

**File: `config/env.local.sh.template`**
```bash
#!/bin/bash
# Local machine-specific configuration
# Copy this to config/env.local.sh and customize

# Company-specific paths
# export ZEROPW=$HOME/dev/go/src/gitlab.com/zeropw/zero
# source $ZEROPW/devel/apple/zpw-functions.sh

# Custom cdpath entries
# cdpath+=(
#     $HOME/dev/work
#     $HOME/dev/personal
# )
```

**In `config/env.sh`**, add at end:
```bash
# Source local overrides if they exist
if [ -f $HOME/.config/env.local.sh ]; then
    source $HOME/.config/env.local.sh
fi
```

**Action Items:**
1. Move Beyond Identity specific config to template
2. Create env.local.sh.template
3. Add env.local.sh to .gitignore
4. Keep only generic, portable config in env.sh

### 2.3 OS Detection Improvements

**Current:** Basic Darwin/Linux case statement

**Enhanced version in `config/env.sh`:**
```bash
case $(uname) in
Darwin)
    # macOS specific configuration
    if [ -x /opt/homebrew/bin/brew ]; then
        export PATH=/opt/homebrew/bin:$PATH
    elif [ -x /usr/local/bin/brew ]; then
        export PATH=/usr/local/bin:$PATH
    fi

    # Add SSH keys if on macOS
    for file in $HOME/.ssh/*.pub; do
        [ -f "$file" ] && ssh-add -K "${file%.*}" 2>/dev/null
    done

    alias linux_dev='docker run --rm --mount source=mjc-dev,target=/home/mjc -it dev:mjc'
    ;;
Linux)
    # Linux specific configuration
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        alias bat='batcat'
    fi

    # Standard Linux paths
    export PATH=/usr/local/bin:$PATH
    ;;
*)
    echo "Warning: Unknown OS - some configurations may not work"
    ;;
esac
```

---

## 3. Repository Organization

### 3.1 File Naming Resolution

**Problem:** CLAUDE.MD in root vs claude/CLAUDE.md - confusion and Git issues.

**Recommendation:**

Choose one location:
- **Option A:** Keep in root as `CLAUDE.md` (more visible)
- **Option B:** Keep in `.claude/` directory with stow (more organized)

**Recommended: Option A**
- More discoverable for new users
- Commonly expected location
- Stow won't manage it (which is fine, it's instructions not config)

**Action Items:**
```bash
# Remove the deleted claude/CLAUDE.md from git
git rm claude/CLAUDE.md

# Add the root version
git add CLAUDE.MD
git mv CLAUDE.MD CLAUDE.md  # Normalize to lowercase .md

# Commit the cleanup
git commit -m "Standardize Claude instructions location"
```

### 3.2 Directory Structure

**Recommended structure:**
```
dots/
├── .claude/                    # Claude Code settings (stowed)
│   └── settings.local.json
├── config/                     # Main configurations (stowed)
│   ├── alacritty/
│   ├── nvim/
│   ├── wezterm/
│   └── env.sh
├── home/                       # Home directory files (stowed)
│   └── dot-gitconfig
├── plan/                       # Design documents
│   ├── critique.md
│   └── recommendations.md
├── scripts/                    # Helper scripts (new)
│   ├── backup.sh
│   ├── restore.sh
│   └── test.sh
├── templates/                  # Configuration templates (new)
│   ├── .credentials.sh.template
│   └── env.local.sh.template
├── .gitignore
├── CLAUDE.md                   # Project instructions
├── LICENSE                     # (add if sharing)
├── makefile
└── README.md                   # (to be created)
```

---

## 4. Installation & Backup System

### 4.1 Enhanced Makefile

**File: `makefile`**
```makefile
.PHONY: help install uninstall backup restore test check-dependencies

# Default target
help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo "make install          - Install dotfiles (with backup)"
	@echo "make uninstall        - Remove installed dotfiles"
	@echo "make backup           - Backup existing configs"
	@echo "make restore          - Restore from backup"
	@echo "make test             - Run configuration tests"
	@echo "make check-dependencies - Check for required tools"

# Check for required dependencies
check-dependencies:
	@command -v stow >/dev/null 2>&1 || { echo "Error: stow not installed" >&2; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "Error: git not installed" >&2; exit 1; }
	@echo "All required dependencies found"

# Backup existing configurations
backup:
	@echo "Creating backup..."
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@if [ -d ~/.config/nvim ]; then cp -r ~/.config/nvim backups/$(shell date +%Y%m%d_%H%M%S)/nvim; fi
	@if [ -d ~/.config/alacritty ]; then cp -r ~/.config/alacritty backups/$(shell date +%Y%m%d_%H%M%S)/alacritty; fi
	@if [ -d ~/.config/wezterm ]; then cp -r ~/.config/wezterm backups/$(shell date +%Y%m%d_%H%M%S)/wezterm; fi
	@if [ -f ~/.gitconfig ]; then cp ~/.gitconfig backups/$(shell date +%Y%m%d_%H%M%S)/gitconfig; fi
	@echo "Backup complete: backups/$(shell date +%Y%m%d_%H%M%S)"

# Install with automatic backup
install: check-dependencies backup
	@echo "Installing dotfiles..."
	stow -v -t ~/.config config
	stow -v -t ~/.claude claude
	stow -v -t ~ --dotfiles home
	@echo "Installation complete!"
	@echo "Don't forget to:"
	@echo "  1. Copy templates to active files"
	@echo "  2. Source env.sh in your shell rc file"

# Uninstall
uninstall:
	@echo "Uninstalling dotfiles..."
	stow -v -t ~/.config --delete config
	stow -v -t ~/.claude --delete claude
	stow -v -t ~ --delete --dotfiles home
	@echo "Uninstall complete"

# Restore from most recent backup
restore:
	@LATEST=$$(ls -t backups/ | head -1); \
	if [ -z "$$LATEST" ]; then \
		echo "No backups found"; \
		exit 1; \
	fi; \
	echo "Restoring from: $$LATEST"; \
	if [ -d "backups/$$LATEST/nvim" ]; then cp -r "backups/$$LATEST/nvim" ~/.config/; fi; \
	if [ -d "backups/$$LATEST/alacritty" ]; then cp -r "backups/$$LATEST/alacritty" ~/.config/; fi; \
	if [ -d "backups/$$LATEST/wezterm" ]; then cp -r "backups/$$LATEST/wezterm" ~/.config/; fi; \
	if [ -f "backups/$$LATEST/gitconfig" ]; then cp "backups/$$LATEST/gitconfig" ~/.gitconfig; fi; \
	echo "Restore complete"

# Run tests
test:
	@echo "Running configuration tests..."
	@command -v shellcheck >/dev/null 2>&1 && shellcheck config/env.sh || echo "shellcheck not installed, skipping"
	@command -v luacheck >/dev/null 2>&1 && luacheck config/nvim/init.lua || echo "luacheck not installed, skipping"
	@echo "Basic syntax checks complete"

# Clean (remove old backups)
clean:
	@echo "Cleaning old backups (keeping last 5)..."
	@ls -t backups/ | tail -n +6 | xargs -I {} rm -rf backups/{}
```

**Action Items:**
1. Replace existing makefile
2. Create backups/ directory
3. Add backups/ to .gitignore
4. Test backup/restore cycle

---

## 5. Documentation

### 5.1 Comprehensive README

**File: `README.md`**

```markdown
# Personal Dotfiles

Personal configuration files for macOS/Linux development environment.

## Overview

This repository manages configuration for:
- **Neovim** - Text editor (Kickstart-based config)
- **Alacritty** - Terminal emulator
- **WezTerm** - Alternative terminal emulator
- **Git** - Version control settings
- **Shell** - Environment variables and aliases

## Prerequisites

### Required
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- Git

### Optional (for development)
- shellcheck - Shell script linting
- luacheck - Lua linting
- Neovim >= 0.10
- Nerd Font (recommended: Hack Nerd Font)

### Installation

#### macOS
```bash
brew install stow git
brew install --cask font-hack-nerd-font
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt install stow git
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
| `make install` | Install configurations (creates backup automatically) |
| `make uninstall` | Remove symlinks |
| `make backup` | Create backup of existing configs |
| `make restore` | Restore from most recent backup |
| `make test` | Run configuration tests |
| `make check-dependencies` | Verify required tools are installed |

### Updating Configurations

1. Make changes in the repository
2. Changes are immediately reflected (symlinks)
3. Commit and push when satisfied

### Adding New Configurations

1. Add files to appropriate directory (`config/`, `home/`)
2. Test with `stow -n` (dry run)
3. Run `make install`

## Structure

```
.
├── config/          # ~/.config/* files
├── home/            # ~/* files (use dot- prefix for dotfiles)
├── .claude/         # Claude Code settings
├── plan/            # Design documents
├── templates/       # Configuration templates
├── backups/         # Automatic backups (not in git)
├── makefile         # Installation automation
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
```

### Credential Management

Store sensitive values in `~/.credentials.sh`:
```bash
export API_KEY="secret-key"
export DATABASE_PASSWORD="secret-password"
```

**Never commit credential files to git!**

## Neovim Configuration

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

### Included Plugins
- Telescope (fuzzy finder)
- LSP support (lua_ls configured)
- Treesitter (syntax highlighting)
- Git integration (fugitive, gitsigns)
- Trouble (diagnostics)
- Which-key (keybinding help)

### Key Bindings
- `<Space>` - Leader key
- `<Space>sf` - Find files
- `<Space>sg` - Live grep
- `<Space>sh` - Search help
- `<Space>ee` - Toggle file tree

See `:help` in Neovim for complete documentation.

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:
```bash
# See what would be done
stow -n -v -t ~/.config config

# Force adoption of existing files
stow --adopt -t ~/.config config
git diff  # Review changes
```

### Restore Original Configs

```bash
make restore
```

### Shell Not Sourcing env.sh

Ensure this line is in your shell RC file:
```bash
source ~/.config/env.sh
```

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements via PRs

## License

MIT License - See LICENSE file

## Acknowledgments

- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Neovim configuration
- [GNU Stow](https://www.gnu.org/software/stow/) - Dotfile management
```

---

## 6. Testing & Validation

### 6.1 Configuration Testing Script

**File: `scripts/test.sh`**
```bash
#!/bin/bash
set -e

echo "=== Dotfiles Configuration Tests ==="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# Test 1: Shell script syntax
echo "Testing shell scripts..."
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck config/env.sh && pass "env.sh syntax valid" || fail "env.sh has errors"
else
    echo "  Skipping (shellcheck not installed)"
fi

# Test 2: Lua syntax
echo "Testing Lua configs..."
if command -v luacheck >/dev/null 2>&1; then
    luacheck config/nvim/init.lua --globals vim && pass "init.lua syntax valid" || fail "init.lua has errors"
else
    echo "  Skipping (luacheck not installed)"
fi

# Test 3: TOML syntax
echo "Testing TOML configs..."
if command -v taplo >/dev/null 2>&1; then
    taplo check config/alacritty/alacritty.toml && pass "alacritty.toml valid" || fail "alacritty.toml has errors"
else
    echo "  Skipping (taplo not installed)"
fi

# Test 4: Git config validity
echo "Testing Git config..."
git config -f home/dot-gitconfig --list >/dev/null && pass "gitconfig valid" || fail "gitconfig has errors"

# Test 5: Check for hardcoded paths
echo "Checking for hardcoded absolute paths..."
HARDCODED=$(grep -r "/Users/mjc" config/ 2>/dev/null | grep -v ".swp" || true)
if [ -z "$HARDCODED" ]; then
    pass "No hardcoded user paths found"
else
    fail "Found hardcoded paths:\n$HARDCODED"
fi

# Test 6: Check for exposed secrets
echo "Checking for potential secrets..."
SECRETS=$(grep -rE "(password|secret|key|token).*=.*['\"]?[A-Za-z0-9]{20,}" config/ 2>/dev/null | grep -v ".swp" || true)
if [ -z "$SECRETS" ]; then
    pass "No obvious secrets found"
else
    fail "Potential secrets found:\n$SECRETS"
fi

# Test 7: Verify template files exist
echo "Checking templates..."
[ -f "templates/.credentials.sh.template" ] && pass ".credentials.sh.template exists" || echo "  Missing .credentials.sh.template"
[ -f "templates/env.local.sh.template" ] && pass "env.local.sh.template exists" || echo "  Missing env.local.sh.template"

echo ""
echo "=== All tests passed ==="
```

**Make executable:**
```bash
chmod +x scripts/test.sh
```

---

## 7. Implementation Roadmap

### Phase 1: Critical (Week 1)
- [ ] Remove SDK key from env.sh
- [ ] Create .credentials.sh.template
- [ ] Rotate exposed Optimizely key
- [ ] Fix CLAUDE.md file naming issue
- [ ] Add backups/ to .gitignore
- [ ] Commit security fixes

### Phase 2: High Priority (Week 2)
- [ ] Replace hardcoded paths in wezterm.lua
- [ ] Create env.local.sh.template
- [ ] Move company-specific config to template
- [ ] Update .gitignore with new patterns
- [ ] Create enhanced makefile with backup
- [ ] Write comprehensive README.md
- [ ] Create directory: scripts/
- [ ] Create directory: templates/

### Phase 3: Medium Priority (Week 3-4)
- [ ] Implement enhanced OS detection
- [ ] Create backup/restore scripts
- [ ] Write test.sh script
- [ ] Test full installation on clean machine
- [ ] Document all dependencies
- [ ] Add troubleshooting section to README
- [ ] Create LICENSE file

### Phase 4: Long-term (Ongoing)
- [ ] Set up GitHub Actions for testing
- [ ] Expand LSP configurations as needed
- [ ] Add more language-specific configs
- [ ] Create pre-commit hooks
- [ ] Add screenshots to README
- [ ] Consider splitting into modular configs
- [ ] Add dotfile update notification system

---

## 8. Specific Code Changes

### Change #1: config/env.sh

**Remove lines 46-47:**
```bash
# REMOVE THIS:
export OPTIMIZELY_SDK_KEY_DEVEL=UYioHayz4pqa2EXuLyRgP9
```

**Add after line 26:**
```bash
# Source local environment overrides
if [ -f ~/.config/env.local.sh ]; then
    source ~/.config/env.local.sh
fi
```

**Move lines 44-77 to templates/env.local.sh.template:**
```bash
# Company-specific configuration
export GOPATH=$HOME/dev/go
export ZEROPW=$GOPATH/src/gitlab.com/zeropw/zero
export PATH=$PATH:$GOPATH/bin
# ... rest of company config
```

### Change #2: config/wezterm/wezterm.lua

**Replace lines 16-27:**
```lua
local home = os.getenv("HOME")
local config_dir = home .. "/.config/wezterm"
local bg_image = config_dir .. "/background.tif"

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
```

### Change #3: .gitignore

**Add:**
```
# Backups
backups/

# Local configuration
config/env.local.sh
.credentials.sh

# OS files
.DS_Store

# Editor
*.swp
*.swo
*~

# Neovim
config/nvim/lazy-lock.json
```

### Change #4: home/dot-gitconfig

**Update credential helper:**
```gitconfig
[credential]
	helper = osxkeychain
```

---

## Summary

These recommendations address:
1. **Security**: Remove secrets, improve credential management
2. **Portability**: Eliminate hardcoded paths, improve OS detection
3. **Maintainability**: Better structure, documentation, testing
4. **Usability**: Backup/restore, clear installation process

Implement in phases based on the priority roadmap. The most critical items (security issues and file conflicts) should be addressed immediately.

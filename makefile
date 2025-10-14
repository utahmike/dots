.PHONY: help install uninstall backup restore test check-dependencies clean

# Default target
help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo "make help                - Show this help message"
	@echo "make install             - Install dotfiles (with backup)"
	@echo "make uninstall           - Remove installed dotfiles"
	@echo "make backup              - Backup existing configs"
	@echo "make restore             - Restore from backup"
	@echo "make test                - Run configuration tests"
	@echo "make check-dependencies  - Check for required tools"
	@echo "make clean               - Remove old backups (keep last 5)"

# Check for required dependencies
check-dependencies:
	@echo "Checking dependencies..."
	@command -v stow >/dev/null 2>&1 || { echo "Error: stow not installed" >&2; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "Error: git not installed" >&2; exit 1; }
	@echo "✓ All required dependencies found"

# Backup existing configurations
backup:
	@echo "Creating backup..."
	@BACKUP_DIR="backups/$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	if [ -d ~/.config/nvim ]; then cp -r ~/.config/nvim "$$BACKUP_DIR/nvim" 2>/dev/null || true; fi; \
	if [ -d ~/.config/alacritty ]; then cp -r ~/.config/alacritty "$$BACKUP_DIR/alacritty" 2>/dev/null || true; fi; \
	if [ -d ~/.config/wezterm ]; then cp -r ~/.config/wezterm "$$BACKUP_DIR/wezterm" 2>/dev/null || true; fi; \
	if [ -d ~/.config/tmux ]; then cp -r ~/.config/tmux "$$BACKUP_DIR/tmux" 2>/dev/null || true; fi; \
	if [ -f ~/.gitconfig ]; then cp ~/.gitconfig "$$BACKUP_DIR/gitconfig" 2>/dev/null || true; fi; \
	if [ -d ~/.claude ]; then cp -r ~/.claude "$$BACKUP_DIR/claude" 2>/dev/null || true; fi; \
	if [ -f ~/.config/env.sh ]; then cp ~/.config/env.sh "$$BACKUP_DIR/env.sh" 2>/dev/null || true; fi; \
	echo "✓ Backup complete: $$BACKUP_DIR"

# Install with automatic backup
install: check-dependencies backup
	@echo "Installing dotfiles..."
	@stow -v -t ~/.config config
	@stow -v -t ~/.claude claude 2>/dev/null || echo "Note: .claude directory not found, skipping"
	@stow -v -t ~ --dotfiles home
	@echo ""
	@echo "✓ Installation complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Copy templates/. credentials.sh.template to ~/.credentials.sh"
	@echo "  2. Copy templates/env.local.sh.template to ~/.config/env.local.sh"
	@echo "  3. Edit these files with your personal values"
	@echo "  4. Add 'source ~/.config/env.sh' to your shell RC file (~/.zshrc or ~/.bashrc)"
	@echo "  5. Reload your shell: exec \$$SHELL"

# Uninstall
uninstall:
	@echo "Uninstalling dotfiles..."
	@stow -v -t ~/.config --delete config 2>/dev/null || true
	@stow -v -t ~/.claude --delete claude 2>/dev/null || true
	@stow -v -t ~ --delete --dotfiles home 2>/dev/null || true
	@echo "✓ Uninstall complete"

# Restore from most recent backup
restore:
	@LATEST=$$(ls -t backups/ 2>/dev/null | head -1); \
	if [ -z "$$LATEST" ]; then \
		echo "Error: No backups found" >&2; \
		exit 1; \
	fi; \
	echo "Restoring from: $$LATEST"; \
	if [ -d "backups/$$LATEST/nvim" ]; then \
		mkdir -p ~/.config && cp -r "backups/$$LATEST/nvim" ~/.config/; \
	fi; \
	if [ -d "backups/$$LATEST/alacritty" ]; then \
		mkdir -p ~/.config && cp -r "backups/$$LATEST/alacritty" ~/.config/; \
	fi; \
	if [ -d "backups/$$LATEST/wezterm" ]; then \
		mkdir -p ~/.config && cp -r "backups/$$LATEST/wezterm" ~/.config/; \
	fi; \
	if [ -d "backups/$$LATEST/tmux" ]; then \
		mkdir -p ~/.config && cp -r "backups/$$LATEST/tmux" ~/.config/; \
	fi; \
	if [ -f "backups/$$LATEST/gitconfig" ]; then \
		cp "backups/$$LATEST/gitconfig" ~/.gitconfig; \
	fi; \
	if [ -d "backups/$$LATEST/claude" ]; then \
		cp -r "backups/$$LATEST/claude" ~/.claude; \
	fi; \
	if [ -f "backups/$$LATEST/env.sh" ]; then \
		mkdir -p ~/.config && cp "backups/$$LATEST/env.sh" ~/.config/env.sh; \
	fi; \
	echo "✓ Restore complete from $$LATEST"

# Run tests
test:
	@echo "Running configuration tests..."
	@if [ -x scripts/test.sh ]; then \
		./scripts/test.sh; \
	else \
		echo "Running basic validation..."; \
		command -v shellcheck >/dev/null 2>&1 && shellcheck config/env.sh || echo "  ⊗ shellcheck not installed, skipping shell tests"; \
		command -v luacheck >/dev/null 2>&1 && luacheck config/nvim/init.lua --globals vim || echo "  ⊗ luacheck not installed, skipping Lua tests"; \
		git config -f home/dot-gitconfig --list >/dev/null && echo "  ✓ gitconfig valid" || echo "  ✗ gitconfig has errors"; \
		echo "✓ Basic validation complete"; \
	fi

# Clean old backups (keep last 5)
clean:
	@echo "Cleaning old backups (keeping last 5)..."
	@if [ -d backups ]; then \
		KEEP=5; \
		COUNT=$$(ls -t backups/ | wc -l | tr -d ' '); \
		if [ "$$COUNT" -gt "$$KEEP" ]; then \
			ls -t backups/ | tail -n +$$((KEEP + 1)) | while read dir; do \
				echo "  Removing backups/$$dir"; \
				rm -rf "backups/$$dir"; \
			done; \
			echo "✓ Cleanup complete"; \
		else \
			echo "  No old backups to remove ($$COUNT backups found)"; \
		fi; \
	else \
		echo "  No backups directory found"; \
	fi

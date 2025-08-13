install:
	stow -t ~/.config config
	stow -t ~/.claude claude
	stow -t ~ --dotfiles home

clean:
	stow -t ~/.config --delete config
	stow -t ~/.claude --delete claude
	stow -t ~ --delete --dotfiles home

install:
	stow -t ~/.config config
	stow -t ~ --dotfiles home

clean:
	stow -t ~/.config --delete config
	stow -t ~ --delete --dotfiles home

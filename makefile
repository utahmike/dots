install:
	stow -t ~ --dotfiles zsh
	stow -t ~ --dotfiles git

clean:
	stow -t ~ --delete --dotfiles zsh
	stow -t ~ --delete --dotfiles git

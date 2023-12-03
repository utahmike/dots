install:
	stow -t ~ --dotfiles zsh
	stow -t ~ --dotfiles git
	stow -t ~ --dotfiles nvim

clean:
	stow -t ~ --delete --dotfiles zsh
	stow -t ~ --delete --dotfiles git
	stow -t ~ --delete --dotfiles nvim

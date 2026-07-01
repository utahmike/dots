# Setup and add SSH Keys for use with home and work.
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
    eval $(ssh-agent)
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock

export OBSIDIAN_VAULT=~/Documents/aspengrove
export BIROOT=$HOME/dev/go/src/gitlab.com/zeropw/zero

case $(uname) in
Darwin)
    # macOS specific configuration
    # Check for Homebrew in multiple locations (Apple Silicon vs Intel)
    if [ -x /opt/homebrew/bin/brew ]; then
        export PATH=/opt/homebrew/bin:$PATH
    elif [ -x /usr/local/bin/brew ]; then
        export PATH=/usr/local/bin:$PATH
    fi

    # Add all private keys for which we have public keys in the .ssh directory
    for file in $HOME/.ssh/*.pub; do
        [ -f "$file" ] && ssh-add -K "${file%.*}" >&/dev/null 2>&1
    done

    alias linux_dev='docker run --rm --mount source=mjc-dev,target=/home/mjc -it dev:mjc'
    ;;
Linux)
    # Linux specific configuration
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu - bat is installed as batcat
        command -v batcat >/dev/null 2>&1 && alias bat='batcat'
    fi

    # Standard Linux paths
    export PATH=/usr/local/bin:$PATH

    # npm global packages
    export PATH=~/.npm-global/bin:$PATH
    ;;
*)
    echo "Warning: Unknown OS ($(uname)) - some configurations may not work" >&2
    ;;
esac

source $HOME/.cargo/env

if [ -f $HOME/.credentials.sh ]; then
    source $HOME/.credentials.sh
fi

# Source local environment overrides
if [ -f ~/.config/env.local.sh ]; then
    source ~/.config/env.local.sh
fi

# Tmux configuration
export TMUX_TMPDIR="$HOME/.tmux/tmp"
mkdir -p "$TMUX_TMPDIR"

# Auto-start tmux (optional, commented by default)
# Uncomment the following lines to automatically start tmux when opening a terminal
# if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$SSH_TTY" ]; then
#     tmux attach -t default || tmux new -s default
# fi

export PATH=$PATH:$HOME/bin:$CARGO_HOME/bin:/usr/local/go/bin:$HOME/dev/aspengrove/scripts

alias ls='lsd'
alias ll="ls -lh"
alias lla="ls -la"

# Nord LS_COLORS - drives file-type/name colors for lsd (and ls/completion).
# Metadata columns (perms, size, date) come from ~/.config/lsd/colors.yaml.
# Frost cyan #88C0D0 dirs, green exec, magenta media, dim archives/etc.
export LS_COLORS="di=38;2;136;192;208:ln=38;2;143;188;187:so=38;2;180;142;173:pi=38;2;235;203;139:ex=38;2;163;190;140:bd=38;2;235;203;139:cd=38;2;235;203;139:su=38;2;191;97;106:sg=38;2;191;97;106:tw=38;2;136;192;208:ow=38;2;136;192;208:or=38;2;191;97;106:mi=38;2;191;97;106:*.tar=38;2;180;142;173:*.tgz=38;2;180;142;173:*.zip=38;2;180;142;173:*.gz=38;2;180;142;173:*.bz2=38;2;180;142;173:*.xz=38;2;180;142;173:*.zst=38;2;180;142;173:*.7z=38;2;180;142;173:*.rar=38;2;180;142;173:*.jpg=38;2;208;135;112:*.jpeg=38;2;208;135;112:*.png=38;2;208;135;112:*.gif=38;2;208;135;112:*.bmp=38;2;208;135;112:*.svg=38;2;208;135;112:*.webp=38;2;208;135;112:*.mp4=38;2;208;135;112:*.mkv=38;2;208;135;112:*.mov=38;2;208;135;112:*.mp3=38;2;208;135;112:*.flac=38;2;208;135;112:*.wav=38;2;208;135;112:*.pdf=38;2;191;97;106:*.md=38;2;236;239;244:*.txt=38;2;216;222;233"
alias vim=nvim
alias gupdate='git fetch origin && git rebase --autostash origin/$(git_main_branch)'
alias awsl='aws ecr get-login-password --profile development --region us-west-2 | docker login --username AWS --password-stdin 273119442198.dkr.ecr.us-west-2.amazonaws.com'
alias rg='rg --no-heading'
alias cdoc='rm -rf target/doc && cargo doc --no-deps --open'

export FZF_DEFAULT_COMMAND='rg --files'
export VISUAL=vim
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# Set up CDPATH for easier navigation (zsh/bash)
cdpath=($HOME/dev)
cdpath+=("${BIROOT:h}")

# Display system info on shell startup
command -v fastfetch >/dev/null 2>&1 && fastfetch

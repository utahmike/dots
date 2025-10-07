# Setup and add SSH Keys for use with home and work.
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
    eval $(ssh-agent)
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock

case $(uname) in
Darwin)
    # alias more=bat
    export PATH=/opt/homebrew/bin:$PATH
    # Add all private keys for which we have public keys in the .ssh directory.
    for file in $HOME/.ssh/*.pub; do ssh-add -K "${file%.*}" >&/dev/null; done

    alias linux_dev='docker run --rm --mount source=mjc-dev,target=/home/mjc -it dev:mjc'
    ;;
    # Linux)
    # alias more=batcat
    # ;;
esac

source $HOME/.cargo/env

if [ -f $HOME/.credentials.sh ]; then
    source $HOME/.credentials.sh
fi

export PATH=$PATH:$HOME/bin:$CARGO_HOME/bin:/usr/local/go/bin

alias ls='lsd'
alias ll="ls -lh"
alias lla="ls -la"
alias vim=nvim
alias gupdate='git fetch origin && git rebase --autostash origin/$(git_main_branch)'
alias awsl='aws ecr get-login-password --profile development --region us-west-2 | docker login --username AWS --password-stdin 273119442198.dkr.ecr.us-west-2.amazonaws.com'
alias rg='rg --no-heading'
alias cdoc='rm -rf target/doc && cargo doc --no-deps --open'

export FZF_DEFAULT_COMMAND='rg --files'
export VISUAL=vim
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# Bring in the zeropw environment.
export GOPATH=$HOME/dev/go
export OPTIMIZELY_SDK_KEY_DEVEL=UYioHayz4pqa2EXuLyRgP9

echo "Loading Beyond Identity Environment"
export ZEROPW=$GOPATH/src/gitlab.com/zeropw/zero
export PATH=$PATH:$GOPATH/bin
export PROTOC=$(which protoc)
export GOPROXY=https://packages.beyondidentity.com/GQ3JMgjVwTYQPLZw/go-packages/go/,https://proxy.golang.org,direct
export GONOSUMDB=go.beyondidentity.com/*

export ZPROOT=$ZEROPW # I prefer this form to the default.

source $ZEROPW/devel/apple/zpw-functions.sh

setopt auto_cd
cdpath=(
    $HOME/dev
    $HOME/dev/authn/authenticatorlibs
    $HOME/dev/authn/shared
    $ZPROOT/..
    $ZPROOT/client
    $ZPROOT/clients/core
    $ZPROOT/clients/core/kmc
    $ZPROOT/clients/core/kmc/beyond
)

# Temporary bindings for work.
export GPG=$ZPROOT/clients/gpg-bi/target/debug/gpg-bi
alias gpgs='$GPG --status-fd=2 -bsau'
function gpgv {
    $GPG --keyid-format=long --status-fd=1 $1 -
}

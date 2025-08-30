. "$HOME/.cargo/env"

case ${OSTYPE} in
    darwin*)
        # export PYENV_ROOT=/usr/local/var/pyenv
        export PYENV_ROOT=${HOME}/.pyenv
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        # if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
        # if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
        export RBENV_ROOT=/usr/local/var/rbenv
        # export NODENV_ROOT=/usr/local/var/nodenv
        export NODENV_ROOT=${HOME}/.nodenv
        export LSCOLORS=xefxcxdxbxegedabagacad
        ;;
    linux*)
        export PYENV_ROOT=${HOME}/.pyenv
        export RBENV_ROOT=${HOME}/.rbenv
        export NODENV_ROOT=${HOME}/.nodenv
        ;;
esac

if [ -d ${NODENV_ROOT} ]; then
    export PATH=${NODENV_ROOT}/bin:$PATH
    eval "$(nodenv init - zsh)"
fi

. "$HOME/.local/bin/env"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

. "$HOME/.cargo/env"

case ${OSTYPE} in
    darwin*)
        # export PYENV_ROOT=/usr/local/var/pyenv
        export PYENV_ROOT=${HOME}/.pyenv
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        # if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
        # if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
        export RBENV_ROOT=/usr/local/var/rbenv
        export LSCOLORS=xefxcxdxbxegedabagacad
        ;;
    linux*)
        export PYENV_ROOT=${HOME}/.pyenv
        export RBENV_ROOT=${HOME}/.rbenv

        ;;
esac


. "$HOME/.local/bin/env"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

alias claude-mem='${HOME}/.bun/bin/bun "${HOME}/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

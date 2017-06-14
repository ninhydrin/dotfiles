## zplug

if [[ -f ~/.zplug/init.zsh ]]; then
    #export ZPLUG_LOADFILE="$HOME/.zsh/zplug.zsh"
    source ~/.zplug/init.zsh
    #source ~/src/github.com/zplug/zplug/init.zsh
    zplug 'zsh-users/zsh-autosuggestions'
    zplug "b4b4r07/zsh-gomi", if:"which fzf"
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        else
            echo
        fi
    fi
    zplug load --verbose
fi

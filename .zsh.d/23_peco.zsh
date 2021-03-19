which peco > /dev/null
if [ $? = 0 -o -f $ZSH_VARIABLES/no_peco ]; then

else
    echo "not installed peco. install? [Y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            brew install peco ;;
        "N" | "No" )
            touch $ZSH_VARIABLES/no_peco ;;
    esac
fi
which peco > /dev/null
if [ $? = 0  ]; then
    function peco-select-history() {
        local tac
        if which tac > /dev/null; then
            tac="tac"
        else
            tac="tail -r"
        fi
        BUFFER=$(\history -n 1 | \
            eval $tac | \
            peco --query "$LBUFFER")
        CURSOR=$#BUFFER
        zle clear-screen
    }
    zle -N peco-select-history
    bindkey '^r' peco-select-history
fi

if [ ! command -v sheldon > /dev/null 2>&1 -a ! -f $ZSH_VARIABLES/no_sheldon ]; then
    echo "Sheldonがインストールされていません。Sheldonをインストールしますか？ [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            echo
            case ${OSTYPE} in
                darwin*)
                    cargo install sheldon
                ;;
                linux*)
                    cargo install sheldon
                ;;
            esac
            ;;
        "N" | "No" | "NO" )
            echo
            touch $ZSH_VARIABLES/no_sheldon ;;
        "n" | "no" )
            echo ;;
        * ) ;;
    esac
fi

if command -v sheldon > /dev/null 2>&1; then
    export SHELDON_CONFIG_DIR=$HOME/dotfiles/sheldon
    eval "$(sheldon source)"
fi

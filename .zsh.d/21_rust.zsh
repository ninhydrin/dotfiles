if [ ! -d $HOME/.cargo -a ! -f $ZSH_VARIABLES/no_rust ]; then
    echo "Rustがインストールされていません。Rustをインストールしますか？ [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            echo
            case ${OSTYPE} in
                darwin*)
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
                ;;
                linux*)
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
                ;;
            esac
            ;;
        "N" | "No" | "NO" )
            echo
            touch $ZSH_VARIABLES/no_rust ;;
        "n" | "no" )
            echo ;;
        * ) ;;
    esac
fi
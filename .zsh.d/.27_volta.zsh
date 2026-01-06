if [ ! command -v volta > /dev/null 2>&1 -a ! -f $ZSH_VARIABLES/no_volta ]; then
    echo "Voltaがインストールされていません。Voltaをインストールしますか？ [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            echo
            case ${OSTYPE} in
                darwin*)
                    curl https://get.volta.sh | bash
                ;;
                linux*)
                    curl https://get.volta.sh | bash
                ;;
            esac
            ;;
        "N" | "No" | "NO" )
            echo
            touch $ZSH_VARIABLES/no_volta ;;
        "n" | "no" )
            echo ;;
        * ) ;;
    esac
fi
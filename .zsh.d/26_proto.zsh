if [ ! command -v proto > /dev/null 2>&1 -a ! -f $ZSH_VARIABLES/no_proto ]; then
    echo "protoがインストールされていません。protoをインストールしますか？ [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            echo
            case ${OSTYPE} in
                darwin*)
                    bash <(curl -fsSL https://moonrepo.dev/install/proto.sh)
                ;;
                linux*)
                    bash <(curl -fsSL https://moonrepo.dev/install/proto.sh)
                ;;
            esac
            ;;
        "N" | "No" | "NO" )
            echo
            touch $ZSH_VARIABLES/no_proto ;;
        "n" | "no" )
            echo ;;
        * ) ;;
    esac
fi

# proto shell activation
# if command -v proto >/dev/null 2>&1; then
#   eval "$(proto activate bash)"
# fi
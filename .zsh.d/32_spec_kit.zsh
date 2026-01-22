# Spec Kit

# インストール方法
# uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

if ! command -v uv &> /dev/null; then
    echo "警告: uvがインストールされていないため、Spec Kitをインストールできません。"
    echo "uvのインストール: https://docs.astral.sh/uv/getting-started/installation/"
elif ! command -v specify &> /dev/null && [ ! -f $ZSH_VARIABLES/no_spec_kit ]; then
    echo "Spec Kit (specify) がインストールされていません。インストールしますか？ [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            echo
            uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
            ;;
        "N" | "No" | "NO" )
            echo
            touch $ZSH_VARIABLES/no_spec_kit ;;
        "n" | "no" )
            echo ;;
        * ) ;;
    esac
fi

alias spec_init="specify init . --ai claude --script sh"
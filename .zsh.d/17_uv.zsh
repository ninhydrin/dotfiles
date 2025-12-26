
if [ ! command -v uv > /dev/null 2>&1 -a ! -f $ZSH_VARIABLES/no_uv ]; then
    echo "uvがインストールされていません。uvをインストールしますか？ [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            echo
            case ${OSTYPE} in
                darwin*)
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                ;;
                linux*)
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                ;;
            esac
            ;;
        "N" | "No" | "NO" )
            echo
            touch $ZSH_VARIABLES/no_uv ;;
        "n" | "no" )
            echo ;;
        * ) ;;
    esac
fi

venv() {
    if [ -d ".venv" ]; then
        source .venv/bin/activate
        echo "✨ .venv環境をアクティベートしたよ！まじ神！✨"
    else
        echo "💔 あれ？このディレクトリに.venvフォルダがないよ～まじ残念！"
    fi
}
venv

alias uva="source .venv/bin/activate"
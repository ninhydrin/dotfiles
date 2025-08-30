
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
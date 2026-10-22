#!/usr/bin/env bash
# yazi: 右の tmux pane でファイルを開く
# Usage: open-in-right-pane.sh <file_path>

FILE="$1"

if [ -z "$FILE" ]; then
  exit 1
fi

# tmux の右ペインにコマンドを送信
# EDITOR が未設定なら nvim をデフォルトにする
EDITOR="${EDITOR:-nvim}"

tmux send-keys -t right "$EDITOR '$FILE'" Enter

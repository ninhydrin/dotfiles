# tcode: tmuxで3ペインの開発環境を一発起動
# レイアウト:
#   左上: yazi (ファイルマネージャー)
#   左下: keifu (Gitコミット履歴)
#   右:   Claude Code
#
# Usage: tcode [project_dir]
function tcode() {
    local project_dir="${1:-.}"
    project_dir="$(cd "$project_dir" 2>/dev/null && pwd)" || {
        echo "Error: ディレクトリが見つかりません: $1" >&2
        return 1
    }

    local session_name="tcode-$(basename "$project_dir")"

    # 既存セッションがあればアタッチ
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach-session -t "$session_name"
        return
    fi

    # 新規セッション作成（右ペイン: Claude Code）
    tmux new-session -d -s "$session_name" -c "$project_dir" -x "$(tput cols)" -y "$(tput lines)"

    # 左右分割（左40% / 右60%）
    tmux split-window -h -t "$session_name" -c "$project_dir" -l '60%'

    # 左ペインを上下分割（上60% / 下40%）
    tmux split-window -v -t "$session_name:0.0" -c "$project_dir" -l '40%'

    # 各ペインでコマンド実行
    # 左上(pane 0): yazi
    tmux send-keys -t "$session_name:0.0" "yazi '$project_dir'" Enter

    # 左下(pane 1): keifu
    tmux send-keys -t "$session_name:0.1" "keifu" Enter

    # 右(pane 2): Claude Code
    tmux send-keys -t "$session_name:0.2" "claude" Enter

    # 右ペイン（Claude Code）にフォーカス
    tmux select-pane -t "$session_name:0.2"

    # アタッチ
    tmux attach-session -t "$session_name"
}

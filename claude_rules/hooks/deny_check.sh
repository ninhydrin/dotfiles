#!/bin/bash

# Bashコマンドセキュリティチェックスクリプト
# Claude Code PreToolUseフックから呼び出される

# 標準入力からJSONを読み取る
JSON_INPUT=$(cat)

# 基本情報の抽出
HOOK_EVENT_NAME=$(echo "$JSON_INPUT" | jq -r '.hook_event_name // "Unknown"')
TOOL_NAME=$(echo "$JSON_INPUT" | jq -r '.tool_name // empty')

# PreToolUseイベントでBashツールの場合のみチェック
if [ "$HOOK_EVENT_NAME" != "PreToolUse" ] || [ "$TOOL_NAME" != "Bash" ]; then
  exit 0  # チェック対象外
fi

# コマンドを抽出
COMMAND=$(echo "$JSON_INPUT" | jq -r '.tool_input.command // ""')

# 危険なコマンドパターンのリスト
DENY_PATTERNS=(
  "sudo *"
  "rm -rf /*"
  "rm -rf ~/*"
  "chmod 777 *"
  "git config --global *"
  "brew install *"
  "brew uninstall *"
  "npm install -g *"
  "pip install *"
  "> /dev/sd*"
  "dd if=*"
  "mkfs.*"
  "curl * | bash"
  "curl * | sh"
  "wget * -O - | bash"
  "wget * -O - | sh"
  "eval *"
  "exec *"
  "source /dev/stdin"
  "bash -c *curl*"
  "sh -c *wget*"
)

# コマンドを分割してチェック（セミコロン、&&、|| で分割）
# IFSを一時的に変更してコマンドを分割
IFS=$'\n'
CMD_PARTS=($(echo "$COMMAND" | sed 's/;/\n/g' | sed 's/&&/\n/g' | sed 's/||/\n/g'))
unset IFS

for cmd_part in "${CMD_PARTS[@]}"; do
  # 前後の空白を削除
  cmd_part=$(echo "$cmd_part" | xargs)

  # 空の場合はスキップ
  [ -z "$cmd_part" ] && continue

  # 各パターンとマッチするかチェック
  for pattern in "${DENY_PATTERNS[@]}"; do
    # globパターンを正規表現に変換
    # * -> .* に変換、? -> . に変換
    regex_pattern=$(echo "$pattern" | sed 's/\*/.*/g' | sed 's/\?/./g')

    if echo "$cmd_part" | grep -qE "^${regex_pattern}"; then
      echo "⚠️  危険なコマンドが検出されました: $cmd_part" >&2
      echo "パターン: $pattern" >&2
      echo "" >&2
      echo "このコマンドは安全性の理由により拒否されました。" >&2
      echo "意図的に実行したい場合は、ENABLE_BASH_SECURITY_CHECK=false を .env に設定してください。" >&2
      exit 2  # 拒否を示す終了コード
    fi
  done
done

# チェック通過
exit 0

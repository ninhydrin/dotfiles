#!/bin/bash

# AI運用5原則 Hook
# 標準入力からJSONを読み取る
JSON_INPUT=$(cat)

SCRIPT_DIR=$(dirname "$0")
CONFIG_FILE="${SCRIPT_DIR}/.env"

# `claude_rules/hooks/.env` があれば読み込む（秘密はここに置く）
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

# 環境変数による通知のグローバル制御（.envで設定可能、デフォルトは全て有効）
GLOBAL_ENABLE_SLACK_NOTIFICATION="${GLOBAL_ENABLE_SLACK_NOTIFICATION:-true}"
GLOBAL_ENABLE_APPLESCRIPT_NOTIFICATION="${GLOBAL_ENABLE_APPLESCRIPT_NOTIFICATION:-true}"
GLOBAL_ENABLE_SOUND_NOTIFICATION="${GLOBAL_ENABLE_SOUND_NOTIFICATION:-true}"

# デバッグログの有効/無効（デフォルトは無効）
ENABLE_DEBUG_LOG="${ENABLE_DEBUG_LOG:-false}"
DEBUG_LOG_FILE="${DEBUG_LOG_FILE:-~/.claude/hook_debug.log}"

# Bashコマンドセキュリティチェックの有効/無効（デフォルトは有効）
ENABLE_BASH_SECURITY_CHECK="${ENABLE_BASH_SECURITY_CHECK:-true}"

# 音声通知のデフォルト設定
SOUND_DIR="${SOUND_DIR:-~/dataset/notifications}"
SOUND_VOLUME="${SOUND_VOLUME:-0.5}"

# 通知の有効/無効を制御するフラグ（デフォルトは全て無効、後で条件により設定）
ENABLE_SLACK_NOTIFICATION=false
ENABLE_APPLESCRIPT_NOTIFICATION=false
ENABLE_SOUND_NOTIFICATION=false

# Slack通知が有効な場合のみ、SLACK_API_TOKENとCHANNEL_IDをチェック
if [ "$GLOBAL_ENABLE_SLACK_NOTIFICATION" = "true" ]; then
  if [ -z "${SLACK_API_TOKEN:-}" ] || [ -z "${CHANNEL_ID:-}" ]; then
    echo "エラー: SLACK_API_TOKEN または CHANNEL_ID が設定されていません" >&2
    echo "対処: ${CONFIG_FILE} に SLACK_API_TOKEN と CHANNEL_ID を設定してください" >&2
    exit 1
  fi
fi

# デフォルトのメッセージ
DEFAULT_MESSAGE="Claude Code の作業が完了しました"
MESSAGE="${1:-$DEFAULT_MESSAGE}"

# タイムスタンプ
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')



# 基本情報の抽出
HOOK_EVENT_NAME=$(echo "$JSON_INPUT" | jq -r '.hook_event_name // "Unknown"')
SESSION_ID=$(echo "$JSON_INPUT" | jq -r '.session_id // "N/A"')
TOOL_NAME=$(echo "$JSON_INPUT" | jq -r '.tool_name // empty')

# デバッグログの出力（有効な場合のみ）
if [ "$ENABLE_DEBUG_LOG" = "true" ]; then
  echo "$HOOK_EVENT_NAME: $JSON_INPUT" >> "$DEBUG_LOG_FILE"
  echo "--------" >> "$DEBUG_LOG_FILE"
fi


case "$HOOK_EVENT_NAME" in
    "PreToolUse")
        # Bashコマンドのセキュリティチェック（別スクリプトを呼び出し）
        if [ "$ENABLE_BASH_SECURITY_CHECK" = "true" ] && [ "$TOOL_NAME" = "Bash" ]; then
          # deny_check.shを呼び出してセキュリティチェック
          echo "$JSON_INPUT" | "${SCRIPT_DIR}/deny_check.sh"
          DENY_CHECK_EXIT_CODE=$?

          # 拒否された場合（終了コード2）は、このスクリプトも終了
          if [ $DENY_CHECK_EXIT_CODE -eq 2 ]; then
            exit 2
          fi
        fi

        # PreToolUseイベントの場合、デフォルトで通知を有効化
        ENABLE_SLACK_NOTIFICATION=true
        ENABLE_APPLESCRIPT_NOTIFICATION=true
        ENABLE_SOUND_NOTIFICATION=false

        case "$TOOL_NAME" in
            "Write")
                ICON=":pencil2:"
                TITLE="ファイルを作成します"
                FILE_PATH=$(echo "$JSON_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // "不明"')
                DETAILS="ファイル: \`${FILE_PATH}\`"
                SAFE_DETAILS="ファイル: ${FILE_PATH}"
                ;;
            "Edit"|"MultiEdit")
                ICON=":memo:"
                TITLE="ファイルを編集します"
                FILE_PATH=$(echo "$JSON_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // "不明"')
                if [ "$TOOL_NAME" = "MultiEdit" ]; then
                    EDIT_COUNT=$(echo "$JSON_INPUT" | jq -r '.tool_input.edits | length // 0')
                    DETAILS="ファイル: \`${FILE_PATH}\`\n編集箇所: ${EDIT_COUNT}件"
                    SAFE_DETAILS="ファイル: ${FILE_PATH}, 編集箇所: ${EDIT_COUNT}件"
                else
                    DETAILS="ファイル: \`${FILE_PATH}\`"
                    SAFE_DETAILS="ファイル: ${FILE_PATH}"
                fi
                ;;
            "Bash")
                ICON=":zap:"
                TITLE="コマンドを実行します"
                COMMAND=$(echo "$JSON_INPUT" | jq -r '.tool_input.command // "不明"')
                # SUCCESS=$(echo "$JSON_INPUT" | jq -r '.tool_response.success // true')
                # STATUS=$([ "$SUCCESS" = "true" ] && echo "成功" || echo "失敗")
                # コマンドが長い場合は省略
                if [ ${#COMMAND} -gt 100 ]; then
                    COMMAND_DISPLAY="${COMMAND:0:97}..."
                else
                    COMMAND_DISPLAY="$COMMAND"
                fi
                DETAILS="コマンド: \`${COMMAND_DISPLAY}\`"
                # AppleScript用は危険文字を除去して短縮
                SAFE_COMMAND=$(echo "${COMMAND_DISPLAY}" | tr -d '`"\\' | head -c 50)
                SAFE_DETAILS="コマンド実行: ${SAFE_COMMAND}"
                ;;
            "Read"|"NotebookRead")
                ICON=":book:"
                TITLE="ファイルを読み取ります"
                FILE_PATH=$(echo "$JSON_INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // "不明"')
                DETAILS="ファイル: \`${FILE_PATH}\`"
                ;;
            "TodoWrite")
                ICON=":white_check_mark:"
                TITLE="TODOリストを更新します"
                TODO_COUNT=$(echo "$JSON_INPUT" | jq -r '.tool_input.todos | length // 0')
                DETAILS="タスク数: ${TODO_COUNT}件"
                ;;
            "Grep"|"Glob")
                ICON=":mag:"
                TITLE="ファイル検索を実行します"
                PATTERN=$(echo "$JSON_INPUT" | jq -r '.tool_input.pattern // "不明"')
                DETAILS="パターン: \`${PATTERN}\`"
                ;;
            "LS")
                ICON=":file_folder:"
                TITLE="ディレクトリを一覧表示します"
                PATH=$(echo "$JSON_INPUT" | jq -r '.tool_input.path // "不明"')
                DETAILS="パス: \`${PATH}\`"
                ;;
            "WebFetch"|"WebSearch")
                ICON=":globe_with_meridians:"
                TITLE="Web情報を取得します"
                if [ "$TOOL_NAME" = "WebFetch" ]; then
                    URL=$(echo "$JSON_INPUT" | jq -r '.tool_input.url // "不明"')
                    DETAILS="URL: ${URL}"
                else
                    QUERY=$(echo "$JSON_INPUT" | jq -r '.tool_input.query // "不明"')
                    DETAILS="検索: ${QUERY}"
                fi
                ;;
            *)
                ICON=":gear:"
                TITLE="${TOOL_NAME}を実行しました"
                DETAILS="ツール: ${TOOL_NAME}"
                ;;
        esac
        ;;
    "PostToolUse")
        # PostToolUseイベントの場合（ツール実行完了後）
        # デフォルトは通知無効
        exit 0
        ;;
    "UserPromptSubmit")
        # UserPromptSubmitイベントの場合（ユーザーがプロンプトを送信）
        # デフォルトは通知無効
        exit 0
        ;;
    "Stop")
        # Stopイベントの場合（メインエージェント完了）
        ENABLE_SLACK_NOTIFICATION=true
        ENABLE_APPLESCRIPT_NOTIFICATION=true
        ENABLE_SOUND_NOTIFICATION=true
        SOUND_DIR=~/dataset/claude/stop  # フック毎の音声を設定する場合
        ICON=":checkered_flag:"
        TITLE="セッションが完了しました"
        DETAILS="セッションID: \`${SESSION_ID}\`"
        ;;
    "SubagentStop")
        # SubagentStopイベントの場合（サブエージェント完了）
        # ENABLE_SLACK_NOTIFICATION=true
        # ENABLE_APPLESCRIPT_NOTIFICATION=true
        # ENABLE_SOUND_NOTIFICATION=true
        ICON=":white_check_mark:"
        TITLE="サブエージェントが完了しました"
        SUBAGENT_ID=$(echo "$JSON_INPUT" | jq -r '.subagent_id // "N/A"')
        DETAILS="サブエージェントID: \`${SUBAGENT_ID}\`"
        ;;
    "PreCompact")
        # PreCompactイベントの場合（コンパクト操作前）
        ENABLE_SLACK_NOTIFICATION=true
        ENABLE_APPLESCRIPT_NOTIFICATION=true
        ENABLE_SOUND_NOTIFICATION=false
        COMPACT_TYPE=$(echo "$JSON_INPUT" | jq -r '.matcher // "Unknown"')
        ICON=":package:"
        TITLE="コンパクト操作を実行します"
        if [ "$COMPACT_TYPE" = "manual" ]; then
            DETAILS="種類: 手動コンパクト"
        elif [ "$COMPACT_TYPE" = "auto" ]; then
            DETAILS="種類: 自動コンパクト（コンテキスト満杯）"
        else
            DETAILS="種類: ${COMPACT_TYPE}"
        fi
        ;;
    "SessionStart")
        # SessionStartイベントの場合（セッション開始）
        ENABLE_SLACK_NOTIFICATION=true
        ENABLE_APPLESCRIPT_NOTIFICATION=true
        # ENABLE_SOUND_NOTIFICATION=true
        START_TYPE=$(echo "$JSON_INPUT" | jq -r '.source // "Unknown"')
        ICON=":rocket:"
        TITLE="セッションを開始します"
        case "$START_TYPE" in
            "startup")
                DETAILS="種類: スタートアップ"
                ;;
            "resume")
                DETAILS="種類: セッション再開"
                ;;
            "clear")
                DETAILS="種類: セッションクリア"
                ;;
            "compact")
                DETAILS="種類: コンパクト後の再開"
                ;;
            *)
                DETAILS="種類: ${START_TYPE}"
                ;;
        esac
        ;;
    "SessionEnd")
        # SessionEndイベントの場合（セッション終了）
        ENABLE_SLACK_NOTIFICATION=true
        ENABLE_APPLESCRIPT_NOTIFICATION=true
        ENABLE_SOUND_NOTIFICATION=true
        END_REASON=$(echo "$JSON_INPUT" | jq -r '.reason // "Unknown"')
        ICON=":stop_sign:"
        TITLE="セッションが終了しました"
        SOUND_DIR=~/dataset/claude/end
        case "$END_REASON" in
            "clear")
                DETAILS="理由: セッションクリア"
                ;;
            "logout")
                DETAILS="理由: ログアウト"
                ;;
            "prompt_input_exit")
                DETAILS="理由: プロンプト入力中に終了"
                ;;
            "other")
                DETAILS="理由: その他"
                ;;
            *)
                DETAILS="理由: ${END_REASON}"
                ;;
        esac
        ;;
    "Notification")
        # Notificationイベントの場合（通知送信時）
        NOTIFICATION_TYPE=$(echo "$JSON_INPUT" | jq -r '.notification_type // "Unknown"')
        case "$NOTIFICATION_TYPE" in
            "idle_prompt")
                # idle_promptは通知無効
                exit 0
                ;;
            *)
                # その他の通知は有効
                ENABLE_SLACK_NOTIFICATION=true
                ENABLE_APPLESCRIPT_NOTIFICATION=true
                ENABLE_SOUND_NOTIFICATION=true
                # SOUND_DIR=~/dataset/notifications/notification  # フック毎の音声を設定する場合
                ICON=":loudspeaker:"
                TITLE="通知します"
                NOTIFICATION_MESSAGE=$(echo "$JSON_INPUT" | jq -r '.message // "no message"')
                DETAILS="@ninhydrin: ${NOTIFICATION_MESSAGE}"
                ;;
        esac
        ;;
    *)
        # その他のイベントは通知無効
        exit 0
        ;;
esac

# Slack通知の送信（スクリプト内フラグとグローバル環境変数の両方がtrueの場合のみ）
if [ "$ENABLE_SLACK_NOTIFICATION" = "true" ] && [ "$GLOBAL_ENABLE_SLACK_NOTIFICATION" = "true" ]; then
    RESPONSE=$(curl -s -X POST https://slack.com/api/chat.postMessage \
        -H "Authorization: Bearer ${SLACK_API_TOKEN}" \
        -H 'Content-Type: application/json' \
        -d @- <<EOF
{
    "username": "Claude Code",
    "channel": "${CHANNEL_ID}",
    "icon_emoji": ":robot_face:",
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "${ICON} *${TITLE}*"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "${DETAILS}"
            }
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": "時刻: ${TIMESTAMP} | セッション: \`${SESSION_ID:0:8}...\`"
                }
            ]
        }
    ]
}
EOF
)
fi
# AppleScript通知（スクリプト内フラグとグローバル環境変数の両方がtrueの場合のみ）
if [ "$ENABLE_APPLESCRIPT_NOTIFICATION" = "true" ] && [ "$GLOBAL_ENABLE_APPLESCRIPT_NOTIFICATION" = "true" ]; then
    # SAFE_DETAILSが設定されていない場合のみデフォルト処理
    if [ -z "${SAFE_DETAILS}" ]; then
        SAFE_DETAILS=$(echo "${DETAILS}" | tr -d '`"\\' | head -c 100)
    fi
    SAFE_TITLE=$(echo "${TITLE}" | tr -d '`"\\')

    # AppleScriptで通知を表示（エラーで止まらないように）
    if ! osascript <<EOF 2>/dev/null
display notification "${SAFE_DETAILS}" with title "Claude Code" subtitle "${SAFE_TITLE}" sound name "Sosumi"
EOF
    then
        # AppleScriptが失敗した場合はログに記録
        echo "AppleScript notification failed: TITLE='${SAFE_TITLE}' DETAILS='${SAFE_DETAILS}'" >&2
    fi
fi

# ランダムな通知音を再生（スクリプト内フラグとグローバル環境変数の両方がtrueの場合のみ）
if [ "$ENABLE_SOUND_NOTIFICATION" = "true" ] && [ "$GLOBAL_ENABLE_SOUND_NOTIFICATION" = "true" ]; then
    sounds=(${SOUND_DIR}/*.wav)
    if [ ${#sounds[@]} -gt 0 ] && [ -f "${sounds[0]}" ]; then
        afplay "${sounds[RANDOM % ${#sounds[@]}]}" -v "$SOUND_VOLUME"
    fi
fi

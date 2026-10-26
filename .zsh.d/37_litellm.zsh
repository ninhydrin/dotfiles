# lclaude: ローカルの LiteLLM 経由で Claude Code を起動する。
# Usage: lclaude / lclaude --model gpt-6-astra / lclaude --resume
# 接続先 127.0.0.1:4000。既定は Sol。再開時も --model でモデルを指定できる。
# LITELLM_MASTER_KEY がなければ、4000 番ポートを公開する Compose の
# litellm サービスからキーを受け取る。キーはファイルに保存しない。
function lclaude() (
  emulate -L zsh
  unsetopt XTRACE VERBOSE

  local litellm_key="${LITELLM_MASTER_KEY:-}"
  if [[ -z "$litellm_key" ]]; then
    local container_id
    container_id=$(command docker ps \
      --filter label=com.docker.compose.service=litellm \
      --filter publish=4000 --format '{{.ID}}') || return 1
    if [[ -z "$container_id" || "$container_id" == *$'\n'* ]]; then
      print -u2 'lclaude: 起動中の LiteLLM を1つに特定できません。Docker と LiteLLM の起動を確認するか、LITELLM_MASTER_KEY を設定してください。'
      return 1
    fi
    litellm_key=$(command docker exec "$container_id" sh -c \
      'printf "%s" "$LITELLM_MASTER_KEY"') || return 1
    if [[ -z "$litellm_key" ]]; then
      print -u2 'lclaude: LiteLLM の LITELLM_MASTER_KEY が空です。'
      return 1
    fi
  fi

  # この起動だけに適用し、通常の Claude Code の設定を維持する。
  unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN
  unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX CLAUDE_CODE_USE_FOUNDRY
  export ANTHROPIC_BASE_URL='http://127.0.0.1:4000'
  export ANTHROPIC_AUTH_TOKEN="$litellm_key"
  unset ANTHROPIC_MODEL CLAUDE_CODE_SUBAGENT_MODEL
  export ANTHROPIC_DEFAULT_FABLE_MODEL=gpt-6-astra
  export ANTHROPIC_DEFAULT_FABLE_MODEL_NAME='GPT-6 Astra'
  export ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
  export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME='GPT-6 Astra'
  export ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-6.1-sol
  export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME='GPT-6.1 Sol'
  export ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-6-luna
  export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME='GPT-6 Luna'
  # auto モードの安全判定は Claude Code から Sol に依頼する。
  # ChatGPT 経由で使えないサーバー側判定を要求せず、従来方式を維持する。
  export CLAUDE_CODE_AUTO_MODE_SERVER=0
  export CLAUDE_CODE_AUTO_MODE_MODEL=gpt-6.1-sol
  # GPT のモデルは再開時に自動復元されないため、既定を Sol にそろえる。
  # ユーザー設定の Claude 用モデル一覧も、この起動だけ GPT 用に切り替える。
  command claude --settings \
    '{"model":"gpt-6.1-sol","availableModels":["gpt-6.1-sol","gpt-6-astra","gpt-6-luna","openai"]}' \
    "$@"
)

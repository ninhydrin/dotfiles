export CLAUDE_CODE_NO_FLICKER=1
alias dclaude='IS_SANDBOX=1 claude --dangerously-skip-permissions'
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-5-5[1m]"
export PATH="${HOME}/global_commands/.venv/bin:$PATH"
export HEADROOM_TELEMETRY=off

# lclaude: ローカルの LiteLLM 経由で Claude Code を起動する。
# Usage: lclaude / lclaude --model gpt-6-astra / lclaude --resume
# キーは環境変数、ローカル設定、Compose の順で取得し、保存しない。
# 設定パスは LITELLM_CONFIG_FILE で変更可能（既定: ~/litellm/config.yaml）。
function lclaude() (
  emulate -L zsh
  unsetopt XTRACE VERBOSE

  local litellm_key="${LITELLM_MASTER_KEY:-}"
  local litellm_config="${LITELLM_CONFIG_FILE:-${HOME}/litellm/config.yaml}"
  if [[ -z "$litellm_key" && -r "$litellm_config" ]]; then
    # YAML の構文エラーにもキーが含まれ得るため、例外本文は表示しない。
    litellm_key=$(command /usr/bin/python3 -I -c '
import sys
try:
    import yaml
    with open(sys.argv[1], encoding="utf-8") as config_file:
        config = yaml.safe_load(config_file)
    key = config["general_settings"]["master_key"]
    if not isinstance(key, str) or not key or key.startswith("os.environ/"):
        raise ValueError()
    if any(char in key for char in "\r\n\x00"):
        raise ValueError()
except Exception:
    print("lclaude: 設定からキーを取得できません。YAML設定とPyYAMLを確認するか、LITELLM_MASTER_KEYを設定してください。", file=sys.stderr)
    sys.exit(1)
sys.stdout.write(key)
' "$litellm_config") || return 1
  fi

  if [[ -z "$litellm_key" ]]; then
    local container_id
    container_id=$(command docker ps \
      --filter label=com.docker.compose.service=litellm \
      --filter publish=4000 --format '{{.ID}}') || return 1
    if [[ -z "$container_id" || "$container_id" == *$'\n'* ]]; then
      print -u2 'lclaude: 起動中のLiteLLMを1つに特定できません。LITELLM_CONFIG_FILEまたはLITELLM_MASTER_KEYを設定してください。'
      return 1
    fi
    litellm_key=$(command docker exec "$container_id" sh -c \
      'printf "%s" "$LITELLM_MASTER_KEY"') || return 1
  fi
  if [[ -z "$litellm_key" || "$litellm_key" == *$'\n'* || "$litellm_key" == *$'\r'* ]]; then
    print -u2 'lclaude: LiteLLMのキーが空、または不正な形式です。'
    return 1
  fi

  # この起動だけに適用。サブエージェントのモデル別の役割分担を保つ。
  unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN
  unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX CLAUDE_CODE_USE_FOUNDRY
  unset CLAUDE_CODE_USE_ANTHROPIC_AWS
  export ANTHROPIC_BASE_URL='http://127.0.0.1:4000'
  export ANTHROPIC_AUTH_TOKEN="$litellm_key"
  unset ANTHROPIC_MODEL CLAUDE_CODE_SUBAGENT_MODEL CLAUDE_CODE_SUBAGENT_MODEL_FORCE
  export ANTHROPIC_DEFAULT_FABLE_MODEL=gpt-6-astra
  export ANTHROPIC_DEFAULT_FABLE_MODEL_NAME='GPT-6 Astra'
  export ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
  export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME='GPT-6 Astra'
  export ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-6.1-sol
  export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME='GPT-6.1 Sol'
  export ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-6-luna
  export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME='GPT-6 Luna'
  # autoモードはClaude Code側からSolへ安全判定を依頼する。
  export CLAUDE_CODE_AUTO_MODE_SERVER=0
  export CLAUDE_CODE_AUTO_MODE_MODEL=gpt-6.1-sol
  command claude --settings \
    '{"model":"gpt-6.1-sol","availableModels":["gpt-6.1-sol","gpt-6-astra","gpt-6-luna"],"remoteControlAtStartup":false}' \
    "$@"
)

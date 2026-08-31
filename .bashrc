. "$HOME/.cargo/env"

case ${OSTYPE} in
    darwin*)
        # export PYENV_ROOT=/usr/local/var/pyenv
        export PYENV_ROOT=${HOME}/.pyenv
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        # if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
        # if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
        export RBENV_ROOT=/usr/local/var/rbenv
        export LSCOLORS=xefxcxdxbxegedabagacad
        ;;
    linux*)
        export PYENV_ROOT=${HOME}/.pyenv
        export RBENV_ROOT=${HOME}/.rbenv

        ;;
esac


. "$HOME/.local/bin/env"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

alias claude-mem='${HOME}/.bun/bin/bun "${HOME}/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

# pnpm（.zshrcと同じ設定。グローバルbinは$PNPM_HOME/bin、旧shimが直下に残るため両方）
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# npm の依存変更系サブコマンドを封じて pnpm に寄せる（.zshrcと同じ方針）。
# 参照系(view/whoami/publish 等)は素通し。緊急時は `command npm ...` で回避可能。
npm() {
  case "$1" in
    install|i|in|ins|isnt|add|ci|update|up|upgrade|uninstall|un|unlink|remove|rm|r|dedupe|ddp|link|ln)
      echo "🚫 npm $1 は無効化されています。pnpm を使ってください:" >&2
      echo "   pnpm $*" >&2
      echo "   (どうしても npm が必要なら: command npm $*)" >&2
      return 1
      ;;
  esac
  command npm "$@"
}

# npx の代替は pnpm dlx
npx() {
  echo "🚫 npx は無効化されています。pnpm dlx を使ってください:" >&2
  echo "   pnpm dlx $*" >&2
  echo "   (どうしても npx が必要なら: command npx $*)" >&2
  return 1
}

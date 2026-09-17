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

# pnpm（.zshrcと同じ設定。グローバルbinは$PNPM_HOME/bin、旧shimが直下に残るため両方）
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# npm/npx は全面禁止（.zshrcと同じ方針）。パッケージ管理は pnpm に一本化する。
npm() {
  echo "🚫 npm は禁止です。pnpm を使ってください:" >&2
  echo "   pnpm $*" >&2
  return 1
}

# npx の代替は pnpm dlx
npx() {
  echo "🚫 npx は禁止です。pnpm dlx を使ってください:" >&2
  echo "   pnpm dlx $*" >&2
  return 1
}

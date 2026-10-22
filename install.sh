#!/usr/bin/env bash
# dotfiles をホームディレクトリにリンクする
# DRY_RUN=1 を付けると、変更するコマンドを実行せずに表示だけする
set -euo pipefail

DOTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCLUSIONS=(.DS_Store .git .gitmodules .travis.yml .Trash .config)

# ランタイムファイルが同じディレクトリに置かれるため、ディレクトリごとではなく
# 指定したファイルだけを ~/.config/<dir>/ にリンクするもの
# - herdr: ログ・ソケット等
# - opencode: service.json・node_modules 等
# - uv: インストール記録（uv-receipt.json）
# （macOS 標準の bash 3.2 は連想配列が使えないため case で書く）
config_file_only() {
  case "$1" in
    herdr) echo config.toml ;;
    opencode) echo cli.json ;;
    uv) echo uv.toml ;;
  esac
}

run() {
  if [ "${DRY_RUN:-}" = 1 ]; then
    echo "$*"
  else
    "$@"
  fi
}

# ホームにリンクするリポジトリ直下のファイル（.config は deploy 内で個別に扱う）
dotfiles() {
  local f ex
  shopt -s nullglob
  for f in "$DOTPATH"/.??* "$DOTPATH"/bin; do
    f="${f##*/}"
    for ex in "${EXCLUSIONS[@]}"; do
      [ "$f" = "$ex" ] && continue 2
    done
    echo "$f"
  done
}

cmd_list() {
  dotfiles
}

cmd_deploy() {
  echo '==> Start to deploy dotfiles to home directory.'
  local f dir name file
  while read -r f; do
    run ln -sfnv "$DOTPATH/$f" "$HOME/$f"
  done < <(dotfiles)
  run mkdir -p "$HOME/.proto"
  run ln -sfnv "$DOTPATH/.prototools" "$HOME/.proto/.prototools"
  run ln -sfnv "$DOTPATH/my_env_files" "$HOME/.env.d"

  # .config は丸ごとsymlinkせず、サブディレクトリ単位にリンクする
  # （丸ごとsymlinkすると ~/.config が無い新規マシンで個別リンクが自己参照になり ln が失敗する）
  if [ -L "$HOME/.config" ]; then
    echo '==> Replacing legacy ~/.config symlink with a real directory'
    run rm "$HOME/.config"
  fi
  echo '==> Deploying .config directories...'
  run mkdir -p "$HOME/.config"
  for dir in "$DOTPATH"/.config/*/; do
    name="$(basename "$dir")"
    file="$(config_file_only "$name")"
    if [ -n "$file" ]; then
      run mkdir -p "$HOME/.config/$name"
      run ln -sfnv "$DOTPATH/.config/$name/$file" "$HOME/.config/$name/$file"
    else
      run ln -sfnv "$DOTPATH/.config/$name" "$HOME/.config/$name"
    fi
  done
}

cmd_update() {
  run git -C "$DOTPATH" pull origin main
}

cmd_clean() {
  echo 'Remove dot files in your home directory...'
  local f
  while read -r f; do
    run rm -vrf "${HOME:?}/$f"
  done < <(dotfiles)
  run rm -rf "$DOTPATH"
}

cmd_help() {
  cat <<'EOF'
./install.sh list      #=> Show dot files in this repo
./install.sh deploy    #=> Create symlink to home directory
./install.sh update    #=> Fetch changes for this repo
./install.sh install   #=> Run update, deploy
./install.sh clean     #=> Remove the dot files and this repo
EOF
}

case "${1:-help}" in
  list) cmd_list ;;
  deploy) cmd_deploy ;;
  update) cmd_update ;;
  clean) cmd_clean ;;
  install)
    cmd_update
    cmd_deploy
    exec "$SHELL"
    ;;
  help) cmd_help ;;
  *)
    cmd_help >&2
    exit 1
    ;;
esac

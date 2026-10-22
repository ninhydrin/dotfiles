#!/usr/bin/env bash
# dotfiles をホームディレクトリにリンクする
# DRY_RUN=1 を付けると、変更するコマンドを実行せずに表示だけする
set -euo pipefail

DOTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCLUSIONS=(.gitmodules .config .zsh)
# git 管理外だが、存在すればリンクするマシン固有・私的なファイル
LOCAL_FILES=(.gitconfig.local .gitconfig-private .zsh_history)

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

# 既に実ファイル・実ディレクトリがある場所は上書きせず飛ばす
# （ln -sfn は実ディレクトリの中にリンクを作ってしまうため）
link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "==> Skip: $dst is not a symlink" >&2
    return 0
  fi
  run ln -sfnv "$src" "$dst"
}

# ホームにリンクするリポジトリ直下のファイル（.config は deploy 内で個別に扱う）
# 作業用の未追跡ファイルを巻き込まないよう、git 管理下のものと LOCAL_FILES に限る
dotfiles() {
  local f ex
  while read -r f; do
    case "$f" in
      .??* | bin) ;;
      *) continue ;;
    esac
    for ex in "${EXCLUSIONS[@]}"; do
      [ "$f" = "$ex" ] && continue 2
    done
    echo "$f"
  done < <(git -C "$DOTPATH" ls-files | cut -d/ -f1 | sort -u)
  for f in "${LOCAL_FILES[@]}"; do
    [ -e "$DOTPATH/$f" ] && echo "$f"
  done
  return 0
}

cmd_list() {
  dotfiles
}

cmd_deploy() {
  echo '==> Start to deploy dotfiles to home directory.'
  local f dir name file
  while read -r f; do
    link "$DOTPATH/$f" "$HOME/$f"
  done < <(dotfiles)
  run mkdir -p "$HOME/.proto"
  link "$DOTPATH/.prototools" "$HOME/.proto/.prototools"
  link "$DOTPATH/my_env_files" "$HOME/.env.d"

  # ~/.zsh/completions には Docker.app の補完などマシン固有のファイルも置かれるため
  # ディレクトリごとではなく、dotfiles の補完ファイルを1つずつリンクする
  run mkdir -p "$HOME/.zsh/completions"
  while read -r f; do
    link "$DOTPATH/$f" "$HOME/$f"
  done < <(git -C "$DOTPATH" ls-files .zsh/completions)

  # .config は丸ごとsymlinkせず、サブディレクトリ単位にリンクする
  # （丸ごとsymlinkすると ~/.config が無い新規マシンで個別リンクが自己参照になり ln が失敗する）
  if [ -L "$HOME/.config" ]; then
    echo '==> Replacing legacy ~/.config symlink with a real directory'
    run rm "$HOME/.config"
  fi
  echo '==> Deploying .config directories...'
  run mkdir -p "$HOME/.config"
  while read -r name; do
    file="$(config_file_only "$name")"
    if [ -n "$file" ]; then
      run mkdir -p "$HOME/.config/$name"
      link "$DOTPATH/.config/$name/$file" "$HOME/.config/$name/$file"
    else
      link "$DOTPATH/.config/$name" "$HOME/.config/$name"
    fi
  done < <(git -C "$DOTPATH" ls-files .config | cut -d/ -f2 | sort -u)
}

cmd_update() {
  run git -C "$DOTPATH" pull origin main
}

cmd_clean() {
  # リポジトリ以外（/ や $HOME）を消さないよう確認する
  if [ ! -f "$DOTPATH/install.sh" ] || [ "$DOTPATH" = "$HOME" ]; then
    echo "Refusing to clean: unexpected DOTPATH=$DOTPATH" >&2
    exit 1
  fi
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
    [ "${DRY_RUN:-}" = 1 ] || exec "$SHELL"
    ;;
  help) cmd_help ;;
  *)
    cmd_help >&2
    exit 1
    ;;
esac

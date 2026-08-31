
fpath=(~/.zsh/completions $fpath)

# シェル関数`compinit`の自動読み込み
# autoload -Uz compinit && compinit -i
autoload -Uz compinit && compinit
autoload -U bashcompinit && bashcompinit


# ZSHHOME(.zsh.d)直下の.zshファイルを数字順に実行する
if [ -d $ZSHHOME -a -r $ZSHHOME -a -x $ZSHHOME ]; then
    for i in `ls $ZSHHOME| sort -n |grep -E '^[0-9]+_[^/]+\.zsh$'`; do
        i="$ZSHHOME/$i"
        [[ ${i##*/} = *.zsh ]] &&
            [ \( -f $i -o -h $i \) -a -r $i ] && . $i
    done
    for i in "$ZSHHOME"/local/[^_]*.zsh(N); do
        . "$i"
    done
fi

bindkey -e
## カレントディレクトリ中に指定されたディレクトリが見つからなかった場合に
## 移動先を検索するリスト。
cdpath=(~)
## ディレクトリが変わったらディレクトリスタックを表示。
chpwd_functions=($chpwd_functions dirs)

# 展開
## --prefix=~/localというように「=」の後でも
## 「~」や「=コマンド」などのファイル名展開を行う。
setopt magic_equal_subst
## 拡張globを有効にする。
## glob中で「(#...)」という書式で指定する。
setopt extended_glob
## globでパスを生成したときに、パスがディレクトリだったら最後に「/」をつける。
setopt mark_dirs

# ジョブ
## jobsでプロセスIDも出力する。
setopt long_list_jobs


# 実行時間
## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

# ログイン・ログアウト
## 全てのユーザのログイン・ログアウトを監視する。
watch="all"
## ログイン時にはすぐに表示する。
log

# 単語
## 「/」も単語区切りとみなす。
WORDCHARS=${WORDCHARS:s,/,,}
## 「|」も単語区切りとみなす。
## 2011-09-19
WORDCHARS="${WORDCHARS}|"

# ウィンドウタイトル
## 実行中のコマンドとユーザ名とホスト名とカレントディレクトリを表示。
update_title() {
    local command_line=
    typeset -a command_line
    command_line=${(z)2}
    local command=
    if [ ${(t)command_line} = "array-local" ]; then
    command="$command_line[1]"
    else
    command="$2"
    fi
    print -n -P "\e]2;"
    echo -n "(${command})"
    print -n -P " %n@%m:%~\a"
}
## X環境上でだけウィンドウタイトルを変える。
if [ -n "$DISPLAY" ]; then
    preexec_functions=($preexec_functions update_title)
fi

if [[ "$TERM" == "dumb" ]]; then
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    unfunction precmd
    unfunction preexec
    PS1='$ '
fi
export PATH=$PATH:$HOME/.nodebrew/current/bin
export NODE_PATH=$(pnpm root -g 2>/dev/null)


alias k=kubectl
alias headlamp='/Applications/Headlamp.app/Contents/Resources/headlamp-server -kubeconfig ~/.kube/config -in-cluster=false -html-static-dir /Applications/Headlamp.app/Contents/Resources/frontend -enable-dynamic-clusters -listen-addr localhost -port 4466'
source <(kubectl completion zsh)
# complete -F __start_kubectl k
export PATH="/usr/local/opt/openjdk/bin:$PATH"

_kssh(){
    # COMPREPLY=( $( kubectl get pods | awk '{print $1}') )
    COMPREPLY=( $(compgen -W "$(kubectl get pods | awk 'NR>1 {print $1}')" ${COMP_WORDS[COMP_CWORD]}  ) )
}

function kssh() {
    kubectl exec -it $1 -- /bin/zsh
}

complete -F _kssh kssh

alias ke="kssh"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
# pnpm 11+ はグローバルbinが $PNPM_HOME/bin。旧レイアウトのshim（codex等）が
# $PNPM_HOME 直下に残っているため両方をPATHに入れる
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
# [ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"

# bun
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='${HOME}/.bun/bin/bun "${HOME}/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'


# tmux helper functions
# セッション名をディレクトリ名にして新規セッションを作成
# 既存セッションがある場合はナンバリングして新しいセッションを作成
function tn() {
  local session_name
  if [ -n "$1" ]; then
    session_name="$1"
  else
    session_name=$(basename "$PWD")
  fi

  # 既存セッションがある場合、ナンバリングして新しいセッションを作成
  if tmux has-session -t="$session_name" 2>/dev/null; then
    local counter=1
    while tmux has-session -t="${session_name}-${counter}" 2>/dev/null; do
      counter=$((counter + 1))
    done
    session_name="${session_name}-${counter}"
  fi

  # 新規セッション作成
  tmux new-session -s "$session_name" -c "$PWD"
}

# セッション名をディレクトリ名にして既存セッションにアタッチ、なければ新規作成
function ta() {
  local session_name
  if [ -n "$1" ]; then
    session_name="$1"
  else
    session_name=$(basename "$PWD")
  fi

  if tmux has-session -t="$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
  else
    tmux new-session -s "$session_name" -c "$PWD"
  fi
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# npm の依存変更系サブコマンドを封じて pnpm に寄せる。
# 参照系(view/whoami/publish 等)は素通し。緊急時は `command npm ...` で回避可能。
npm() {
  case "$1" in
    install|i|in|ins|isnt|add|ci|update|up|upgrade|uninstall|un|unlink|remove|rm|r|dedupe|ddp|link|ln)
      print -u2 "🚫 npm $1 は無効化されています。pnpm を使ってください:"
      print -u2 "   pnpm ${@}"
      print -u2 "   (どうしても npm が必要なら: command npm ${@})"
      return 1
      ;;
  esac
  command npm "$@"
}

# npx の代替は pnpm dlx
npx() {
  print -u2 "🚫 npx は無効化されています。pnpm dlx を使ってください:"
  print -u2 "   pnpm dlx ${@}"
  print -u2 "   (どうしても npx が必要なら: command npx ${@})"
  return 1
}

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<

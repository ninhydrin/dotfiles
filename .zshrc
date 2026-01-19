
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
export NODE_PATH=`npm root -g`


alias k=kubectl
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
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
# [ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"

# bun
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='${HOME}/.bun/bin/bun "${HOME}/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

export PATH="$HOME/.npm-global/bin:$PATH"

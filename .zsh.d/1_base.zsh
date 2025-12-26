
# -*- sh -*-
# git clone https://github.com/syl20bnr/spacemacs .emacs.d

# brew tap homebrew/science;brew install openblas # openblas for numpy
# conda install -c conda-forge numpy
export PATH="/usr/local/opt/ncurses/bin:$PATH"

case ${OSTYPE} in
    darwin*)
        function emacs () { /Applications/Emacs.app/Contents/MacOS/Emacs $1 &}
        alias imgcat='~/.imgcat'
        alias imgls='~/.imgls'
        # alias chrome='google-chrome'
        alias -s html=chrome
        # alias google-chrome='open -a Google\ Chrome'
        alias lsusb='system_profiler SPUSBDataType'
            ;;
    linux*)
        # function emacs () { /usr/bin/emacs $1 &}
        ;;
esac

#任意のエイリアス
if [ ! -d $HOME/.zsh_variables ]; then
    mkdir $HOME/.zsh_variables
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

# プロンプト
## PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
## PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
## コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

## 256色生成用便利関数
### red: 0-5
### green: 0-5
### blue: 0-5
color256()
{
    local red=$1; shift
    local green=$2; shift
    local blue=$3; shift

    echo -n $[$red * 36 + $green * 6 + $blue + 16]
}

fg256()
{
    echo -n $'\e[38;5;'$(color256 "$@")"m"
}

bg256()
{
    echo -n $'\e[48;5;'$(color256 "$@")"m"
}

## プロンプトの作成
### ↓のようにする。
###   -(user@debian)-(0)-<2011/09/01 00:54>------------------------------[/home/user]-
###   -[84](0)%                                                                   [~]

## バージョン管理システムの情報も表示する
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats \
    '(%{%F{white}%K{green}%}%s%{%f%k%}:`git config user.name`)-[%{%F{white}%K{blue}%}%b%{%f%k%}]'
zstyle ':vcs_info:*' actionformats \
    '(%{%F{white}%K{green}%}%s%{%f%k%}:`git config user.name`)-[%{%F{white}%K{blue}%}%b%{%f%k%}|%{%F{white}%K{red}%}%a%{%f%k%}]'

### プロンプトバーの左側
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %{%F{cyan}%}...%{%f%}: 「...」をシアン色の文字にする。
###   %n: ユーザ名
###   %m: ホスト名（完全なホスト名ではなくて短いホスト名）
###   %{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%f%k%b%}:
###                           最後に実行したコマンドが正常終了していれば
###                           太字で白文字で緑背景にして異常終了していれば
###                           太字で白文字で赤背景にする。
###   %{%F{white}%}: 白文字にする。
###     %(x.true-text.false-text): xが真のときはtrue-textになり
###                                偽のときはfalse-textになる。
###       ?: 最後に実行したコマンドの終了ステータスが0のときに真になる。
###       %K{green}: 緑景色にする。
###       %K{red}: 赤景色を赤にする。
###   %?: 最後に実行したコマンドの終了ステータス
###   %{%k%}: 背景色を元に戻す。
###   %{%f%}: 文字の色を元に戻す。
###   %{%b%}: 太字を元に戻す。
###   %D{%Y/%m/%d %H:%M}: 日付。「年/月/日 時:分」というフォーマット。
prompt_bar_left_self="[%{%B%}%n%{%b%}%{%F{cyan}%}@%{%f%}%{%B%}%m%{%b%}]"
prompt_bar_left_status="(%{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%k%f%b%})"
prompt_bar_left_date="<%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}>"
prompt_bar_left="-${prompt_bar_left_self}-${prompt_bar_left_status}-${prompt_bar_left_date}-"
### プロンプトバーの右側
###   %{%B%K{magenta}%F{white}%}...%{%f%k%b%}:
###       「...」を太字のマゼンタ背景の白文字にする。
###   %d: カレントディレクトリのフルパス（省略しない）
### prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"
prompt_bar_right="-[%{%B%K{blue}%F{white}%}%d%{%f%k%b%}]-"

### 2行目左にでるプロンプト。
###   %h: ヒストリ数。
###   %(1j,(%j),): 実行中のジョブ数が1つ以上ある場合だけ「(%j)」を表示。
###     %j: 実行中のジョブ数。
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %#: 一般ユーザなら「%」、rootユーザなら「#」になる。
prompt_left="-[%h]%(1j,(%j),)%{%B%}%#%{%b%} "

## プロンプトフォーマットを展開した後の文字数を返す。
## 日本語未対応。
count_prompt_characters()
{
    # print:
    #   -P: プロンプトフォーマットを展開する。
    #   -n: 改行をつけない。
    # sed:
    #   -e $'s/\e\[[0-9;]*m//g': ANSIエスケープシーケンスを削除。
    # wc:
    #   -c: 文字数を出力する。
    # sed:
    #   -e 's/ //g': *BSDやMac OS Xのwcは数字の前に空白を出力するので削除する。
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}

## プロンプトを更新する。
update_prompt()
{
    # プロンプトバーの左側の文字数を数える。
    # 左側では最後に実行したコマンドの終了ステータスを使って
    # いるのでこれは一番最初に実行しなければいけない。そうし
    # ないと、最後に実行したコマンドの終了ステータスが消えて
    # しまう。
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    # プロンプトバーに使える残り文字を計算する。
    # $COLUMNSにはターミナルの横幅が入っている。
    local bar_rest_length=$[COLUMNS - bar_left_length]

    local bar_left="$prompt_bar_left"
    # パスに展開される「%d」を削除。
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    # 「%d」を抜いた文字数を計算する。
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    # パスの最大長を計算する。
    #   $[...]: 「...」を算術演算した結果で展開する。
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    # パスに展開される「%d」に最大文字数制限をつける。
    #   %d -> %(C,%${max_path_length}<...<%d%<<,)
    #     %(x,true-text,false-text):
    #         xが真のときはtrue-textになり偽のときはfalse-textになる。
    #         ここでは、「%N<...<%d%<<」の効果をこの範囲だけに限定させる
    #         ために用いているだけなので、xは必ず真になる条件を指定している。
    #       C: 現在の絶対パスが/以下にあると真。なので必ず真になる。
    #       %${max_path_length}<...<%d%<<:
    #          「%d」が「${max_path_length}」カラムより長かったら、
    #          長い分を削除して「...」にする。最終的に「...」も含めて
    #          「${max_path_length}」カラムより長くなることはない。
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    # 「${bar_rest_length}」文字分の「-」を作っている。
    # どうせ後で切り詰めるので十分に長い文字列を作っているだけ。
    # 文字数はざっくり。
    local separator="${(l:${bar_rest_length}::-:)}"
    # プロンプトバー全体を「${bar_rest_length}」カラム分にする。
    #   %${bar_rest_length}<<...%<<:
    #     「...」を最大で「${bar_rest_length}」カラムにする。
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"

    # プロンプトバーと左プロンプトを設定
    #   "${bar_left}${bar_right}": プロンプトバー
    #   $'\n': 改行
    #   "${prompt_left}": 2行目左のプロンプト
    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    # 右プロンプト
    #   %{%B%F{white}%K{green}}...%{%k%f%b%}:
    #       「...」を太字で緑背景の白文字にする。
    #   %~: カレントディレクトリのフルパス（可能なら「~」で省略する）
    RPROMPT="[%{%B%F{white}%K{blue}%}%~%{%k%f%b%}]"
    case "$TERM_PROGRAM" in
    Apple_Terminal)
        # Mac OS Xのターミナルでは$COLUMNSに右余白が含まれていないので
        # 右プロンプトに「-」を追加して調整。
        ## 2011-09-05
         RPROMPT="${RPROMPT}-"
        ;;
    esac

    # バージョン管理システムの情報を取得する。
    LANG=C vcs_info >&/dev/null
    # バージョン管理システムの情報があったら右プロンプトに表示する。
    if [ -n "$vcs_info_msg_0_" ]; then
        PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
        RPROMPT="${vcs_info_msg_0_}-${RPROMPT}"
    fi
}

## コマンド実行前に呼び出されるフック。
precmd_functions=($precmd_functions update_prompt)
alias e="emacs"
alias imgcat='~/.imgcat'
alias imgls='~/.imgls'
alias chrome='google-chrome'
alias -s html=chrome

alias -g L="|& $PAGER"
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sed'

alias platex=/usr/local/texlive/2016/bin/x86_64-darwin/platex 
alias dvipdfmx=/usr/local/texlive/2015/bin/x86_64-darwin/dvipdfmx

alias sl='la'
alias ks='la'
alias l='la'
alias al='la'

### -nw: ターミナル内でEmacsを起動する。
alias enw="emacs -nw"
alias x="exit"

## 完全に削除。
alias rr="command rm -rf"
## ファイル操作を確認する。
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

## pushd/popdのショートカット。
alias pd="pushd"
alias po="popd"

## lsとpsの設定
### ls: できるだけGNU lsを使う。
### ps: 自分関連のプロセスのみ表示。
case $(uname) in
    *BSD|Darwin)
		if [ -x "$(which gnuls)" ]; then
			alias s="gnuls"
			alias la="ls -lhAF --color=auto"
		else
			alias la="ls -lhAFG"
		fi
		alias ps="ps -fU$(whoami)"
		;;
    SunOS)
		if [ -x "`which gls`" ]; then
			alias ls="gls"
			alias la="ls -lhAF --color=auto"
		else
			alias la="ls -lhAF"
		fi
		alias ps="ps -fl -u$(/usr/xpg4/bin/id -un)"
		;;
    *)
		alias la="ls -lhAF --color=auto"
		alias ps="ps -fU$(whoami) --forest"
		;;
esac
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
fi

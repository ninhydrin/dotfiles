alias e="emacs"
alias imgcat='~/.imgcat'
alias imgls='~/.imgls'
# alias chrome='google-chrome'
alias gitlog='git log --oneline --decorate --graph --branches --tags --remotes'
alias -s html=chrome

alias -g L="|& $PAGER"
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sed'

alias platex=/usr/local/texlive/2016/bin/x86_64-darwin/platex
alias dvipdfmx=/usr/local/texlive/2015/bin/x86_64-darwin/dvipdfmx

alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"

alias sl='la'
alias l='la'
alias al='la'

### brew doctor時のpyenvのwarning対策
alias brew="env PATH=${PATH/\/Users\/${USER}\/\.pyenv\/shims:?/} brew"

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
alias fetch-pr="!f() { git fetch origin pull/$1/head:$1; }; f"
# open-pr = !open "$(git config remote.origin.url | sed -Ee 's!(git@|git://|ssh://)!http://!' -e 's!:([^/])!/\\1!')/pull/new/$(git rev-parse --abbrev-ref HEAD)"

alias tmuxa="tmux a -t"
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/| /g'"

function tensorboard-docker(){
  command docker run -p 6006:6006 -v @$1:/mounted tensorboard --logger /mounted
}

alias smi="nvidia-smi"
# brew のpyenvでのwarning対策
alias brew="env PATH=${PATH/\/Users\/${USER}\/\.pyenv\/shims:/} brew"

alias rmds="find . -name '*.DS_Store' -type f -ls -delete"

alias tmuxa="tmux a -t"
alias jn="jupyter-notebook"

#amadeus
alias amadeus="~/amadeus/.venv/bin/python ~/amadeus/job.py"
alias ks="kubectl get svc"
alias kj="kubectl get jobs"
alias kp="kubectl get pods"
alias kr='kubectl get ResourceQuota --all-namespaces|grep yoko'

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


# プルリクをローカルに持ってくる
# https://qiita.com/great084/items/ad74dd064a2c2bc47cff
function gfp() {
    command git fetch origin pull/$1/head:PR-$1
}

alias myclaude='env -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_BASE_URL -u CLAUDE_CODE_SUBAGENT_MODEL ANTHROPIC_MODEL=opusplan claude'
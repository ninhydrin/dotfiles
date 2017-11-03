setopt no_global_rcs

export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:
export PATH=${HOME}/.nodebrew/current/bin:${PATH}
export LIBRARY_DIRS=/opt/local/lib

export GOROOT=/usr/local/go/
export GOPATH=~/dev/go-workspace
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/bin
export PATH=/usr/local/cuda/bin:${PATH}

export DYLD_FALLBACK_LIBRARY_PATH=$ANACONDA_HOME/lib:/usr/local/lib:/usr/lib
export DYLD_FALLBACK_LIBRARY_PATH=~/.pyenv/versions/anaconda-2.3.0/lib:$DYLD_FALLBACK_LIBRARY_PATH

export ZSHHOME="${HOME}/.zsh.d"


case ${OSTYPE} in
    darwin*)
        export PYENV_ROOT=/usr/local/var/pyenv
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
        if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
        export RBENV_ROOT=/usr/local/var/rbenv
        export LSCOLORS=xefxcxdxbxegedabagacad
        ;;
    linux*)
        export PYENV_ROOT=${HOME}/.pyenv
        export RBENV_ROOT=${HOME}/.rbenv
        ;;
esac


if [ -d ${PYENV_ROOT} ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    export PYTHONPATH=./pyenv/python:$PYTHONPATH
    eval "$(pyenv init -)"
fi
if [ -d ${PYENV_ROOT} ]; then
    export PATH=${RBENV_ROOT}/bin:$PATH
    eval "$(rbenv init -)"
fi



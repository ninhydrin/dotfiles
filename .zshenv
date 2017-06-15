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

export PYTHONPATH=./pyenv/python:$PYTHONPATH
export PYENV_ROOT="${HOME}/.pyenv"
export NANDEMONAI="${HOME}/.pyenv"

export PYTHONPATH=./pyenv/python:$PYTHONPATH

if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
fi
eval "$(rbenv init -)"

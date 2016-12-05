export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:
export PATH=${HOME}/.nodebrew/current/bin:${PATH}

#export PATH=~/python/pylearn2/pylearn2/scripts:${PATH}
#export PYLEARN2_DATA_PATH=~/python/pylearn2_data
#export PYTHONPATH=~/caffe/python:$PYTHONPATH

export GOROOT=/usr/local/go/
export GOPATH=~/dev/go-workspace
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

export LD_LIBRARY_PATH=/usr/local/cuda-6.5/lib64:/usr/local/bin
export DYLD_FALLBACK_LIBRARY_PATH=$ANACONDA_HOME/lib:/usr/local/lib:/usr/lib
export DYLD_FALLBACK_LIBRARY_PATH=~/.pyenv/versions/anaconda-2.3.0/lib:$DYLD_FALLBACK_LIBRARY_PATH
export LIBRARY_DIRS=/opt/local/lib
export ZSHHOME="${HOME}/.zsh.d"
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
fi

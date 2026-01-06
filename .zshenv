setopt no_global_rcs

export PATH=/usr/local/bin:/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/sbin:
export PATH=${HOME}/.nodebrew/current/bin:${PATH}
export LIBRARY_DIRS=/opt/local/lib

#conda
export PATH=$PATH:/opt/conda/bin:

# Go lang
export GOROOT=/usr/local/go/
export GOPATH=~/dev/go-workspace
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

export DYLD_FALLBACK_LIBRARY_PATH=$ANACONDA_HOME/lib:/usr/local/lib:/usr/lib
export DYLD_FALLBACK_LIBRARY_PATH=~/.pyenv/versions/anaconda-2.3.0/lib:$DYLD_FALLBACK_LIBRARY_PATH

export ZSHHOME="${HOME}/.zsh.d"

# CUDA
export PATH=/usr/local/cuda/bin:${PATH}
export CUDA_ROOT=/usr/local/cuda
export CUDA_PATH=/usr/local/cuda
export LD_LIBRARY_PATH=/usr/local/cuda/lib64
export CPATH=/usr/local/cuda/include:$CPATH

# JAVA
export PATH=$PATH:/usr/local/opt/openjdk/bin/java
# OpenMPI
# CentOS7ならhttps://labo.utsubo.tokyo/2017/09/22/post-1212/ を参考に
export PATH=$PATH:/usr/lib64/openmpi/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/openmpi/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/include/openmpi-x86_64
export CPLUS_INCLUDE_PATH=$C_INCLUDE_PATH

# Rust
export RUSTUP_DIR="${HOME}/.rustup/"
export CARGO_DIR="${HOME}/.cargo/"
export PATH="$CARGO_DIR/bin:$PATH"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
case ${OSTYPE} in
    darwin*)
        # export PYENV_ROOT=/usr/local/var/pyenv
        export PYENV_ROOT=${HOME}/.pyenv
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        # if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
        # if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
        export RBENV_ROOT=/usr/local/var/rbenv
        export LSCOLORS=xefxcxdxbxegedabagacad
        ;;
    linux*)
        export PYENV_ROOT=${HOME}/.pyenv
        export RBENV_ROOT=${HOME}/.rbenv
        ;;
esac

# uv
export PATH=$HOME/.local/bin:$PATH


# if [ -d ${PYENV_ROOT} ]; then
    # export PATH=${PYENV_ROOT}/bin:$PATH
    # export PYTHONPATH=./pyenv/python:$PYTHONPATH
    # eval "$(pyenv init -)"
# fi

# if [ -d ${RBENV_ROOT} ]; then
    # export PATH=${RBENV_ROOT}/bin:$PATH
    # eval "$(rbenv init -)"
# fi

export PATH=$HOME/.nodebrew/current/bin:$PATH

# ZPLUG
export ZPLUG_HOME=${HOME}/dotfiles/.zplug

export ZSH_VARIABLES=${HOME}/.zsh_variables
export PATH="/opt/homebrew/bin:$PATH"


# Load all *.env files from .env.d directory
if [ -d "$HOME/.env.d" ]; then
  for env_file in "$HOME/.env.d"/*.env(N); do
    [ -r "$env_file" ] && source "$env_file"
  done
fi

# claude
export ENABLE_TOOL_SEARCH=true
export ENABLE_EXPERIMENTAL_MCP_CLI=false

# proto
# bash <(curl -fsSL https://moonrepo.dev/install/proto.sh)
export PROTO_HOME="$HOME/.proto";
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH";

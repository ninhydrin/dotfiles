export PYENV_ROOT="${HOME}/.pyenv"

if [ ! -e ${PYENV_ROOT} -a ! -f $ZSH_VARIABLES/no_pyenv ]; then
    echo "There is not .pyenv. Do you clone pyenv ? [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            case ${OSTYPE} in
                darwin*)
                    brew install pyenv
                    brew install pyenv-virtualenv
                ;;
                linux*)
                    git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}
                    git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv
                ;;
            esac
            ;;
        "N" )
            touch $ZSH_VARIABLES/no_pyenv ;;
        * ) ;;
    esac
fi

# alias newenv="echo pyenv not installed!!"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
    newenv(){
        if [ $# -eq 0 ]; then
            echo "input new python env name"
        elif [ $# -eq 1 ]; then
            # pyenv virtualenv --python 3.10.0 miniconda3-latest $1
            pyenv virtualenv --python 3.9.0 miniconda3-latest $1
            pyenv local $1
            pyenv rehash
        else
            pyenv virtualenv --python 3.9.0 miniconda3-latest $1
        fi
    }
fi

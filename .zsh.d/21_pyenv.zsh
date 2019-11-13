if [ ! -e $HOME/.pyenv ]; then
    echo "There is not .pyenv. Do you clone pyenv ? [y/n]"
    read ANSWER
    case $ANSWER in
        "" | "Y" | "y" | "yes" | "Yes" | "YES" )
            case ${OSTYPE} in
                darwin*)
                    brew install pyenv
                    brew install pyenv-virtualenv
                ;;
                linux*)
                    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
                    git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv
                ;;
            esac
            ;;
        * ) ;;
    esac
fi
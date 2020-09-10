export PYENV_ROOT="${HOME}/.pyenv"

if [ ! -e ${PYENV_ROOT} ]; then
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
        * ) ;;
    esac
fi

alias newenv="echo pyenv not installed!!"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
	alias newenv="pyenv virtualenv --python 3.7.4 miniconda3-latest "
	if [ ! -d ${PYENV_ROOT}/versions/miniconda3-latest ]; then
		echo "not installed miniconda3-latest. install? [Y/n]"
		read -k 1 ANSWER
		case $ANSWER in "Y" | "y" | "yes" | "Yes" | "YES" )
		pyenv install miniconda3
		# conda install -y -c conda-forge opencv
		pip install opencv-python
		alias newenv="pyenv virtualenv --python 3.7.4 miniconda3-latest "
		;;
		* ) echo "miniconda not installed";;
		esac
	fi
fi
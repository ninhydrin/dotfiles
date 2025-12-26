if [ ! -e $HOME/.rbenv ]; then
    echo "There is not .rbenv. Do you clone rbenv ? [y/n]"
    read -k 1 ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            case ${OSTYPE} in
                darwin*)
                    brew install rbenv
                ;;
                linux*)
                    git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
                ;;
            esac
            ;;
        * ) ;;
    esac
fi
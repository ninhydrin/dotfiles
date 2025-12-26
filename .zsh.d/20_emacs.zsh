if [ ! -e $HOME/.emacs.d ]; then
    echo "There is not .emacs.d. Do you clone spacemacs ? [y/n]"
    read ANSWER
    case $ANSWER in
        "" | "Y" | "y" | "yes" | "Yes" | "YES" ) git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d;;
        * ) ;;
    esac
fi
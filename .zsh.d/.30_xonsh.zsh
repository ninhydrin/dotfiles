which xonsh
if [ $? = 0  ]; then
    # xonsh
else
    echo "not installed xonsh. install? [Y/n]"
    read -k 1 ANSWER
    case $ANSWER in "Y" | "y" | "yes" | "Yes" | "YES" )
        pip install xonsh
        xonsh
        ;;
        * ) echo "start zsh";;
    esac
fi
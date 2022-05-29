# ZSHHOME(.zsh.d)直下の.zshファイルを数字順に実行する
if [ -d $ZSHHOME -a -r $ZSHHOME -a -x $ZSHHOME ]; then
    for i in `ls $ZSHHOME| sort -n |grep -E "^\d+_.+\.zsh$"`; do
        i="$ZSHHOME/$i"
        [[ ${i##*/} = *.zsh ]] &&
            [ \( -f $i -o -h $i \) -a -r $i ] && . $i
    done
fi

which kubectl > /dev/null
if [ $? = 0 ]; then

else
    alias k='kubectl'
    alias ks='kubectl get svc'
    alias kj='kubectl get jobs'
    alias kp='kubectl get pods'
fi

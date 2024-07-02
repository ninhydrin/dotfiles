_kssh(){
    # COMPREPLY=( $( kubectl get pods | awk '{print $1}') )
    COMPREPLY=( $(compgen -W "$(kubectl get pods | awk 'NR>1 {print $1}')" ${COMP_WORDS[COMP_CWORD]}  ) )
}

function kssh() {
    kubectl exec -it $1 -- /bin/zsh
}

complete -F _kssh kssh

alias ke="kssh"

_amadeus(){
    # COMPREPLY=( $( kubectl get pods | awk '{print $1}') )
    COMPREPLY=( $(compgen -W "$(kubectl get jobs | awk '{print $1}')" ${COMP_WORDS[COMP_CWORD]}  ) )
}
complete -F _amadeus amadeus


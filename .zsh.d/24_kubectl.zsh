_kssh(){
    # COMPREPLY=( $( kubectl get pods | awk '{print $1}') )
    COMPREPLY=( $(compgen -W "$(kubectl get pods | awk 'NR>1 {print $1}')" ${COMP_WORDS[COMP_CWORD]}  ) )
}

function kssh() {
    kubectl exec -it $1 -- ${2:-/bin/zsh}
}

complete -F _kssh kssh

alias ke="kssh"

_amadeus(){
    # COMPREPLY=( $( kubectl get pods | awk '{print $1}') )
    COMPREPLY=( $(compgen -W "$(kubectl get jobs | awk '{print $1}')" ${COMP_WORDS[COMP_CWORD]}  ) )
}
complete -F _amadeus amadeus


function kube_switch() {
    kcontext=$(kubectl config get-contexts  | peco --initial-index=1 --prompt='kubectl config use-context > ' |  sed -e 's/^\*//' | awk '{print $1}')
    if [ -n "$kcontext" ]; then
        kubectl config use-context $kcontext
    fi
}

kej() {
  kubectl exec -it $(kubectl get pods --selector=job-name=$1 -o jsonpath='{.items[0].metadata.name}') -- ${2:-/bin/zsh}
}
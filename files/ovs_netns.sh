#!/bin/bash
function netns () {
    color=$1
    shift
    args=$@
    if [[ ${args[0]} = "bash" ]]
    then
	echo "To risky for my taste"
    else
	if [[ $(ip netns list | grep -o ${color}) == ${color} ]]
	then
	    echo -ne ${colorlist[$color]}
	    sudo ip netns exec ${color} ${args[@]}
	    echo -ne '\e[0m'
	else
	    echo "namespace ${color} does not exist"
	fi
    fi
    }
for ns in ${namespaces[@]}
do
    alias ${ns}="netns ${ns}" && alias ${ns} && export ${ns} 
done

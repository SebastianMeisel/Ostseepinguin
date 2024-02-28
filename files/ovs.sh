#!/bin/bash
script_dir="$(dirname ${BASH_SOURCE[0]})"
. ${script_dir}/ovs_setup.sh
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

for ns in ${namespaces[@]}
do
    if [[ ! $(ip netns list | grep -o ${ns}) == ${ns} ]]
    then
	sudo ip netns add ${ns}
	echo "${ns} namespace added."
    fi
done
ip netns list
sleep 1

for ns in ${namespaces[@]}
do
  netns ${ns} ip link set lo up
    echo "Loopback in ${ns} is up."
done

for ns in ${namespaces[@]}
do
    sudo ip link add veth-${ns::1} type veth peer eth0-${ns::1}
    echo "Linked veth-${ns} to eth0-${ns}."
done

for ns in ${namespaces[@]}
do
    sudo ip link set eth0-${ns::1} netns ${ns}
done

ip=1
for ns in ${namespaces[@]}
do
    ip=$((ip+1))
  netns ${ns} ip address add 10.0.0.${ip}/24 dev eth0-${ns::1}
  netns ${ns} ip link set dev eth0-${ns:0:1} up
    echo "Add IP 10.0.0.${ip} to eth0-${ns::1}."
done

sudo systemctl start ovs-vswitchd.service
echo "Started ovs-vswitchd"

sudo ovs-vsctl add-br SW1

for ns in {r,g,b}
do
    sudo ovs-vsctl add-port SW1 veth-${ns}
    echo "Added veth-${ns} to SW1."
done

for ns in {r,g,b}
do
    sudo ip link set veth-${ns} up
    echo "Link veth-{ns} is up."
done

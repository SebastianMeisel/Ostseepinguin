#!/bin/bash
function red () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	if [[ $(ip netns list | grep -o "red") == red ]]
	then
	    echo -ne '\e[32m'
	    sudo ip netns exec red $@
	    echo -ne '\e[0m'
	else
	    echo "namespace red does not exist"
	fi
    fi
    }

function green () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	if [[ $(ip netns list | grep -o "green") == green ]]
	then
	    echo -ne '\e[32m'
	    sudo ip netns exec green $@
	    echo -ne '\e[0m'
	else
	    echo "namespace green does not exist"
	fi
    fi
    }

function orange () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	if [[ $(ip netns list | grep -o "orange") == orange ]]
	then
	    echo -ne '\e[32m'
	    sudo ip netns exec orange $@
	    echo -ne '\e[0m'
	else
	    echo "namespace orange does not exist"
	fi
    fi
    }

function blue () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	if [[ $(ip netns list | grep -o "blue") == blue ]]
	then
	    echo -ne '\e[32m'
	    sudo ip netns exec blue $@
	    echo -ne '\e[0m'
	else
	    echo "namespace blue does not exist"
	fi
    fi
    }

namespaces=(red green blue)
for ns in ${namespaces[@]}
do
    if [[ ! $(ip netns list | grep -q ${ns}) == ${ns} ]]
    then
	sudo ip netns add ${ns}
	echo "${ns} namespace added."
    fi
done
ip netns list
sleep 1

for ns in ${namespaces[@]}
do
  ${ns} ip link set lo up
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
    ${ns} ip address add 10.0.0.${ip}/24 dev eth0-${ns::1}
    ${ns} ip link set dev eth0-${ns:0:1} up
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

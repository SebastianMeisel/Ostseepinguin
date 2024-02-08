#!/bin/bash
function green () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	echo -ne '\e[32m'
	ip netns exec green $@
	echo -ne '\e[0m'
    fi
    }

function red () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	echo -ne '\e[31m'
	ip netns exec red $@
	echo -ne '\e[0m'
    fi
    }

function orange () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	echo -ne '\e[33m'
	ip netns exec orange $@
	echo -ne '\e[0m'
    fi
    }

function blue () {
    if [[ $1 = "bash" ]]
    then
	echo "To risky for my taste"
    else
	echo -ne '\e[34m'
	ip netns exec blue $@
	echo -ne '\e[0m'
    fi
    }

ip netns add red
ip netns add green
ip netns add blue

red ip l dev lo up
green ip l dev lo up
blue ip l dev lo up

red ip l
green ip l
blue ip l

ip link add veth-r type veth peer eth0-r
ip link add veth-g type veth peer eth0-g
ip link add veth-b type veth peer eth0-b

ip link set eth0-r netns red
ip link set eth0-g netns green
ip link set eth0-b netns blue

red ip address add 10.0.0.2/24 dev eth0-r
red ip link set dev eth0-r up
green ip address add 10.0.0.3/24 dev eth0-g
green ip link set dev eth0-g up
blue ip address add 10.0.0.4/24 dev eth0-b
blue ip link set dev eth0-b up

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi
case $ID_LIKE in
    debian|ubuntu)
        systemctl start ovs-vswitchd.service
        ;;
    fedora|rhel|centos)
        systemctl start ovs-vswitchd
        ;;
    suse)
        systemctl start ovs-vswitchd
        ;;
    arch)
        systemctl start openvswitch
        ;;
    *)
        echo "Unsupported distribution."
        exit 1
        ;;
esac
else
echo "Cannot determine the Linux distribution."
exit 1
fi

ovs-vsctl add-br SW1
ovs-vsctl show

ovs-vsctl add-port SW1 veth-r
ovs-vsctl add-port SW1 veth-b
ovs-vsctl add-port SW1 veth-g
ovs-vsctl show

ip link set veth-r up
ip link set veth-g up
ip link set veth-b up
ip a | grep veth -A3

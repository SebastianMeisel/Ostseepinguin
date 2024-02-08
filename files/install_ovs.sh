#!/bin/bash
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi
case $ID_LIKE in
    debian|ubuntu)
        apt install -y openvswitch-switch
        ;;
    fedora|rhel|centos)
        yum install -y openvswitch
        ;;
    suse)
        zypper install -y openvswitch
        ;;
    arch)
        pacman -Syu openvswitch
        ;;
    *)
        echo "Unsupported distribution."
        exit 1
        ;;
esac

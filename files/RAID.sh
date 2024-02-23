#!/bin/bash
export LC_ALL=C

export RAID_DIR=$(mktemp -d RAIDXXXXX)
cd ${RAID_DIR}
fallocate -l 500M disk1.img
fallocate -l 500M disk2.img
fallocate -l 500M disk3.img
fallocate -l 500M disk4.img
fallocate -l 500M disk5.img

sudo /usr/sbin/losetup  /dev/loop100 ./disk1.img
sudo /usr/sbin/losetup  /dev/loop200 ./disk2.img
sudo /usr/sbin/losetup  /dev/loop300 ./disk3.img
sudo /usr/sbin/losetup  /dev/loop400 ./disk4.img
sudo /usr/sbin/losetup  /dev/loop500 ./disk5.img

sudo mdadm --create /dev/md0 --level=1 --raid-devices=5 /dev/loop{1..5}00

sudo /usr/sbin/mkfs.ext4 /dev/md0

sudo mkdir /mnt/raid_sim
sudo mount /dev/md0 /mnt/raid_sim/
cd /mnt/raid_sim

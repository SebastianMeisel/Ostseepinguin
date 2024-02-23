#!/bin/bash
RAID_DIR=$(find /home/ -type d -name RAID?????)
cd ${RAID_DIR}
sudo umount /mnt/raid_sim
sudo rm -r /mnt/raid_sim
sudo mdadm --stop /dev/md0
sudo mdadm --remove /dev/md0
cat /proc/mdstat
for i in {1..5}
do
    sudo losetup -d /dev/loop${i}00
done
cd ..
rm -r ${RAID_DIR}

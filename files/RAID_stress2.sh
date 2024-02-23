#!/bin/bash
RAID_DIR=$(find /home/ -type d -name RAID?????)
echo ${RAID_DIR}

for f in ${RAID_DIR}/disk{2,4}.img
do
    export FILE=$f
    export iterations=$((600 / 30))
    bad_data_per_iteration=$((200 * 1024 * 1024 / iterations))
    for i in {1..$iterations}; do
	# Seek to a random offset within the image file
	offset=$((RANDOM % ($(($(du -b ${FILE} | awk '{print $1}') - 10240)))))
	# Write bad data using fallocate
	sudo fallocate -l $bad_data_per_iteration -o $offset ${FILE}
	# Optionally, simulate some delay between writes
	sleep 30
    done
done

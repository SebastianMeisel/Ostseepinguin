#!/bin/bash
RUNDIR=$(mktemp -d blue_named_run_XXXXX)
chmod 777 ${RUNDIR}
cd ${RUNDIR}
netns blue named -c /etc/bind/named.conf.local

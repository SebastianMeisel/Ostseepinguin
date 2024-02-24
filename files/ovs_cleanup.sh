#!/bin/bash
# List of namespaces created by your previous script
target_namespaces=(red green blue)

# List of veth interfaces created by your previous script
target_interfaces=(veth-r veth-g veth-b)

# Check for existing namespaces
if [[ -n $(ip netns list) ]]; then
  echo "Removing network namespaces..."

  # Loop through each namespace and remove only matching ones
  for ns in $(ip netns list | awk '{print $1}'); do
    if [[ "${target_namespaces[@]}" =~ "$ns" ]]; then
      sudo ip netns del $ns
      echo "Removed namespace: $ns"
    fi
  done
else
  echo "No network namespaces found."
fi

# Check for existing veth interfaces
if [[ $(ip link show | grep veth -c) -gt 0 ]]; then
  echo "Removing veth interfaces..."

  # Loop through each veth interface and remove only matching ones
  for veth in $(ip link show | grep veth | awk '{print $2}' |sed 's/@.*$//g'); do
    if [[ "${target_interfaces[@]}" =~ "$veth" ]]; then
      sudo ip link del $veth
      echo "Removed interface: $veth"
    fi
  done
else
  echo "No veth interfaces found."
fi

echo "Stopping and disabling Open vSwitch..."
sudo systemctl stop ovs-vswitchd.service

# check if named run directory for blue namespace exitsts
if [[ -d $(ls -d blue_named_run_?????) ]]; then 
    rm -rf blue_named_run_?????
    echo "Removed run directory for named service in blue".
fi

echo "Cleanup complete!"

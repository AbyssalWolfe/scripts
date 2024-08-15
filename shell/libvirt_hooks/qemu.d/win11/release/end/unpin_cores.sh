#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Get all cores
ALL_CORES=$(lscpu | sed -nr 's/^On-line.*([0-9]+\-[0-9]+)$/\1/p')

# Unpin cpu cores
echo "$(date) INFO: Unpinning CPU cores..." >>"$LOG"
systemctl set-property --runtime -- system.slice AllowedCPUs="$ALL_CORES"
systemctl set-property --runtime -- user.slice AllowedCPUs="$ALL_CORES"
systemctl set-property --runtime -- init.scope AllowedCPUs="$ALL_CORES"

#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Pin cpu cores
echo "$(date) INFO: Pinning CPU cores..." >>"$LOG"
systemctl set-property --runtime -- system.slice AllowedCPUs="$CORES"
systemctl set-property --runtime -- user.slice AllowedCPUs="$CORES"
systemctl set-property --runtime -- init.scope AllowedCPUs="$CORES"

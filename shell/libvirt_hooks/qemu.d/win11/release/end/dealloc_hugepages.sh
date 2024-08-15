#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Deallocate hugepages
echo "$(date) INFO: Deallocating hugepages..." >>"$LOG"
echo 0 >/proc/sys/vm/nr_hugepages

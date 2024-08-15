#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Set real-time scheduling priority
if pid=$(pidof "$QEMU"); then
	if chrt -f -p 1 "$pid"; then
		echo "$(date) INFO: real-time scheduling SET for $QEMU pid: $pid" >>"$LOG"
	else
		echo "$(date) ERROR: real-time scheduling FAILED for $QEMU pid: $pid" >>"$LOG"
	fi
fi

#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Set IRQ affinities
echo "$(date) INFO: Setting IRQ affinities..." >>"$LOG"
sed -n -e 's/ \([0-9]\+\):.*/\1/p' /proc/interrupts | while read -r i; do
	echo "$CORES" | sed -r 's/\-[0-9]+//g' >/proc/irq/"$i"/smp_affinity_list
done

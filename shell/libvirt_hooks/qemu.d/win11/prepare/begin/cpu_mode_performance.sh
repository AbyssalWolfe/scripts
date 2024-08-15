#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Enable CPU governor performance mode
echo "$(date) INFO: Setting CPU governor to performance..." >>"$LOG"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
	echo "performance" >"$file"
done
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Enable CPU governor on-demand mode
echo "$(date) INFO: Setting CPU governor to ondemand..." >>"$LOG"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
	echo "ondemand" >"$file"
done
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Unbind devices
echo "$(date) INFO: Unbinding devices..." >>"$LOG"
for dev in $VIRSH_DEVICES; do
	virsh nodedev-reattach "$dev"
done

# Unload vfio
echo "$(date) INFO: Unloading vfio..." >>"$LOG"
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

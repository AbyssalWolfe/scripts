#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Load vfio
echo "$(date) INFO: Loading vfio..." >>"$LOG"
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci

# Rebind devices to vfio
echo "$(date) INFO: Rebinding devices to vfio..." >>"$LOG"
for dev in $VIRSH_DEVICES; do
	echo "$(date) INFO: Rebinding $dev to vfio..." >>"$LOG"
	virsh nodedev-detach "$dev"
done

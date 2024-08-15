#!/bin/sh

# Load the config file
. /etc/libvirt/hooks/kvm.conf

# Calculate number of hugepages to allocate from memory (in MB)
HUGEPAGES="$((MEMORY / $(($(grep Hugepagesize /proc/meminfo | awk '{print $2}') / 1024))))"

# Allocate hugepages
echo "$(date) INFO: Allocating hugepages..." >>"$LOG"
echo $HUGEPAGES >/proc/sys/vm/nr_hugepages
ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)

# Compact memory and retry if not all hugepages were allocated
TRIES=0
while [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ] && [ $TRIES -lt 1000 ]; do
	echo 1 >/proc/sys/vm/compact_memory
	echo $HUGEPAGES >/proc/sys/vm/nr_hugepages
	ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
	echo "$(date) INFO: Succesfully allocated $ALLOC_PAGES / $HUGEPAGES" >>"$LOG"
	TRIES=$((TRIES + 1))
done

# Check if all hugepages were allocated
if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]; then
	echo "$(date) ERROR: Not able to allocate all hugepages. Reverting..." >>"$LOG"
	echo 0 >/proc/sys/vm/nr_hugepages
	exit 1
else
	echo "$(date) INFO: Successfully allocated $ALLOC_PAGES hugepages." >>"$LOG"
fi

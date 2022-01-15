#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

info_print "*** PACK ROOTFS BEGIN ***"

info_print "Packing initramfs. This may take a while."

# Remove the old 'initramfs' archive if it exists.
rm -f "$WORK_DIR"/rootfs.cpio.xz

cd "$ROOTFS"

# Packs the current 'initramfs' folder structure in 'cpio.xz' archive.
find . | cpio -R root:root -H newc -o | xz -9 --check=none > "$WORK_DIR"/rootfs.cpio.xz

info_print "Packing of initramfs has finished."

cd "$SRC_DIR"

info_print "*** PACK ROOTFS END ***"

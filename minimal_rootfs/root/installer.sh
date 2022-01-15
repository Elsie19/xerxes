#!/bin/sh
set -e

dir=$(pwd)
if [ -z "$1" ]; then
	echo "You must specify a drive to install to

example:
$0 sda"
	exit 1
fi
mkfs.ext2 /dev/"$1"
mkdir -p /tmp/mnt/inst
mount /dev/"$1" /tmp/mnt/inst
cd /tmp/mnt/inst
mkdir boot
cd /tmp/mnt/device/boot
cp -r kernel.xz rootfs.xz /tmp/mnt/inst/boot
cp -r syslinux/syslinux.cfg /tmp/mnt/inst
dd if=/usr/share/mbr/mbr.bin of=/dev/"$1" bs=440 count=1
sleep 1
cd /tmp/mnt/inst
extlinux --install .
sleep 1
cd
umount /dev/"$1"

rmdir /tmp/mnt/inst

cat << DEOF

  Installation is now complete. Device '/dev/\$1' should be bootable now. Check
  the above output for any errors. You need to remove the ISO image and restart
  the system. Let us hope the installation process worked!!! :)

DEOF

cd $dir

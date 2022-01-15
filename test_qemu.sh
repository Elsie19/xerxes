#!/bin/sh

set -e

mkdir -p minimal_overlay/rootfs/etc/autorun
cat << CEOF > minimal_overlay/rootfs/etc/autorun/99_autoshutdown.sh
#!/bin/sh

# This script shuts down the OS automatically.
sleep 10 && poweroff &

echo "  Xerxes Linux will shut down in 10 seconds."

CEOF
chmod +x minimal_overlay/rootfs/etc/autorun/99_autoshutdown.sh

cat <<CEOF > minimal_boot/bios/boot/syslinux/syslinux.cfg
SERIAL 0
DEFAULT operatingsystem
LABEL operatingsystem
    LINUX /boot/kernel.xz
    APPEND console=tty0 console=ttyS0
    INITRD /boot/rootfs.xz

CEOF

./repackage.sh
qemu-system-x86_64 -m 256M -cdrom xerxes.iso -boot d -localtime -nographic &

sleep 5
if [ "$(ps -ef | grep -i "[q]emu-system")" = "" ] ; then
  info_print "$(date) | !!! FAILURE !!! Xerxes Linux is not running in QEMU."
  exit 1
else
  info_print "$(date) | Xerxes Linux is running in QEMU. Waiting for automatic shutdown."
fi

RETRY=10
while [ ! "$RETRY" = "0" ] ; do
  info_print "$(date) | Countdown: $RETRY"
  if [ "$(ps -ef | grep -i "[q]emu-system")" = "" ] ; then
    break
  fi
  sleep 30
  RETRY=$(($RETRY - 1))
done

if [ "$(ps -ef | grep -i "[q]emu-system")" = "" ] ; then
  info_print "$(date) | Xerxes Linux is not running in QEMU."
else
  info_print "$(date) | !!! FAILURE !!! Xerxes Linux is still running in QEMU."
  exit 1
fi

cat << CEOF

  ##################################################################
  #                                                                #
  # QEMU test passed. Clean manually the affected Xerxes artifacts #
  #                                                                #
  ##################################################################

CEOF

info_print "$(date) | Xerxes QEMU test - END ***"

set +e

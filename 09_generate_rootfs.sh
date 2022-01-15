#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

info_print "*** GENERATE ROOTFS BEGIN ***"

info_print "Preparing rootfs work area. This may take a while."
rm -rf "$ROOTFS"

# Copy all Busybox generated stuff to the location of our 'rootfs' folder.
cp -r "$BUSYBOX_INSTALLED" "$ROOTFS"

# Copy all rootfs resources to the location of our 'rootfs' folder.
cp -r "$SRC_DIR"/minimal_rootfs/* "$ROOTFS"

# Delete the '.keep' files which we use in order to keep track of otherwise
# empty folders.
find "$ROOTFS"/* -type f -name '.keep' -exec rm {} +

# Remove 'linuxrc' which is used when we boot in 'RAM disk' mode.
rm -f "$ROOTFS"/linuxrc

# This is for the dynamic loader. Note that the name and the location are both
# specific for 32-bit and 64-bit machines. First we check the Busybox executable
# and then we copy the dynamic loader to its appropriate location.
BUSYBOX_ARCH="$(file "$ROOTFS"/bin/busybox | cut -d' ' -f3)"
if [ "$BUSYBOX_ARCH" = "64-bit" ] ; then
  mkdir -p "$ROOTFS"/lib64
  cp "$SYSROOT"/lib/ld-linux* "$ROOTFS"/lib64
  info_print "Dynamic loader is accessed via '/lib64'."
else
  cp "$SYSROOT"/lib/ld-linux* "$ROOTFS"/lib
  info_print "Dynamic loader is accessed via '/lib'."
fi

# Copy all necessary 'glibc' libraries to '/lib' BEGIN.

# Busybox has direct dependencies on these libraries.
cp "$SYSROOT"/lib/libm.so.6 "$ROOTFS"/lib
cp "$SYSROOT"/lib/libc.so.6 "$ROOTFS"/lib
cp "$SYSROOT"/lib/libresolv.so.2 "$ROOTFS"/lib
echo 'PS1="[\u@\h \W]\$ "' > "$SYSROOT"/.bashrc

# Copy all necessary 'glibc' libraries to '/lib' END.

info_print "Reducing the size of libraries and executables."
set +e
strip -g \
  "$ROOTFS"/bin/* \
  "$ROOTFS"/sbin/* \
  "$ROOTFS"/lib/* \
  2>/dev/null
set -e

# Read the 'OVERLAY_LOCATION' property from '.config'
OVERLAY_LOCATION="$(read_property OVERLAY_LOCATION)"

if [ "$OVERLAY_LOCATION" = "rootfs" ] && \
   [ -d "$OVERLAY_ROOTFS" ] && \
   [ ! "$(ls -A "$OVERLAY_ROOTFS")" = "" ] ; then

  info_print "Merging overlay software in rootfs."

  # With '--remove-destination' all possibly existing soft links in
  # $OVERLAY_ROOTFS will be overwritten correctly.
  cp -r --remove-destination \
    "$OVERLAY_ROOTFS"/* "$ROOTFS"
  cp -r --remove-destination \
    "$SRC_DIR"/minimal_overlay/rootfs/* "$ROOTFS"
fi

echo "The rootfs area has been generated."

cd "$SRC_DIR"

info_print "*** GENERATE ROOTFS END ***"

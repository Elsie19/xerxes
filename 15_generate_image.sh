#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

info_print "*** GENERATE IMAGE BEGIN ***"

# Prepare the work area.
rm -f "$SRC_DIR"/xerxes_image.tgz
rm -rf "$WORK_DIR"/xerxes_image
mkdir -p "$WORK_DIR"/xerxes_image

if [ -d "$ROOTFS" ] ; then
  # Copy the rootfs.
  cp -r "$ROOTFS"/* \
    "$WORK_DIR"/xerxes_image
else
  info_print "Cannot continue - rootfs is missing."
  exit 1
fi

if [ -d "$OVERLAY_ROOTFS" ] && \
   [ ! "$(ls -A "$OVERLAY_ROOTFS")" = "" ] ; then

  info_print "Merging overlay software in image."

  # Copy the overlay content.
  # With '--remove-destination' all possibly existing soft links in
  # $WORK_DIR/xerxes_image will be overwritten correctly.
  cp -r --remove-destination "$OVERLAY_ROOTFS"/* \
    "$WORK_DIR"/xerxes_image
  cp -r --remove-destination "$SRC_DIR"/minimal_overlay/rootfs/* \
    "$WORK_DIR"/xerxes_image
else
  info_print "Xerxes image will have no overlay software."
fi

cd "$WORK_DIR"/xerxes_image

# Generate the image file (ordinary 'tgz').
tar -zcf "$SRC_DIR"/xerxes_image.tgz -- *

cat << CEOF

  ##################################################################
  #                                                                #
  #    Xerxes Linux image 'xerxes_image.tgz' has been generated.   #
  #                                                                #
  #    You can import the Xerxes image in Docker like this:        #
  #                                                                #
  #    docker import xerxes_image.tgz xerxes:latest                #
  #                                                                #
  #  Then you can run Xerxes shell in Docker container like this:  #
  #                                                                #
  #    docker run -it xerxes /bin/bash                             #
  #                                                                #
  ##################################################################

CEOF

info_print "*** GENERATE IMAGE END ***"

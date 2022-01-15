#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the vim source directory which ls finds, e.g. 'Pythno-3.7.0'.
cd $(ls -d neofetch-*)

rm -rf $DEST_DIR

echo "Installing '$BUNDLE_NAME'."
make -j3 install DESTDIR=$DEST_DIR

echo "Generating '$BUNDLE_NAME'."

#echo "Reducing '$BUNDLE_NAME' size."
#set +e
#strip -g $DEST_DIR/usr/bin/*
#set -e

# With '--remove-destination' all possibly existing soft links in
# '$OVERLAY_ROOTFS' will be overwritten correctly.
cp -r --remove-destination $DEST_DIR/* \
  $OVERLAY_ROOTFS

echo "Bundle '$BUNDLE_NAME' has been installed."

cd $SRC_DIR

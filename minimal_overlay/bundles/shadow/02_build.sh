#!/bin/sh

set -e

. ../../common.sh

cd $WORK_DIR/overlay/$BUNDLE_NAME

# Change to the vim source directory which ls finds, e.g. 'Pythno-3.7.0'.
cd $(ls -d shadow-*)

if [ -f Makefile ] ; then
  echo "Preparing '$BUNDLE_NAME' work area. This may take a while."
  make -j $NUM_JOBS clean
else
  echo "The clean phase for '$BUNDLE_NAME' has been skipped."
fi

rm -rf $DEST_DIR

echo "Configuring '$BUNDLE_NAME'."
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -e "224s/rounds/min_rounds/" -i libmisc/salt.c
./configure --sysconfdir=/etc \
            --with-group-name-max-length=32

echo "Building '$BUNDLE_NAME'."
make -j3

echo "Installing '$BUNDLE_NAME'."
make -j3 exec_prefix=/usr install DESTDIR=$DEST_DIR

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

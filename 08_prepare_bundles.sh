#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

info_print "*** PREPARE OVERLAY BEGIN ***"

info_print "Preparing overlay work area."
rm -rf "$WORK_DIR"/overlay*

# Read the 'OVERLAY_BUNDLES' property from '.config'
OVERLAY_BUNDLES="$(read_property OVERLAY_BUNDLES)"

if [ ! "$OVERLAY_BUNDLES" = "" ] ; then
  info_print "Generating additional overlay bundles. This may take a while."
  cd "$SRC_DIR"/minimal_overlay
  ./overlay_build.sh
  cd "$SRC_DIR"
else
  info_print "Generation of additional overlay bundles has been skipped."
fi

info_print "*** PREPARE OVERLAY END ***"

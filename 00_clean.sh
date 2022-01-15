#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

info_print "*** CLEAN BEGIN ***"

info_print "Cleaning up the main work area. This may take a while."
sudo rm -rf "$WORK_DIR"
mkdir "$WORK_DIR"
mkdir -p "$SOURCE_DIR"

info_print "*** CLEAN END ***"

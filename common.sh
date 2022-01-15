#!/bin/sh

set -e

bold=$(tput bold)
blue="\e[0;94m"
yellow="\e[0;33m"
reset="\e[0m"
normal=$(tput sgr0)
SRC_DIR=$PWD
CONFIG=$SRC_DIR/.config
SOURCE_DIR=$SRC_DIR/source
WORK_DIR=$SRC_DIR/work
KERNEL_INSTALLED=$WORK_DIR/kernel/kernel_installed
GLIBC_OBJECTS=$WORK_DIR/glibc/glibc_objects
GLIBC_INSTALLED=$WORK_DIR/glibc/glibc_installed
BUSYBOX_INSTALLED=$WORK_DIR/busybox/busybox_installed
SYSROOT=$WORK_DIR/sysroot
ROOTFS=$WORK_DIR/rootfs
OVERLAY_ROOTFS=$WORK_DIR/overlay_rootfs
ISOIMAGE=$WORK_DIR/isoimage
ISOIMAGE_OVERLAY=$WORK_DIR/isoimage_overlay

# This function reads property from the main '.config' file.
#
# Using () instead of {} for the function body is a POSIX
# compliant way to execute subshell and as consequence all
# variables in the function will become effectively in local
# scope. Note that the 'local' keyword is supported by most
# shells but it is not POSIX compliant.
read_property() (
  # The property we are looking for.
  prop_name="$1"

  # The value of the property set initially to empty string.
  prop_value=

  if [ ! "$prop_name" = "" ] ; then
    # Search in the main '.config' file.
    prop_value="$(grep -i ^${prop_name}= $CONFIG | cut -f2- -d'=' | xargs)"
  fi

  echo $prop_value
)

# Read commonly used properties from the main '.config' file.
JOB_FACTOR="$(read_property JOB_FACTOR)"
CFLAGS="$(read_property CFLAGS)"
NUM_CORES="$(grep -c ^processor /proc/cpuinfo)"

# Calculate the number of 'make' jobs to be used later.
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))

download_source() (
  url=$1  # Download from this URL.
  file=$2 # Save the resource in this file.

  local="$(read_property USE_LOCAL_SOURCE)"

  if [ "$local" = "true" -a ! -f "$file"  ] ; then
    echo "${bold}Source file '$file' is missing and will be downloaded.${normal}"
    local=false
  fi

  if [ ! "$local" = "true" ] ; then
    echo "${bold}Downloading source file from '$url'.${normal}"
    echo "${bold}Saving source file in '$file'.${normal}"
    wget -O "$file" -c "$url"
  else
    echo "${bold}Using local source file '$file'.${normal}"
  fi
)

extract_source() (
  file=$1
  name=$2

  # Delete folder with previously extracted source.
  echo "${bold}Removing '$name' work area. This may take a while.${normal}"
  rm -rf "${WORK_DIR:?}"/"$name"
  mkdir "${WORK_DIR:?}"/"$name"

  # Extract source to folder 'work/$source'.
  tar -xvf "$file" -C "${WORK_DIR:?}"/"$name"
)

info_print() {
  echo "${yellow}*${reset} ${blue}$*${reset}"
}

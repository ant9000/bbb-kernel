#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd "$BASE"

# latest 6.6 LTS kernel with PREEMPT_RT patches
KERNEL_GIT=https://git.kernel.org/pub/scm/linux/kernel/git/rt/linux-stable-rt.git
KERNEL_TAR=$(curl -s "$KERNEL_GIT" | perl -ne 'm{(linux-stable-rt-6\.6\.\d+-rt\d+\.tar\.gz)} && print "$1",$/;' | sort -rV | head -1)
KERNEL_TAR=linux-stable-rt-6.6.65-rt47.tar.gz
KERNEL_URL=$KERNEL_GIT/snapshot/$KERNEL_TAR
KERNEL_DIR=${KERNEL_TAR%\.t*}
CM3_FIRMWARE_URL=https://git.ti.com/cgit/processor-firmware/ti-amx3-cm3-pm-firmware/snapshot/ti-amx3-cm3-pm-firmware-08.04.01.001.tar.gz
CM3_FIRMWARE_TAR=$(basename $CM3_FIRMWARE_URL)
CM3_FIRMWARE_DIR=${CM3_FIRMWARE_TAR%.tar.gz}

[ -d downloads ] || mkdir downloads
[ -f "downloads/$KERNEL_TAR" ] || curl -o "downloads/$KERNEL_TAR" "$KERNEL_URL"
[ -d "$KERNEL_DIR" ] || tar xvf "downloads/$KERNEL_TAR"
[ "$(readlink linux-src)" == "$KERNEL_DIR" ] || {
  [ -L linux-src ] && rm linux-src
  ln -s "$KERNEL_DIR" linux-src
}
[ -f "downloads/$CM3_FIRMWARE_TAR" ] || curl -o "downloads/$CM3_FIRMWARE_TAR" "$CM3_FIRMWARE_URL"
[ -d "$CM3_FIRMWARE_DIR" ] || tar xvf "downloads/$CM3_FIRMWARE_TAR"
[ "$(readlink ti-amx3-cm3-pm-firmware)" == "$CM3_FIRMWARE_DIR" ] || {
  [ -L ti-amx3-cm3-pm-firmware ] && rm ti-amx3-cm3-pm-firmware
  ln -s "$CM3_FIRMWARE_DIR" ti-amx3-cm3-pm-firmware
}

which arm-none-eabi-gcc > /dev/null || sudo apt install gcc-arm-none-eabi

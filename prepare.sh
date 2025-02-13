#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd "$BASE"

# latest 6.6 LTS kernel with PREEMPT_RT patches
KERNEL_GIT=https://git.kernel.org/pub/scm/linux/kernel/git/rt/linux-stable-rt.git
KERNEL_TAR=$(curl -s "$KERNEL_GIT" | perl -ne 'm{(linux-stable-rt-6\.6\.\d+-rt\d+\.tar\.gz)} && print "$1",$/;' | sort -rV | head -1)
KERNEL_URL=$KERNEL_GIT/snapshot/$KERNEL_TAR
KERNEL_DIR=${KERNEL_TAR%\.t*}

[ -d downloads ] || mkdir downloads
[ -f "downloads/$KERNEL_TAR" ] || curl -o "downloads/$KERNEL_TAR" "$KERNEL_URL"
[ -d "$KERNEL_DIR" ] || tar xvf "downloads/$KERNEL_TAR"
[ "$(readlink linux-src)" == "$KERNEL_DIR" ] || {
  [ -L linux-src ] && rm linux-src
  ln -s "$KERNEL_DIR" linux-src
}

which arm-none-eabi-gcc > /dev/null || sudo apt install gcc-arm-none-eabi

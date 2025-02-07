#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd $BASE

MAKE_ARGS="ARCH=arm CROSS_COMPILE=arm-none-eabi- -j$(nproc)"

if [ ! -d build ]; then
  cd linux-src
  make mrproper
  make O=$BASE/build $MAKE_ARGS omap2plus_defconfig
  cd $BASE/build
  cp $BASE/defconfig .config
  make $MAKE_ARGS olddefconfig
  cd $BASE
fi

cd build

if [ ! -z $1 ]; then
  make $MAKE_ARGS $*
  exit 0
fi

make $MAKE_ARGS zImage modules dtbs
make $MAKE_ARGS modules_install INSTALL_MOD_PATH=$BASE/deploy/
KERNEL=$(make kernelrelease)
make $MAKE_ARGS savedefconfig

cd $BASE
[ -d deploy/boot/extlinux ] || mkdir -p deploy/boot/extlinux
cp build/defconfig deploy/boot/config-${KERNEL}
cp build/arch/arm/boot/zImage deploy/boot/
cp build/arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb deploy/boot/
cat > deploy/boot/extlinux/extlinux.conf <<EOF
label Linux microSD
    kernel /zImage
    devicetree /am335x-boneblack.dtb
    append console=ttyS0,115200n8 root=/dev/mmcblk0p2 rw rootfstype=ext4 rootwait earlyprintk mem=512M
EOF

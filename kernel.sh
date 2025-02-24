#!/bin/bash

set -e
BASE=$(dirname $(realpath $0))
cd "$BASE"

MAKE_ARGS="ARCH=arm CROSS_COMPILE=arm-none-eabi- -j$(nproc)"

if [ ! -d build ]; then
  cd linux-src
  make mrproper
  make O=../build $MAKE_ARGS omap2plus_defconfig
  cd ../build
  cp ../defconfig .config
  make $MAKE_ARGS olddefconfig
  cd ..
fi

cd build

if [ ! -z $1 ]; then
  make $MAKE_ARGS $*
  exit 0
fi

[ -d ../deploy ] && rm -rf ../deploy
make $MAKE_ARGS zImage modules dtbs
make $MAKE_ARGS modules_install INSTALL_MOD_PATH=../deploy/
KERNEL=$(make kernelrelease)
make $MAKE_ARGS savedefconfig

cd ..
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

[ -d rtl88x2bu ] || git clone https://github.com/RinCat/RTL88x2BU-Linux-Driver.git rtl88x2bu
cd rtl88x2bu
make $MAKE_ARGS KSRC=../build/ LOCALVERSION=$KERNEL
dest=../deploy/lib/modules/${KERNEL}/kernel/drivers/net/wireless/realtek/88x2bu/
[ -d $dest ] || mkdir -p $dest
rm -f ${dest}/*.ko
find . -name \*.ko -exec cp {} ${dest} \;
mkdir -p ../deploy/etc/modprobe.d/
echo "options 88x2bu rtw_switch_usb_mode=2 rtw_drv_log_level=2" > ../deploy/etc/modprobe.d/rtl88x2bu.conf
cd ..

# depmod -a
/sbin/depmod -b deploy/ -F build/System.map ${KERNEL}

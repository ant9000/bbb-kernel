### BBB with mainline u-boot and kernel

  https://community.element14.com/products/devtools/single-board-computers/next-genbeaglebone/b/blog/posts/booting-beagleboneblack-with-the-mainline-uboot-and-linux-kernel

### PREEMPT_RT kernels

  https://wiki.linuxfoundation.org/realtime/preempt_rt_versions

### UPDATED RTW88 DRIVER

  https://github.com/lwfinger/rtw88

### USAGE

Use `prepare.sh` to download and unpack the latest 6.6 kernel with RT patches, and a toolchain for compiling it (written for Debian or apt-based Linux distros):

```
git clone https://github.com/ant9000/bbb-kernel
cd bbb-kernel
./prepare.sh
```

To configure kernel:

```
./kernel.sh menuconfig
```

To compile a kernel with current settings:

```
./kernel.sh
```

Compiled kernel will be available in the `deploy/` directory tree.

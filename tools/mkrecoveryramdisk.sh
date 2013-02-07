#!/bin/bash

# $1: root dir

if [ $# -ne 1 ]; then
    echo "Error: wrong number of arguments in cmd: $0 $* "
    return
fi

ROOTDIR=$1

pushd $ROOTDIR
find . -print |cpio -H newc -o |gzip -9 > ../../recovery.ramdisk.cpio.gz
mkimage -A arm -O linux -T ramdisk -n "Recovery Ram Disk" -d ../../recovery.ramdisk.cpio.gz ../../initrd_recovery.u-boot
popd
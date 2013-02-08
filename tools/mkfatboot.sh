#!/bin/bash

# $1: image name
# $2: prod out dir
# $3: root dir
# $4: bootscript

if [ $# -ne 4 ]; then
    echo "Error: wrong number of arguments in cmd: $0 $* "
    return
fi

echo "image: $1 prod_out: $2 root: $3 bootscript: $4"

IMAGE=$1
OUTDIR=$2
ROOTDIR=$3
BOOTSCRIPT=$4

IMAGEFILE=$OUTDIR/obj/$IMAGE

rm $IMAGEFILE > /dev/null 2>&1
mkfs.vfat -C $IMAGEFILE 20480 

#copy files to image
mcopy -i $IMAGEFILE $OUTDIR/initrd_recovery.u-boot ::/
mcopy -i $IMAGEFILE $OUTDIR/initrd.u-boot ::/
mcopy -i $IMAGEFILE $ROOTDIR/kernel_imx/arch/arm/boot/uImage ::/uImage53
mcopy -i $IMAGEFILE $ROOTDIR/bootable/bootloader/uboot-imx/board/boundary/nitrogen53/$BOOTSCRIPT ::/

#lib and modules, create temp dir structure
touch $OUTDIR/obj/.bcb
mkdir $OUTDIR/obj/tmpboot > /dev/null 2>&1
mkdir $OUTDIR/obj/tmpboot/lib > /dev/null 2>&1
mkdir $OUTDIR/obj/tmpboot/lib/modules > /dev/null 2>&1

#copy files to temp
cp -ravf $ROOTDIR/kernel_imx/drivers/media/video/mxc/capture/*.ko $OUTDIR/obj/tmpboot/lib/modules/
cp -rvf $ROOTDIR/kernel_imx/drivers/i2c/xrp6840.ko $OUTDIR/obj/tmpboot/lib/modules/

cp $ROOTDIR/compat-wireless/drivers/net/wireless/wl12xx/wl12xx.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/drivers/net/wireless/wl12xx/wl12xx_sdio.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/net/mac80211/mac80211.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/net/wireless/cfg80211.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/compat/compat.ko $OUTDIR/obj/tmpboot/lib/modules/

cp $ROOTDIR/compat-wireless/net/bluetooth/hidp/hidp.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/net/bluetooth/rfcomm/rfcomm.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/net/bluetooth/bnep/bnep.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/net/bluetooth/bluetooth.ko $OUTDIR/obj/tmpboot/lib/modules/
cp $ROOTDIR/compat-wireless/drivers/bluetooth/hci_uart.ko $OUTDIR/obj/tmpboot/lib/modules/

#copy .bcb file
mcopy -s -i $IMAGEFILE $OUTDIR/obj/.bcb ::/

#copy modules into image
mcopy -s -i $IMAGEFILE $OUTDIR/obj/tmpboot/lib ::/
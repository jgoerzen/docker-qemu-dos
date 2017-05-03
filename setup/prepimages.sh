#!/bin/bash

set -e
set -x

. /usr/local/bin/imagefuncs.sh

cd /tmp/setup
unzip /tmp/setup/FreeDOS1.2net.vhd.zip
rm /tmp/setup/FreeDOS1.2net.vhd.zip
qemu-img convert -O qcow2 FreeDOS1.2net.vhd baseprep.qcow2
rm FreeDOS1.2net.vhd
gzip baseprep.qcow2

# Now customize our image.
prepimageedit baseprep.qcow2.gz

prepsed C:FDCONFIG.SYS
patch "$TEMPSED" /tmp/setup/fdconfig.sys.patch
finishsed

prepsed C:AUTOEXEC.BAT
echo "D:\\BOOTUP" >> "$TEMPSED"
finishsed

# This suppresses the login prompt at boot
mcopy -D o /tmp/setup/FREEDOS.PWL c:/net

finishimageedit "/dos/baseimages/freedos-c-net.qcow2"
gzip -9 /dos/baseimages/freedos-c-net.qcow2

rm baseprep.qcow2.gz


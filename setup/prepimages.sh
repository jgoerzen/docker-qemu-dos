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

mcopy -D o WORKING/FDCONFIG.SYS C:
mcopy -D o WORKING/AUTOEXEC.BAT C:

prepsed C:AUTOEXEC.BAT
echo "D:\\BOOTUP" >> "$TEMPSED"
finishsed

# This suppresses the login prompt at boot
mcopy -D o /tmp/setup/FREEDOS.PWL c:/net

finishimageedit "/dos/baseimages/freedos-c-net.qcow2"
gzip -9 /dos/baseimages/freedos-c-net.qcow2

rm baseprep.qcow2.gz


#!/bin/bash

set -e
set -x

# Plan:
# G holds the apps (runtime stuff written out)
# H holds static tools/utils.  G:\UTILS on path.
# I and J are not mounted by default.

mkdir -p /dos/drive_{g,h,i,j,k}
mkdir /dos/baseimages
mkdir /dos/runimages
mkdir /dos/drive_h/UTILS

cd /tmp/setup
wget https://www.lazybrowndog.net/freedos/virtualbox/downloads/vhd/FreeDOS1.2net.vhd.zip

# parted 3.x dropped resize command.
wget http://snapshot.debian.org/archive/debian/20130107T153033Z/pool/main/p/parted/libparted0debian1_2.3-12_amd64.deb
wget http://snapshot.debian.org/archive/debian/20130107T153033Z/pool/main/p/parted/parted_2.3-12_amd64.deb
#wget http://http.us.debian.org/debian/pool/main/p/parted/parted_2.3-12_amd64.deb
#wget http://http.us.debian.org/debian/pool/main/p/parted/libparted0debian1_2.3-12_amd64.deb

sha256sum -c < sums


dpkg -i /tmp/setup/*.deb
echo "parted hold" | dpkg --set-selections
echo "libparted0debian1 hold" | dpkg --set-selections
rm /tmp/setup/*.deb

########
# Prepare the images

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
cd /


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
zcat freedos-c.qcow2.gz > /dos/baseimages/freedos-c-minimal.qcow2
rm freedos-c.qcow2.gz

dpkg -i /tmp/setup/*.deb
echo "parted hold" | dpkg --set-selections
echo "libparted0debian1 hold" | dpkg --set-selections


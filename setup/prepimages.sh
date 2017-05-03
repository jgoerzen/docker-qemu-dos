#!/bin/bash

set -e
set -x

. /usr/local/bin/imagefuncs.sh

cd /tmp/setup
unzip /tmp/setup/FreeDOS1.2net.vhd.zip
rm /tmp/setup/FreeDOS1.2net.vhd.zip
qemu-img convert FreeDOS1.2net.vhd baseprep.qcow2
rm FreeDOS1.2net.vhd
gzip baseprep.qcow2

# Now customize our image.
prepimageedit baseprep.qcow2.gz



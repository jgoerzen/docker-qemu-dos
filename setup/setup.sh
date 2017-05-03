#!/bin/bash

set -e
set -x

mkdir -p /dos/drive_{g,h,i,j,k}
mkdir /dos/drive_g/{BOOT,SCRIPTS}
mkdir /dos/baseimages
mkdir /dos/runimages

cd /tmp/setup
zcat freedos-c.qcow2.gz > /dos/baseimages/freedos-c-minimal.qcow2
rm freedos-c.qcow2.gz


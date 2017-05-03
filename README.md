# qemu for running DOS in Docker Server

This image can be used standalone, or as a base for other images.

It provides a qemu environment and a VNC console for it, running on
port 5901.  This can be used for various guest OSs, but the image
has special additional support for running DOS guests.  It is built
on my generic [jgoerzen/qemu](https://github.com/jgoerzen/docker-qemu).

# Install and run

You can install with:

    docker pull jgoerzen/qemu-dos

And run with:

    docker run -d -p 5901:5901 --name myqemu jgoerzen/qemu-dos

# Installed files for DOS

All the fun happens under `/dos`.

Under `/dos/baseimages`, there are two drive C: images that can be used
for booting.  The basic one is `/dos/baseimages/freedos-c-minimal.qcow2.gz`,
which is a typical FreeDOS 1.2 basic installation plus a TCP/IP stack.  It is ready to run as-is.

The more interesting one can be found at `/dos/baseimages/freedos-c-net.qcow2`.
It is based on the [FreeDOS 1.2NET image](https://www.lazybrowndog.net/freedos/virtualbox/?page_id=33),
and contains, among other things, support for TCP/IP and mounting network
shares.  There is a whole infrastructure around using this as the base
image for spinning up a bunch of qemu images (eg, for multi-node BBSs)
with shared file store using samba.  This will be described later.

By default, nodes start the net image and the console starts the basic image.

Also:

- `/dos/runimages` is where runtime images get stored.  It should be
  empty when the container boots the first time; images will be created on demand.
- `/dos/drive_g` through `drive_k` are shared to the net image systems
   via samba as `G:` through `K:`.
   - `G:` is intended to be used for applications (which, in DOS, tend to
     write to their install directories, so this could make an ideal volume)
   - `H:` is intended to be static, and hold utilities, etc.  `H:\UTILS` is
     added to the DOS PATH by the default startup scripts.
   - `G:` and `H:` are mounted in the DOS image by the default startup scripts,
     though it would be easy to mount the others as well.
   - Child images may, but are not required to, follow this convention:
- `G:` and `H:` are copied to the local `D:` filesystem for those images
   that do not have the ability to mount the Samba drive.

This image uses supervisor; please see the supervisor/ directory for
examples.  Adding your own processes is very simple.

# Environment variable

 - `VNCPASSWORD` can set the password for the VNC console
   (maximum 8 characters, a limitation of tightvncserver).  If you do not set
   one, a random password will be assigned on each start of the container, and
   logged in the docker logs.

# VNC-based console

VNC is exposed on port 5901.  You can connect to this port.  You will see, by default,
an xterm (white) and a qemu terminal (black) running here, though
child images may alter these defaults.

# Included startup scripts

There are scripts to help get your systems going.  They, basically:

 - Make a copy of `/dos/baseimages/freedos-c-net.qcow2`, storing it and the
   rest of the data referenced here under `/dos/runimages`.
 - Patch the copied image to set the SMB machine name to a unique
   session name.
 - Create a `/dos/baseimages/SESSION/drive_d/BOOTUP.BAT` file that
   configures the SMB client and mounts the shared drives.  This file
   is called by the end of AUTOEXEC.BAT and is presented as a VFAT
   partition on `D:` to the environment.
 - Spawn QEMU and then clean up the temporary setup.

The relevant scripts are installed to `/usr/local/bin` and reading them
will help you fit it all together.  In this image,
`qemuconsole` is called from `supervisord` to create the default image.
It calls `mksessimg` to build the customized directory for the qemu invocation,
then runs qemu.  qemu puts its console on VNC port :2, and opens a serial
connection to TCP port 7000.  (tcpser or some such could be ideal
for monitoring this).

# Sources

This is prepared by John Goerzen <jgoerzen@complete.org> and the source
can be found at https://github.com/jgoerzen/docker-bbs/tree/master/qemu-dos

# Included Software

- Parted version 2 is pulled in from an old Debian version.  This version is
  used because it can resize partitions (resize command dropped in parted 3.x)
- The DOS drive C minimal image is prepared from FreeDOS with standard "full install" plus
the network basics as documented in [their HOWTO](http://wiki.freedos.org/wiki/index.php/Networking_FreeDOS_-_Quick_Networking_HowTo).  To this, only XFS plus the CRT patch
have been added.  (Note: XFS does not seem to be working in a modern environment.)
- The base OS is [FreeDOS](http://www.freedos.org/) 1.2.
- The FreeDOS distribution is [1.2NET](https://www.lazybrowndog.net/freedos/virtualbox/?page_id=33)
- I have customized CONFIG.SYS to work around some bugs and improve idle
  CPU usage.  AUTOEXEC.BAT just makes a quick call.


# References and information

- [User-space NFS server UNFS3](http://unfs3.sourceforge.net/)
- [XFS, a DOS NFS client](ftp://ftp.cc.umanitoba.ca/software/pc_network/)
  - [Info on PATCHCRT to address Runtime error 200](http://www.pcmicro.com/elebbs/faq/rte200.html)
- [Using FreeDOS on QEMU](https://en.wikibooks.org/wiki/QEMU/FreeDOS)
- [FreeDOS](http://www.freedos.org/)
- FreeDOS client
  - [FreeDOS with client](https://www.lazybrowndog.net/freedos/virtualbox/?page_id=8)
  - [Networking FreeDOS](http://wiki.freedos.org/wiki/index.php/Networking_FreeDOS_-_MS_Client)
  - [Share a Linux folder with FreeDOS](https://www.lazybrowndog.net/freedos/virtualbox/?page_id=374)
- [QEMU networking](https://en.wikibooks.org/wiki/QEMU/Networking#SMB_server)
  - [QEMU's SMB server](https://wiki.archlinux.org/index.php/QEMU#QEMU.27s_built-in_SMB_server)
- [strace on Docker](https://github.com/moby/moby/issues/21051)
  - magic incantation was: --privileged --cap-add SYS_PTRACE --security-opt seccomp:unconfined
- Dealing with DOS not idling CPU
  - [VirtualBox Heat](http://wiki.freedos.org/wiki/index.php/VirtualBox_-_Heat)
  - [DOSIDLE commands](http://www.scampers.org/steve/vmware/)
- [Dealing with RunTime Error 200](http://www.pcmicro.com/elebbs/faq/rte200.html)

# Copyright

Docker scripts, etc. are
Copyright (c) 2017 John Goerzen 
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of the University nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

Additional software copyrights as noted.


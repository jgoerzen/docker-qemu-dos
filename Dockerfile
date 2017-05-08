FROM jgoerzen/qemu
MAINTAINER John Goerzen <jgoerzen@complete.org>

RUN apt-get update && \
    apt-get -y -u dist-upgrade && \
    apt-get -y --no-install-recommends install \
            fatresize mtools dosfstools samba diffutils dos2unix patch && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY scripts/ /usr/local/bin/
COPY setup/ /tmp/setup/
# Do the download ASAP so we don't hit the download sites overly hard
COPY supervisor/ /etc/supervisor/conf.d/
COPY freedos-c-minimal.qcow2.gz /dos/baseimages/freedos-c-minimal.qcow2.gz
COPY smb.conf /etc/samba/smb.conf
RUN /tmp/setup/setup.sh
RUN rm -rf /tmp/setup

EXPOSE 5901
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]


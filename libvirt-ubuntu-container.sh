#!/bin/sh
set -e
##### flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
##### flatpak install --user org.virt_manager.virt-manager
if [ -z ${CONTAINER_ENGINE} ] ; then CONTAINER_ENGINE='docker' ; fi
mkdir -pv /var/run/libvirt
${CONTAINER_ENGINE} run \
    -d \
    --name libvirt \
    --net host \
    --cgroupns host \
    --pids-limit=-1 \
    --user root:root \
    --privileged \
    --security-opt label=disable \
    --security-opt apparmor=unconfined \
    --annotation run.oci.keep_original_groups=1 \
    --cap-add=ALL \
    -v /dev:/dev:rslave \
    -v /sys:/sys:rslave \
    -v libvirt-files-save:/var/lib/libvirt:Z \
    -v libvirt-state-save:/etc/libvirt:Z \
    -v libvirt-cache-save:/var/cache:Z \
    -v libvirt-root-save:/root:Z \
    -v /var/run/libvirt:/var/run/libvirt:Z \
    ubuntu:24.04 bash -xc "
                        export DEBIAN_FRONTEND=noninteractive
                        apt-get update
                        apt-get install -y \
                            libvirt-daemon-system \
                            qemu-kvm
                        setsid --fork /usr/sbin/virtlogd >/dev/null 2>/dev/null
                        sleep 10
                        setsid --fork /usr/sbin/virtlockd >/dev/null 2>/dev/null
                        /usr/sbin/libvirtd
                        sleep infinity"

#!/bin/sh
set -e
##### flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
##### flatpak install --user org.virt_manager.virt-manager
if [ -z ${CONTAINER_ENGINE} ] ; then CONTAINER_ENGINE='docker' ; fi
rm -rv /run/libvirt /run/libvirt-container
mkdir /run/libvirt-container
ln -sf /run/libvirt-container/libvirt /run/libvirt
${CONTAINER_ENGINE} run \
    -dt \
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
    -v /run/libvirt-container:/run:Z \
    ubuntu:24.04 bash -xc "
                        export DEBIAN_FRONTEND=noninteractive
                        apt-get update
                        apt-get install -y \
                            libvirt-daemon-system \
                            qemu-kvm
                            systemd
                        UNIT_TARGETS_TO_MASK='
		                        /usr/lib/systemd/system/*.mount
		                        /usr/lib/systemd/system/console-getty.service
		                        /usr/lib/systemd/system/getty@.service
		                        /usr/lib/systemd/system/systemd-machine-id-commit.service
		                        /usr/lib/systemd/system/systemd-binfmt.service
		                        /usr/lib/systemd/system/systemd-tmpfiles*
		                        /usr/lib/systemd/system/systemd-udevd.service
		                        /usr/lib/systemd/system/systemd-udev-trigger.service
		                        /usr/lib/systemd/systemd-resolved
		                        /usr/lib/systemd/system/modprobe*
		                        /usr/lib/systemd/system/dpkg*
		                        /usr/lib/systemd/system/apt*
		                        /usr/lib/systemd/system/systemd-update-utmp*
	                    '
                        for unit in \$(find \${UNIT_TARGETS_TO_MASK} 2> /dev/null); do
                            systemctl mask \"\$(basename \"\${unit}\")\" || :
                        done
                        for socket_unit in 'libvirtd.socket' 'libvirtd-admin.socket' 'libvirtd-ro.socket' ; do
                            sed -i 's/SocketMode.*/SocketMode=0777/g' /usr/lib/systemd/system/\$socket_unit
                        done
                        echo -e 'ForwardToConsole=yes\nTTYPath=/dev/console' >> /etc/systemd/journald.conf
                        /usr/lib/systemd/systemd"

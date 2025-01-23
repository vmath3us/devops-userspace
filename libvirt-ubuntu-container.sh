#!/bin/sh
##### flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
##### flatpak install --user org.virt_manager.virt-manager
if [ $(whoami) != "root" ] ; then exit 1 ; fi

docker image inspect docker-ubuntu-libvirt-systemd >>/dev/null ||
(
cat <<-IS_DOCKERFILE
FROM ubuntu:noble

SHELL [ "/bin/bash", "-xc" ]

ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF
echo 'export LC_ALL=pt_BR.UTF-8' >> /etc/profile.d/locale.sh
echo 'export LANG=pt_BR.UTF-8' >> /etc/profile.d/locale.sh
echo 'LANG=pt_BR.UTF-8' >> /etc/locale.conf
apt-get update
apt-get install -y locales tzdata
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure -fnoninteractive tzdata
echo -e 'pt_BR.UTF-8 UTF-8\nen_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

export LANG='pt_BR.UTF-8'
export LANGUAGE='pt_BR:en'
export LC_ALL='pt_BR.UTF-8'

apt-get install -y \\
            libvirt-daemon-system \\
            qemu-kvm \\
            virtiofsd \\
            vim \\
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
            /usr/lib/systemd/system/systemd-update-utmp*
            /usr/lib/systemd/systemd-resolved
            /usr/lib/systemd/system/modprobe*
            /usr/lib/systemd/system/dpkg*
            /usr/lib/systemd/system/apt*
'
for unit in \$(find \${UNIT_TARGETS_TO_MASK} 2> /dev/null); do
        systemctl mask \$(basename \${unit}) || :
done
for socket_unit in 'libvirtd.socket' 'libvirtd-admin.socket' 'libvirtd-ro.socket' ; do
        sed -i 's/SocketMode.*/SocketMode=0777/g' /usr/lib/systemd/system/\$socket_unit
done
echo '
ForwardToConsole=yes
TTYPath=/dev/console
' >> /etc/systemd/journald.conf
EOF
ENTRYPOINT [ "/bin/bash" , "-xc" , "echo -e '127.0.0.1  localhost\\n::1 localhost' > /etc/hosts; for i in {0..10} ; do ip link del virbr\$i ; done ;   exec /usr/lib/systemd/systemd" ]
IS_DOCKERFILE
)| docker build - -t docker-ubuntu-libvirt-systemd --progress=plain

rm -rv /run/libvirt /run/libvirt-container
mkdir /run/libvirt-container
ln -sf /run/libvirt-container/libvirt /run/libvirt

docker run \
    -dt \
    --name libvirt \
    --net host \
    --cgroupns host \
    --dns 127.0.0.53 \
    --pids-limit=-1 \
    --user root:root \
    --privileged \
    --security-opt label=disable \
    --security-opt apparmor=unconfined \
    --annotation run.oci.keep_original_groups=1 \
    -v /dev:/dev \
    -v /sys:/sys \
    -v /run/libvirt-container:/run:Z \
    -v libvirt-default-shared:/libvirt-default-shared:Z \
    -v libvirt-files-save:/var/lib/libvirt:Z \
    -v libvirt-state-save:/etc/libvirt:Z \
    -v libvirt-cache-save:/var/cache:Z \
    -v libvirt-root-save:/root:Z \
    --cap-add=ALL \
    docker-ubuntu-libvirt-systemd 

docker logs -f libvirt
#### mount -t virtiofs      virtioshare         /host-path
####                        tag no libvirt     path no convidado

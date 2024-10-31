#!/bin/sh
set -e
### ${1} is only key, assume ED25519
#### if your key is     ssh-ed2559 my-key name-key
#### run
#### bash <this-script> 'my-key'
####
#### access using virt-manager remote-mode   (thanks 89luca89 -> https://github.com/89luca89/distrobox/blob/main/docs/posts/run_libvirt_in_distrobox.md#connect-via-ssh)
if [ -z ${1} ] ; then
    echo 'ssh pubkey null; exiting'
    exit
fi
ROOT_PASSWORD=$(echo "${1}" | sha1sum | awk '{print $1}')
if [ -z ${CONTAINER_ENGINE} ] ; then CONTAINER_ENGINE='docker' ; fi
${CONTAINER_ENGINE} run \
    -d \
    --env ROOT_PASSWORD=${ROOT_PASSWORD} \
    --env SSH_PUBKEY="${1}" \
    --name libvirt \
    --net host \
    --cgroupns host \
    --pids-limit=-1 \
    --user root:root \
    --privileged \
    --security-opt label=disable \
    --security-opt apparmor=unconfined \
    --annotation run.oci.keep_original_groups=1 \
    -v /dev:/dev:rslave \
    -v /sys:/sys:rslave \
    -v libvirt-files-save:/var/lib/libvirt:Z \
    -v libvirt-state-save:/etc/libvirt:Z \
    -v libvirt-cache-save:/var/cache:Z \
    -v libvirt-root-save:/root:Z \
    --cap-add=ALL \
    ubuntu:24.04 bash -xc "
                        export DEBIAN_FRONTEND=noninteractive
                        apt-get update
                        apt-get install -y \
                            ssh \
                            libvirt-daemon-system \
                            qemu-kvm
                        ssh-keygen -A
                        printf \"\${ROOT_PASSWORD}\n\${ROOT_PASSWORD}\" | passwd root
                        sed -i \
                        	-e \"s/#ListenAddress.*/ListenAddress 127.0.0.1/g\" \
                        	-e \"s/#Port.*/Port 10100/g\" \
                        	-e \"s/#PermitRoot.*/PermitRootLogin yes/g\" \
                        	/etc/ssh/sshd_config
                        mkdir -pv /root/.ssh
                        echo \"ssh-ed25519 \${SSH_PUBKEY} libvirtkey\" >> /root/.ssh/authorized_keys
                        mkdir -pv /run/sshd
                        /usr/sbin/sshd
                        setsid --fork /usr/sbin/virtlogd >/dev/null 2>/dev/null
                        sleep 10
                        setsid --fork /usr/sbin/virtlockd >/dev/null 2>/dev/null
                        /usr/sbin/libvirtd
                        sleep infinity"

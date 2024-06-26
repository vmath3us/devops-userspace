#!/bin/bash
if [ -z $CONTAINER_ENGINE ] ; then CONTAINER_ENGINE="docker" ; fi
"${CONTAINER_ENGINE}" create \
        --restart=unless-stopped \
        --entrypoint /bin/sh \
        --tty \
        --interactive \
        --name machine-owner \
        --privileged \
        --security-opt label=disable \
        --security-opt apparmor=unconfined \
        --pids-limit=-1 \
        --user root:root \
        --ipc host \
        --network host \
        --pid host \
        --volume /:/run/host:rslave \
        --volume /dev:/dev:rslave \
        --volume /sys:/sys:rslave \
        --cap-add=ALL \
        alpine:edge -ec "if [ ! -e /root/.zshrc ] ;then
                            apk add curl
                            curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/sh-provisioning.sh | sh
                            fi
                            sleep infinity"
"${CONTAINER_ENGINE}" start machine-owner
"${CONTAINER_ENGINE}" logs -f machine-owner

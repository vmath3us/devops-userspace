#!/bin/sh
if [ -z $CONTAINER_ENGINE ] ; then
        CONTAINER_ENGINE="docker"
            if [ -z $ROOTLESS ] ; then
                socket_origin="-v /var/run/docker.sock"
            else
                socket_origin="-v /run/user/$(id -g)/docker.sock"
            fi
        socket_mount_string="${socket_origin}:/var/run/docker.sock:Z --env DOCKER_HOST=unix:///var/run/docker.sock"
elif [ $CONTAINER_ENGINE = "podman" ] ; then
        if [ -z $ROOTLESS ] ; then
            eval "podman system service unix:/run/podman.sock --time 0 &"
            socket_origin="-v /run/podman.sock"
        else
            eval "podman system service unix:/run/user/$(id -g)/podman/podman.sock --time=0 &"
            socket_origin="-v /run/user/$(id -g)/podman/podman.sock"
        fi
        socket_mount_string="${socket_origin}:/var/run/podman.sock:Z --env CONTAINER_HOST=unix:/var/run/podman.sock"
fi
eval "$CONTAINER_ENGINE run \
-i --rm \
--security-opt label=disable \
${socket_mount_string} \
--env CONTAINER_ENGINE=${CONTAINER_ENGINE} \
alpine:edge sh -uelic 'apk add --update curl $CONTAINER_ENGINE
    $CONTAINER_ENGINE build --no-cache -t devops-userspace-$CONTAINER_ENGINE https://gitlab.com/vmath3us/devops-userspace/-/raw/main/Dockerfile'" &&
curl -L https://gitlab.com/vmath3us/devops-userspace/-/raw/main/create.sh -o create-box &&
printf '\e[1;32m%s\e[m\n' "

    sudo install -m755 create-box /usr/local/bin/.
    Execute a partir da pasta alvo, -h para instruçoes

"

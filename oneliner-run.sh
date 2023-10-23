#!/bin/sh
if [ $SECTYPE = "bare" ] ; then
    if [ -z $IS_A_BUILD ] ; then IS_A_BUILD=2 ; fi
       CONTAINER_ENGINE=${CONTAINER_ENGINE} IS_A_BUILD=${IS_A_BUILD} sh -uelic 'if [ $IS_A_BUILD = 1 ] ; then
        apk add --update $CONTAINER_ENGINE
        mkdir -pv /root/build_dir
        cd /root/build_dir
        curl -L https://gitlab.com/vmath3us/devops-userspace/-/raw/main/Dockerfile -o Dockerfile
        $CONTAINER_ENGINE build -t devops-userspace-$CONTAINER_ENGINE .
        else
        apk add zsh ; curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zsh_provisioning.sh | zsh
        fi'
elif [ -z $SECTYPE ] || [ $SECTYPE != "bare" ] ; then
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
    alpine sh -uelic 'apk add curl; curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/oneliner-run.sh | IS_A_BUILD=1 SECTYPE=bare sh'"
    curl -LO https://gitlab.com/vmath3us/devops-userspace/-/raw/main/create.sh
    printf '\e[1;32m%s\e[m\n\n\n' "install -m755 create.sh para seu PATH. Execute a partir da pasta alvo, -h para instruçoes"
fi

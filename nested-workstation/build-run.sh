#!/bin/bash
#############---build
set -e
docker pull docker:latest
docker pull ubuntu:24.04

DOCKER_IMAGE_DIGEST=$(docker image inspect docker:latest --format='{{index .RepoDigests 0}}')
UBUNTU_IMAGE_DIGEST=$(docker image inspect ubuntu:24.04 --format='{{index .RepoDigests 0}}')

unset -- INCLUDE_EXTRAS ENVIRONMENT PASS DOCKER_MODE

source ./.env-xpra

docker build . \
            -t docker-workstation-includeextras-"${INCLUDE_EXTRAS}"-interfacemode-"${ENVIRONMENT}" \
            --progress=plain \
            --build-arg UBUNTU_IMAGE_DIGEST="${UBUNTU_IMAGE_DIGEST}" \
            --build-arg DOCKER_IMAGE_DIGEST="${DOCKER_IMAGE_DIGEST}" \
            --build-arg INCLUDE_EXTRAS="${INCLUDE_EXTRAS}" \
            --build-arg ENVIRONMENT="${ENVIRONMENT}" \
            --build-arg FLATHUB_PRELOAD="${FLATHUB_PRELOAD}" \
            --build-arg FLATHUB_PACKAGES="${FLATHUB_PACKAGES}"

#############---run
if [[ $DOCKER_MODE = "nested" ]] ; then
  export DOCKER_MODE_STRING="
    --env DOCKER_MODE='nested' \
    -p 127.0.0.1:15000:15000 \
    --privileged \
    -v docker-workstation-persistence-"${ENVIRONMENT}":/var/lib/docker:Z"
elif [[ $DOCKER_MODE = "socket" ]] ; then
  export DOCKER_MODE_STRING="
    --env DOCKER_MODE='socket' \
    --net host \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock:Z"
else
    exit 1
fi
if [[ $AUDIO_HOST = "true" ]]  ; then
  export AUDIO_HOST_STRING="
    -v /run/user/1000/pulse:/run/user/1000/pulse \
    -e PULSE_SERVER=unix:/run/user/1000/pulse/native"
fi
eval "docker run \
            -d \
            --shm-size=1G \
            --env PASS="${PASS}" \
            --env ENVIRONMENT="${ENVIRONMENT}" \
            -v home-docker-workstation-docker-"${ENVIRONMENT}":/home/ubuntu:Z \
            "${DOCKER_MODE_STRING}" \
            "${AUDIO_HOST_STRING}" \
            --name docker-workstation-"${ENVIRONMENT}" \
            --hostname docker-workstation-"${ENVIRONMENT}" \
            docker-workstation-includeextras-"${INCLUDE_EXTRAS}"-interfacemode-"${ENVIRONMENT}"
"
docker logs -f docker-workstation-"${ENVIRONMENT}"

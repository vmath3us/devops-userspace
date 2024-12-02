#!/bin/bash
docker build . -t docker-workstation-lxqt-systemd --progress=plain
export PASS=$(uuidgen| sed 's/-//g')
docker run \
            -dt \
            --env PASS="${PASS}" \
            -p 127.0.0.1:15000:15000 \
            --shm-size 1G \
            --privileged \
            -v home-docker-workstation-lxqt-systemd:/home/ubuntu:Z \
            -v docker-workstation-persistence-lxqt-systemd:/var/lib/docker:Z \
            --name docker-workstation-lxqt-systemd \
            docker-workstation-lxqt-systemd:latest
docker logs -f docker-workstation-lxqt-systemd

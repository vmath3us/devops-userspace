#!/bin/bash
docker build . -t docker-workstation-xfce-systemd --progress=plain
export PASS=$(uuidgen| sed 's/-//g')
docker run \
            -dt \
            --env PASS="${PASS}" \
            -p 127.0.0.1:15000:15000 \
            --shm-size 1G \
            --privileged \
            -v home-docker-workstation-xfce-systemd:/home/ubuntu:Z \
            -v docker-workstation-persistence-xfce-systemd:/var/lib/docker:Z \
            --name docker-workstation-xfce-systemd \
            docker-workstation-xfce-systemd:latest
docker logs -f docker-workstation-xfce-systemd

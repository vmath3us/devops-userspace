#!/bin/bash
docker build . -t docker-workstation-plasma-systemd --progress=plain
export PASS=$(uuidgen| sed 's/-//g')
docker run \
            -dt \
            --env PASS="${PASS}" \
            -p 127.0.0.1:15000:15000 \
            --shm-size 1G \
            --privileged \
            -v home-docker-workstation-plasma-systemd:/home/ubuntu:Z \
            -v docker-workstation-persistence-plasma-systemd:/var/lib/docker:Z \
            --name docker-workstation-plasma-systemd \
            docker-workstation-plasma-systemd:latest
docker logs -f docker-workstation-plasma-systemd

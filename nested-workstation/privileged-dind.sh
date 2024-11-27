#!/bin/bash
docker build . -t docker-workstation
export PASS=$(uuidgen)
docker run \
            -d \
            --env PASS="${PASS}" \
            -p 127.0.0.1:15000:15000 \
            --shm-size 1G \
            --privileged \
            -v home-docker-workstation:/home/ubuntu:Z \
            -v docker-workstation-persistence:/var/lib/docker:Z \
            --name docker-workstation \
            docker-workstation:latest
docker logs -f docker-workstation

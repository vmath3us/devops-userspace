#!/bin/bash
docker build . -t docker-workstation
export PASS=$(uuidgen)
docker run \
            -d \
            --env PASS="${PASS}" \
            -p 127.0.0.1:15000:15000 \
            --shm-size 1G \
            -v home-docker-workstation:/home/ubuntu:Z \
            -v /var/run/docker.sock:/var/run/docker.sock:Z \
            --net host \
            --name docker-workstation \
            docker-workstation:latest
docker logs -f docker-workstation

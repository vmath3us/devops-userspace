#!/bin/bash
docker build . -t docker-workstation
export PASS=$(uuidgen | sed 's/-//g')
export ENVIRONMENT=''
docker run \
            -dt \
            --env PASS="${PASS}" \
            --env ENVIRONMENT="${ENVIRONMENT}" \
            -p 127.0.0.1:15000:15000 \
            --privileged \
            -v home-docker-workstation:/home/ubuntu:Z \
            -v docker-workstation-persistence:/var/lib/docker:Z \
            --name docker-workstation \
            docker-workstation:latest
docker logs -f docker-workstation

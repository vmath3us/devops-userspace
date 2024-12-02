#!/bin/bash
### para orquestrar o docker do host em vez de um dind, remova a instalação do dockerfile.
### adicione no dockerfile, no RUN de instalação do docker, ao fim, o comando 'systemctl disable docker.service docker.socket'
### privileged continua necessário, para execução do systemd no container
### net host nesse cenário é usado para manter transparente a abertura de portas
### use volume nomeados, ou o caminho absoluto ***do ponto de vista do host***

docker build . -t docker-workstation
export PASS=$(uuidgen| sed 's/-//g')
docker run \
            -dt \
            --env PASS="${PASS}" \
            -p 127.0.0.1:15000:15000 \
            --shm-size 1G \
            -v home-docker-workstation:/home/ubuntu:Z \
            -v /var/run/docker.sock:/var/run/docker.sock:Z \
            --net host \
            --privileged \
            --name docker-workstation \
            docker-workstation:latest
docker logs -f docker-workstation

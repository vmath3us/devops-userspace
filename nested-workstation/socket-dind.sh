#!/bin/bash
### privileged continua necessário, para execução do systemd no container
### net host nesse cenário é usado para garantir que seja transparente a abertura/uso de portas
### use volume nomeados, ou o caminho absoluto ***do ponto de vista do host*** para volumes montados
### os serviços do systemd para o docker não são necessários, desabilite/mascare
### garanta usuario:grupo funcional sobre o docker.sock para o container (pode conflitar com o uso a partir do host, considere chmod 0777)

export PASS=$(uuidgen | sed 's/-//g')
export ENVIRONMENT=''
docker build . -t docker-workstation
docker run \
            -dt \
            --env PASS="${PASS}" \
            --env ENVIRONMENT="${ENVIRONMENT}" \
            --env DOCKER_HOST='unix:///docker.sock' \
            -p 127.0.0.1:15000:15000 \
            --privileged \
            -v /var/run/docker.sock:/docker.sock:Z \
            -v home-docker-workstation:/home/ubuntu:Z \
            --net host \
            --privileged \
            --name docker-workstation \
            --entrypoint bash \
            docker-workstation:latest \
            -ec '
                systemctl disable docker.service docker.socket containerd
                systemctl mask docker.service docker.socket containerd
                chown -v root:docker /docker.sock
                exec /usr/lib/systemd/systemd
                '
docker logs -f docker-workstation

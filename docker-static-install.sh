#!/bin/bash

# bash curl tar gzip gnu-setsid (util-linux)
set -e

if [ $(whoami) != "root" ] ; then exit 1 ; fi

LATEST_DOCKER=$(curl -L https://get.docker.com/rootless |awk -F'=' '/STABLE_LATEST=/ {gsub(/"/, "", $2); print $2; exit}')

## https://docs.docker.com/engine/install/binaries
LATEST_DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/docker-"${LATEST_DOCKER}".tgz"

LATEST_BUILDX_URL=$(curl https://api.github.com/repos/docker/buildx/releases/latest | awk '/browser_download_url/ && /linux-amd64/ && !/json/ { gsub(/"/, "", $2); print $2 }')

LATEST_COMPOSE_URL=$(curl https://api.github.com/repos/docker/compose/releases/latest | awk '/browser_download_url/ && /linux-x86_64/ && !/sha256/ { gsub(/"/, "", $2); print $2 }')



BINARIES_DIR='/usr/local/bin'

PLUGINS_DIR='/root/.docker/cli-plugins'

mkdir -pv "${BINARIES_DIR}"
mkdir -pv "${PLUGINS_DIR}"

curl -L "${LATEST_DOCKER_URL}" -o "${BINARIES_DIR}"/docker-"${LATEST_DOCKER}".tgz
curl -L "${LATEST_BUILDX_URL}" -o "${PLUGINS_DIR}"/docker-buildx
curl -L "${LATEST_COMPOSE_URL}" -o "${PLUGINS_DIR}"/docker-compose

tar -C "${BINARIES_DIR}" -xf "${BINARIES_DIR}"/docker-"${LATEST_DOCKER}".tgz

for i in "${PLUGINS_DIR}"/*
do
    chmod -v +x "${i}"
done
if [ -e /usr/lib/systemd ]
then
cat > /etc/systemd/system/docker.service <<-EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com

[Service]
Environment="PATH=/usr/bin:/usr/sbin:/usr/local/bin/docker"
ExecStart=/usr/local/bin/docker/dockerd

[Install]
WantedBy=multi-user.target
EOF
 systemctl daemon-reload
 systemctl enable --now /etc/systemd/system/docker.service
else
    setsid --fork bash -c "PATH="${PATH}":"${BINARIES_DIR}"/docker dockerd >> /dev/ttydocker 2>> /dev/ttydocker"
    echo -e "\n\n"${BINARIES_DIR}"/docker/dockerd iniciado via setsid, adicione-o posteriormente ao init system\n\n"
fi
until stat /var/run/docker.sock >/dev/null 2>/dev/null
do
    echo -ne "esperando pelo docker socket\r"
done

"${BINARIES_DIR}"/docker/docker run hello-world
"${BINARIES_DIR}"/docker/docker compose version
"${BINARIES_DIR}"/docker/docker buildx version

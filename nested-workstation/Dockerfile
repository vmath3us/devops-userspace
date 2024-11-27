FROM ubuntu:noble

ENV PASS='358689eda899af35f8a4da4a2211f67af8a90f1e0fd8b92b0d709513707778e8'

SHELL [ "/bin/bash", "-c" ]


RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh
echo 'export LANG=en_US.UTF-8' >> /etc/profile.d/locale.sh
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
apt-get update
apt-get install -y locales tzdata
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure -fnoninteractive tzdata
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
EOF

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh
echo 'export LANG=en_US.UTF-8' >> /etc/profile.d/locale.sh
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
apt-get update
apt-get install -y \
            dbus-x11 \
            uuid-runtime \
            wget \
            gnupg \
            iproute2 \
            sudo \
            vim \
            nano \
            ripgrep \
            htop \
            ssh \
            rsync \
            xvfb \
            x11-xserver-utils \
            python3-pip \
            python3-uinput \
            terminator \
            tmux \
            curl \
            gzip \
            git \
            bash-completion \
            fonts-noto-color-emoji \
            bzip2 \
            flatpak

pip3 install pyinotify --break-system-packages
EOF

RUN <<EOF

usermod -aG sudo ubuntu
printf "$PASS\n$PASS" | passwd ubuntu

EOF


RUN <<EOF
wget -q -O- https://xpra.org/gpg.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg

echo 'deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg arch=amd64,arm64] https://xpra.org noble main' > /etc/apt/sources.list.d/xpra.list

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y xpra
EOF



### docker dind
RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
                iptables
update-alternatives --set iptables /usr/sbin/iptables-legacy

groupadd -g 98765 docker
##### -> https://hub.docker.com/_/docker/tags?name=dind
##### -> https://hub.docker.com/layers/library/docker/dind/images/sha256-c8050e971e7c9517d0004d3ec241d6c860ae36332082f18ed7f24e82fafb8cb7?context=explore

LATEST_DOCKER=$(curl -L https://api.github.com/repos/moby/moby/releases/latest | awk -F'tag/' '/html_url/ {gsub(/v/, "", $2); print $2}' | awk -F'"' '{print $1}')

LATEST_DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/docker-"${LATEST_DOCKER}".tgz"

cd /usr/local/bin
curl -L $LATEST_DOCKER_URL | tar -zxf -  --strip-components 1 --directory /usr/local/bin/ --no-same-owner

curl -L https://raw.githubusercontent.com/docker-library/docker/refs/heads/master/modprobe.sh -o ./modprobe

curl -LO https://raw.githubusercontent.com/docker-library/docker/refs/heads/master/dockerd-entrypoint.sh
curl -LO https://raw.githubusercontent.com/docker-library/docker/refs/heads/master/docker-entrypoint.sh
curl -LO https://raw.githubusercontent.com/moby/moby/refs/heads/master/hack/dind


chmod +x ./modprobe
chmod +x ./dockerd-entrypoint.sh
chmod +x ./docker-entrypoint.sh
chmod +x ./dind

mkdir -pv /usr/local/libexec/docker/cli-plugins/
cd /usr/local/libexec/docker/cli-plugins/

LATEST_BUILDX_URL=$(curl https://api.github.com/repos/docker/buildx/releases/latest | awk '/browser_download_url/ && /linux-amd64/ && !/json/ { gsub(/"/, "", $2); print $2 }')
LATEST_COMPOSE_URL=$(curl https://api.github.com/repos/docker/compose/releases/latest | awk '/browser_download_url/ && /linux-x86_64/ && !/sha256/ { gsub(/"/, "", $2); print $2 }')
curl -L $LATEST_BUILDX_URL -o docker-buildx
curl -L $LATEST_COMPOSE_URL -o docker-compose
chmod +x ./*
ln -s /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose


cat >> /usr/local/bin/docker-start.sh <<-IS_DOCKER_STARTER
#!/bin/bash
setsid --fork bash -c "export TINI_SUBREAPER='1' ; export  DOCKER_TLS_CERTDIR='' ; /usr/local/bin/dockerd-entrypoint.sh dockerd >> /dev/ttydocker 2>> /dev/ttydocker"
IS_DOCKER_STARTER

chmod +x /usr/local/bin/docker-start.sh

cat >> /home/ubuntu/.bashrc <<-IS_DOCKERSETUP
source /etc/bash_completion
source <(docker completion bash)
IS_DOCKERSETUP


usermod -aG docker ubuntu
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
cd /opt
curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -o code.deb
apt-get install -y ./code.deb
rm ./code.deb
curl -o ./codium.deb -L $(curl https://api.github.com/repos/VSCodium/vscodium/releases/latest  | awk '/browser_download_url/ && /amd64.deb/ && !/sha/ { gsub(/"/, "", $2); print $2 }')
apt-get install -y ./codium.deb
rm ./codium.deb
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
cd /opt
curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o chrome.deb
apt-get install -y ./chrome.deb
rm ./chrome.deb
cat > /usr/local/bin/run-google-chrome.sh <<-IS_SCRIPT
#!/bin/bash
rm -rf /home/ubuntu/.config/google-chrome/Singleton* || true
google-chrome --no-sandbox --enable-unsafe-swiftshader
IS_SCRIPT
chmod +x /usr/local/bin/run-google-chrome.sh
EOF

RUN <<EOF
cd /opt
curl -L 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=pt-BR' -o firefox-latest.tar.bz2
tar -xf ./firefox-latest.tar.bz2
rm ./firefox-latest.tar.bz2
ln -s /opt/firefox/firefox /usr/local/bin/firefox
EOF

USER ubuntu

RUN <<EOF

cd /home/ubuntu
mkdir -pv ./.local/bin
mkdir -pv ./.local/share/fonts
mkdir -pv ./.config/tmux
mkdir -pv ./.config/terminator


curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o /home/ubuntu/.local/share/fonts/meslo_nerd_bold.ttf
fc-cache -vf

cat > ./.config/tmux/tmux.conf <<-IS_TMUX_CONF
unbind C-b
set -g prefix C-s
default_color=colour202

set-window-option -g mode-keys vi
set-window-option -g xterm-keys on
set -s escape-time 0

set-option -g history-limit 3000

set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

setw -g pane-base-index 1
set -g base-index 1
set -g pane-border-status top
set -g status-left-length 50
set -g status-justify absolute-centre

set -g status-style "fg=black,bg=\${default_color}"
set -g window-status-format "#[fg=black] #I:#W "
set -g window-status-current-format "#[bg=black,fg=\${default_color}] #I:#W "
set -g pane-border-status top
set -g pane-border-style "bg=black fg=\${default_color}"
set -g pane-active-border-style "bg=\${default_color} fg=black"
set -g status-left "#[bg=black,fg=\${default_color}] #{session_name} "
set -g status-right "#[bg=black,fg=\${default_color}] %Y/%m/%d %H:%M:%S "

bind = split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
bind s choose-buffer
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind u resize-pane -L 3
bind i resize-pane -D 3
bind o resize-pane -U 3
bind p resize-pane -R 3
IS_TMUX_CONF

cat > ./.config/terminator/config <<-IS_TERMINATOR_CONF
[global_config]
[keybindings]
  full_screen = ""
[profiles]
  [[default]]
    font = MesloLGS NF Bold 16
    use_custom_command = True
    custom_command = tmux -2 -u new-session -A -s default
    use_system_font = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
IS_TERMINATOR_CONF
EOF

USER root
RUN <<EOF
cat > /usr/local/bin/xpra-entrypoint.sh <<-IS_A_ENTRYPOINT
#!/bin/bash
export PASS="\${PASS}"
printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\nsenha: \$PASS\n\n"
rm -rvf /tmp/.X* || true
mkdir -pv -m 0700 /run/user/1000
mkdir -pv -m 0700 /run/xpra/1000
mkdir -pv -m 0700 /run/xpra/ubuntu
chown -Rv ubuntu:ubuntu /run/user/1000
chown -Rv ubuntu:ubuntu /run/xpra/ubuntu
chown -Rv ubuntu:ubuntu /run/xpra/1000

# https://github.com/flatpak/flatpak/issues/5076#issuecomment-1425084748
dbus-send --system /org/freedesktop/DBus org.freedesktop.DBus 2>/dev/null|| dbus-daemon --system --fork 2>/dev/null
if [ ! -e /var/run/docker.sock ] || ! mountpoint -q /var/run/docker.sock ; then
    printf "\n\ndocker.sock não detectado, executando script para docker-in-docker....\n\n"
    /usr/local/bin/docker-start.sh
else
    printf "\n\ndocker.sock detectado, pulando execução de script para docker-in-docker....\n\n"
fi


printf "\n\nesperando docker.sock para executar 'chown -v ubuntu:docker /var/run/docker.sock'....\n\n"
until [ -e /var/run/docker.sock ] ; do
    sleep 0.1
done
chown -v ubuntu:docker /var/run/docker.sock

sleep 5
su -c "
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DBUS_SYSTEM_BUS_ADDRESS='/run/dbus/system_bus_socket' \\
    FLATPAK_SYSTEM_HELPER_ON_SESSION='/run/dbus/system_bus_socket' \\
    DISPLAY=':80' \\
    XCURSOR_SIZE='50' \\
    LANG='en_US.UTF-8' \\
    LANGUAGE='en_US:en' \\
    LC_ALL='en_US.UTF-8' \\
        xpra start \\
        ':80' \\
        '-d auth' \\
        '--bind-tcp=0.0.0.0:15000,auth=password,value=\$PASS' \\
        '--mdns=no' \\
        '--webcam=no' \\
        '--no-daemon' \\
        '--notifications=no' \\
        '--no-audio' \\
        '--start-on-connect=/usr/bin/terminator' \\
        '--start=xhost +'
" ubuntu

sleep infinity
IS_A_ENTRYPOINT

chmod +x /usr/local/bin/xpra-entrypoint.sh
EOF

EXPOSE 15000

VOLUME /home/ubuntu
VOLUME /var/lib/docker

ENTRYPOINT [ "/usr/local/bin/xpra-entrypoint.sh" ]

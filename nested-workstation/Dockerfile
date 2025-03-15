FROM docker:latest AS docker-bins

FROM ubuntu:24.04

ARG UBUNTU_IMAGE_DIGEST

LABEL ubuntu.image="$UBUNTU_IMAGE_DIGEST"

ARG DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-c" ]
################----------------> locale/timezone
USER root
RUN <<EOF
echo 'export LC_ALL=pt_BR.UTF-8' >> /etc/profile.d/locale.sh
echo 'export LANG=pt_BR.UTF-8' >> /etc/profile.d/locale.sh
echo 'LANG=pt_BR.UTF-8' >> /etc/locale.conf
apt-get update
apt-get install -y locales tzdata
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure -fnoninteractive tzdata
echo -e 'pt_BR.UTF-8 UTF-8\nen_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
EOF

ENV LANG='pt_BR.UTF-8'
ENV LANGUAGE='pt_BR:en'
ENV LC_ALL='pt_BR.UTF-8'
################----------------> locale/timezone
#
#
#
################----------------> xpra
USER root
RUN <<EOF
apt-get install -y \
            bash-completion \
            bzip2 \
            curl \
            dbus-x11 \
            flatpak \
            fonts-noto-color-emoji \
            git \
            gnupg \
            gzip \
            htop \
            iproute2 \
            iptables \
            jq \
            less \
            libarchive-tools \
            libpulse0 \
            python3-pip \
            python3-uinput \
            python3-watchdog \
            sudo \
            terminator \
            tmux \
            uuid-runtime \
            vim \
            wget \
            x11-xserver-utils \
            xdg-desktop-portal \
            xdg-desktop-portal-gnome \
            xdg-desktop-portal-gtk \
            xsel \
            xvfb \
            xz-utils \
            --no-install-recommends

usermod -aG sudo ubuntu
EOF

USER root
RUN <<EOF
wget -q -O- https://xpra.org/gpg.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg

echo 'deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg arch=amd64] https://xpra.org noble main' > /etc/apt/sources.list.d/xpra.list

apt-get update
apt-get install -y xpra=6.2.2-r0-1 \
                    xpra-client-gtk3=6.2.2-r0-1 \
                    xpra-client=6.2.2-r0-1 \
                    xpra-codecs=6.2.2-r0-1 \
                    xpra-common=6.2.2-r0-1 \
                    xpra-html5=16.2-r0-1 \
                    xpra-server=6.2.2-r0-1 \
                    xpra-x11=6.2.2-r0-1 \
                    xpra=6.2.2-r0-1 \
                    --no-install-recommends
EOF
################----------------> xpra
#
#
#
################----------------> cli-extras
RUN <<EOF
mkdir -pv /.extract_static_releases 
LATEST_EZA_URL=$(curl https://api.github.com/repos/eza-community/eza/releases/latest | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar")) | .browser_download_url')
curl -L $LATEST_EZA_URL | bsdtar -C /.extract_static_releases -zxf -

LATEST_ZOXIDE_URL=$(curl https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar")) | .browser_download_url')
curl -L $LATEST_ZOXIDE_URL | bsdtar -C /.extract_static_releases -zxf -

LATEST_BAT_URL=$(curl https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar")) | .browser_download_url')
curl -L $LATEST_BAT_URL | bsdtar -C /.extract_static_releases --strip-components=1 -zxf -

LATEST_YAZI_URL=$(curl https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.zip")) | .browser_download_url')
curl -L $LATEST_YAZI_URL | bsdtar -C /.extract_static_releases --strip-components=1  -zxf -

LATEST_FD_URL=$(curl https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar")) | .browser_download_url')
curl -L $LATEST_FD_URL | bsdtar -C /.extract_static_releases --strip-components=1  -zxf - 

LATEST_RG_URL=$(curl https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar")) | .browser_download_url')
curl -L $LATEST_RG_URL | bsdtar -C /.extract_static_releases --strip-components=1  -zxf - 


for i in eza zoxide bat yazi fd rg ; do
    install -m755 /.extract_static_releases/"${i}" /usr/local/bin/"${i}"
done
ls -lha /usr/local/bin

rm -rf /.extract_static_releases
EOF
################----------------> cli-extras
#
#
#
################----------------> browsers/gui-editors
ARG INCLUDE_EXTRAS

LABEL include.extra.tools="$INCLUDE_EXTRAS"

USER root
RUN <<EOF
if [[ $INCLUDE_EXTRAS = "true" ]]  ; then
mkdir /downloads
cd /downloads
curl -L 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=pt-BR' -o firefox.tarball
curl -o ./codium.deb -L $(curl https://api.github.com/repos/VSCodium/vscodium/releases/latest  | awk '/browser_download_url/ && /amd64.deb/ && !/sha/ { gsub(/"/, "", $2); print $2 }')
curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -o code.deb
curl -L 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -o chrome.deb

tar -C /opt -xf ./firefox.tarball
ln -s /opt/firefox/firefox /usr/local/bin/firefox
wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications

apt-get update
apt-get install -y ./*.deb

cd /
rm -r /downloads
else
    exit 0
fi
EOF
################----------------> browsers/gui-editors
#
#
#
################----------------> desktops
ARG ENVIRONMENT

LABEL gui.mode="$ENVIRONMENT"

USER root
RUN <<EOF
case $ENVIRONMENT in
    lxqt)
        apt-get install -y \
                    lxqt \
                    openbox \
                    --no-install-recommends

mkdir -pv /home/ubuntu/.config/lxqt

cat > /home/ubuntu/.config/lxqt/session.conf <<-IS_LXQT_CONF
[General]
__userfile__=true
window_manager=openbox
IS_LXQT_CONF
chown -R ubuntu:ubuntu /home/ubuntu/.config
    ;;
    xfce)
        apt-get install -y \
                    xfce4-settings \
                    xfwm4 \
                    xubuntu-desktop-minimal \
                    --no-install-recommends

mkdir -pv /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml

cat > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<-IS_XFWM4_CONFIG
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
IS_XFWM4_CONFIG

chown -R ubuntu:ubuntu /home/ubuntu/.config
    ;;
    plasma)
    apt-get install -y \
                    kde-plasma-desktop \
                    kwin-x11 \
                    plasma-settings \
                    --no-install-recommends

mkdir -pv /home/ubuntu/.config

cat > /home/ubuntu/.config/kwinrc <<-IS_KWIN_CONFIG
[Compositing]
Enabled=false
IS_KWIN_CONFIG

chown -R ubuntu:ubuntu /home/ubuntu/.config
    ;;
    *)
    exit 0
    ;;
esac
EOF
ENV ENVIRONMENT=$ENVIRONMENT
################----------------> desktops
#
#
#
################----------------> docker
ARG DOCKER_IMAGE_DIGEST

LABEL docker.image.get.bins="$DOCKER_IMAGE_DIGEST"

COPY --from=docker-bins --chmod=755 /usr/local/bin/. /usr/local/bin/.
COPY --from=docker-bins --chmod=755 /usr/local/libexec/docker/cli-plugins/. /usr/local/libexec/docker/cli-plugins/.
USER root
RUN <<EOF

groupadd -g 90990 docker

usermod -aG docker ubuntu

cat >> /home/ubuntu/.bashrc <<-IS_DOCKERSETUP
source /etc/bash_completion
source <(docker completion bash)
IS_DOCKERSETUP
EOF
################----------------> docker
#
#
#
################----------------> home setup
USER ubuntu
RUN <<EOF

cd /home/ubuntu
mkdir -pv ./.local/bin
mkdir -pv ./.local/share/fonts
mkdir -pv ./.config/tmux
mkdir -pv ./.config/terminator


curl -L https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/patched-fonts/IBMPlexMono/Mono/BlexMonoNerdFont-Bold.ttf -o ~/.local/share/fonts/blex-mono-nerd-font-bold.ttf
fc-cache -f

curl -L https://gitlab.com/vmath3us/devops-userspace/-/raw/main/bare-metal-tmux.conf -o ./.config/tmux/tmux.conf || true
sed -i 's/white/colour202/g' ./.config/tmux/tmux.conf || true

echo 'setw -g mouse on' >> ./.config/tmux/tmux.conf
echo "set -s copy-command 'xsel --clipboard --input'" >> ./.config/tmux/tmux.conf

cat > ./.config/terminator/config <<-IS_TERMINATOR_CONF
[global_config]
[keybindings]
  full_screen = ""
[profiles]
  [[default]]
    font = BlexMono Nerd Font Bold 16
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

###### history -a grant immeediately save bash_history (docker kill/docker rm > recreate)
sed -i \
      -e 's/shopt -s histappend/shopt -s histappend\nPROMPT_COMMAND="history -a"/' \
      -e 's/HISTSIZE.*/HISTSIZE=1000000/' \
      -e 's/HISTFILESIZE.*/HISTFILESIZE=2000000\nHISTTIMEFORMAT="+%Y-%m-%d--%H-%M-%S "/' \
      /home/ubuntu/.bashrc

EOF
################----------------> home setup
#
#
#
################----------------> mkdir/chown
USER root

RUN <<EOF
mkdir -pv /run/dbus

mkdir -pv -m0700 /run/user/1000
mkdir -pv -m0775 /run/xpra
chown -Rv ubuntu:ubuntu /run/user/1000
chown -Rv ubuntu:ubuntu /run/xpra
EOF
################----------------> mkdir/chown
#
#
#
################----------------> flatpak pre-install on user volume (run as root/su -c, depends system dbus)
ARG FLATHUB_PRELOAD
ARG FLATHUB_PACKAGES

RUN <<EOF
if [[ $FLATHUB_PRELOAD = "true" ]] ; then
  dbus-daemon --system --fork 2>/dev/null
  FLATHUB_PRELOAD_COMMAND="
      mkdir -pv /home/ubuntu/.local/share/flatpak
      FLATPAK_SYSTEM_HELPER_ON_SESSION='/run/dbus/system_bus_socket'
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
      flatpak install -y ${FLATHUB_PACKAGES}
      "
  su -c "eval \"${FLATHUB_PRELOAD_COMMAND}\"" ubuntu
  rm -rv /run/dbus/*
  rm -rv /run/dbus/.*
  exit 0
else
  true
fi
EOF
################----------------> flatpak pre-install on user volume (run as root/su -c, depends system dbus)
#
#
#
################----------------> entrypoint
RUN <<EOF
cat > /usr/local/bin/xpra-exec.sh <<-IS_XPRA_STARTER
#!/bin/bash
grace_stop() {
  set -x
  echo "Recebido SIGTERM! Encerrando..."
  su -c "kill -s SIGTERM \$(cat /run/user/1000/xpra/15000/server.pid)" ubuntu
  if [[ \$DOCKER_MODE = "nested" ]] ; then
    kill -s SIGTERM \$(cat /run/docker.pid)
  fi
  kill -s SIGTERM \$(cat /run/dbus/pid)
  rm -rv /run/dbus/* || true
  rm -rv /run/dbus/.* || true
  rm -r /tmp/* || true
  rm -r /tmp/.* || true
  exit 0
}

trap 'grace_stop' SIGTERM

dbus-daemon --system --fork 2>/dev/null
DOCKER_MODE="\${DOCKER_MODE}"
if [[ \$DOCKER_MODE = "nested" ]] ; then
    setsid --fork bash -c "DOCKER_HOST='unix:///var/run/docker.sock' DOCKER_TLS_CERTDIR='' TINI_SUBREAPER=1 DOCKER_DRIVER='overlay2' /usr/local/bin/docker-entrypoint.sh dockerd --tls=false --experimental >>/dev/stdout 2>>/dev/stdout"
    NET='0.0.0.0'
elif [[ \$DOCKER_MODE = "socket" ]] ; then
    chown root:docker /var/run/docker.sock
    NET='127.0.0.1'
else
    true
fi
PASS="\${PASS}"
if [ -z \$PASS ] ; then
    PASS=\$(uuidgen| sed 's/-//g')
fi

printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\n                password xpra/sudo: \$PASS                \n\n\n"

ENVIRONMENT="\${ENVIRONMENT}"

case \$ENVIRONMENT in
    lxqt)
        EXEC="/usr/bin/startlxqt"
        XPRA_MODE="start-desktop"
    ;;
    xfce)
        EXEC="/usr/bin/startxfce4"
        XPRA_MODE="start-desktop"
    ;;
    plasma)
        EXEC="/usr/bin/startplasma-x11"
        XPRA_MODE="start-desktop"
    ;;
    *)
        EXEC="xhost +"
        XPRA_MODE="start"
    ;;
esac


setsid --fork runuser -P -l ubuntu -c "
    FLATPAK_SYSTEM_HELPER_ON_SESSION='/run/dbus/system_bus_socket' \\
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DISPLAY=':15000' \\
    XCURSOR_SIZE='50' \\
        xpra \${XPRA_MODE} \\
        ':15000' \\
        '-d auth' \\
        '--bind-tcp=\${NET}:15000,auth=password,value=\${PASS}' \\
        '--mdns=no' \\
        '--webcam=no' \\
        '--notifications=no' \\
        '--bell=no' \\
        '--no-daemon' \\
        '--no-audio' \\
        '--start-on-connect=/usr/bin/terminator' \\
        '--start=\${EXEC}'
" 
sleep infinity &
wait
IS_XPRA_STARTER

chmod +x /usr/local/bin/xpra-exec.sh
EOF
################----------------> entrypoint
#
#
#
################----------------> config
EXPOSE 15000

VOLUME /home/ubuntu
VOLUME /var/lib/docker

USER root

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/usr/local/bin/xpra-exec.sh" ]
################----------------> config

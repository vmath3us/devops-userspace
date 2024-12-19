FROM ubuntu:noble

ENV PASS='358689eda899af35f8a4da4a2211f67af8a90f1e0fd8b92b0d709513707778e8'

SHELL [ "/bin/bash", "-c" ]

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
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

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
            systemd \
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
            xsel \
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


### docker
RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update

curl -fsSL https://get.docker.com | bash

cat >> /home/ubuntu/.bashrc <<-IS_DOCKERSETUP
source /etc/bash_completion
source <(docker completion bash)
if [ -e /docker.sock ] ; then export DOCKER_HOST='unix:///docker.sock' ; fi    ### dind docker by host socket
IS_DOCKERSETUP

usermod -aG docker ubuntu
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
cd /opt
curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -o code.deb
apt-get install -y ./code.deb
rm ./code.deb
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
cd /opt
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
EOF

RUN <<EOF
#### -> https://support.mozilla.org/en-US/kb/install-firefox-linux
cd /opt
curl -L 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=pt-BR' -o firefox-latest.tar.bz2
tar -xf ./firefox-latest.tar.bz2
rm ./firefox-latest.tar.bz2
ln -s /opt/firefox/firefox /usr/local/bin/firefox
wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y lxqt openbox --no-install-recommends
systemctl disable display-manager.service || true
systemctl mask display-manager.service || true
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y xubuntu-desktop-minimal xfce4-settings xfwm4 --no-install-recommends
systemctl disable display-manager.service || true
systemctl mask display-manager.service || true
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y kde-plasma-desktop kwin-x11 plasma-settings --no-install-recommends
systemctl disable display-manager.service || true
systemctl mask display-manager.service || true
EOF

USER ubuntu

RUN <<EOF

cd /home/ubuntu
mkdir -pv ./.local/bin
mkdir -pv ./.local/share/fonts
mkdir -pv ./.local/share/flatpak
mkdir -pv ./.config/tmux
mkdir -pv ./.config/terminator

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user

curl -L https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o /home/ubuntu/.local/share/fonts/meslo_nerd_bold.ttf
fc-cache -vf

cat > ./.config/tmux/tmux.conf <<-IS_TMUX_CONF
unbind C-b
set -s copy-command 'xsel --clipboard --input'
set -g prefix C-a
default_color=colour202
#setw -g mouse on

set-option -g set-titles on
set-option -g set-titles-string "#S / #W"


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

bind c new-window -c "#{pane_current_path}"
bind s choose-buffer

bind-key -n C-g split-window -h -c "#{pane_current_path}"
bind-key -n C-f split-window -v -c "#{pane_current_path}"

bind-key -n M-h select-pane -L
bind-key -n M-j select-pane -D
bind-key -n M-k select-pane -U
bind-key -n M-l select-pane -R
bind-key -n M-n next-window

bind-key -n C-h resize-pane -L
bind-key -n C-j resize-pane -D
bind-key -n C-k resize-pane -U
bind-key -n C-l resize-pane -R
bind-key -n C-o send C-n

bind-key -n C-d list-sessions
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

USER ubuntu

RUN <<EOF

cd /home/ubuntu

mkdir -pv ./.config/lxqt

cat >./.config/lxqt/session.conf <<-IS_LXQT_CONF
[General]
__userfile__=true
window_manager=openbox
IS_LXQT_CONF


mkdir -pv ./.config/xfce4/xfconf/xfce-perchannel-xml

cat > ./.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<-IS_XFWM4_CONFIG
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
IS_XFWM4_CONFIG

cat > ./.config/kwinrc <<-IS_KWIN_CONFIG
[Compositing]
Enabled=false
IS_KWIN_CONFIG

EOF

USER root

RUN <<EOF
cat > /usr/local/bin/xpra-exec.sh <<-IS_XPRA_STARTER
#!/bin/bash
export PASS="\${PASS}"
if [ -z \$PASS ] ; then
    export PASS=$(uuidgen| sed 's/-//g')
fi
export ENVIRONMENT="\${ENVIRONMENT}"
case \$ENVIRONMENT in
    plasma)
        export EXEC="/usr/bin/startplasma-x11"
        export XPRA_MODE="start-desktop"
    ;;
    xfce)
        export EXEC="/usr/bin/startxfce4"
        export XPRA_MODE="start-desktop"
    ;;
    lxqt)
        export EXEC="/usr/bin/startlxqt"
        export XPRA_MODE="start-desktop"
    ;;
    *)
        export EXEC="xhost +"
        export XPRA_MODE="start"
    ;;
esac
printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\n                password xpra/sudo: \$PASS                \n\n\n"
rm -rf /tmp/.X* 2>>/dev/null
mkdir -p -m 0700 /run/xpra/ubuntu 2>>/dev/null
mkdir -p -m 0700 /run/xpra/1000 2>>/dev/null
chown -R ubuntu:ubuntu /run/user/1000 2>>/dev/null
chown -R ubuntu:ubuntu /run/xpra/ubuntu 2>>/dev/null
chown -R ubuntu:ubuntu /run/xpra/1000 2>>/dev/null

su -c "
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DBUS_SYSTEM_BUS_ADDRESS='/run/dbus/system_bus_socket' \\
    FLATPAK_SYSTEM_HELPER_ON_SESSION='/run/dbus/system_bus_socket' \\
    DISPLAY=':80' \\
    XCURSOR_SIZE='50' \\
    LANG='pt_BR.UTF-8' \\
    LANGUAGE='pt_BR:en' \\
    LC_ALL='pt_BR.UTF-8' \\
        xpra \$XPRA_MODE \\
        ':80' \\
        '-d auth' \\
        '--bind-tcp=0.0.0.0:15000,auth=password,value=\$PASS' \\
        '--mdns=no' \\
        '--webcam=no' \\
        '--no-daemon' \\
        '--notifications=no' \\
        '--no-audio' \\
        '--start-on-connect=/usr/bin/terminator' \\
        '--start=\$EXEC'
" ubuntu
IS_XPRA_STARTER

chmod +x /usr/local/bin/xpra-exec.sh

cat > /etc/systemd/system/xpra-start.service <<-IS_XPRA_SERVICE
[Unit]
Description=xpra-start

[Service]
Type=oneshot
PassEnvironment=PASS
PassEnvironment=ENVIRONMENT
ExecStart=/usr/local/bin/xpra-exec.sh
StandardOutput=tty
StandardError=tty
TTYPath=/dev/console

[Install]
WantedBy=multi-user.target
IS_XPRA_SERVICE

systemctl enable /etc/systemd/system/xpra-start.service


#### by 89luca89 -> https://github.com/89luca89/distrobox/blob/18053c254a83750c49c08e58df2e48a0f04aef48/distrobox-init#L2549 
UNIT_TARGETS="
	/usr/lib/systemd/system/*.mount
	/usr/lib/systemd/system/*.automount
	/usr/lib/systemd/system/console-getty.service
	/usr/lib/systemd/system/getty@.service
	/usr/lib/systemd/system/systemd-machine-id-commit.service
	/usr/lib/systemd/system/systemd-binfmt.service
	/usr/lib/systemd/system/systemd-tmpfiles*
	/usr/lib/systemd/system/systemd-udevd.service
	/usr/lib/systemd/system/systemd-udev-trigger.service
	/usr/lib/systemd/system/systemd-update-utmp*
	/usr/lib/systemd/user/pipewire*
	/usr/lib/systemd/user/wireplumber*
	/usr/lib/systemd/system/suspend.target
	/usr/lib/systemd/system/hibernate.target
	/usr/lib/systemd/system/hybrid-sleep.target
"
for unit in $(find ${UNIT_TARGETS} 2> /dev/null); do
	systemctl mask "$(basename "${unit}")" || true
done

### other masks
MASK="
    anacron.service
    anacron.timer
    apt-daily-upgrade.timer
    apt-daily.timer
    avahi-daemon.service
    cryptsetup.target
    cups.path
    cups.service
    dpkg-db-backup.timer
    e2scrub_all.timer
    e2scrub_reap.service
    getty.target
    integritysetup.target
    ldconfig.service
    local-fs-pre.target
    local-fs.target
    man-db.timer
    modprobe@dm_mod.service
    modprobe@drm.service
    modprobe@efi_pstore.service
    modprobe@loop.service
    motd-news.timer
    network-online.target
    network.target
    nss-lookup.target
    paths.target
    plymouth-quit-wait.service
    plymouth-quit.service
    plymouth-read-write.service
    remote-fs.target
    rtkit-daemon.service
    rtkit-daemon.target
    slices.target
    sockets.target
    swap.target
    system-modprobe.slice
    systemd-ask-password-console.path
    systemd-ask-password-wall.path
    systemd-journal-catalog-update.service
    systemd-journal-flush.service
    systemd-modules-load.service
    systemd-remount-fs.service
    systemd-resolved.service
    systemd-sysctl.service
    systemd-sysusers.service
    systemd-update-done.service
    time-set.target
    timers.target
    udisks2.service
    upower.service
    upower.target
    veritysetup.target
    wpa_supplicant.service
"

for unit in ${MASK}; do
	systemctl disable ${unit} || true
	systemctl mask ${unit} || true
done

EOF

EXPOSE 15000

VOLUME /home/ubuntu
VOLUME /var/lib/docker

ENTRYPOINT [ "/usr/lib/systemd/systemd" ]

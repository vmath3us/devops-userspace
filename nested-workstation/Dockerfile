FROM ubuntu:noble
ENV PASS='358689eda899af35f8a4da4a2211f67af8a90f1e0fd8b92b0d709513707778e8'

SHELL [ "/bin/bash", "-c" ]

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
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
            git \
            bash-completion \
            bzip2
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


### monte o /var/run/docker.sock do host ou execute em modo --privileged para docker in docker (DIND) 
RUN <<EOF

curl -fsSL https://get.docker.com | sh

usermod -aG docker ubuntu

cat >> /home/ubuntu/.bashrc <<-IS_DOCKERSETUP
echo 'to docker, run
sudo su -c '\''setsid --fork bash -c "dockerd >/dev/ttydocker 2>/dev/ttydocker"'\'''
source /etc/bash_completion
source <(docker completion bash)
IS_DOCKERSETUP

EOF


RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
cd /opt
curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -o code.deb
apt-get install -y ./code.deb
curl -o ./codium.deb -L $(curl https://api.github.com/repos/VSCodium/vscodium/releases/latest  | awk '/browser_download_url/ && /amd64.deb/ && !/sha/ { gsub(/"/, "", $2); print $2 }')
apt-get install -y ./codium.deb
EOF

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
cd /opt
curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o chrome.deb
apt-get install -y ./chrome.deb
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
mkdir -pv -m 0700 /run/user/1000
mkdir -pv -m 0700 /run/xpra/1000
mkdir -pv -m 0700 /run/xpra/ubuntu
chown -Rv ubuntu:ubuntu /run/user/1000
chown -Rv ubuntu:ubuntu /run/xpra/ubuntu
chown -Rv ubuntu:ubuntu /run/xpra/1000

dbus-send --system /org/freedesktop/DBus org.freedesktop.DBus 2>/dev/null|| dbus-daemon --system --fork 2>/dev/null
sleep 5
su -c "
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DISPLAY=':80' \\
    XCURSOR_SIZE='50' \\
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

ENTRYPOINT [ "/usr/local/bin/xpra-entrypoint.sh" ]

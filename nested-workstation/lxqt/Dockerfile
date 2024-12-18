FROM docker-workstation:latest

USER ubuntu

RUN <<EOF

cd /home/ubuntu

mkdir -pv ./.config/lxqt

cat >./.config/lxqt/session.conf <<-IS_LXQT_CONF
[General]
window_manager=openbox
IS_LXQT_CONF

EOF

USER root

RUN <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y lxqt openbox --no-install-recommends
systemctl disable display-manager.service || true
systemctl mask display-manager.service || true
EOF

RUN <<EOF
cat > /usr/local/bin/xpra-exec.sh <<-IS_XPRA_STARTER
#!/bin/bash
export PASS="\${PASS}"
if [ -z \$PASS ] ; then
    export PASS=$(uuidgen| sed 's/-//g')
fi
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
        xpra start-desktop \\
        ':80' \\
        '-d auth' \\
        '--bind-tcp=0.0.0.0:15000,auth=password,value=\$PASS' \\
        '--mdns=no' \\
        '--webcam=no' \\
        '--no-daemon' \\
        '--notifications=no' \\
        '--no-audio' \\
        '--start-on-connect=/usr/bin/terminator' \\
        '--start=/usr/bin/startlxqt'
" ubuntu
IS_XPRA_STARTER

chmod +x /usr/local/bin/xpra-exec.sh

cat > /etc/systemd/system/xpra-start.service <<-IS_XPRA_SERVICE
[Unit]
Description=xpra-start

[Service]
Type=oneshot
PassEnvironment=PASS
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

EOF

EXPOSE 15000

VOLUME /home/ubuntu
VOLUME /var/lib/docker

ENTRYPOINT [ "/usr/lib/systemd/systemd" ]

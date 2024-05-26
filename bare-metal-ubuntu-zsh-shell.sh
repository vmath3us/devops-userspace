#!/bin/bash
if [ $(whoami) = "root" ] ; then
	mkdir -pv /var/lib/root-save/{work,upper} &&
	if ! mountpoint /root ; then
	mount -t overlay overlay -o lowerdir=/root,upperdir=/var/lib/root-save/upper/,workdir=/var/lib/root-save/work/ /root
	fi &&
	if [ ! -e /root/.zshrc ] ; then
	    echo "instalando dependencias em 10 segundos, ctrl-c para cancelar"
	    echo "comando: apt install -y git bash curl zsh"
	    for i in {10..1} ; do
	        echo -ne "$i restantes\r"
	        sleep 1
	    done &&
	    apt update &&
	    apt install -y git bash zsh curl ; curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/sh-provisioning.sh | MINIMAL_PROVISIONED=1 PROFILE=shell zsh || exit 1
	fi && echo "execute: 
                exec zsh
                "
else
    echo "execute como root, saindo com erro"
    exit 1
fi

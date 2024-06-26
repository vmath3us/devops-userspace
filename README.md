# How to

docker image create:

    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/oneliner-run.sh | sh

rootless docker image create:
    
    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/oneliner-run.sh | ROOTLESS=1 sh

podman image create:
    
    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/oneliner-run.sh | CONTAINER_ENGINE=podman sh

rootless podman image create:
    
    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/oneliner-run.sh | CONTAINER_ENGINE=podman ROOTLESS=1 sh

**Container create and attach using create.sh**.


directly on podman/docker container (rootless or rootfull):

    podman/docker run -dit <your flags and volumes> --name <name> alpine:edge sh -uelic "if [ ! -e /root/.zshrc ] ;then apk add curl ; curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/sh-provisioning.sh | sh ; fi ; sleep infinity"

    podman/docker logs -f <name>

    podman/docker exec -it --detach-keys "" <name> zsh

**Support stop/kill -> start -> exec**.



kubernetes:

    kubectl apply -f https://gitlab.com/vmath3us/devops-userspace/-/raw/main/deployment-devops-userspace.yaml

    kubectl logs -f <pod-name>

    kubectl exec --stdin --tty <pod-name> -- /bin/zsh

or:

    kubectl apply -f https://gitlab.com/vmath3us/devops-userspace/-/raw/main/job-devops-userspace.yaml

    kubectl patch jobs devops-userspace-job -p '{"spec" : {"suspend" : false }}'

    kubectl logs -f <pod-name>

    kubectl exec --stdin --tty <pod-name> -- /bin/zsh

or:

    kubectl run --image=alpine:edge <pod-name> -- /bin/sh -uelic "apk add curl ; curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/sh-provisioning.sh | sh ; sleep infinity"

    kubectl logs -f <pod-name>

    kubectl exec --stdin --tty <pod-name> -- /bin/zsh


## DANGEOURS

Full owner machine: all process, disks, net interfaces, permissions, all cluster machines (workers). Allow host chroot.
kubernetes:

    kubectl apply -f https://gitlab.com/vmath3us/devops-userspace/-/raw/main/daemonset-machine-owner.yaml

docker/podman(docker by default, set CONTAINER_ENGINE=podman):

    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/container-machine-owner.sh | bash

## Extras

shell configure:

    p10k configure

Read sh-provisioning.sh to profiles.


## SHELL ONLY
ubuntu/debian:

    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/bare-metal-ubuntu-zsh-shell.sh | bash 

## Docker static install
systemd or using setsid --fork:

    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/docker-static-install.sh | bash 

## Rke2 single node setup
rke2 script install (v1.28.9+rke2r1 + local-path v0.0.27 Retain, systemd init only):
    
    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/rke2-local-path-stgc.sh | bash

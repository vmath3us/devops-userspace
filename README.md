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

    podman/docker run -dit <your flags and volumes> --name <name> alpine:edge sh -uelic "if [ ! -e /root/.zshrc ] ;then apk add curl zsh ; curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zsh_provisioning.sh | zsh ; fi ; sleep infinity"

    podman/docker logs -f <name>

    podman/docker exec -it --detach-keys "" <name> zsh

**Support stop/kill -> start -> exec**.



kubernetes:

    kubectl apply -f https://gitlab.com/vmath3us/devops-userspace/-/raw/main/deployment-devops-userspace.yaml

    kubectl logs -f <pod-name>

    kubectl exec --stdin --tty <pod-name> -- /bin/zsh

or:

    kubectl apply -f https://gitlab.com/vmath3us/devops-userspace/-/raw/main/job-devops-userspace.yaml

    kubectl patch jobs -n devops-userspace-job -p '{"spec" : {"suspend" : false }}'

    kubectl logs -f <pod-name>

    kubectl exec --stdin --tty <pod-name> -- /bin/zsh

or:

    kubectl run --image=alpine:edge <pod-name> -- /bin/sh -uelic "apk add curl zsh ; curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zsh_provisioning.sh | zsh ; sleep infinity"

    kubectl logs -f <pod-name>

    kubectl exec --stdin --tty <pod-name> -- /bin/zsh

shell configure:

    p10k configure

Read zsh_provisioning.sh to profiles


## SHELL ONLY
ubuntu/debian:

    curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/bare-metal-ubuntu-zsh-shell.sh | bash 

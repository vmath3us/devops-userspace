FROM alpine:edge
RUN sh -uelic "apk add curl zsh ; curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zsh_provisioning.sh | zsh"
ENTRYPOINT [ "sleep" , "infinity" ]

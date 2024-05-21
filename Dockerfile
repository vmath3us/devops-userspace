FROM alpine:edge
ARG PROFILE=${PROFILE}
RUN sh -uelic 'apk add curl zsh ; curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zsh_provisioning.sh | PROFILE=$PROFILE zsh'
VOLUME /root
VOLUME /tmp
ENTRYPOINT [ "sleep" , "infinity" ]

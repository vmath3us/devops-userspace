FROM alpine:edge
ARG PROFILE=${PROFILE}
RUN sh -uelic 'apk add curl ; curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/sh-provisioning.sh | PROFILE=$PROFILE sh'
VOLUME /root
VOLUME /tmp
ENTRYPOINT [ "sleep" , "infinity" ]

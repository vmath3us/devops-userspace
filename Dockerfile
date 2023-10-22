FROM alpine:edge
RUN sh -uelic "apk add curl ; curl -fSL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/oneliner-run.sh | IS_A_BUILD=2 SECTYPE=bare sh"
ENTRYPOINT [ "sleep" , "infinity" ]

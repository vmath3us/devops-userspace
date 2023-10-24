#!/bin/bash
function branding(){
    printf '\e[1;37m%s\e[m\n' "
    ###################################
    #                                 #
    #                                 #    
    #           Create-Box            #
    #                                 #
    #                                 #
    ###################################
"
}
# rootless + dind implica em
# crie/use o socket rootless dentro do container, de forma que novos containers também sejam
# rootless, mas AO LADO do container pai (e não aninhados). Dessa forma, destruir o pai
# nao destroi os filhos, todos os volumes sao preservados, etc.
# rootfull + dind implica no mesmo (passagem do socket rootfull), com todos os riscos de segurança que isso acarreta.
# https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#known-issues-with-docker-socket-binding
# a passagem do socket permite que os 'filhos' posssam ser criados com mais privilégios que o pai
#
# no caso de rootfull, um container 'filho' criado com cap_add=ALL permite ate mesmo injeçao de módulos no kernel.
# nos dois casos, o container pai consegue destruir a si mesmo
# nos dois casos, é possível criar um 'filho' que monte pastas do host diferentes do pai
function dind_generate_setup(){
    if [ $container_engine == "docker" ] ; then
        docker_in_docker
    else
        podman_in_podman
    fi
    return
}
function docker_in_docker(){
# rootless
# docker run -it --rm --security-opt label=disable -v /run/user/$(id -g)/docker.sock:/var/run/docker.sock:Z --env DOCKER_HOST=unix:///var/run/docker.sock alpine sh -uelic "apk add docker ; docker ps -a"
# rootfull
# docker run -it --rm --security-opt label=disable -v /var/run/docker.sock:/var/run/docker.sock:Z --env DOCKER_HOST=unix:///var/run/docker.sock alpine sh -uelic "apk add docker ; docker ps -a"
    if [ -z $rootless ] ; then
        socket_origin="-v /var/run/docker.sock"
    else
        socket_origin="-v /run/user/$(id -g)/docker.sock"
    fi
    socket_mount_string="${socket_origin}:/var/run/docker.sock:Z --env DOCKER_HOST=unix:///var/run/docker.sock"
    return
}
function podman_in_podman(){
# https://www.redhat.com/sysadmin/podman-inside-container
# https://github.com/containers/podman/issues/11422
# https://docs.podman.io/en/latest/markdown/podman-system-service.1.html#run-the-command-directly
# podman é "socketless" por padrão. crie o socket para montar no container
# rootless
# podman system service unix:/run/user/$(id -g)/podman/podman.sock --time=0 &
# o --time é quanto tempo o socket suporta ficar ocioso. 0 para não ter timeout
#
# podman run -it --rm --security-opt label=disable -v /run/user/$(id -g)/podman/podman.sock:/var/run/podman.sock:Z --env CONTAINER_HOST=unix:/var/run/podman.sock alpine sh -uelic "apk add podman ; podman ps -a"
#
# rootfull
# podman system service unix:/run/podman.sock --time 0 &
# podman run -it --rm --security-opt label=disable -v /run/podman.sock:/var/run/podman.sock:Z --env CONTAINER_HOST=unix:/var/run/podman.sock alpine sh -uelic "apk add podman ; podman ps -a"

    if [ -z $rootless ] ; then
        eval "podman system service unix:/run/podman.sock --time 0 &"
        socket_origin="-v /run/podman.sock"
    else
        eval "podman system service unix:/run/user/$(id -g)/podman/podman.sock --time=0 &"
        socket_origin="-v /run/user/$(id -g)/podman/podman.sock"
    fi
    socket_mount_string="${socket_origin}:/var/run/podman.sock:Z --env CONTAINER_HOST=unix:/var/run/podman.sock"
    return
}
function container_create_gen_command(){
    command_gen="
    $container_engine create -it
    --security-opt label=disable
    --name $container_name
    --hostname $container_name
    --net host
    ${socket_mount_string}
    -v ${code_mount_path}:/run/host${code_mount_path}:rslave
    -w /run/host${code_mount_path}
    $image_name:latest"
}
function container_create_exec_command(){
    clear
    for i in {5..1}; do
        printf '\e[1;37m%s\e[m\n' "em $i segundos, será executado o comando abaixo, ctrl-c para cancelar"
        printf '\e[1;33m%s\e[m\n' "
        $command_gen
        "
        sleep 1
        clear
    done
    eval $command_gen
}
function container_entry_print_command(){
    printf '\e[1;37m%s\e[m\n' "iniciando $container_name..."
    eval "$container_engine start $container_name"
    printf '\e[1;32m%s\e[m\n' "para entrar, execute

        $container_engine exec -it --detach-keys \"\" $container_name zsh

"
}
function show_help(){
    printf '\e[1;37m%s\e[m\n' "
 
    -i | --image : nome da imagem base (obrigatório)
                se não fornecido, será devops-userspace-<container_engine>

    -n | --name : nome do container (obrigatório, só aceita - como separador)
                se não fornecido, será devops-userspace-<container_engine>-ano-mes-dia--hora-min-sec

    -e | --engine : escolha entre podman e docker (padrão=docker)


    -r | --rootless : se é para usar o container engine rootless
                padrão=falso
                (docker rootless não é tão usado quanto deveria)
                https://docs.docker.com/engine/security/rootless/


    -d | --dind : se o socket do container engine deve ser remontado dentro do container
            (útil para usar o container engine sem ter que sair do ambiente, mas é
            um problema de segurança, especialmente em setups rootfull)
            padrão=falso


    exemplo de comando completo:
    create-box -d -e podman -r -i devops-userspace-podman -n dev-on-container

    gerará um container:
    1. que permite usar a container engine escolhida;
    2. sendo essa engine o podman;
    3. em modo rootless;
    4. usando a imagem devops-userspace-podman;
    5. sob o nome dev-on-container.

    -h | --help: Exibe essa mensagem"
}
function main(){
passes=0
while :; do
    if [ $passes -le 20 ] ; then
    let passes++
        case $1 in
            --rootless | -r)
                rootless=1
                shift
                ;;
            --dind | -d)
                dind_setup=1
                shift
                ;;
            --name | -n)
                if [ -n "$2" ]; then
                    container_name="$2"
                    shift
                    shift
                fi
                ;;
            --engine | -e)
                if [ -n "$2" ]; then
                    container_engine="$2"
                    shift
                    shift
                fi
                ;;
            --image | -i)
                if [ -n "$2" ]; then
                    image_name="$2"
                    shift
                    shift
                fi
                ;;
            -h | --help)
                help_invoc=1
                branding
                show_help
                break
                ;;
            *)
                if [ $passes -le 10 ] ; then
                    help_invoc=0
                else
                    help_invoc=1
                fi
                break
                ;;
        esac
    else
        force_break=1
        break
    fi
done
if [ $help_invoc != 1 ] && [ $force_break != 1 ] ; then
code_mount_path=$(readlink -f $PWD)
    if [ -z $container_engine ] || [ $container_engine != "podman" ]; then container_engine="docker"; fi
    if [ -z $image_name ] ; then image_name="devops-userspace-$container_engine" ; fi
    if [ -z $container_name ] ; then container_name="$image_name-$(date +%Y-%m-%d--%H-%M-%S)" ; fi
    if [ ! -z $rootless ] && [ $(id -g) == "0" ] ; then
        printf '\e[1;31m%s\e[m\n' "rootless selecionado, porém executando como root, saindo"
        exit 1
    fi
    if [ ! -z $dind_setup ] ; then dind_generate_setup ; fi &&
    container_create_gen_command &&
    container_create_exec_command &&
    container_entry_print_command
else
    if [ $force_break -eq 1 ] ; then
        branding
        printf '\e[1;31m%s\e[m\n' "
        Erro de entrada desconhecido
        -h para ajuda"
        exit 1
    else
        exit 0
    fi
fi
}
force_break=0
help_invoc=0
main ${@}

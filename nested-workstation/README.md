## workstation in docker

```bash
bash ./privileged-dind.sh #### preferido 
```
Acesse localhost:15000 em algum navegador ***do host*** , use a senha que aparece no log do container para login.

É possível configurar uma senha explicitamente editando o script.

Esta é a mesma senha usada para comandos sudo.

Ctrl-c para sair do log (não interrompe a execução).

Se usar o botão de tela cheia, o alt-tab funcionará para trocar de janela.

Se quiser que seja acessivel em toda a rede interna, altere o bind-port para -p 15000:15000.


A instalação do docker é via o script oficial get.docker.com, conforme visível no Dockerfile

O uso do docker deve ser transparente, incluindo montagem de pastas de dentro da docker-workstation.

Mesmo kind deve funcionar aqui (testado). -> https://kind.sigs.k8s.io/

Se atente que abertura de portas ficará atrelada ao ip do container.

No host, execute:

```bash
docker container inspect docker-workstation | grep IPAddress
```

Ou, de dentro da docker-workstation, execute:
```bash
ip -br -c a   ### olhe a saída que começa com eth0
```

O que for criado com:
```bash
docker run -p 8080:8080 ....
```
de dentro da docker-workstation, será acessivel do host somente via docker-workstation-ip:8080.

Chrome e Firefox estão inclusos como navegadores na build da docker-workstation, e de dentro deles,
localhost:8080 funcionará.

A opção shm-size é usada para permitir que o chrome (e electrons, como o vscod(e/ium) seja executado.
Ver -> https://stackoverflow.com/questions/56218242/headless-chromium-on-docker-fails

Pode-se adicionar --memory=sizeG , para limitar o consumo máximo de memória.

Isso irá afetar por óbvio o total de cargas de trabalho internas possíveis.

Como editores, estão inclusos vim, nano, vscode e vscodium.

O terminal abre por padrão executando tmux, com leader-key alterada para ctrl-s, e outras customizações vi-like,
como pode ser visto no Dockerfile, ou de dentro da docker-workstation, em ~/.config/tmux/tmux.conf.
O suporte a mouse do tmux foi deixado desligado para não conflitar com o terminal. A rolagem via mouse porem, depende de 'ctrl-s [' (aperte q para sair).

Ter o tmux por padrão aumenta a resiliencia, dado que em caso de falha de conexão com o xpra, ou se o terminator fechar inesperadamente, ou mesmo
o xpra inteiro tiver um crash, o tmux (idealmente) se mantem de pé, sendo possível um rettach via terminal (docker exec no host), ou,
ao recuperar o xpra, voltar ao tmux via terminal.

Este terminal é o terminator, configurado por padrão com uma nerdfont,
compatível com oh-my-posh, oh-my-zsh, starship, powerlevel10k, etc.
Os padrões podem ser alterados via a interface do terminator, ou editando ~/.config/terminator/config.

O suporte a flatpak é instalado, e o flathub configurado como remote --user, para manter tudo no volume padronizado na build. (/home/ubuntu).
```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
```
Entre nas pastas abaixo para builds que incluem ambientes desktop completos.

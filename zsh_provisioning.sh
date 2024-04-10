#!/bin/zsh
function minimal_userspace()
{
    echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh &&
    echo 'export LANG=en_US.UTF-8' >> /etc/profile.d/locale.sh
    apk add --update \
            tmux \
            musl-locales \
            git \
            bash \
            neovim \
            htop \
            tar \
            zstd \
            coreutils \
            gzip \
            lz4 \
            lzo \
            xz \
            libarchive-tools \
            openssh \
            gpg \
            gpg-agent \
            zsh-vcs \
            ripgrep \
            icu-data-full \
            bat \
            tree \
            bind-tools \
            fd
cat >> /root/.tmux.conf <<EOF
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF
cat >> /usr/local/bin/tarballroot <<EOF
#!/bin/bash
tar \\
--exclude=/root/.cache \\
--exclude=/root/.gnupg \\
--exclude=/root/.local \\
--exclude=/root/.oh-my-zsh \\
--exclude=/root/.config/nvim \\
--exclude=/root/.fzf \\
-I 'zstd -T0 -v --fast -c' \\
-cpf /save-root.tar.zst /root && base32 /save-root.tar.zst
EOF
chmod +x /usr/local/bin/tarballroot

    MINIMAL_PROVISIONED="true"
    return
}
function large_userspace()
{
    apk add --update \
            ansible \
            iproute2 \
            helm \
            findmnt \
            jq \
            lynx \
            py3-pip \
            github-cli \
            git-lfs \
            podman \
            docker \
            docker-compose \
            zsh-vcs \
            diffutils \
            findutils \
            ranger \
            pv \
            zellij \
            glab
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl &&
chmod +x /usr/local/bin/kubectl
    return
}
function editor()
{
    if [ -z $MINIMAL_PROVISIONED ] ; then
        apk add bash git neovim ripgrep
        MINIMAL_PROVISIONED="downstream"
    fi
    apk add lua \
            nodejs \
            npm \
            lazygit \
            bottom \
            python3 \
            go \
            alpine-sdk --update &&
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    return
}
function shell()
{
    if [ -z $MINIMAL_PROVISIONED ] ; then
        apk add bash git neovim ripgrep
        MINIMAL_PROVISIONED="downstream"
    fi
    # apt/zypper/dnf/any install git bash zsh curl
    # MINIMAL_PROVISIONED=1 PROFILE=shell zsh zsh_provisioning.sh
    curl -L https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zshrc -o ~/zshrc &&
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &&
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &&
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &&
    ~/.fzf/install --completion --key-bindings --update-rc &&
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k &&
    cp ~/zshrc ~/.zshrc &&
        if [ $(whoami) != "root" ] ; then ; sed -i "s|/root|$HOME|g" .zshrc ; fi
    # exec zsh
    ##### exemplo #######
    # podman run \
    # -v $PWD:$PWD:Z \
    # -w $PWD \
    # -dit \
    # --name debian-shell \
    # --rm \
    # debian:stable-slim sh -uelic 'apt update ; 
    # apt install -y git bash zsh curl ; 
    # curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zsh_provisioning.sh | MINIMAL_PROVISIONED=1 PROFILE=shell zsh ; sed -i "s|/root|$HOME|g" $HOME/.zshrc; sleep infinity'
    return
}
#--[no-]key-bindings  Enable/disable key bindings (CTRL-T, CTRL-R, ALT-C)
#    --[no-]completion    Enable/disable fuzzy completion (bash & zsh)
#    --[no-]update-rc     Whether or not to update shell configuration files
function main()
{
    if [ $PROFILE = "full" ] ; then
        minimal_userspace &&
        large_userspace &&
        editor &&
        shell
    elif [ $PROFILE = "minimal" ] ; then
        minimal_userspace &&
        editor &&
        shell
    elif [ $PROFILE = "editor" ] ; then
        editor &&
        shell
    elif [ $PROFILE = "shell" ] ; then
        shell
    fi
}
if [ -z $PROFILE ] ; then PROFILE="full" ; fi
main

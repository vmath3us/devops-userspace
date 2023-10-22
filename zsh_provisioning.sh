#!/bin/zsh
apk add --update \
        ansible \
        iproute2 \
        htop \
        helm \
        tar \
        zstd \
        gzip \
        lz4 \
        lzo \
        xz \
        libarchive-tools \
        findmnt \
        openssh \
        gpg \
        gpg-agent \
        icu-data-full \
        jq \
        lynx \
        zsh \
        bat \
        tree \
        py3-pip \
        bash \
        git \
        lua \
        nodejs \
        npm \
        lazygit \
        bottom \
        python3 \
        go \
        neovim \
        ripgrep \
        alpine-sdk \
        github-cli \
        podman \
        docker \
        zsh-vcs \
        glab &&
git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim &&
git clone https://github.com/AstroNvim/user_example ~/.config/nvim/lua/user &&
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl &&
chmod +x /usr/local/bin/kubectl &&
curl -L https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zshrc -o /root/zshrc &&
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &&
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &&
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &&
/root/.fzf/install --completion --key-bindings --update-rc &&
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k &&
cp /root/zshrc ~/.zshrc &&
exit 0 || exit 1
#--[no-]key-bindings  Enable/disable key bindings (CTRL-T, CTRL-R, ALT-C)
#    --[no-]completion    Enable/disable fuzzy completion (bash & zsh)
#    --[no-]update-rc     Whether or not to update shell configuration files

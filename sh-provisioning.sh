#!/bin/sh
function minimal_userspace()
{
    echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh &&
    echo 'export LANG=en_US.UTF-8' >> /etc/profile.d/locale.sh
    apk add --update \
            zsh \
            util-linux \
            zoxide \
            eza \
            inotify-tools \
            alpine-conf \
            shadow \
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
    chsh -s /bin/zsh root
    setup-timezone America/Sao_Paulo
    auxiliar_scripts_create
    tmux_heredoc
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
            glab
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl &&
chmod +x /usr/local/bin/kubectl
    return
}
function editor()
{
    if [ -z $MINIMAL_PROVISIONED ] ; then
        apk add zsh eza zoxide bash git neovim fd ripgrep bat tmux shadow
        chsh -s /bin/zsh root
        tmux_heredoc
        auxiliar_scripts_create
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
        apk add zsh eza zoxide bash git neovim fd ripgrep bat tmux shadow
        chsh -s /bin/zsh root
        mkdir -p /root/.config/nvim
        neovim_heredoc
        tmux_heredoc
        auxiliar_scripts_create
        MINIMAL_PROVISIONED="downstream"
    fi

    # apt/zypper/dnf/any install git bash zsh curl
    # MINIMAL_PROVISIONED=1 PROFILE=shell zsh sh-provisioning.sh
    curl -L https://gitlab.com/vmath3us/devops-userspace/-/raw/main/zshrc -o ~/zshrc &&
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &&
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &&
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &&
    ~/.fzf/install --completion --key-bindings --update-rc &&
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k &&
    cp ~/zshrc ~/.zshrc &&
    if [ $(whoami) != "root" ] ; then sed -i "s|/root|$HOME|g" ~/.zshrc ; fi
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
    # curl -fsL https://gitlab.com/vmath3us/devops-userspace/-/raw/main/sh-provisioning.sh | MINIMAL_PROVISIONED=1 PROFILE=shell zsh ; sed -i "s|/root|$HOME|g" $HOME/.zshrc; sleep infinity'
    return
}
#--[no-]key-bindings  Enable/disable key bindings (CTRL-T, CTRL-R, ALT-C)
#    --[no-]completion    Enable/disable fuzzy completion (bash & zsh)
#    --[no-]update-rc     Whether or not to update shell configuration files
function tmux_heredoc()
{
    mkdir -pv ~/.config/tmux
cat > ~/.config/tmux/tmux.conf <<EOF
unbind C-b
set -g prefix C-w
default_color=cyan

set-window-option -g mode-keys vi
set-window-option -g xterm-keys on
set -s escape-time 0

set-option -g history-limit 3000

set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"

setw -g pane-base-index 1
set -g base-index 1
set -g pane-border-status top
set -g status-left-length 50
set -g status-justify absolute-centre

set -g status-style "fg=black,bg=\${default_color}"
set -g window-status-format "#[fg=black] #I:#W "
set -g window-status-current-format "#[bg=black,fg=\${default_color}] #I:#W "
set -g pane-border-status top
set -g pane-border-style "bg=black fg=\${default_color}"
set -g pane-active-border-style "bg=\${default_color} fg=black"
set -g status-left "#[bg=black,fg=\${default_color}] #{session_name} "
set -g status-right "#[bg=black,fg=\${default_color}] %Y/%m/%d %H:%M:%S "

bind = split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
bind s choose-buffer
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind u resize-pane -L 3
bind i resize-pane -D 3
bind o resize-pane -U 3
bind p resize-pane -R 3
EOF
    return
}
function neovim_heredoc(){
   mkdir -pv ~/.config/nvim 
cat > ~/.config/nvim/init.vim <<EOF
syntax on
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set smartindent
set hidden
set cursorline
set number relativenumber
set incsearch
set ignorecase
set smartcase
set scrolloff=8
set signcolumn=yes
set cmdheight=2
set updatetime=100
set clipboard=unnamedplus
set encoding=utf-8
set splitbelow
set autoread
set mouse=a
filetype on
filetype plugin on
filetype indent on
map <C-j> <C-w>j
map <C-h> <C-w>h
map <C-k> <C-w>k
map <C-l> <C-w>l
map <C-t> :tabNext<CR>
nmap qq :q
nmap qf :q! <CR>
nmap wq :wq <CR>
nmap ss :%s/
nmap ww :w <CR>
nmap tt :tabnew
nmap tv :vsplit
nmap op o<Esc>p
nmap oi O<Esc>j
nmap oo A<CR>
nmap tw :terminal
nmap bw :w :bw <CR>
nmap bq :bdelete! <CR>
nmap bn :bN <CR>
nmap bp :bp <CR>
EOF
    return
}
function auxiliar_scripts_create()
{
cat > /usr/local/bin/tarballroot <<EOF
#!/bin/bash
tar \\
--exclude=/root/.cache \\
--exclude=/root/.gnupg \\
--exclude=/root/.local \\
--exclude=/root/.oh-my-zsh \\
--exclude=/root/.config/nvim \\
--exclude=/root/.fzf \\
-I 'zstd -T0 -v --fast -c' \\
-cpf /save-root.tar.zst /root && cat /save-root.tar.zst
EOF
chmod +x /usr/local/bin/tarballroot
cat > /usr/local/bin/auto-commiter <<EOF
#!/bin/bash
monitor_changes() {
    absolute_path=\$(realpath "\$PWD")
    delta=\$(git diff --no-color)
    datetime=\$(date +"%Y-%m-%d--%H-%M-%S")
    commit_message="\$absolute_path \$datetime"\$'\n\n'"\$delta"
    git add .
    git commit -m "\$commit_message"
}
git checkout -b save-wip-\$(date +"%Y-%m-%d--%H-%M-%S")
while true ; do
    inotifywait -qq -r -e modify -e create -e delete \$PWD
    monitor_changes
done
EOF
chmod +x /usr/local/bin/auto-commiter
    return
}

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
    if [ ! -z $HEREDOCS ] ; then
        tmux_heredoc
        neovim_heredoc
    fi
}
if mountpoint -q /run/host && [ -z $MACHINE_OWNER ] 
then
    exit
fi
if [ ! -z $ONLY_HEREDOCS ] ; then
    tmux_heredoc
    neovim_heredoc
    exit
fi
if [ -z $PROFILE ] ; then PROFILE="full" ; fi
main

unset SESSION_MANAGER
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

plugins=(
     git
     gitignore
     docker
     fzf
     docker-compose
     zsh-autosuggestions
     systemd
     zsh-syntax-highlighting
     ansible
)
source $ZSH/oh-my-zsh.sh

###############################################################################
#                   gpg
#############################################################################
export GPG_TTY=$TTY
gpg-agent --daemon
gpgconf --launch gpg-agent
###############################################################################

###############################################################################
#                   ssh
#############################################################################
if [ ! -e /etc/ssh/ssh_host_ed25519_key.pub ] ; then ssh-keygen -A ; fi
#############################################################################

#####################################################################################
#                               vi mode
#####################################################################################
set -o vi
bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
#####################################################################################
#
#			alias session
#
#####################################-general-#######################################
alias c="clear"
alias edit="nvim"
alias e="exit"
alias td="tmux detach"
alias top="htop"
alias vim="nvim"
alias dhere="curl -ZfsSLOC -"
alias html="lynx --display_charset=utf-8 -force_html -vikeys"
alias htmldump="lynx --display_charset=utf-8 -force_html -dump"
alias ip="ip -br -c a"
alias paste='curl -F 'file=@-' 0x0.st'
alias moment="date +%Y-%m-%d--%H-%M-%S"
alias fd="fd|fzf"
alias speedtest="curl -fSL https://raw.githubusercontent.com/sivel/speedtest-cli/22210ca35228f0bbcef75a7c14587c4ecb875ab4/speedtest.py | python3"
#########################################
#                                       #
#               force color             #
#                                       #    
#########################################
export COLORTERM=truecolor
export TERM=xterm-256color
#########################################
#                                       #
#               force locale            #
#                                       #    
#########################################
if [ -e /etc/profile.d/locale.sh ] ; then source /etc/profile.d/locale.sh ; fi
#########################################
export MANPAGER="nvim +Man!" 
export EDITOR="nvim"
export FZF_BASE=/root/fzf/shell
#upload file,512mb limit
upload() {
    for i in "$@" 
    do
        curl -F file=@$i http://0x0.st 
    done 
}
copy(){
cp -paruv "$@"
}
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
for i in docker podman helm kubectl ; do
    if command -v $i ; then
        source <($i completion zsh)
    fi
done
autoload -U compinit; compinit
alias k=kubectl
cclock () {
	curl -v https://google.com 2>&1 | rg '< date'
	date
}
upregex(){

printf "\n\"mount| sed -e \\\"/[A-Z]/d\\\" -e \\\"s/.*lower.*upperdir=//g\\\" -e \\\"s/,work.*//g\\\" -e '1\\\!d'\"%s\n\n"

}
gpg-sym-upload()
{
gpg --output - --armor --cipher-algo AES256 --symmetric ${@} | base32 | paste
}
stmux()
{
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
     echo "parametro nulo, precisa de usuário, destino, e nome da sessão, nessa ordem"
     exit 1
else
ssh "$1"@"$2" -t "if [ \$(which tmux) ] ; then
cat > \$HOME/.tmux.conf <<EOF
set-window-option -g mode-keys vi
set-option -g history-limit 3000000
set -g default-terminal \"tmux-256color\"
set -ga terminal-overrides \",*256col*:Tc\"
set -g pane-border-status top
bind = split-window -h
bind - split-window -v
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind-key -n M-h resize-pane -L
bind-key -n M-j resize-pane -D
bind-key -n M-k resize-pane -U
bind-key -n M-l resize-pane -R
EOF
TERM=xterm-256color tmux -2 -u new-session -A -s "${3}"
else
exec bash
fi"
fi
}
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

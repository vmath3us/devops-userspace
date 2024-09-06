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
alias gitmux="tmux new-session -d -s autocommiter -c "$(pwd)" "auto-commiter""
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
alias speedtest="curl -fSL https://raw.githubusercontent.com/sivel/speedtest-cli/22210ca35228f0bbcef75a7c14587c4ecb875ab4/speedtest.py | python3"
#by https://raw.githubusercontent.com/josean-dev/dev-environment-files/2c12f439f451ef6483d3d9916c8e33b178ff74ad/.zshrc
# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#000000"
bg_highlight="#143652"
orange="#F85000"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${orange},fg+:${fg},bg+:${bg_highlight},hl+:${orange},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ----- Bat (better cat) -----

export BAT_THEME=tokyonight_night

# ---- Eza (better ls) -----

alias ls="eza --icons=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

alias cd="z"
#by https://raw.githubusercontent.com/josean-dev/dev-environment-files/2c12f439f451ef6483d3d9916c8e33b178ff74ad/.zshrc
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
     return 1
else
ssh "$1"@"$2" -t 'if [ $(which tmux) ] ; then
cat > /tmp/.vmath3us.tmux.conf <<EOF
default_color=red

set-window-option -g mode-keys vi
set-window-option -g xterm-keys on
set -s escape-time 0

set-option -g history-limit 3000000

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
bind-key -n M-u resize-pane -L 3
bind-key -n M-i resize-pane -D 3
bind-key -n M-o resize-pane -U 3
bind-key -n M-p resize-pane -R 3
EOF
TERM=xterm-256color tmux -S /tmp/.vmath3us.tmux.sock -f /tmp/.vmath3us.tmux.conf -2 -u new-session -A -s '\"${3}\"'
else
exec bash
fi'
fi
}
term-colors () 
{
     for i in {0..255}; do
          printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i
               if ! (( ($i + 1 ) % 8 )); then
                    echo
               fi
     done

}

geoip ()
{
     curl ipinfo.io/"${@}" | jq -r
}
secret_decode()
{
  jq -r '.data | map_values(@base64d)'
}
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

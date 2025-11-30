zmodload zsh/complist
autoload -U compinit && compinit

_comp_options+=(globdots)

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select

bindkey -v
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'l' vi-forward-char

unsetopt beep

setopt auto_cd
setopt auto_param_slash
setopt auto_pushd
setopt complete_in_word
setopt hist_ignore_all_dups
setopt pushd_silent
unsetopt prompt_sp

alias ls='ls -hN --color=auto --group-directories-first'
alias mkdir='mkdir --parents'
alias tar='tar --verbose'
alias untar='tar --extract --file'
alias uptime='uptime -p'

export PS1='%~ '
export KEYTIMEOUT=1 # Reduce <Esc> timeout

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -e

autoload -Uz compinit
compinit

source /usr/lib/spaceship-prompt/spaceship.zsh

export LD_LIBRARY_PATH=/usr/lib32/nvidia:/usr/lib/nvidia:$LD_LIBRARY_PATH

alias pacman-clean='sudo pacman -Scc --noconfirm && sudo pacman -Rns $(pacman -Qtdq) --noconfirm'
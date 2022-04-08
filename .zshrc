# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export ZSH="$HOME/.oh-my-zsh"

plugins=(asdf dotbare zsh-autosuggestions zsh-syntax-highlighting)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

if [ -d "$HOME/.local/profile" ] ; then
  for f in "$HOME/.local/profile/"*; do
    source "$f"
  done
fi

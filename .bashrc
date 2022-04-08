# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval "$(starship init bash)"

# Load user profile
if [ -d "$HOME/.local/profile" ] ; then
  for f in "$HOME/.local/profile/"*; do
    source "$f"
  done
fi

### EXPORT
export TERM="xterm-256color"                      # getting proper colors
export EDITOR="nvim"                              # $EDITOR use Neovim in terminal
export VISUAL="code"                              # $VISUAL use VS Code in GUI mode

### "bat" as manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export GPG_TTY=$(tty)

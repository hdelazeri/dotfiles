if [ -d "/home/hdelazeri/.local/share/pnpm" ]; then
  export PNPM_HOME="/home/hdelazeri/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
  alias pnpx="pnpm dlx"
fi

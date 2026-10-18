#!/bin/sh
set -e

# Make sure opencode is in PATH
# make sure opencode is in PATH
export PATH="$HOME/.opencode/bin:$PATH"

mkdir -p ~/.local/share ~/.config

# Link data/config dirs only when the default locations are free. When a
# volume is mounted directly at the default path (e.g. /root/.config/opencode),
# `ln -sf target <dir>` would drop a useless `config`/`data` symlink INSIDE it.
[ -e "$HOME/.local/share/opencode" ] || ln -sf /data "$HOME/.local/share/opencode"
[ -e "$HOME/.config/opencode" ] || ln -sf /config "$HOME/.config/opencode"

# Auto-detect config file if not explicitly set
# Check jsonc FIRST (mounted volume takes precedence over baked-in)
if [ -z "$OPENCODE_CONFIG" ]; then
  if [ -f /config/opencode.jsonc ]; then
    export OPENCODE_CONFIG=/config/opencode.jsonc
  elif [ -f /config/opencode.json ]; then
    export OPENCODE_CONFIG=/config/opencode.json
  fi
fi

# Debug info
if [ "$DEBUG" = "true" ]; then
  echo "--- DEBUG INFO ---"
  echo "Node version:     $(node --version)"
  echo "Python version:   $(python3 --version 2>/dev/null || echo 'not installed')"
  echo "pip version:      $(pip3 --version 2>/dev/null || echo 'not installed')"
  echo "uv version:       $(uv --version 2>/dev/null || echo 'not installed')"
  echo "OpenCode version: $(opencode --version 2>/dev/null || echo 'not installed')"
  echo ""
  echo "PATH:             $PATH"
  echo "OpenCode binary:  $(which opencode 2>/dev/null || echo 'not found')"
  echo "OPENCODE_CONFIG:  ${OPENCODE_CONFIG:-<not set>}"
  echo "Config files:     $(ls -la /config/ 2>/dev/null || echo '<empty>')"
  echo "Config symlink:   $(ls -la ~/.config/opencode 2>/dev/null || echo 'not found')"
  echo "Data symlink:     $(ls -la ~/.local/share/opencode 2>/dev/null || echo 'not found')"
fi

echo "======================="

ARGS=""

if [ -n "$OPENCODE_PORT" ]; then
  ARGS="$ARGS --port $OPENCODE_PORT"
fi

if [ -n "$OPENCODE_HOSTNAME" ]; then
  ARGS="$ARGS --hostname $OPENCODE_HOSTNAME"
fi

# V2: port/hostname are scoped to `serve`, so they must come after the
# subcommand. Pre-command flags fall through to top-level help and exit 1.
exec opencode "$@" $ARGS

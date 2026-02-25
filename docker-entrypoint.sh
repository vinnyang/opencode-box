#!/bin/sh
set -e

# Make sure opencode is in PATH
export PATH="$HOME/.opencode/bin:$PATH"

# Pass server password as environment variable if set
if [ -n "$OPENCODE_SERVER_PASSWORD" ]; then
  export OPENCODE_SERVER_PASSWORD
fi

mkdir -p ~/.local/share ~/.config

# Link data directory for persistence
ln -sf /data ~/.local/share/opencode

# Link config so OpenCode finds it in default location
ln -sf /config ~/.config/opencode

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

exec opencode $ARGS "$@"

#!/bin/sh
set -e

# Make sure opencode is in PATH
export PATH="$HOME/.opencode/bin:$PATH"

# Pass server password as environment variable if set
if [ -n "$OPENCODE_SERVER_PASSWORD" ]; then
  export OPENCODE_SERVER_PASSWORD
fi

echo "=== Container Startup ==="
echo "Node version:     $(node --version)"
echo "Python version:   $(python3 --version 2>/dev/null || echo 'not installed')"
echo "pip version:      $(pip3 --version 2>/dev/null || echo 'not installed')"
echo "uv version:       $(uv --version 2>/dev/null || echo 'not installed')"
echo "OpenCode version: $(opencode --version 2>/dev/null || echo 'not installed')"
echo "======================="

mkdir -p ~/.local/share ~/.config
ln -sf /data ~/.local/share/opencode
ln -sf /config ~/.config/opencode

ARGS=""

if [ -n "$OPENCODE_PORT" ]; then
  ARGS="$ARGS --port $OPENCODE_PORT"
fi

if [ -n "$OPENCODE_HOSTNAME" ]; then
  ARGS="$ARGS --hostname $OPENCODE_HOSTNAME"
fi

exec opencode $ARGS "$@"

#!/bin/sh
set -e

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

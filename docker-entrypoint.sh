#!/bin/sh
set -e

ARGS=""

if [ -n "$OPENCODE_PORT" ]; then
  ARGS="$ARGS --port $OPENCODE_PORT"
fi

if [ -n "$OPENCODE_HOSTNAME" ]; then
  ARGS="$ARGS --hostname $OPENCODE_HOSTNAME"
fi

exec opencode $ARGS "$@"

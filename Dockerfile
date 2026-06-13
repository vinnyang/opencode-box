FROM node:alpine

LABEL org.opencontainers.image.title="opencode-box" \
      org.opencontainers.image.description="OpenCode AI coding agent in a container, with Node (npx) and Python (uvx) MCP support" \
      org.opencontainers.image.source="https://github.com/vinnyang/opencode-box" \
      org.opencontainers.image.licenses="MIT"

# Pin opencode to the tracked version for reproducible builds (the installer reads $VERSION).
# Copied first so a version bump invalidates the install layer cache.
COPY .opencode-version /tmp/oc-version

RUN apk upgrade --no-cache && \
    apk add --no-cache git ripgrep jq python3 py3-pip curl bash tar && \
    pip3 install --break-system-packages uv && \
    curl -fsSL https://opencode.ai/install | VERSION="$(cat /tmp/oc-version)" bash && \
    rm /tmp/oc-version
# Need to compile native MCP deps (Python wheels / node-gyp)? add: build-base python3-dev

ENV PATH="/root/.opencode/bin:$PATH"

RUN mkdir -p /config /data/sessions /data/snapshots /data/log /projects

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Baked-in default config (overridden when a /config volume is mounted)
COPY config/opencode.json /config/opencode.json

EXPOSE 4096

# Liveness probe (default unsecured server returns 200 at /; adjust if you require auth)
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- "http://localhost:${OPENCODE_PORT:-4096}/" >/dev/null 2>&1 || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["serve"]

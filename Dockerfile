FROM node:alpine@sha256:233761595746769ebfdb6090f44fc7cdf818ae0ce62d2b37e0367723b9823e36

# Populated automatically by Docker Buildx per target platform (amd64 / arm64).
ARG TARGETARCH

LABEL org.opencontainers.image.title="opencode-box" \
      org.opencontainers.image.description="OpenCode AI coding agent in a container, with Node (npx) and Python (uvx) MCP support" \
      org.opencontainers.image.source="https://github.com/vinnyang/opencode-box" \
      org.opencontainers.image.licenses="MIT"

# Pin opencode to the tracked version for reproducible builds.
# Copied first so a version bump invalidates the install layer cache.
COPY .opencode-version /tmp/oc-version

RUN apk upgrade --no-cache && \
    apk add --no-cache git ripgrep jq python3 py3-pip curl bash tar && \
    pip3 install --break-system-packages uv && \
    OC_VER="$(cat /tmp/oc-version)" && \
    case "$TARGETARCH" in \
      amd64) OC_ARCH="x64" ;; \
      arm64) OC_ARCH="arm64" ;; \
      *) echo "unsupported TARGETARCH: '$TARGETARCH'" >&2; exit 1 ;; \
    esac && \
    curl -fsSL -o /tmp/oc.tar.gz \
      "https://github.com/anomalyco/opencode/releases/download/v${OC_VER}/opencode-linux-${OC_ARCH}-musl.tar.gz" && \
    tar -xzf /tmp/oc.tar.gz -C /usr/local/bin opencode && \
    chmod 755 /usr/local/bin/opencode && \
    rm /tmp/oc.tar.gz /tmp/oc-version
# Need to compile native MCP deps (Python wheels / node-gyp)? add: build-base python3-dev

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

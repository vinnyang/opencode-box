FROM node:alpine@sha256:6f08a523443ddedf52941874c203475b0ad503e859ad70cb26ab8be9a517dbd5

# Populated automatically by Docker Buildx per target platform (amd64 / arm64).
ARG TARGETARCH

LABEL org.opencontainers.image.title="opencode-box" \
      org.opencontainers.image.description="OpenCode AI coding agent in a container, with Node (npx) and Python (uvx) MCP support" \
      org.opencontainers.image.source="https://github.com/vinnyang/opencode-box" \
      org.opencontainers.image.licenses="MIT"

# Pin opencode to the tracked version for reproducible builds.
# Copied first so a version bump invalidates the install layer cache.
COPY .opencode-version /tmp/oc-version

# v2 binaries are published as npm platform packages, not GitHub release assets.
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
      "https://registry.npmjs.org/@opencode/cli-linux-${OC_ARCH}-musl/-/cli-linux-${OC_ARCH}-musl-${OC_VER}.tgz" && \
    tar -xzf /tmp/oc.tar.gz -C /tmp package/bin/opencode && \
    mv /tmp/package/bin/opencode /usr/local/bin/opencode && \
    chmod 755 /usr/local/bin/opencode && \
    rm -rf /tmp/oc.tar.gz /tmp/package /tmp/oc-version
# Need to compile native MCP deps (Python wheels / node-gyp)? add: build-base python3-dev

RUN mkdir -p /config /data/sessions /data/snapshots /data/log /projects

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Baked-in default config (overridden when a /config volume is mounted)
COPY config/opencode.json /config/opencode.json

EXPOSE 4096

# Liveness probe (default unsecured server returns 200 at /; adjust if you require auth)
# Use 127.0.0.1, not localhost: the v2 server binds IPv4-only and busybox wget
# resolves localhost to ::1 first, then reports connection refused.
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- "http://127.0.0.1:${OPENCODE_PORT:-4096}/" >/dev/null 2>&1 || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["serve"]

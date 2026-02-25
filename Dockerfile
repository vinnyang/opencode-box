FROM node:alpine

RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache python3 py3-pip curl bash && \
    pip3 install --break-system-packages uv && \
    curl -fsSL https://opencode.ai/install | bash && \
    echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.bashrc

RUN mkdir -p /config /data/sessions /data/snapshots /data/log /projects /mcp

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 4096

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["web"]

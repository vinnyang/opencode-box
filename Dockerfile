FROM node:alpine
RUN apk update && apk upgrade --no-cache && \
    npm install -g opencode-ai && \
    npm cache clean --force
RUN mkdir -p /config
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
EXPOSE 4096
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["web"]
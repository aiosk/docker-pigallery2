FROM node:16-buster AS builder
# copying only package{-lock}.json to make node_modules cachable
RUN git clone https://github.com/bpatrik/pigallery2.git /build
WORKDIR /build
RUN ln -s /usr/local/bin/node /usr/local/sbin/node \
    && npm install --unsafe-perm \
    && mkdir -p /build/release/data/config \
    && mkdir -p /build/release/data/db \
    && mkdir -p /build/release/data/images \
    && mkdir -p /build/release/data/tmp \
    && npm run create-release \
    && cd /build/release \
    && npm install --unsafe-perm


FROM ghcr.io/linuxserver/baseimage-ubuntu:focal AS main
WORKDIR /app
ENV NODE_ENV=production \
    # overrides only the default value of the settings (the actualy value can be overwritten through config.json)
    default-Server-Database-dbFolder=/app/data/db \
    default-Server-Media-folder=/app/data/images \
    default-Server-Media-tempFolder=/app/data/tmp \
    # flagging dockerized environemnt
    PI_DOCKER=true

EXPOSE 80
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends ca-certificates wget ffmpeg nodejs \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/release /app
VOLUME ["/app/data/config", "/app/data/db", "/app/data/images", "/app/data/tmp"]
HEALTHCHECK --interval=40s --timeout=30s --retries=3 --start-period=60s \
  CMD wget --quiet --tries=1 --no-check-certificate --spider \
  http://localhost:80/heartbeat || exit 1

COPY root/ /
# after a extensive job (like video converting), pigallery calls gc, to clean up everthing as fast as possible
# Exec form entrypoint is need otherwise (using shell form) ENV variables are not properly passed down to the app
# ENTRYPOINT ["node", "./src/backend/index", "--expose-gc",  "--config-path=/app/data/config/config.json"]


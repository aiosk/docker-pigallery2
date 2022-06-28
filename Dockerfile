FROM node:16-buster AS builder
RUN git clone https://github.com/bpatrik/pigallery2.git /build
WORKDIR /build
RUN npm install --unsafe-perm \
    && mkdir -p /build/release/data/config \
    && mkdir -p /build/release/data/db \
    && mkdir -p /build/release/data/images \
    && mkdir -p /build/release/data/tmp \
    && npm run create-release \
    && cd /build/release \
    && npm install --unsafe-perm


FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS main
WORKDIR /app
ENV NODE_ENV=production \
    # overrides only the default value of the settings (the actualy value can be overwritten through config.json)
    default-Server-Database-dbFolder=/app/data/db \
    default-Server-Media-folder=/app/data/images \
    default-Server-Media-tempFolder=/app/data/tmp \
    # flagging dockerized environemnt
    PI_DOCKER=true

EXPOSE 80
COPY root/ /
RUN chmod +x /node_setup_16.x && /node_setup_16.x \
    && apt-get install -y --no-install-recommends ca-certificates wget ffmpeg nodejs \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/release /app
VOLUME ["/app/data/config", "/app/data/db", "/app/data/images", "/app/data/tmp"]
HEALTHCHECK --interval=40s --timeout=30s --retries=3 --start-period=60s \
  CMD wget --quiet --tries=1 --no-check-certificate --spider \
  http://localhost:80/heartbeat || exit 1

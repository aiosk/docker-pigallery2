FROM bpatrik/pigallery2:1.9.3 as builder

FROM ghcr.io/linuxserver/baseimage-ubuntu:focal
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
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y --no-install-recommends ca-certificates wget ffmpeg nodejs \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app /app
VOLUME ["/app/data/config", "/app/data/db", "/app/data/images", "/app/data/tmp"]
HEALTHCHECK --interval=40s --timeout=30s --retries=3 --start-period=60s \
  CMD wget --quiet --tries=1 --no-check-certificate --spider \
  http://localhost:80/heartbeat || exit 1

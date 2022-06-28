# pigallery2


[bpatrik/pigallery2](https://github.com/bpatrik/PiGallery2) + s6 overlay

```
docker run -d \
  --name=pigallery2 \
  --env PUID=1000 \
  --env PGID=1000 \
  --env TZ=Asia/Jakarta \
  --env NODE_ENV=production \
  --publish=80:80 \
  --volume /path/to/config:/app/data/config \
  --volume /path/to/tmp:/app/data/tmp \
  --volume db-data:/app/data/db \
  --volume /path/to/images:/app/data/images:ro \
  --restart unless-stopped \
  ghcr.io/aiosk/pigallery2
```
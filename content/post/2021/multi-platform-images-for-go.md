---
title: "On Multi-Platform Docker images"
date: 2021-07-15T09:29:54-07:00
publishdate: 2021-07-15
lastmod: 2021-07-15
tags: []
---

Until recently, [Faktory](https://contribsys.com/faktory) only supported the x86_64 platform. With the
rise of the Apple Silicon chip and AWS Graviton, it was obvious that I
would need to roll out ARM64 support soon. This week
I spent several days fighting Docker's support for multi-platform images and wanted to document what I learned.

## Faktory OSS

The [Faktory OSS build](https://github.com/contribsys/faktory/blob/master/Makefile) was relatively straightforward, with three steps
for each platform:

1. Build the ./faktory binary on the host.
2. Compress the binary with upx (this cuts the binary in half, 10MB -> 5MB)
3. Run buildx for that platform to copy the binary into the platform-specific image and load it into the
   local registry for testing.

```make
dimg: clean generate ## Make cross-platform Docker images for the current version
	GOOS=linux GOARCH=amd64 go build -o faktory cmd/faktory/daemon.go
	upx -qq ./faktory
	docker buildx build --platform linux/amd64 --tag contribsys/faktory:$(VERSION) --tag contribsys/faktory:latest --load .
	GOOS=linux GOARCH=arm64 go build -o faktory cmd/faktory/daemon.go
	upx -qq ./faktory
	docker buildx build --platform linux/arm64 --tag contribsys/faktory:$(VERSION) --tag contribsys/faktory:latest --load .
```

Once that is done, a simple `push` sends the built images to docker.io:

```make
dpush:
	docker push contribsys/faktory:$(VERSION)
	docker push contribsys/faktory:latest
```

Note a couple of things about this build process:

1. I'm not using multi-stage builds. The Go binary is built locally on
   the host machine, not inside an image, and COPY'd into the image.
   That's why I can't use buildx to build multiple platforms
   simultaneously. The ./faktory binary is specific to the platform.
2. You can see the resulting multi-platform manifest with this command:
   `docker manifest inspect contribsys/faktory:1.5.2`
3. Perhaps I should consider a multi-stage Dockerfile with CI integration to build and push OSS images, rather than doing it locally?
   This would make the release process extremely easy but I've never done it before, pointers welcome.

## Faktory Enterprise

Because Faktory Enterprise uses my own private Docker registry, I used a
different approach. **I'm still not sure which approach is better or worse**
but here's what I did.

```make
dpush: clean generate
	GOOS=linux GOARCH=amd64 go build -o tmp/linux/amd64 cmd/daemon/main.go
	GOOS=linux GOARCH=arm64 go build -o tmp/linux/arm64 cmd/daemon/main.go
	upx -qq ./tmp/linux/amd64
	upx -qq ./tmp/linux/arm64
	ssh -N -f -L 9999:localhost:9999 root@docker.contribsys.com
	sleep 2
	docker buildx --builder focused_saha build --platform="linux/amd64,linux/arm64" -t host.docker.internal:9999/contribsys/$(NAME):$(VERSION) --push .
```

Here's the trick: I'm building multiple binaries and naming them according to Docker's
TARGETPLATFORM variable, e.g. "linux/amd64". Now I can use a proper multi-platform build
and the Dockerfile will pull in the right binary with this trick:

```docker
FROM alpine:3.13
ARG TARGETPLATFORM
RUN apk add --no-cache redis ca-certificates socat
COPY ./tmp/$TARGETPLATFORM /faktory
```

Docker will pull the right Alpine image for each platform, copy the platform-specific binary and push the resulting images to my registry with one command:

```
docker buildx --builder focused_saha build --platform="linux/amd64,linux/arm64" -t host.docker.internal:9999/contribsys/faktory-ent:$(VERSION) --push .
```

(The custom "focused_saha" builder is required to disable HTTPS and allow
an "insecure" registry. It's not really insecure because of the SSH tunnel.)

I'm not a Docker expert by any means so I can't tell which approach is
right or wrong or what the tradeoffs might be. I hope this helps
someone; tweet at @getajobmike if you have a comment or suggestion.

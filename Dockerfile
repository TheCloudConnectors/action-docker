FROM docker:24.0.7-dind

# Install necessary packages for overlay2
RUN apk add --no-cache \
    e2fsprogs \
    util-linux \
    xfsprogs \
    xfsprogs-extra

RUN \
	mkdir -p /aws && \
	apk -Uuv add groff less python3 py-pip && \
	pip install awscli --break-system-packages && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

RUN mkdir -p /root/.docker/cli-plugins && \
    wget -qO /root/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-amd64 && \
    chmod +x /root/.docker/cli-plugins/docker-buildx

ADD build.sh /bin/

RUN chmod +x /bin/build.sh

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/build.sh"]
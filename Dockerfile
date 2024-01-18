FROM docker:24.0.7-dind

RUN \
	mkdir -p /aws && \
	apk -Uuv add groff less python3 py-pip && \
	pip install awscli --break-system-packages && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

ADD build.sh /bin/

RUN chmod +x /bin/build.sh

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/build.sh"]
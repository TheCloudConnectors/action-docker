FROM docker:18.09.0-dind

RUN \
	mkdir -p /aws && \
	apk -Uuv add groff less python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

ADD build.sh /bin/

RUN chmod +x /bin/build.sh

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/build.sh"]
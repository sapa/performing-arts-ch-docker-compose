FROM alpine:latest

COPY entrypoint.sh /
COPY backup.sh /

RUN \
	mkdir -p /aws /backups && \
	apk -Uuv add python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/* && \
  chmod +x /entrypoint.sh /backup.sh


ENTRYPOINT /entrypoint.sh
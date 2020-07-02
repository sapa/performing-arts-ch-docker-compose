FROM alpine:latest

COPY entrypoint.sh /

RUN \
	mkdir -p /data/backup /aws /backups && \
	apk -Uuv add python3 py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/* && \
  chmod +x /entrypoint.sh


ENTRYPOINT /entrypoint.sh

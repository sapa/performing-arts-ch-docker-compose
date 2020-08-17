FROM alpine:3.12.0

COPY entrypoint.sh /

RUN \
	mkdir -p /data/backup /aws /backups && \
	apk -Uuv add python3 py3-pip && \
	pip3 install awscli six && \
	apk --purge -v del py3-pip && \
	rm /var/cache/apk/* && \
  chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh

#!/bin/sh

if [ -z "${CRON_SCHEDULE}" ]; then
	echo "No CRON_SCHEDULE provided. No backups will be performed." 
	while :; do sleep 2073600; done
fi

if [ -n "${CRON_SCHEDULE}" ]; then
	echo "Creating crontab"
    echo -e "$CRON_SCHEDULE /backup.sh\n" > /etc/crontabs/root
	echo "Starting crond"
	crond -f
fi

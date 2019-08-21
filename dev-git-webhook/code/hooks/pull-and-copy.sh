#!/bin/sh
GIT_DIRECTORY="/git"

if [ -d "$GIT_DIRECTORY" ]; then
	cd ${GIT_DIRECTORY}/*
	git pull origin
#	cp -R data/* /data/
	cp -R ./* /apps/${WEBHOOK_APP_DIRECTORY}
#	chown -R 100:101 /data
fi


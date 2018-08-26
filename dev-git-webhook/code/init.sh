#!/bin/sh
GIT_DIRECTORY="/git"

if [ ! -d "$GIT_DIRECTORY" ]; then
	echo "Initial GIT checkout."
	mkdir ${GIT_DIRECTORY}
	cd ${GIT_DIRECTORY} 
	git clone -b ${WEBHOOK_BRANCH_LIST} ${WEBHOOK_GIT_REPOSITORY}
	cd ./*
	cp -R data/* /data/
	cp -R ./* /apps/${WEBHOOK_APP_DIRECTORY}
	chown -R 100:101 /data
fi
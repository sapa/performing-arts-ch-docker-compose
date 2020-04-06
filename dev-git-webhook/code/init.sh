#!/bin/sh
GIT_DIRECTORY="/git"
APP_PATH="/apps/${APP_NAME}"

if [ ! -d "$GIT_DIRECTORY" ]; then
        echo "Initial GIT checkout. [init.sh]"

        mkdir ${GIT_DIRECTORY}
        cd ${GIT_DIRECTORY}
		
	# == TEMPLATES ==
        echo "- Cloning: git clone -b ${WEBHOOK_WHITELISTED_BRANCH} ${WEBHOOK_GIT_REPOSITORY}"
        git clone -b ${WEBHOOK_WHITELISTED_BRANCH} ${WEBHOOK_GIT_REPOSITORY}

        cd ./*

        mkdir /apps/${WEBHOOK_APP_DIRECTORY}
	
        cp -R ./* /apps/${WEBHOOK_APP_DIRECTORY}

	chown -R 100:0 /apps/${WEBHOOK_APP_DIRECTORY}
	
	#  == SHIRO/USERS ==
	rm -R ${GIT_DIRECTORY}
	mkdir ${GIT_DIRECTORY}
	cd ${GIT_DIRECTORY}


	echo "- Cloning: git clone -b ${WEBHOOK_USERS_BRANCH} ${WEBHOOK_SHIRO_GIT_REPOSITORY}"
        git clone -b ${WEBHOOK_USERS_BRANCH} ${WEBHOOK_SHIRO_GIT_REPOSITORY}
	
	cd ./${USERS_REPO_NAME}

       # mkdir ${WEBHOOK_SHIRO_DIRECTORY}

        chown -R 100:0 /${WEBHOOK_SHIRO_DIRECTORY}
        cp -R ./* /${WEBHOOK_SHIRO_DIRECTORY}
fi

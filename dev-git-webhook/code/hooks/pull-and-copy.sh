#!/bin/sh
GIT_DIRECTORY="/git"

if [ -d "$GIT_DIRECTORY" ]; then
	echo "Webhook call [pull-and-copy.sh]"
	
	cd ${GIT_DIRECTORY}/*

	git pull origin
	ls -l
	#git pull https://github.com/sapa/performing-arts-ch-templates.git

#	cp -R ./* /runtime-data

	#cp -R ./apps/performing-arts-ch/config /runtime-data
	#cp -R ./apps/performing-arts-ch/data /runtime-data

	#git pull https://github.com/sapa/performing-arts-ch-users.git
	#cp -R ./* /${WEBHOOK_SHIRO_DIRECTORY}
else
        echo "Initial GIT checkout. [pull-and-copy.sh]"

        mkdir ${GIT_DIRECTORY}
        cd ${GIT_DIRECTORY}

        # == TEMPLATES ==
        echo "- Cloning: git clone -b ${WEBHOOK_WHITELISTED_BRANCH} ${WEBHOOK_GIT_REPOSITORY}"
        git clone -b ${WEBHOOK_WHITELISTED_BRANCH} ${WEBHOOK_GIT_REPOSITORY}

        cd ./*

        mkdir /apps/${WEBHOOK_APP_DIRECTORY}

        chown -R 100:0 /apps/${WEBHOOK_APP_DIRECTORY}
        cp -R ./* /apps/${WEBHOOK_APP_DIRECTORY}

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

#!/bin/sh
GIT_DIRECTORY="/git"
USERS_REPO_NAME="performing-arts-ch-users"

if [ -d "$GIT_DIRECTORY" ]; then
	echo "Webhook call [pull-and-copy.sh]"
	cd ${GIT_DIRECTORY}/*

	git pull origin

	cp -R ./* /apps/${WEBHOOK_APP_DIRECTORY}
	cp -R ./* /${WEBHOOK_SHIRO_DIRECTORY}
else
        echo "Initial GIT checkout. [pull-and-copy.sh]"
	mkdir ${GIT_DIRECTORY}
        cd ${GIT_DIRECTORY}

        # == TEMPLATES ==
        echo "- Cloning: git clone -b ${WEBHOOK_BRANCH_LIST} ${WEBHOOK_GIT_REPOSITORY}"
        git clone -b ${WEBHOOK_BRANCH_LIST} ${WEBHOOK_GIT_REPOSITORY}

        cd ./*

        mkdir /apps/${WEBHOOK_APP_DIRECTORY}

        chown -R 100:0 /apps/${WEBHOOK_APP_DIRECTORY}
        cp -R ./* /apps/${WEBHOOK_APP_DIRECTORY}

        #  == SHIRO/USERS ==
        rm -R ${GIT_DIRECTORY}
        mkdir ${GIT_DIRECTORY}
        cd ${GIT_DIRECTORY}

        echo "- Cloning: git clone -b ${WEBHOOK_BRANCH_LIST} ${WEBHOOK_SHIRO_GIT_REPOSITORY}"
        git clone -b ${WEBHOOK_USERS_BRANCH_LIST} ${WEBHOOK_SHIRO_GIT_REPOSITORY}

        cd ./${USERS_REPO_NAME}

       # mkdir ${WEBHOOK_SHIRO_DIRECTORY}

        chown -R 100:0 /${WEBHOOK_SHIRO_DIRECTORY}
        cp -R ./* /${WEBHOOK_SHIRO_DIRECTORY}
fi

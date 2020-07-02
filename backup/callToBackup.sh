#!/bin/bash
# This file shall be executed by a cronjon to trigger the backup process
PATH_TO_SCRIPT=/home/ubuntu/performing-arts-ch-docker-compose/backup/

### ADD THE NAME OF ANY ENVIRONMENT TO BE BACKED UP TO THIS ARRAY
declare -a environments=(
   # "dev"
    "prod"
)

#### START CODE, DO NOT EDIT ####

# backup function
# takes the name of the environment as a parameter
function backup {
    echo "[$(date "+%Y-%m-%d")] Starting backup for ${environment}"

    echo "-> Navigating into working directory"
    currentDir="$(pwd)"
    cd ${PATH_TO_SCRIPT} || return

    cd ../metaphactory-blazegraph/"${environment}"/ || return

    echo "-> Shutting down metaphacts-platform containers"
    docker-compose down

    echo "-> Starting cron-backup container"
    docker-compose -f ../../backup/docker-compose.yml up

    echo "Starting up metaphacts-platform containers again"
    docker-compose up -d

    cd "${currentDir}" || return

    echo "[$(date "+%Y-%m-%d")] Finished backup for ${environment}"
}


for environment in "${environments[@]}"
do
  backup "${environment}"
done

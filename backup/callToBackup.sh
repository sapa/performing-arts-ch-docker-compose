#!/bin/bash

set -e

# This file shall be executed by a cronjon to trigger the backup process
PATH_TO_SCRIPT=/home/ubuntu/performing-arts-ch-docker-compose/backup/

### ADD THE NAME OF ANY ENVIRONMENT TO BE BACKED UP TO THIS ARRAY
declare -a environments=(
    "dev"
   # "prod"
)

backup_date=$(date +%Y-%m-%d_%H-%M)


#### START CODE, DO NOT EDIT ####
# backup function
# takes the name of the environment as a parameter
function backup {
    echo "[${backup_date}] Starting backup for ${environment}"

    echo "-> starting online backup of Blazegraph"
    blazegraph_container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${environment}-blazegraph)
    curl --data-urlencode "file=/blazegraph-data/blazegraph.jnl.backup" --data-urlencode "compress=true" http://${blazegraph_container_ip}:8080/blazegraph/backup

    echo "-> Navigating into working directory"
    currentDir="$(pwd)"
    cd ${PATH_TO_SCRIPT} || return

    cd ../metaphactory-blazegraph/"${environment}"/ || return

    echo "-> Starting cron-backup container"
    docker-compose -f ../../backup/docker-compose.yml up

    cd "${currentDir}" || return

    echo "[${backup_date}] Finished backup for ${environment}"
}

for environment in "${environments[@]}"; do
    backup "${environment}"
done

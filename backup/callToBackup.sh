#!/bin/bash

set -e

PATH_TO_SCRIPT=/home/ubuntu/performing-arts-ch-docker-compose/backup/
backup_date=$(date +%Y-%m-%d_%H-%M)

if [ -z "$1" ]; then
    echo "[E] No argument supplied. Has be one of 'dev' or 'prod'"
    exit 1
fi
environment=${1}

for i in $(seq 1 50); do printf "="; done
echo ""
echo "[I] Starting backup for ${environment} on ${backup_date}"

echo "[I] starting online backup of Blazegraph"
blazegraph_container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${environment}-blazegraph)
curl --data-urlencode "file=/blazegraph-data/blazegraph.jnl.backup.gz" --data-urlencode "compress=true" http://${blazegraph_container_ip}:8080/blazegraph/backup

echo "[I] Navigating into working directory"
cd ${PATH_TO_SCRIPT} || return

# uses the environment of the blazegraph deployment to get access to specific variables, like COMPOSE_PROJECT_NAME
cd ../metaphactory-blazegraph/"${environment}"/ || return
echo "[I] Starting cron-backup container"
docker-compose -f ../../backup/docker-compose.yml up

echo "[I] Finished backup for ${environment}"
for i in $(seq 1 3); do echo ""; done

exit 0

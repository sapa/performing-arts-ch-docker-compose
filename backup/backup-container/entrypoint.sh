#!/bin/sh

set -e

BACKUP_TIME=$(date "+%Y-%m-%d_%H-%M")

BACKUP_FILE_NAME="${BACKUP_NAME}-${BACKUP_TIME}.tar.gz"
BACKUP_FILE_PATH="${BACKUP_BASE_PATH}/${BACKUP_FILE_NAME}"

BACKUP_RUNTIME_FILE_NAME="${BACKUP_RUNTIME_NAME}-${BACKUP_TIME}.tar.gz"
BACKUP_RUNTIME_FILE_PATH="${BACKUP_BASE_PATH}/${BACKUP_RUNTIME_FILE_NAME}"

tar -zcvf "${BACKUP_FILE_PATH}" "${BLAZEGRAPH_BACKUP}"
tar -zcvf "${BACKUP_RUNTIME_FILE_PATH}" "${FOLDERS_TO_BACKUP_RUNTIME}"

if [ -z "${S3_BUCKET_URL}" ]; then
    echo "No S3 BUCKET specified. Skipping S3 backup."
fi
if [ -n "${S3_BUCKET_URL}" ]; then
    echo "Uploading backup archive ${BACKUP_FILE_PATH} to S3 ${S3_BUCKET_URL}"
    aws s3 cp --quiet "${BACKUP_FILE_PATH}" "${S3_BUCKET_URL}" --endpoint-url "${ENDPOINT_URL}"

    echo "Uploading runtime backup archive ${BACKUP_RUNTIME_FILE_PATH} to S3 ${S3_BUCKET_URL}"
    aws s3 cp --quiet "${BACKUP_RUNTIME_FILE_PATH}" "${S3_BUCKET_URL}" --endpoint-url "${ENDPOINT_URL}"
fi

if [ -n "${KEEP_BACKUP_DAYS}" ]; then
    echo "Removing old backups. Only keeping backups created in the last ${KEEP_BACKUP_DAYS} days."
    find "${BACKUP_BASE_PATH}" -mtime "+${KEEP_BACKUP_DAYS}" -type f -delete;
else
    echo "KEEP_BACKUP_DAYS was not set. Not removing any old backups."
fi

# remove current Blazegraph backup file, because Blazegraph doesn't support overwriting them
rm ${BLAZEGRAPH_BACKUP}

exit 0

#!/bin/sh
echo "Starting backup"
BACKUP_FILE_NAME=$BACKUP_NAME-`date "+%Y-%m-%d_%H-%M-%S"`.tar.gz
BACKUP_FILE_PATH=/backups/$BACKUP_FILE_NAME
S3_BUCKET_FULLURL="${S3_BUCKET_URL}${BACKUP_FILE_NAME}"
echo "Creating backup archive ${BACKUP_FILE_PATH} ."
tar -zcvf $BACKUP_FILE_PATH $FOLDERS_TO_BACKUP
if [ -z "${S3_BUCKET_URL}" ]; then
    echo "No S3 BUCKET specified. Will skip S3 backup."
fi
if [ -n "${S3_BUCKET_URL}" ]; then
    echo "Uploading backup archive ${BACKUP_FILE_PATH} to S3 ${S3_BUCKET_FULLURL}"
	aws s3 cp $BACKUP_FILE_PATH $S3_BUCKET_FULLURL
fi

if [ -n "${NUMBER_OF_BACKUPS_TO_KEEP}" ]; then
    echo "Removing old backups. Only keeping the latest ${NUMBER_OF_BACKUPS_TO_KEEP}."
    ls -tpd /backups/* | grep -v '/$' | tail -n +$($NUMBER_OF_BACKUPS_TO_KEEP+1) | xargs -I {} rm -- {}
else
	echo ""
fi

echo "Finished backup "`date "+%Y-%m-%d_%H-%M-%S"`
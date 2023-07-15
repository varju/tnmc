#!/usr/bin/env bash

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

. $BASE_DIR/.envrc

date >> $LOG_FILE
docker exec -i tnmc_db_1 bash -c 'mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE --opt --no-tablespaces --result-file /backups/tnmc-$(date +%Y%m%d-%H%M).sql; gzip /backups/*sql' >> $LOG_FILE 2>&1
echo >> $LOG_FILE
echo >> $LOG_FILE

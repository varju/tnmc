#!/usr/bin/env bash

export DOCKER_HOST=tcp://pluto.varju.ca:2376 DOCKER_TLS_VERIFY=1

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

date >> $LOG_FILE
docker exec -i tnmc-db-1 bash -c 'mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE --opt --no-tablespaces --result-file /backups/tnmc-$(date +%Y%m%d-%H%M).sql; gzip /backups/*sql' 2>&1 | tee -a $LOG_FILE
echo >> $LOG_FILE
echo >> $LOG_FILE

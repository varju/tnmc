#!/usr/bin/env bash

export DOCKER_HOST=tcp://pluto.varju.ca:2376 DOCKER_TLS_VERIFY=1

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

date >> $LOG_FILE
docker exec -ti tnmc_web_1 /tnmc/movies/cron/send_movielist.cgi 2>&1 | tee -a $LOG_FILE
echo >> $LOG_FILE
echo >> $LOG_FILE

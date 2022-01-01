#!/usr/bin/env bash

export DOCKER_HOST=tcp://pluto.varju.ca:2376 DOCKER_TLS_VERIFY=1

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

date >> $LOG_FILE
docker exec -i tnmc-web-1 /tnmc/movies/cron/get_movies_cineplex.cgi >> $LOG_FILE 2>&1
echo >> $LOG_FILE
echo >> $LOG_FILE

#!/usr/bin/env bash

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

. $BASE_DIR/.envrc

date >> $LOG_FILE
docker exec -i tnmc_web_1 /tnmc/movies/cron/movie_notify_email.cgi >> $LOG_FILE 2>&1
docker exec -i tnmc_web_1 /tnmc/movies/cron/movie_notify_phone.cgi >> $LOG_FILE 2>&1
echo >> $LOG_FILE
echo >> $LOG_FILE

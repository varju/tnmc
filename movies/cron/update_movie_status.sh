#!/usr/bin/env bash

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

. $BASE_DIR/.envrc

date >> $LOG_FILE

if [[ $(date +%u) -eq 2 ]]; then
  docker exec -i tnmc_web_1 /tnmc/movies/cron/update_movie_status.cgi >> $LOG_FILE 2>&1
else
  echo "Error: Script should only be run on Tuesdays" >> $LOG_FILE 2>&1
fi

echo >> $LOG_FILE
echo >> $LOG_FILE

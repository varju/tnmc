#!/usr/bin/env bash

export DOCKER_HOST=tcp://pluto.varju.ca:2376 DOCKER_TLS_VERIFY=1

BASE_DIR=$(cd $(dirname $0)/../..; pwd)
LOG_FILE=$BASE_DIR/logs/$(basename $0 | sed -e 's|\..*||').log

date >> $LOG_FILE

if [[ $(date +%u) -eq 2 ]]; then
  docker exec -i tnmc-web-1 /tnmc/movies/cron/update_movie_status.cgi 2>&1 | tee -a $LOG_FILE
else
  echo "Error: Script should only be run on Tuesdays" 2>&1 | tee -a $LOG_FILE
fi

echo >> $LOG_FILE
echo >> $LOG_FILE

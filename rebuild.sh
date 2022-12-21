#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +%s)

docker build -t tnmc:$TIMESTAMP .
docker tag tnmc:$TIMESTAMP tnmc:latest

cd ~/dev/mars.varju.ca/pluto
docker rm -f tnmc_web_1
./recompose docker-apps/tnmc.yaml

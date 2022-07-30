#!/usr/bin/env bash
set -e

docker build -t varju/tnmc .

cd ~/dev/mars.varju.ca/pluto
docker rm -f tnmc_web_1
./recompose docker-apps/tnmc.yaml

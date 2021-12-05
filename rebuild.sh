#!/usr/bin/env bash
set -e

docker build -t varju/tnmc .

cd ~/dev/mars.varju.ca/pluto
docker-compose --project-name tnmc --file docker-apps/tnmc.yaml up --detach

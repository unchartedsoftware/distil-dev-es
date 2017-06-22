#!/bin/bash

source ./server/config.sh

docker run \
  --user elasticsearch \
  --rm \
  --name $DOCKER_IMAGE_NAME \
  -p 9200:9200 \
  -p 6379:6379 \
  docker.uncharted.software/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION 

#!/bin/bash

source ./server/config.sh

HIGHLIGHT='\033[0;34m'
NC='\033[0m'

echo -e "${HIGHLIGHT}Getting distil-ingest..${NC}"

# get distil-ingest and force a static rebuild of it so that it can run on Alpine
go get -u -v github.com/unchartedsoftware/distil-ingest/cmd/distil-merge
go get -u -v github.com/unchartedsoftware/distil-ingest/cmd/distil-classify
go get -u -v github.com/unchartedsoftware/distil-ingest/cmd/distil-ingest
env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a github.com/unchartedsoftware/distil-ingest/cmd/distil-merge
env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a github.com/unchartedsoftware/distil-ingest/cmd/distil-classify
env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a github.com/unchartedsoftware/distil-ingest/cmd/distil-ingest
mv distil-merge ./server
mv distil-classify ./server
mv distil-ingest ./server

echo -e "${HIGHLIGHT}Copying D3M data..${NC}"

# copy the d3m data into the docker context
mkdir -p ./server/data/d3m
for DATASET in "${DATASETS[@]}"
do
    echo "cp $HOST_DATA_DIR/$DATASET into ./server/data/d3m/$DATASET"
    cp -r $HOST_DATA_DIR/$DATASET ./server/data/d3m
done

echo -e "${HIGHLIGHT}Building image ${DOCKER_IMAGE_NAME}...${NC}"

# build the docker image
cd server

docker build \
    --build-arg aws_access_key=$AWS_ACCESS_KEY \
    --build-arg aws_secret_key=$AWS_SECRET_KEY \
    --build-arg aws_region=$AWS_REGION  \
    --tag docker.uncharted.software/$DOCKER_IMAGE_NAME:${DOCKER_IMAGE_VERSION} .
cd ..
echo -e "${HIGHLIGHT}Done${NC}"

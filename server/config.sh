#!/bin/sh

# name and version of docker image that will be created
DOCKER_IMAGE_NAME=distil_dev_es
DOCKER_IMAGE_VERSION=0.10.1

# datasets to ingest
DATASETS=(26_radon_seed 32_wikiqa 60_jester 185_baseball 196_autoMpg 313_spectrometer 38_sick 1491_one_hundred_plants_margin 27_wordLevels 57_hypothyroid 299_libras_move 534_cps_85_wages 1567_poker_hand 22_handgeometry)

# path to data on local system (ingest from HDFS not currently supported)
HOST_DATA_DIR=~/datasets/seed_datasets_current

# path to data in the docker container
CONTAINER_DATA_DIR=/input/d3m

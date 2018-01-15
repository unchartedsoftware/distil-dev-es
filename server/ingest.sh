#!/bin/bash

source ./config.sh

SCHEMA_PATH=/datasetDoc.json
DATA_PATH=/tables/learningData.csv
MERGED_OUTPUT_PATH=tables/merged.csv
OUTPUT_SCHEMA=tables/mergedDataSchema.json
DATASET_FOLDER_SUFFIX=_dataset
MERGE_HAS_HEADER=1

for DATASET in "${DATASETS[@]}"
do
    echo "--------------------------------------------------------------------------------"
    echo " Merging $DATASET dataset"
    echo "--------------------------------------------------------------------------------"
    ./distil-merge \
        --schema="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$SCHEMA_PATH" \
        --data="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$DATA_PATH" \
        --raw-data="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/" \
        --output-path="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$MERGED_OUTPUT_PATH" \
        --output-schema-path="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$OUTPUT_SCHEMA" \
        --has-header=$MERGE_HAS_HEADER
done

CLASSIFICATION_OUTPUT_PATH=tables/classification.json
REST_ENDPOINT=http://localhost:5000
CLASSIFICATION_FUNCTION=fileUpload

for DATASET in "${DATASETS[@]}"
do
    echo "--------------------------------------------------------------------------------"
    echo " Classifying $DATASET dataset"
    echo "--------------------------------------------------------------------------------"
    ./distil-classify \
        --schema="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$OUTPUT_SCHEMA" \
        --rest-endpoint="$REST_ENDPOINT" \
        --classification-function="$CLASSIFICATION_FUNCTION" \
        --dataset="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$MERGED_OUTPUT_PATH" \
        --output="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$CLASSIFICATION_OUTPUT_PATH"
done

IMPORTANCE_OUTPUT=tables/importance.json
RANKING_REST_ENDPOINT=HTTP://localhost:5001
RANKING_FUNCTION=pca
NUMERIC_OUTPUT_SUFFIX=_numeric.csv
TYPE_SOURCE=classification

for DATASET in "${DATASETS[@]}"
do
    echo "--------------------------------------------------------------------------------"
    echo " Ranking $DATASET dataset"
    echo "--------------------------------------------------------------------------------"
    ./distil-rank \
        --schema="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$OUTPUT_SCHEMA" \
        --dataset="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$MERGED_OUTPUT_PATH" \
        --rest-endpoint="$RANKING_REST_ENDPOINT" \
        --ranking-function="$RANKING_FUNCTION" \
        --numeric-output="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$DATASET$NUMERIC_OUTPUT_SUFFIX" \
        --classification="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$CLASSIFICATION_OUTPUT_PATH" \
        --has-header=$MERGE_HAS_HEADER \
        --output="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$IMPORTANCE_OUTPUT" \
        --type-source="$TYPE_SOURCE"
done

METADATA_INDEX=datasets
ES_ENDPOINT=http://localhost:9200
SUMMARY_OUTPUT_PATH=summary.txt
TYPE_SOURCE=classification

for DATASET in "${DATASETS[@]}"
do
    echo "--------------------------------------------------------------------------------"
    echo " Ingesting $DATASET dataset"
    echo "--------------------------------------------------------------------------------"
    ./distil-ingest \
        --es-endpoint="$ES_ENDPOINT" \
        --es-metadata-index="$METADATA_INDEX" \
        --es-data-index="$DATASET" \
        --es-dataset-prefix="d_" \
        --schema="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$OUTPUT_SCHEMA" \
        --dataset="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$MERGED_OUTPUT_PATH" \
        --classification="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$CLASSIFICATION_OUTPUT_PATH" \
        --summary="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$SUMMARY_OUTPUT_PATH" \
        --importance="$CONTAINER_DATA_DIR/${DATASET}/${DATASET}$DATASET_FOLDER_SUFFIX/$IMPORTANCE_OUTPUT" \
        --type-source="$TYPE_SOURCE" \
        --clear-existing \
        --metadata-only
done

#!/bin/bash 

cd "$(dirname "$0")"

# Some variables

ENV=$1
export RUN_ID="20c7e3f3b3584b769bf6cacd4643d43d"
export TEST_RUN=False

if [[ $ENV == "stage" ]]
    then 
    export STREAM_NAME="ride_predictions_${ENV}"
    export MODEL_BUCKET="mlops-zoomcamp-nakul-${ENV}"
elif [[ $ENV == "prod" ]]
    then
    export STREAM_NAME="ride_predictions"
    export MODEL_BUCKET="mlops-zoomcamp-nakul"
else 
    echo "Value must be either stage or prod"
    exit 1
fi 

aws s3 rm s3://$MODEL_BUCKET --recursive

echo "Running terraform destroy"
TF_VAR_run_id=$RUN_ID TF_VAR_test_run=$TEST_RUN terraform destroy -auto-approve -var-file="vars/${ENV}.tfvars"

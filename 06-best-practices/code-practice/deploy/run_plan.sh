#!/bin/bash

cd "$(dirname "$0")"

ENV=$1
export RUN_ID="20c7e3f3b3584b769bf6cacd4643d43d"
export TEST_RUN=False

if [[ $ENV == "stage" ]]
    then 
    export STREAM_NAME="ride_predictions_${ENV}"
elif [[ $ENV == "prod" ]]
    then
    export STREAM_NAME="ride_predictions"
else 
    echo "Value must be either stage or prod"
    exit 1
fi 

# run terraform for ${ENV}
echo "Initialising terraform"
terraform init -backend-config="key=mlops-zoomcamp-${ENV}.tfstate" --reconfigure

echo "Running terraform plan"
TF_VAR_run_id=$RUN_ID TF_VAR_test_run=$TEST_RUN terraform plan -var-file="vars/${ENV}.tfvars"

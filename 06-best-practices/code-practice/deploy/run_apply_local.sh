#!/bin/bash

cd "$(dirname "$0")"

# Some variables

ENV=$1
export RUN_ID="20c7e3f3b3584b769bf6cacd4643d43d"
export TEST_RUN=False
export MODEL_BUCKET_DEV="mlops-zoomcamp-nakul-dev"

if [[ $ENV == "stage" ]]
    then 
    export STREAM_NAME="ride_predictions_${ENV}"
    export MODEL_BUCKET="mlops-zoomcamp-nakul-${ENV}"
    export FUNCTION_NAME="ride-prediction-service-${ENV}"
elif [[ $ENV == "prod" ]]
    then
    export STREAM_NAME="ride_predictions"
    export MODEL_BUCKET="mlops-zoomcamp-nakul"
    export FUNCTION_NAME="ride-prediction-service"
else 
    echo "Value must be either stage or prod"
    exit 1
fi 

# run terraform for ${ENV}
echo "Initialing terraform"
terraform init -backend-config="key=mlops-zoomcamp-${ENV}.tfstate" --reconfigure

echo "Running terraform apply"
TF_VAR_run_id=$RUN_ID TF_VAR_test_run=$TEST_RUN terraform apply -auto-approve -var-file="vars/${ENV}.tfvars"

# copy model artifacts
echo "Copying model artifacts to the bucket"
aws s3 sync s3://${MODEL_BUCKET_DEV} s3://${MODEL_BUCKET}
# update the environment variables for lambda function
echo "Updating the lambda function"
variables="{STREAM_NAME=${STREAM_NAME}, MODEL_BUCKET=${MODEL_BUCKET}, RUN_ID=${RUN_ID}, TEST_RUN=${TEST_RUN}}"
aws --region us-east-2 lambda update-function-configuration --function-name $FUNCTION_NAME --environment "Variables=${variables}"

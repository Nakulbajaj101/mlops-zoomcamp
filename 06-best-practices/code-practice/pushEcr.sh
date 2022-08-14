#!/bin/bash
REPO_NAME="ride-predictions-streaming"

export ECR_REPO_NAME="${REPO_NAME}-test"
export AWS_ACCOUNT_ID="135015496169"

 
#Local setup profile
export AWS_ACCESS_KEY_ID=$(aws configure get lamda_kinesis.aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get lamda_kinesis.aws_secret_access_key)
export AWS_DEFAULT_REGION=$(aws configure get lamda_kinesis.region)


aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker tag ${LOCAL_IMAGE_NAME} $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:latest

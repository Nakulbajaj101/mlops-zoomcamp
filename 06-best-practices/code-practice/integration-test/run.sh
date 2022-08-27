#!/bin/bash
cd "$(dirname "$0")"
if [[ -z "${GITHUB_ACTIONS}" ]]

then
  echo "Running tests locally"
  
  #Local setup profile
  export AWS_ACCESS_KEY_ID=$(aws configure get lamda_kinesis.aws_access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(aws configure get lamda_kinesis.aws_secret_access_key)
  export AWS_DEFAULT_REGION=$(aws configure get lamda_kinesis.region)

else
  echo "Running tests in github runner"

  # Setup in github deploy script
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

fi

export STREAM_NAME="ride_predictions"
export RUN_ID="20c7e3f3b3584b769bf6cacd4643d43d"
export TEST_RUN=False
export KINESIS_ENDPOINT_URL='http://localstack:4566/'

if [ "${LOCAL_IMAGE_NAME}" == "" ]; then
    LOCAL_TAG=`date +"%Y-%m-%d-%H-%M"`
    export LOCAL_IMAGE_NAME="stream-model-duration:${LOCAL_TAG}"
    echo "LOCAL_IMAGE_NAME is not set, building a new image with tag ${LOCAL_IMAGE_NAME}"
    docker build --build-arg STREAM_NAME_ARG=${STREAM_NAME} --build-arg RUN_ID_ARG=${RUN_ID} --build-arg TEST_RUN_ARG=${TEST_RUN} -t ${LOCAL_IMAGE_NAME} ..
else
    echo "no need to build image ${LOCAL_IMAGE_NAME}"
fi

docker-compose up -d

sleep 5 

aws --endpoint-url http://localhost:4566  kinesis create-stream --stream-name $STREAM_NAME --shard-count 1

sleep 5

echo "Running lambda integration tests"
pipenv run python test_docker.py
RESULT=$?

if [ $RESULT -eq 0 ]; then
  echo model lambda integration tests passed
else
  docker-compose logs
  echo model lambda integration tests failed
  docker-compose down
  exit ${RESULT}
fi

echo "Running kinesis integration tests"
pipenv run python test_kinesis.py
RESULT=$?

if [ $RESULT -eq 0 ]; then
  echo kinesis integration test passed
else
  docker-compose logs
  echo kinesis integration tests failed
  docker-compose down
  exit ${RESULT}
fi
docker-compose down

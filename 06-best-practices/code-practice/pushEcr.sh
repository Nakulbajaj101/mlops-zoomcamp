#!/bin/bash
REPO_NAME="ride-predictions-streaming"
if [[ -z $1 ]]

then 
    export ECR_REPO_NAME="${REPO_NAME}-test"
elif [[ $1 == 'stage' ]] 
    export ECR_REPO_NAME="${REPO_NAME}-$1"
elif  [[ $1 == 'prod' ]] 
    export ECR_REPO_NAME="${REPO_NAME}"
else
    echo "Value must be stage or prod"
    exit 1
fi

export AWS_ACCOUNT_ID="135015496169"

if [[ -z "${GITHUB_ACTIONS}" ]]

then  
  #Local setup profile
  export AWS_ACCESS_KEY_ID=$(aws configure get lamda_kinesis.aws_access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(aws configure get lamda_kinesis.aws_secret_access_key)
  export AWS_DEFAULT_REGION=$(aws configure get lamda_kinesis.region)

else
  # Setup in github deploy script
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

fi

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker tag ${LOCAL_IMAGE_NAME} $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:latest

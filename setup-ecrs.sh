 #!/bin/bash
export AWS_PAGER=""
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)
REGION=us-east-1

# login to ECR
echo "################### Login To ECR ###################"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# creating ecr repositories
ECR_APPLICATION_REPO_NAME=ha-app-application-tier
aws ecr describe-repositories --repository-names ${ECR_APPLICATION_REPO_NAME} || aws ecr create-repository --repository-name ${ECR_APPLICATION_REPO_NAME}

ECR_PRESENTATION_REPO_NAME=ha-app-presentation-tier
aws ecr describe-repositories --repository-names ${ECR_PRESENTATION_REPO_NAME} || aws ecr create-repository --repository-name ${ECR_PRESENTATION_REPO_NAME}

# building and pushing the application tier image
cd ./application-tier/
echo "################### Building application tier image ###################"
ECR_APPLICATION_TIER_REPO=$(aws ecr describe-repositories --repository-names ${ECR_APPLICATION_REPO_NAME} | jq -r '.repositories[0].repositoryUri')
docker build -t ha-app-application-tier:v1.0 .
docker tag ha-app-application-tier:v1.0 ha-app-application-tier:v2.0

echo "################### Pushing application tier image ###################"
docker push ha-app-application-tier:v2.0

#building and pushing the presentation tier image
cd ../presentation-tier/
echo "################### Building presentation tier image ###################"
ECR_PRESENTATION_TIER_REPO=$(aws ecr describe-repositories --repository-names ${ECR_PRESENTATION_REPO_NAME} | jq -r '.repositories[0].repositoryUri')
docker build -t ha-app-presentation-tier:v1.0 .
docker tag ha-app-presentation-tier:v1.0 ha-app-presentation-tier:v2.0

echo "################### Pushing presentation tier image ###################"
docker push ha-app-presentation-tier:v2.0

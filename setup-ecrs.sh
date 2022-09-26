 #!/bin/bash
export AWS_PAGER=""
ACCOUNT_ID=166430721814
REGION=us-east-1

# login to ECR
echo "################### Login To ECR ###################"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# creating ecr repositories
aws ecr create-repository --repository-name ha-app-application-tier

aws ecr create-repository --repository-name ha-app-presentation-tier

# building and pushing the application tier image
cd ./application-tier/
echo "################### Building application tier image ###################"
docker build -t ha-app-application-tier .
docker tag ha-app-application-tier:latest 166430721814.dkr.ecr.us-east-1.amazonaws.com/ha-app-application-tier:latest

echo "################### Pushing application tier image ###################"
docker push 166430721814.dkr.ecr.us-east-1.amazonaws.com/ha-app-application-tier:latest

#building and pushing the presentation tier image
cd ../presentation-tier/
echo "################### Building presentation tier image ###################"
docker build -t ha-app-presentation-tier .
docker tag ha-app-presentation-tier:latest 166430721814.dkr.ecr.us-east-1.amazonaws.com/ha-app-presentation-tier:latest

echo "################### Pushing presentation tier image ###################"
docker push 166430721814.dkr.ecr.us-east-1.amazonaws.com/ha-app-presentation-tier:latest

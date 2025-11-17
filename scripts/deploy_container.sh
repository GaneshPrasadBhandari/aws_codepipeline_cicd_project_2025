#!/usr/bin/env bash
set -euo pipefail

# These variables must match the ones defined in your buildspec.yml
AWS_REGION="us-east-1"
IMAGE_REPO_NAME="mlproject-flask-cicd-ecrrepo"
IMAGE_TAG="latest" # Or v1, depending on which tag you want to deploy

# Get environment details
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"

# 1. Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 2. Pull the image
echo "Pulling latest image: ${ECR_URI}:${IMAGE_TAG}"
docker pull ${ECR_URI}:${IMAGE_TAG}

# 3. Run the new container with the fixed port mapping
# -p 80:5000 maps the host's public port 80 to the container's internal port 5000
echo "Running new container, mapping host port 80 to container port 5000..."
docker run -d \
  --name mlproject_service \
  -p 80:5000 \
  --restart always \
  ${ECR_URI}:${IMAGE_TAG}

echo "Docker container deployment complete."s
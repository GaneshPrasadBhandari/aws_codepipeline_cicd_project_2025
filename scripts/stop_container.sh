#!/usr/bin/env bash
set -euo pipefail

APP_NAME="mlproject_service"

# Stop the running container
if [ $(docker ps -q -f name=$APP_NAME) ]; then
    echo "Stopping existing container: $APP_NAME"
    docker stop $APP_NAME
fi

# Remove the container
if [ $(docker ps -aq -f name=$APP_NAME) ]; then
    echo "Removing existing container: $APP_NAME"
    docker rm $APP_NAME
fi

echo "Old container cleanup complete."
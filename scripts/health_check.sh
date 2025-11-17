#!/usr/bin/env bash
set -euo pipefail

# Simple check to see if the container is running and healthy

APP_NAME="mlproject_service"
MAX_ATTEMPTS=10
ATTEMPT=0

echo "Starting deployment health check..."

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Check if the container is running and not just exited
    CONTAINER_STATUS=$(docker inspect --format '{{.State.Status}}' $APP_NAME 2>/dev/null || echo "not_found")
    
    if [ "$CONTAINER_STATUS" == "running" ]; then
        echo "Container is running."
        exit 0
    fi
    
    echo "Container status: $CONTAINER_STATUS. Retrying in 5 seconds..."
    sleep 5
    ATTEMPT=$((ATTEMPT + 1))
done

echo "Health check failed: Container did not start correctly."
exit 1
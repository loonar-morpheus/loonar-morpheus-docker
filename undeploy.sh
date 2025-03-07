#!/bin/bash

# Function to load environment variables from .env file
load_env() {
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    else
        echo "Error: .env file not found"
        exit 1
    fi
}

# Load environment variables
load_env

if [ -z "$COMPOSE_PROJECT_NAME" ]; then
    echo "Error: COMPOSE_PROJECT_NAME not found in .env file"
    exit 1
fi

echo "Cleaning up resources for project: $COMPOSE_PROJECT_NAME"

# Stop and remove all containers in the stack
docker compose down -v

# Get all volumes created by this stack and remove them
VOLUMES=$(docker volume ls --filter name=${COMPOSE_PROJECT_NAME} -q)
if [ ! -z "$VOLUMES" ]; then
    echo "Removing volumes:"
    echo "$VOLUMES"
    docker volume rm $VOLUMES
fi

# Get and remove the network created by this stack
NETWORKS=$(docker network ls --filter name=${COMPOSE_PROJECT_NAME} -q)
if [ ! -z "$NETWORKS" ]; then
    echo "Removing networks:"
    echo "$NETWORKS"
    docker network rm $NETWORKS
fi

# Get and remove images used by this stack
IMAGES=$(docker compose images -q)
if [ ! -z "$IMAGES" ]; then
    echo "Removing images:"
    echo "$IMAGES"
    docker image rm $IMAGES
fi

# Clean up any unused Docker resources specific to this stack
docker system prune -f --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}"

# Remove any remaining container data for this project
if [ -d "/var/lib/docker/volumes/${COMPOSE_PROJECT_NAME}_*" ]; then
    sudo rm -rf /var/lib/docker/volumes/${COMPOSE_PROJECT_NAME}_*
fi

echo "Cleanup completed for project: $COMPOSE_PROJECT_NAME"

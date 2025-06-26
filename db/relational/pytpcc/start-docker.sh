#!/bin/bash

# Path to Dockerfile (three directories up)
DOCKERFILE_PATH="../../../Dockerfile.pytpcc"

# Tag for the built image
IMAGE_TAG="pytpcc:latest"
# Network name for the cluster
NETWORK_NAME="vh-evil-inc"

# Build the Docker image
docker build -t "$IMAGE_TAG" -f "$DOCKERFILE_PATH" "$(dirname "$DOCKERFILE_PATH")"

# Run the container interactively, mounting the current directory to /app/py-tpcc/benchmark
docker run -it --rm \
  -v "$(pwd):/app/py-tpcc/benchmark" \
  --network "$NETWORK_NAME" \
  "$IMAGE_TAG" \
  /bin/bash

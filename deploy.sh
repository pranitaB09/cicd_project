#!/bin/bash

echo "========== Deployment Started =========="

echo "Stopping old containers (if running)..."
docker compose down

echo "Building & starting containers..."
docker compose up --build -d

echo "Deployment completed successfully!"

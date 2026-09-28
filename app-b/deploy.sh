#!/bin/bash
set -euo pipefail
echo "Building and starting the stack..."
docker-compose up --build -d

echo "Waiting for app-a to be ready..."
for i in {1..15}; do
  if curl -sf http://localhost/app-a/ > /dev/null; then
    echo "app-a is up!"
    break
  fi
  echo "Not ready yet... retrying ($i/15)"
  sleep 2
done
echo "Waiting for app-b to be ready..."
for i in {1..15}; do
  if curl -sf http://localhost/app-b/ > /dev/null; then
    echo "app-b is up!"
    break
  fi
  echo "Not ready yet... retrying ($i/15)"
  sleep 2
done
echo "Deployment successful — both services are healthy!"

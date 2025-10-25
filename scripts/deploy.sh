#!/usr/bin/env bash
set -e  # stop on error

LAYERS=(
  "networking"
  "database"
  "storage"
  "backend-app"
  "frontend-app"
)

ACTION=${1:-apply}
TF_FLAGS=${2:-"-auto-approve"}

for layer in "${LAYERS[@]}"; do
  echo "🚀 Running terraform $ACTION on $layer ..."
  cd "terraform/$layer"   # updated path
  terraform init -upgrade
  terraform $ACTION $TF_FLAGS
  cd ../..               # go back to root
done

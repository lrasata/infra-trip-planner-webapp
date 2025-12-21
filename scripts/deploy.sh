#!/usr/bin/env bash
set -e
# stop on error
LAYERS_APPLY=(
  "security"
  "networking"
  "database"
  "backend"
  "frontend"
)

LAYERS_DESTROY=(
  "frontend"
  "backend"
  "database"
  "networking"
  "security"
)

ACTION=${1:-apply}
TF_FLAGS=${2:-"-auto-approve"}
VAR_FILE=${3:-"$(pwd)/terraform/common/staging.tfvars"}

if [ "$ACTION" == "destroy" ]; then
  LAYERS=("${LAYERS_DESTROY[@]}")
else
  LAYERS=("${LAYERS_APPLY[@]}")
fi

for layer in "${LAYERS[@]}"; do
  echo "🚀 Running terraform $ACTION on $layer ..."
  cd "terraform/layers/$layer"
  terraform init -upgrade
  terraform $ACTION $TF_FLAGS -var-file="$VAR_FILE" -compact-warnings
  cd ../..
done

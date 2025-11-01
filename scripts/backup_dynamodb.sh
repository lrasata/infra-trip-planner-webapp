#!/usr/bin/env bash
set -e

# Read arguments from command line
TABLE_NAME="$1"
BACKUP_NAME="$2"

if [[ -z "$TABLE_NAME" || -z "$BACKUP_NAME" ]]; then
  echo "Usage: $0 <table-name> <backup-name>"
  exit 1
fi

# Create DynamoDB backup
aws dynamodb create-backup --table-name "$TABLE_NAME" --backup-name "$BACKUP_NAME"

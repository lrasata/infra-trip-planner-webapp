#!/usr/bin/env bash
set -e

# Read arguments
TARGET="$1"   # Terraform-managed target table
TEMP="$2"     # Temporary table to restore backup into
BACKUP="$3"   # Backup ARN

if [[ -z "$TARGET" || -z "$TEMP" || -z "$BACKUP" ]]; then
  echo "Usage: $0 <target-table> <temp-table> <backup-arn>"
  exit 1
fi

echo "Restoring DynamoDB backup to temporary table '$TEMP'..."
aws dynamodb restore-table-from-backup --target-table-name "$TEMP" --backup-arn "$BACKUP"

echo "Waiting for temp table '$TEMP' to become ACTIVE..."
aws dynamodb wait table-exists --table-name "$TEMP"

echo "Copying data into Terraform-managed table '$TARGET'..."
# Transform scan output into proper batch-write JSON
aws dynamodb scan --table-name "$TEMP" --query 'Items[]' \
  | jq -c --arg table "$TARGET" '{($table): [ .[] | {PutRequest: {Item: .}} ] }' > items-batch.json

aws dynamodb batch-write-item --request-items file://items-batch.json --return-consumed-capacity TOTAL

echo "Deleting temporary table '$TEMP'..."
aws dynamodb delete-table --table-name "$TEMP"

rm items-batch.json

echo "Restore completed successfully."

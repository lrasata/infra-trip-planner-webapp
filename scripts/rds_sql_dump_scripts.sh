#!/usr/bin/env bash
set -euo pipefail

# SCRIPTS ONLY FOR TEMPORARY ENV : dev/test/staging

# ----------- CONFIGURATION -----------
# Source DB (prod/staging)
SOURCE_HOST="xxxxxxxx.us-east-1.rds.amazonaws.com"
SOURCE_PORT=5432
SOURCE_DB="trip-db"
SOURCE_USER="postgres"
SOURCE_PASSWORD=""

# Target DB (dev/test/staging)
TARGET_HOST="yyyyyyyy.us-east-1.rds.amazonaws.com"
TARGET_PORT=5432
TARGET_DB="temp-trip-planner"
TARGET_USER="postgres"
TARGET_PASSWORD=""

# S3 bucket to store dumps
S3_BUCKET="dumps-xxxxxxx"

export PGPASSWORD="$SOURCE_PASSWORD"

# ----------- DUMP FROM SOURCE -----------
DUMP_FILE="/tmp/${SOURCE_DB}-$(date +%Y%m%d%H%M%S).sql.gz"
echo "Dumping database $SOURCE_DB..."
pg_dump -h "$SOURCE_HOST" -p "$SOURCE_PORT" -U "$SOURCE_USER" -Fc "$SOURCE_DB" | gzip > "$DUMP_FILE"

echo "Uploading dump to s3://$S3_BUCKET/$(basename $DUMP_FILE)..."
aws s3 cp "$DUMP_FILE" "s3://$S3_BUCKET/"

# ----------- RESTORE TO TARGET DB -----------
export PGPASSWORD="$TARGET_PASSWORD"

echo "Downloading dump from S3..."
aws s3 cp "s3://$S3_BUCKET/$(basename $DUMP_FILE)" "$DUMP_FILE"

echo "Creating temporary DB $TARGET_DB..."
psql -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -c "DROP DATABASE IF EXISTS $TARGET_DB;"
psql -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -c "CREATE DATABASE $TARGET_DB;"

echo "Restoring dump into temporary DB $TARGET_DB..."
gunzip -c "$DUMP_FILE" | pg_restore -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -d "$TARGET_DB" --no-owner --clean

# ----------- CLEANUP TEMPORARY DB -----------
echo "Cleaning up temporary DB..."
psql -h "$TARGET_HOST" -p "$TARGET_PORT" -U "$TARGET_USER" -c "DROP DATABASE IF EXISTS $TARGET_DB;"

echo "Done."

#!/bin/bash

# MySQL Server Credentials
MYSQL_USER="${MYSQL_USER}"
MYSQL_PASS="${MYSQL_PASS}"
MYSQL_HOST="${MYSQL_HOST}"

# S3 Configuration
CONFIG_FILE="/root/.s3cfg"

# Define ignorable databases (e.g., system databases)
IGNORED_DATABASES="information_schema|performance_schema|mysql|sys"

# Check if required commands are available
if ! command -v mysqldump &>/dev/null || ! command -v s3cmd &>/dev/null || ! command -v xz &>/dev/null; then
    echo "Error: mysqldump, s3cmd, and xz are required to run this script."
    exit 1
fi

# Get list of databases
databases=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -h "$MYSQL_HOST" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

# Extract the bucket name from the environment variable
BUCKET_NAME="${S3_BUCKET_NAME}"

# Backup each database
for db in $databases; do

    # Skip ignored databases
    if [[ "$IGNORED_DATABASES" =~ "$db" ]]; then
        echo "Skipping $db..."
        continue
    fi
    
    echo "Dumping database: $db"
    
    # Define backup file
    backup_file="/backup/${db}_$(date +%Y%m%d%H%M%S).sql.xz"

    # Dump and compress database
    if mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASS" -h "$MYSQL_HOST" --databases "$db" | xz -6 -T0 > "$backup_file"; then
        echo "Uploading $db backup to s3://${BUCKET_NAME}..."
        s3cmd put "$backup_file" "s3://${BUCKET_NAME}" --config "$CONFIG_FILE"
        echo "Backup of $db uploaded successfully."
    else
        echo "Failed to dump and upload $db"
        exit 1
    fi
done

echo "All databases backed up and uploaded successfully."

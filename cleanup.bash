#!/bin/bash

# S3 Configuration
CONFIG_FILE="/root/.s3cfg"

# Debug: Print configuration file details
echo "CONFIG_FILE: ${CONFIG_FILE}"

# Retention policy variables
DAILY_RETENTION=${DAILY_RETENTION}
WEEKLY_RETENTION=${WEEKLY_RETENTION}
MONTHLY_RETENTION=${MONTHLY_RETENTION}
YEARLY_RETENTION=${YEARLY_RETENTION}

# Define date variables for calculating time-based retention
now=$(date +%s)
daily_retention_days=$((DAILY_RETENTION * 24 * 60 * 60))
weekly_retention_days=$((WEEKLY_RETENTION * 7 * 24 * 60 * 60))
monthly_retention_days=$((MONTHLY_RETENTION * 30 * 24 * 60 * 60))
yearly_retention_days=$((YEARLY_RETENTION * 365 * 24 * 60 * 60))

# Function to convert date to timestamp
date_to_timestamp() {
    date -d "$1" +%s
}

# Function to determine if a file should be retained based on retention policy
should_retain_file() {
    local file_date=$1
    local file_timestamp=$(date_to_timestamp "$file_date")
    local file_age_seconds=$(( now - file_timestamp ))
    local file_age_days=$(( file_age_seconds / (24 * 60 * 60) ))
    local file_day_of_week=$(date -d "$file_date" +%u)
    local file_day_of_month=$(date -d "$file_date" +%d)

    echo "Checking file date: $file_date (timestamp: $file_timestamp, age days: $file_age_days)"

    if (( file_age_seconds <= daily_retention_days )); then
        echo "Retaining: Daily backup"
        return 0
    elif (( file_age_seconds <= weekly_retention_days )) && (( file_day_of_week == 1 )); then
        echo "Retaining: Weekly backup"
        return 0
    elif (( file_age_seconds <= monthly_retention_days )) && (( file_day_of_month == 1 )); then
        echo "Retaining: Monthly backup"
        return 0
    elif (( file_age_seconds <= yearly_retention_days )) && (( file_day_of_month == 1 )); then
        echo "Retaining: Yearly backup"
        return 0
    else
        echo "Deleting: Not meeting retention policy"
        return 1
    fi
}

# Extract the bucket name from the environment variable
BUCKET_NAME="${S3_BUCKET_NAME}"

# List all backup files in the S3 bucket
s3cmd ls "s3://${BUCKET_NAME}" --config "${CONFIG_FILE}" | while read -r line; do
    # Skip directory listings
    if [[ "$line" == DIR* ]]; then
        continue
    fi
    
    file_date=$(echo "$line" | awk '{print $1 " " $2}')
    file_name=$(echo "$line" | awk '{print $4}')

    if ! should_retain_file "$file_date"; then
        echo "Deleting backup file $file_name as it doesn't meet the retention policy..."
        s3cmd del "$file_name" --config "${CONFIG_FILE}"
    fi
done

# List all files in the local backup directory
for file in /backup/*; do
    file_date=$(date -r "$file" "+%Y-%m-%d %H:%M:%S")
    file_name=$(basename "$file")

    if ! should_retain_file "$file_date"; then
        echo "Deleting local backup file $file_name as it doesn't meet the retention policy..."
        rm -f "$file"
    fi
done

echo "Cleanup routine completed."

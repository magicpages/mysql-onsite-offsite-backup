#!/bin/bash

# Create the .s3cfg file dynamically using environment variables
cat <<EOF > /root/.s3cfg
[default]
host_base = ${S3_HOST_BASE}
host_bucket = ${S3_HOST_BUCKET}
bucket_location = ${S3_BUCKET_LOCATION}
use_https = True
access_key = ${S3_ACCESS_KEY}
secret_key = ${S3_SECRET_KEY}
EOF

# Export retention policy variables for use in scripts
export DAILY_RETENTION=${DAILY_RETENTION}
export WEEKLY_RETENTION=${WEEKLY_RETENTION}
export MONTHLY_RETENTION=${MONTHLY_RETENTION}
export YEARLY_RETENTION=${YEARLY_RETENTION}

# Start the cron service in the foreground
cron -f

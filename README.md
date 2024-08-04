# MySQL Onsite and Offsite Backup

## Overview

This repository is an open-source tool designed to create and manage MySQL database backups. It allows you to store backups both onsite (e.g., on your own server or NAS) and offsite (e.g., on S3-compatible storage). This ensures data redundancy and security, protecting against data loss in various scenarios.

This tool was developed for the specific use case at [Magic Pages](https://magicpages.com), a managed Ghost CMS hosting provider, to maintain robust backups of all databases. However, it can be used by anyone needing a reliable MySQL backup solution.

## Features

- Daily automated MySQL database backups.
- (Onsite) storage of backups on the server that runs the tool (e.g., a NAS).
- Offsite storage of backups on S3-compatible storage.
- Configurable backup retention policies.
- Configuration purely via environment variables.
- Runs as a Docker container for easy deployment.

## Requirements

- Docker and Docker Compose
- MySQL server
- S3-compatible storage

## Installation

1. **Clone the Repository**

  ```sh
  git clone https://github.com/magicpages/mysql-onsite-offsite-backup.git
  cd mysql-onsite-offsite-backup
  ```

2. **Create and Configure the .env File**

Create a .env file in the root directory and fill in the necessary environment variables:

```sh
MYSQL_USER=root
MYSQL_PASS=your_mysql_password
MYSQL_HOST=your_mysql_host
S3_ACCESS_KEY=your_s3_access_key
S3_SECRET_KEY=your_s3_secret_key
S3_BUCKET_NAME=your_s3_bucket_name
S3_HOST_BASE=your_s3_host_base
S3_HOST_BUCKET=%(bucket)s.your_s3_host_base
S3_BUCKET_LOCATION=your_s3_bucket_location

# Backup retention policies
DAILY_RETENTION=7
WEEKLY_RETENTION=4
MONTHLY_RETENTION=6
YEARLY_RETENTION=2
```

3. **Build and Run the Docker Container**

```sh
docker compose up -d
```

## Usage

### Backup

The backup process is automated using a cron job configured in the Docker container. The backup script will:

1. Connect to the MySQL server.
2. List all databases.
3. Dump each database.
4. Compress the dumps.
5. Store the compressed dumps both locally (on your server or NAS) and offsite (on S3-compatible storage).

### Cleanup

The cleanup process is also automated using a cron job. It will:

1. Remove old backups based on the retention policy both onsite and offsite.

### Manual Trigger

You can manually trigger the backup and cleanup scripts inside the running container:

```sh
# Enter the running container
docker exec -it mysql-onsite-offsite-backup_backup_1 bash

# Run backup script
bash /usr/local/bin/backup.bash

# Run cleanup script
bash /usr/local/bin/cleanup.bash
```

## Configuration

The tool is configured via environment variables in the .env file. The following variables are required:

- MYSQL_USER: MySQL username
- MYSQL_PASS: MySQL password
- MYSQL_HOST: MySQL host
- S3_ACCESS_KEY: S3 access key
- S3_SECRET_KEY: S3 secret key
- S3_BUCKET_NAME: S3 bucket name
- S3_HOST_BASE: S3 host base URL
- S3_HOST_BUCKET: S3 host bucket URL pattern
- S3_BUCKET_LOCATION: S3 bucket location
- DAILY_RETENTION: Number of daily backups to retain
- WEEKLY_RETENTION: Number of weekly backups to retain
- MONTHLY_RETENTION: Number of monthly backups to retain
- YEARLY_RETENTION: Number of yearly backups to retain

### Cron Schedule

The default cron schedule is set to run the backup and cleanup scripts at 2 AM daily (the server's local time). You can customize this by editing the crontab file in the project directory.
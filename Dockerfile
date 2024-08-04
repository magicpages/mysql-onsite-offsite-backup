# Dockerfile

FROM ubuntu:24.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y mysql-client s3cmd xz-utils curl cron && \
    apt-get clean

# Copy backup, cleanup, and entrypoint scripts
COPY backup.bash /usr/local/bin/backup.bash
COPY cleanup.bash /usr/local/bin/cleanup.bash
COPY entrypoint.bash /usr/local/bin/entrypoint.bash

# Make the scripts executable
RUN chmod +x /usr/local/bin/backup.bash /usr/local/bin/cleanup.bash /usr/local/bin/entrypoint.bash

# Add crontab file in the cron directory
COPY crontab /etc/cron.d/backup-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/backup-cron

# Apply cron job
RUN crontab /etc/cron.d/backup-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
CMD ["cron", "-f"]

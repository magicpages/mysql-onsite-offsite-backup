# Dockerfile

FROM ubuntu:24.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y mysql-client s3cmd xz-utils curl cron && \
    apt-get clean

# Copy scripts and crontab
COPY backup.bash cleanup.bash entrypoint.bash /usr/local/bin/
COPY crontab /etc/cron.d/backup-cron

# Make the scripts executable and set up cron jobs
RUN chmod +x /usr/local/bin/backup.bash /usr/local/bin/cleanup.bash /usr/local/bin/entrypoint.bash && \
    chmod 0644 /etc/cron.d/backup-cron && \
    crontab /etc/cron.d/backup-cron && \
    touch /var/log/cron.log

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
CMD ["cron", "-f"]

#!/bin/bash

set -euo pipefail


LOG_FILE="/var/log/maintenance.log"

log_rotation(){
	/home/ubuntu/day19/scripts/log_rotate.sh \
	/var/log/myapp >> "$LOG_FILE" 2>&1
}

backup() {
    /home/ubuntu/day19/scripts/backup.sh \
    /home/ubuntu/practice_sh \
    /home/ubuntu/backup >> "$LOG_FILE" 2>&1
}

main() {

    echo "" >> "$LOG_FILE"
    echo "$(date) : Starting Maintenance..." >> "$LOG_FILE"

    log_rotation
    backup

    echo "Maintenance completed for today" >> "$LOG_FILE"
}

main

echo "Successfully written logs to $LOG_FILE"


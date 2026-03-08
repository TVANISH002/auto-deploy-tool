#!/bin/bash

source config.conf

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "Manual rollback started..."

if [ ! -f "$BACKUP_DIR/last_successful_image.txt" ]; then
    log_message "No backup image found for rollback."
    exit 1
fi

PREVIOUS_IMAGE=$(cat "$BACKUP_DIR/last_successful_image.txt")

if [ -z "$PREVIOUS_IMAGE" ]; then
    log_message "Backup image file is empty."
    exit 1
fi

log_message "Rolling back to image: $PREVIOUS_IMAGE"

docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker rm "$CONTAINER_NAME" >/dev/null 2>&1

docker run -d -p "$PORT:8000" --name "$CONTAINER_NAME" "$PREVIOUS_IMAGE"

if [ $? -eq 0 ]; then
    log_message "Manual rollback completed successfully."
else
    log_message "Manual rollback failed."
    exit 1
fi
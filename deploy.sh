#!/bin/bash

# Load configuration
source config.conf

# Create required directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Rollback function
rollback() {
    log_message "Deployment failed. Starting rollback..."

    if [ -f "$BACKUP_DIR/last_successful_image.txt" ]; then
        PREVIOUS_IMAGE=$(cat "$BACKUP_DIR/last_successful_image.txt")
        log_message "Previous stable image found: $PREVIOUS_IMAGE"

        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1

        docker run -d -p "$PORT:8000" --name "$CONTAINER_NAME" "$PREVIOUS_IMAGE" >/dev/null 2>&1

        if [ $? -eq 0 ]; then
            log_message "Rollback successful. App restored using image: $PREVIOUS_IMAGE"
        else
            log_message "Rollback failed. Manual intervention required."
        fi
    else
        log_message "No previous stable image found. Cannot rollback."
    fi

    exit 1
}

log_message "========================================"
log_message "Starting deployment for $APP_NAME"

# Step 1: Pull latest code
log_message "Pulling latest code from repository..."
git pull

if [ $? -ne 0 ]; then
    log_message "git pull failed."
    exit 1
fi

# Step 2: Save currently running image info (if container exists)
CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME" 2>/dev/null)

if [ -n "$CURRENT_IMAGE" ]; then
    echo "$CURRENT_IMAGE" > "$BACKUP_DIR/last_successful_image.txt"
    log_message "Saved current running image for rollback: $CURRENT_IMAGE"
else
    log_message "No running container found. Fresh deployment."
fi

# Step 3: Build new Docker image with timestamp tag
NEW_TAG=$(date '+%Y%m%d%H%M%S')
NEW_IMAGE="${IMAGE_NAME}:${NEW_TAG}"

log_message "Building new Docker image: $NEW_IMAGE"
docker build -t "$NEW_IMAGE" .

if [ $? -ne 0 ]; then
    log_message "Docker build failed."
    rollback
fi

# Optional: also tag latest
docker tag "$NEW_IMAGE" "${IMAGE_NAME}:latest"

# Step 4: Stop and remove old container
log_message "Stopping old container if it exists..."
docker stop "$CONTAINER_NAME" >/dev/null 2>&1

log_message "Removing old container if it exists..."
docker rm "$CONTAINER_NAME" >/dev/null 2>&1

# Step 5: Run new container
log_message "Starting new container..."
docker run -d -p "$PORT:8000" --name "$CONTAINER_NAME" "$NEW_IMAGE"

if [ $? -ne 0 ]; then
    log_message "Failed to start new container."
    rollback
fi

# Step 6: Wait a few seconds before health check
log_message "Waiting for application to start..."
sleep 8

# Step 7: Health check
log_message "Performing health check on $APP_HEALTH_URL"
curl -f "$APP_HEALTH_URL" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "$NEW_IMAGE" > "$BACKUP_DIR/last_successful_image.txt"
    log_message "Health check passed. Deployment successful."
else
    log_message "Health check failed."
    rollback
fi

log_message "Deployment completed successfully."
log_message "========================================"
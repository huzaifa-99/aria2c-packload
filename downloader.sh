#!/bin/bash

LOG_FILE="$(pwd)/logs.txt" # both aria2c and script logs are added in this file
DOWNLOAD_DIR="$(pwd)/downloads"
DOWNLOAD_LINKS_FILE="$(pwd)/download_links.txt"
BAD_LINKS_FILE="$(pwd)/bad_links.txt"
TIMEOUT_WHEN_TORRENT_DOWNLOAD_SPEED_0=600 # ~ 10 minutes
MAX_DOWNLOAD_DIR_STORAGE_SIZE_IN_MBS=20000 # ~ 20 gbs

# logger function
log() {
    local message="$1"
    echo "$message"
    echo "[Log]: $message" >> "$LOG_FILE"
}

# cleanup function
cleanup() {
    log "received SIGINT/SIGTERM, cleaning up..."
    # termination aria2c process if running
    if [ -n "$ARIA2_PID" ]; then
        log "terminating aria2c"
        kill "$ARIA2_PID"
        wait "$ARIA2_PID" 2>/dev/null # await aria2c termination
    fi
    exit 0
}

# trap SIGINT and SIGTERM signals to call cleanup function
trap cleanup SIGINT SIGTERM

# validate directories
if [ ! -d "$DOWNLOAD_DIR" ]; then
    log "creating directory: $DOWNLOAD_DIR"

    if mkdir -p "$DOWNLOAD_DIR"; then
        log "directory created: $DOWNLOAD_DIR"
    else
        log "failed to create directory: $DOWNLOAD_DIR"
        exit 1
    fi
fi

if [ ! -f "$DOWNLOAD_LINKS_FILE" ]; then
    log "download links file not found: $DOWNLOAD_LINKS_FILE"
    exit 1
fi

# validate aria2c command
if ! command -v "aria2c" &> /dev/null; then
    log "aria2c is not installed."
    exit 1
fi

# download individual link content with aria2c
while true; do
    # read download directory size (in mbs)
    directory_size=$(du -sm "$DOWNLOAD_DIR" | awk '{print $1}')
    if [ "$directory_size" -gt "$MAX_DOWNLOAD_DIR_STORAGE_SIZE_IN_MBS" ]; then
        log "downloads directory size exceeds maximum configured storage size ($MAX_DOWNLOAD_DIR_STORAGE_SIZE_IN_MBS MB). Terminating..."
        exit 1
    fi

    # read the first download links file
    DOWNLOAD_LINK=$(head -n 1 "$DOWNLOAD_LINKS_FILE")

    # exit if nothing to download
    if [ -z "$DOWNLOAD_LINK" ]; then
        log "no download link found in: $DOWNLOAD_LINKS_FILE. exiting..."
        exit 0
    fi

    # run ariac in background to download
    log "downloading linked media: $DOWNLOAD_LINK"
    aria2c --seed-time=0 --bt-stop-timeout=$TIMEOUT_WHEN_TORRENT_DOWNLOAD_SPEED_0 --dir="$DOWNLOAD_DIR" "$DOWNLOAD_LINK" >> "$LOG_FILE" 2>&1 & # it will stop once download is completed
    ARIA2_PID=$!
    log "aria2c process (PID: $ARIA2_PID) is downloading in background"

    # await aria2c to finish downloading before moving to the next download link
    wait "$ARIA2_PID"
    ARIA2_EXIT_CODE=$?
    if [ $ARIA2_EXIT_CODE -eq 0 ]; then
        # no error, download completed
        log "download complete: $DOWNLOAD_DIR"
    else
        # download error, add download link to bad links file
        log "download failed: $DOWNLOAD_DIR - aria2c exit code: $ARIA2_EXIT_CODE - adding download link to bad links file"
        echo "$DOWNLOAD_LINK" >> "$BAD_LINKS_FILE"
    fi

    # remove the download link from download links file
    log "removing download link from download links file: $DOWNLOAD_LINKS_FILE"
    tail -n +2 "$DOWNLOAD_LINKS_FILE" > "$DOWNLOAD_LINKS_FILE.tmp" && mv "$DOWNLOAD_LINKS_FILE.tmp" "$DOWNLOAD_LINKS_FILE"
done

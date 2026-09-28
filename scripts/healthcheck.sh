#!/bin/bash
set -euo pipefail

LOG_FILE="scripts/healthcheck.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
STATUS=0

if curl -sf http://localhost/app-a/ > /dev/null; then
  echo "$TIMESTAMP - app-a: UP" >> "$LOG_FILE"
else
  echo "$TIMESTAMP - app-a: DOWN" >> "$LOG_FILE"
  STATUS=1
fi

if curl -sf http://localhost/app-b/ > /dev/null; then
  echo "$TIMESTAMP - app-b: UP" >> "$LOG_FILE"
else
  echo "$TIMESTAMP - app-b: DOWN" >> "$LOG_FILE"
  STATUS=1
fi

echo "Healthcheck complete. Results logged to $LOG_FILE"
exit $STATUS
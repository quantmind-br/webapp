#!/bin/bash
APP_NAME="test"
URL="http"
ICON_FILENAME="icon"
CUSTOM_EXEC="exec"
MIME_TYPES="mime"

JSON_OBJ=$(jq -n \
              --arg name "$APP_NAME" \
              --arg url "$URL" \
              --arg icon "$ICON_FILENAME" \
              --arg exec "$CUSTOM_EXEC" \
              --arg mime "$MIME_TYPES" \
              '{name: $name, url: $url, icon: $icon, custom_exec: $exec, mime_types: $mime}')
echo "$JSON_OBJ"

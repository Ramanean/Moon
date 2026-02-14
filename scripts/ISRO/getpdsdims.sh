#!/bin/bash

# Target directory (defaults to current folder)
TARGET_DIR="${1:-.}"

echo -e "FILE_NAME\tLINES\tSAMPLES"
echo -e "------------------------------------------------------------"

# Find all .xml files recursively
find "$TARGET_DIR" -type f -name "*.xml" | while read -r XML_FILE; do
    
    # 1. Extract Lines
    # Logic: Find the block after <axis_name>Line</axis_name> and grab the next <elements> value
    LINES=$(grep -A 1 "<axis_name>Line</axis_name>" "$XML_FILE" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')

    # 2. Extract Samples
    # Logic: Find the block after <axis_name>Sample</axis_name> and grab the next <elements> value
    SAMPLES=$(grep -A 1 "<axis_name>Sample</axis_name>" "$XML_FILE" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')

    # Only print if both values were found
    if [[ -n "$LINES" && -n "$SAMPLES" ]]; then
        BASE_NAME=$(basename "$XML_FILE")
        echo -e "$BASE_NAME\t$LINES\t$SAMPLES"
    fi
done
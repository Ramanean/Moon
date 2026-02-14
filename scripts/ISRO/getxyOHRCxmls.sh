#!/bin/bash

# Check if a directory was provided, otherwise use current directory
TARGET_DIR="${1:-.}"

# Define the PDS4 namespace
NS="--ns pds=http://pds.nasa.gov/pds4/pds/v1"

echo -e "FILE_NAME\tLINES\tSAMPLES"
echo -e "------------------------------------------------------------"

# Find all .xml files in the folder and subfolders
find "$TARGET_DIR" -type f -name "*.xml" | while read -r XML_FILE; do
    
    # Extract Line elements
    # We look for Axis_Array where axis_name is 'Line'
    LINES=$(xmllint $NS --xpath "string(//pds:Axis_Array[pds:axis_name='Line']/pds:elements)" "$XML_FILE" 2>/dev/null)
    
    # Extract Sample elements
    # We look for Axis_Array where axis_name is 'Sample'
    SAMPLES=$(xmllint $NS --xpath "string(//pds:Axis_Array[pds:axis_name='Sample']/pds:elements)" "$XML_FILE" 2>/dev/null)
    
    # Only print if we actually found dimensions (skips non-observational XMLs)
    if [[ -n "$LINES" && -n "$SAMPLES" ]]; then
        # Get just the filename without the full path for the display
        BASE_NAME=$(basename "$XML_FILE")
        echo -e "$BASE_NAME\t$LINES\t$SAMPLES"
    fi
done
#!/bin/bash

# Ensure a file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <xml_file>"
    exit 1
fi

FILE=$1

# Define the namespaces used in the XML
# Note: PDS4 often uses a default namespace, which we map to 'pds'
NS="--ns pds=http://pds.nasa.gov/pds4/pds/v1 --ns isda=https://isda.issdc.gov.in/pds4/isda/v1"

echo "--- Chandrayaan-2 Product Metadata ---"

# 1. Extract Identification Area Data
LID=$(xmllint $NS --xpath "string(//pds:Identification_Area/pds:logical_identifier)" "$FILE")
echo "Logical ID: $LID"

# 2. Extract Time Coordinates
START_TIME=$(xmllint $NS --xpath "string(//pds:Time_Coordinates/pds:start_date_time)" "$FILE")
echo "Start Time: $START_TIME"

# 3. Extract Mission Area (ISDA Specific) Parameters
ORBIT=$(xmllint $NS --xpath "string(//isda:Product_Parameters/isda:imaging_orbit_number)" "$FILE")
echo "Imaging Orbit: $ORBIT"

ALTITUDE=$(xmllint $NS --xpath "string(//isda:Product_Parameters/isda:spacecraft_altitude)" "$FILE")
UNIT_ALT=$(xmllint $NS --xpath "string(//isda:Product_Parameters/isda:spacecraft_altitude/@unit)" "$FILE")
echo "Spacecraft Altitude: $ALTITUDE $UNIT_ALT"

# 4. Extract File Information
FILENAME=$(xmllint $NS --xpath "string(//pds:File/pds:file_name)" "$FILE")
echo "Data File: $FILENAME"

# 5. Extract Image Dimensions (Lines and Samples)
LINES=$(xmllint $NS --xpath "string(//pds:Axis_Array[pds:axis_name='Line']/pds:elements)" "$FILE")
SAMPLES=$(xmllint $NS --xpath "string(//pds:Axis_Array[pds:axis_name='Sample']/pds:elements)" "$FILE")
echo "Image Size: ${LINES} lines x ${SAMPLES} samples"

echo "--------------------------------------"
#!/bin/bash

# --- Configuration ---
PROG_NAME="ch2-getlatlon"
INSTALL_DIR="$HOME/.local/bin"
BASH_CONFIG="$HOME/.bashrc"

echo "🚀 Starting installation of $PROG_NAME..."

# 1. Create the local bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# 2. Write the program content to a temporary file
cat << 'EOF' > "$PROG_NAME"
#!/bin/bash
# PDS4 Refined Coordinate Extractor
TARGET_DIR="${1:-.}"
OUTPUT_CSV="${2:-refined_coords.csv}"

# CSV Header
HEADER="FILE_NAME,UL_LAT,UL_LON,UR_LAT,UR_LON,LL_LAT,LL_LON,LR_LAT,LR_LON"
echo "$HEADER" > "$OUTPUT_CSV"

echo "📂 Scanning $TARGET_DIR for PDS4 labels..."

# Helper function to extract value for a specific tag
extract_tag() {
    local tag=$1
    local xml_content=$2
    # Matches <isda:tag...>VALUE</isda:tag>
    echo "$xml_content" | grep "<isda:$tag" | sed "s/.*<isda:$tag[^>]*>\(.*\)<\/isda:$tag>.*/\1/" | tr -d '[:space:]'
}

process_xml() {
    local FILE_PATH=$1
    local CONTENT=$2
    local BASE=$(basename "$FILE_PATH")

    # Extract all 8 coordinate points
    UL_LAT=$(extract_tag "upper_left_latitude" "$CONTENT")
    UL_LON=$(extract_tag "upper_left_longitude" "$CONTENT")
    UR_LAT=$(extract_tag "upper_right_latitude" "$CONTENT")
    UR_LON=$(extract_tag "upper_right_longitude" "$CONTENT")
    LL_LAT=$(extract_tag "lower_left_latitude" "$CONTENT")
    LL_LON=$(extract_tag "lower_left_longitude" "$CONTENT")
    LR_LAT=$(extract_tag "lower_right_latitude" "$CONTENT")
    LR_LON=$(extract_tag "lower_right_longitude" "$CONTENT")

    # Only write to CSV if we found data
    if [[ -n "$UL_LAT" ]]; then
        echo "$BASE,$UL_LAT,$UL_LON,$UR_LAT,$UR_LON,$LL_LAT,$LL_LON,$LR_LAT,$LR_LON" >> "$OUTPUT_CSV"
    fi
}


# 2. Process XML files inside ZIP archives
find "$TARGET_DIR" -type f -name "*.zip" | while read -r ZIP_FILE; do
    unzip -Z1 "$ZIP_FILE" 2>/dev/null | grep -i '\.xml$' | while read -r XML_IN_ZIP; do
        # Extract content to memory
        CONTENT=$(unzip -p "$ZIP_FILE" "$XML_IN_ZIP" 2>/dev/null)
        process_xml "$XML_IN_ZIP" "$CONTENT"
    done
done

echo "✅ Done! Data saved to $OUTPUT_CSV"
EOF

# 3. Make the script executable
chmod +x "$PROG_NAME"

# 4. Move to the installation directory
mv "$PROG_NAME" "$INSTALL_DIR/"
echo "✅ Program moved to $INSTALL_DIR/$PROG_NAME"

# 5. Ensure the directory is in the PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASH_CONFIG"
    echo "📝 Added $INSTALL_DIR to your PATH in $BASH_CONFIG"
    echo "👉 Please run: source $BASH_CONFIG to finish setup."
else
    echo "[Already in PATH]"
fi

echo "---"
echo "🎉 Installation complete! Run: $PROG_NAME <directory> <output.csv>"

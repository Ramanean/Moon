#!/bin/bash

# --- Configuration ---
PROG_NAME="pds-dims-fromzip"
INSTALL_DIR="$HOME/.local/bin"
BASH_CONFIG="$HOME/.bashrc"

echo "🚀 Starting installation of $PROG_NAME..."

# 1. Create the local bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# 2. Write the program content to a temporary file
cat << 'EOF' > "$PROG_NAME"
#!/bin/bash
# PDS4 Dimension Extractor (Zip-compatible CSV version)
TARGET_DIR="${1:-.}"
OUTPUT_FILE="output_dimensions.csv"

# Write CSV Header
echo "FILE_NAME,LINES,SAMPLES" > "$OUTPUT_FILE"

echo "Searching for XML data in $TARGET_DIR..."

# --- Function to process XML content from a stream ---
process_xml_stream() {
    local content="$1"
    local filename="$2"

    # Extract elements using a slightly more robust grep/sed for piped content
    LINES=$(echo "$content" | grep -A 1 "<axis_name>Line</axis_name>" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')
    SAMPLES=$(echo "$content" | grep -A 1 "<axis_name>Sample</axis_name>" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')

    if [[ -n "$LINES" && -n "$SAMPLES" ]]; then
        echo "$filename,$LINES,$SAMPLES" >> "$OUTPUT_FILE"
    fi
}

# --- 1. Process Standalone XML Files ---
find "$TARGET_DIR" -type f -name "*.xml" | while read -r XML_FILE; do
    XML_CONTENT=$(cat "$XML_FILE")
    process_xml_stream "$XML_CONTENT" "$(basename "$XML_FILE")"
done

# --- 2. Process XML Files inside ZIP Archives ---
find "$TARGET_DIR" -type f -name "*.zip" | while read -r ZIP_FILE; do
    # List files in zip and filter for .xml
    unzip -l "$ZIP_FILE" | grep "\.xml$" | awk '{print $4}' | while read -r INTERNAL_XML; do
        # Extract to stdout (-p) and process
        XML_CONTENT=$(unzip -p "$ZIP_FILE" "$INTERNAL_XML")
        process_xml_stream "$XML_CONTENT" "$(basename "$INTERNAL_XML")"
    done
done

echo "✅ Extraction complete. Results saved to: $OUTPUT_FILE"
EOF

# 3. Make the script executable
chmod +x "$PROG_NAME"

# 4. Move to the installation directory
mv "$PROG_NAME" "$INSTALL_DIR/"
echo "✅ Program moved to $INSTALL_DIR/$PROG_NAME"

# 5. Ensure the directory is in the PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASH_CONFIG"
    echo "📝 Added $INSTALL_DIR to your PATH in $BASH_CONFIG"
    echo "👉 Please run: source $BASH_CONFIG to finish setup."
else
    echo "[Already in PATH]"
fi

echo "---"
echo "🎉 Installation complete! Run '$PROG_NAME' to generate the CSV."
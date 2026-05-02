#!/bin/bash

# --- Configuration ---
PROG_NAME="getch2isis"
INSTALL_DIR="$HOME/.local/bin"
BASH_CONFIG="$HOME/.bashrc"

echo "🚀 Starting installation of $PROG_NAME..."

# 1. Create the local bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# 2. Write the program content to a temporary file
cat << 'EOF' > "$PROG_NAME"
#!/bin/bash
# PDS4 to ISIS Raw Importer

if [ "$#" -lt 1 ]; then
    echo "Usage: $PROG_NAME <file1.zip> <file2.zip> ..."
    exit 1
fi

for ZIP_FILE in "$@"; do
    if [[ ! -f "$ZIP_FILE" ]]; then
        echo "⚠️  File not found: $ZIP_FILE. Skipping..."
        continue
    fi

    # Get the base name (remove path and .zip extension)
    BASE_NAME=$(basename "$ZIP_FILE" .zip)
    
    echo "📦 Processing $ZIP_FILE..."

    # 1. Locate the XML file inside the zip specifically under /data/calibrated/
    # We use -Z1 to list files and grep for the specific path pattern
    XML_PATH=$(unzip -Z1 "$ZIP_FILE" 2>/dev/null | grep "data/calibrated/.*\.xml$" | head -n 1)

    if [[ -z "$XML_PATH" ]]; then
        echo "❌ Could not find XML file in data/calibrated/ inside $ZIP_FILE"
        continue
    fi

    echo "📄 Reading metadata from: $XML_PATH"

    # 2. Extract content to memory and parse dimensions
    CONTENT=$(unzip -p "$ZIP_FILE" "$XML_PATH" 2>/dev/null)
    
    LINES=$(echo "$CONTENT" | grep -A 1 "<axis_name>Line</axis_name>" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')
    SAMPLES=$(echo "$CONTENT" | grep -A 1 "<axis_name>Sample</axis_name>" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')

    if [[ -n "$LINES" && -n "$SAMPLES" ]]; then
        echo "📐 Dimensions found: Lines=$LINES, Samples=$SAMPLES"
        
        # 3. Execute the raw2isis command
        # Note: This assumes the .raw file is available in the current directory 
        # or extracted from the zip.
        COMMAND="raw2isis from=${BASE_NAME}.raw to=${BASE_NAME}.cub samples=$SAMPLES lines=$LINES bands=1 bittype=unsignedbyte"
        
        echo "⚙️  Executing: $COMMAND"
        eval "$COMMAND"
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully created ${BASE_NAME}.cub"
        else
            echo "❌ Error: raw2isis failed for $BASE_NAME"
        fi
    else
        echo "❌ Error: Could not extract dimensions from $XML_PATH"
    fi
    echo "---"
done
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
echo "🎉 Installation complete! You can now run: $PROG_NAME file1.zip file2.zip"

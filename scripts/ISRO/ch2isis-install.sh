#!/bin/bash

# --- Configuration ---
PROG_NAME="ch2toisis"
INSTALL_DIR="$HOME/.local/bin"
BASH_CONFIG="$HOME/.bashrc"

echo "🚀 Starting installation of $PROG_NAME..."

# 1. Create the local bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# 2. Write the program content to a temporary file
cat << 'EOF' > "$PROG_NAME"
#!/bin/bash
# PDS4 to ISIS Importer (Internal ZIP extraction)

if [ "$#" -lt 1 ]; then
    echo "Usage: $PROG_NAME <file1.zip> <file2.zip> ..."
    exit 1
fi

for ZIP_FILE in "$@"; do
    if [[ ! -f "$ZIP_FILE" ]]; then
        echo "⚠️  File not found: $ZIP_FILE. Skipping..."
        continue
    fi

    # Get the base name for the output .cub file
    BASE_NAME=$(basename "$ZIP_FILE" .zip)
    
    echo "📦 Processing $ZIP_FILE..."

    # 1. Find the XML and IMG file paths inside the zip (data/calibrated/)
    XML_PATH=$(unzip -Z1 "$ZIP_FILE" 2>/dev/null | grep "data/calibrated/.*\.xml$" | head -n 1)
    IMG_PATH=$(unzip -Z1 "$ZIP_FILE" 2>/dev/null | grep "data/calibrated/.*\.img$" | head -n 1)

    if [[ -z "$XML_PATH" || -z "$IMG_PATH" ]]; then
        echo "❌ Required files (.xml or .img) not found in data/calibrated/ inside $ZIP_FILE"
        continue
    fi

    # 2. Extract XML metadata to memory
    CONTENT=$(unzip -p "$ZIP_FILE" "$XML_PATH" 2>/dev/null)
    
    LINES=$(echo "$CONTENT" | grep -A 1 "<axis_name>Line</axis_name>" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')
    SAMPLES=$(echo "$CONTENT" | grep -A 1 "<axis_name>Sample</axis_name>" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')

    if [[ -n "$LINES" && -n "$SAMPLES" ]]; then
        echo "📐 Found Dimensions: Lines=$LINES, Samples=$SAMPLES"
        
        # 3. Extract the .img file from ZIP to current directory
        # -j (junk paths) extracts the file directly into the current folder
        echo "📤 Extracting $(basename "$IMG_PATH")..."
        unzip -j "$ZIP_FILE" "$IMG_PATH" -d . 2>/dev/null
        
        EXTRACTED_IMG=$(basename "$IMG_PATH")

        # 4. Execute raw2isis
        echo "⚙️  Converting to ISIS cube..."
	    sleep 25s
        timeout 0 raw2isis from="$EXTRACTED_IMG" to="${BASE_NAME}.cub" samples=12000  lines=93693 bands=1 bittype=unsignedbyte byteorder=msb
        
        if [ $? -eq 0 ]; then
            echo "✅ Created ${BASE_NAME}.cub"
            # Cleanup extracted .img to save space
            #rm "$EXTRACTED_IMG"
            echo "🧹 Removed temporary file $EXTRACTED_IMG"
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
echo "🎉 Installation complete! Use: $PROG_NAME file1.zip"

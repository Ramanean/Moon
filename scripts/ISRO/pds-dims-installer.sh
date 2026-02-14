#!/bin/bash

# --- Configuration ---
PROG_NAME="pds-dims"
INSTALL_DIR="$HOME/.local/bin"
BASH_CONFIG="$HOME/.bashrc"

echo "🚀 Starting installation of $PROG_NAME..."

# 1. Create the local bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# 2. Write the program content to a temporary file
cat << 'EOF' > "$PROG_NAME"
#!/bin/bash
# PDS4 Dimension Extractor (Raw Shell Version)
TARGET_DIR="${1:-.}"

echo -e "FILE_NAME\tLINES\tSAMPLES"
echo -e "------------------------------------------------------------"

find "$TARGET_DIR" -type f -name "*.xml" | while read -r XML_FILE; do
    # Logic: Search for the axis block and extract the element count
    LINES=$(grep -A 1 "<axis_name>Line</axis_name>" "$XML_FILE" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')
    SAMPLES=$(grep -A 1 "<axis_name>Sample</axis_name>" "$XML_FILE" | grep "<elements>" | sed 's/.*<elements>\(.*\)<\/elements>.*/\1/' | tr -d '[:space:]')

    if [[ -n "$LINES" && -n "$SAMPLES" ]]; then
        BASE_NAME=$(basename "$XML_FILE")
        echo -e "$BASE_NAME\t$LINES\t$SAMPLES"
    fi
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
echo "🎉 Installation complete! You can now run '$PROG_NAME' from any folder."
#!/bin/bash

# --- CONFIGURATION ---
# Base URL for the web viewer
VIEWER_BASE="https://seasick.github.io/openscad-web-gui/?"

# Check if OpenSCAD is installed
if ! command -v openscad &> /dev/null
then
    echo "Error: OpenSCAD is not installed. Please install it to proceed."
    exit 1
fi

# Check if inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null
then
    echo "Error: This folder is not a git repository. Cannot auto-detect URLs."
    exit 1
fi

echo "Auto-detecting Git repository info..."

# 1. Get current branch (e.g., 'main' or 'master')
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 2. Get remote origin URL (supports both HTTPS and SSH)
REMOTE_URL=$(git config --get remote.origin.url)

# 3. Clean the URL to get "User/Repo" format
# Remove .git suffix
CLEAN_URL=${REMOTE_URL%.git}
# Remove protocol prefixes (https://github.com/ or git@github.com:)
REPO_SLUG=${CLEAN_URL#*github.com[:/]}

echo "  - Repository: $REPO_SLUG"
echo "  - Branch: $BRANCH"

# Construct the Raw GitHub Base URL
RAW_BASE="https://raw.githubusercontent.com/$REPO_SLUG/$BRANCH"

echo "Starting preview and link generation..."

# Find all unique directories containing .scad files, excluding root.
find . -mindepth 2 -type f -name "*.scad" -print0 | xargs -0 -n1 dirname | sort -u | while read -r dir;
do
    echo "Processing directory: $dir"
    
    README_PATH="$dir/README.md"
    
    # Create or overwrite the README.md
    echo "# Previews for $(basename "$dir")" > "$README_PATH"
    echo "" >> "$README_PATH"
    echo "This file was automatically generated." >> "$README_PATH"
    echo "" >> "$README_PATH"

    # Process every .scad file in the directory
    for scad_file in "$dir"/*.scad;
    do
        if [ -f "$scad_file" ]; then
            FILENAME=$(basename "$scad_file")
            PNG_FILENAME="${FILENAME%.scad}.png"
            PNG_PATH="$dir/$PNG_FILENAME"
            
            # Calculate clean relative path (removes leading ./)
            REL_PATH=${scad_file#./}
            
            # Construct the full URL for the web viewer
            FULL_URL="${VIEWER_BASE}${RAW_BASE}/${REL_PATH}"
            
            echo "  - Generating preview for $FILENAME..."
            
            # Generate PNG image using OpenSCAD CLI
            openscad -o "$PNG_PATH" \
                     --autocenter \
                     --viewall \
                     --imgsize=800,600 \
                     "$scad_file" > /dev/null 2>&1
            
            # Check if image was created and append to README
            if [ -f "$PNG_PATH" ]; then
                echo "    - Success: $PNG_FILENAME created."
                
                # Write to README
                echo "## $FILENAME" >> "$README_PATH"
                echo "" >> "$README_PATH"
                
                # 1. Clickable Image
                echo "[![Preview of $FILENAME]($PNG_FILENAME)]($FULL_URL)" >> "$README_PATH"
                echo "" >> "$README_PATH"
                
                # 2. Clickable Text Link
                echo "[🔗 Open Interactive 3D Preview]($FULL_URL)" >> "$README_PATH"
                echo "" >> "$README_PATH"
                echo "---" >> "$README_PATH"
            else
                echo "    - Error: Could not generate preview for $FILENAME."
            fi
        fi
    done
    echo "Directory processing complete: $dir"
    echo ""
done

echo "All previews and links have been generated."
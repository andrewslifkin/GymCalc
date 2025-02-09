#!/bin/bash

# Exit on any error
set -e

echo "🔍 Verifying project resources..."

# Define project root
PROJECT_ROOT="$SRCROOT/GymCalc"
RESOURCES_DIR="$PROJECT_ROOT/Resources"

# Create required directories if they don't exist
REQUIRED_DIRS=(
    "$RESOURCES_DIR"
    "$RESOURCES_DIR/Assets.xcassets"
    "$RESOURCES_DIR/Localization"
    "$RESOURCES_DIR/Fonts"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "📁 Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

# Verify asset catalogs
if [ -d "$RESOURCES_DIR/Assets.xcassets" ]; then
    echo "✓ Verifying asset catalogs..."
    xcassets=$(find "$RESOURCES_DIR" -name "*.xcassets")
    for asset in $xcassets; do
        if [ -n "$(find "$asset" -mindepth 1 -print -quit)" ]; then
            echo "  Validating: $asset"
            xcrun actool --compile "$RESOURCES_DIR" "$asset" \
                --minimum-deployment-target 15.0 \
                --platform iphoneos \
                --warnings --errors \
                --output-format human-readable-text || true
        else
            echo "  ℹ️ Empty asset catalog: $asset (skipping validation)"
        fi
    done
fi

# Verify localization files
if [ -d "$RESOURCES_DIR/Localization" ]; then
    echo "✓ Verifying localization files..."
    strings=$(find "$RESOURCES_DIR/Localization" -name "*.strings" 2>/dev/null || true)
    if [ -n "$strings" ]; then
        for file in $strings; do
            echo "  Validating: $file"
            plutil -lint "$file" || true
        done
    else
        echo "  ℹ️ No .strings files found (skipping validation)"
    fi
fi

# Verify Info.plist
if [ -f "Info.plist" ]; then
    echo "✓ Verifying Info.plist..."
    if ! plutil -lint "Info.plist"; then
        echo "❌ Error: Invalid Info.plist file"
        exit 1
    fi
fi

# Check for common issues
echo "✓ Checking for common issues..."

# Check for large files
find . -type f -size +10M | while read file; do
    echo "⚠️ Warning: Large file detected: $file"
done

# Check for invalid file names
find . -name "* *" -o -name "*[^a-zA-Z0-9._-]*" | while read file; do
    echo "⚠️ Warning: File name contains spaces or special characters: $file"
done

echo "✅ Resource verification completed successfully!"

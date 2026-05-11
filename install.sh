#!/usr/bin/env bash
# KOL Browser — Install plasmoid
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLASMOID_FILE="${SCRIPT_DIR}/KOL.plasmoid"

echo "KOL Browser — Installation"
echo "========================="

# Check if kpackagetool6 is available
if ! command -v kpackagetool6 &>/dev/null; then
    echo "❌ kpackagetool6 not found. Install plasma-workspace-devel:"
    echo "   sudo dnf install plasma-workspace-devel"
    exit 1
fi

# Install from source directory
echo "📦 Installing plasmoid from $SCRIPT_DIR ..."
if kpackagetool6 -t Plasma/Applet -i "$SCRIPT_DIR" 2>&1; then
    echo "✅ Plasmoid installed successfully!"
    echo "   Add it to your panel/desktop from the widget explorer."
else
    echo "⚠️  Installation failed. Trying upgrade..."
    if kpackagetool6 -t Plasma/Applet -u "$SCRIPT_DIR" 2>&1; then
        echo "✅ Plasmoid upgraded successfully!"
    else
        echo "❌ Installation failed. Check the errors above."
        exit 1
    fi
fi
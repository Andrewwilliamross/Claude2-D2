#!/bin/bash

# Claude2-D2 Configuration Script
# Automatically configures Claude Code settings to use the soundboard

set -e

SETTINGS_FILE="$HOME/.claude/settings.json"

echo "🔧 Configuring Claude Code settings..."
echo ""

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "❌ Settings file not found at $SETTINGS_FILE"
    echo "Run install.sh first to set up the soundboard"
    exit 1
fi

# Backup existing settings
BACKUP_FILE="$HOME/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SETTINGS_FILE" "$BACKUP_FILE"
echo "📦 Backed up existing settings to:"
echo "   $BACKUP_FILE"
echo ""

# Check if hooks are already configured
if grep -q "notification-hook.sh" "$SETTINGS_FILE"; then
    echo "✅ Notification hook is already configured!"
else
    # Use Python or Node to properly merge JSON (if available)
    # Otherwise, show manual instructions
    if command -v python3 &> /dev/null; then
        python3 <<'PYTHON'
import json
import os

settings_file = os.path.expanduser("~/.claude/settings.json")

# Read existing settings
with open(settings_file, 'r') as f:
    settings = json.load(f)

# Add hooks configuration
if 'hooks' not in settings:
    settings['hooks'] = {}

settings['hooks']['Notification'] = [{
    "matcher": "",
    "hooks": [{
        "type": "command",
        "command": "~/.claude/notification-hook.sh"
    }]
}]

# Write updated settings
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("✅ Configuration updated successfully!")
PYTHON
    else
        echo "⚠️  Could not automatically update settings (Python not found)"
        echo ""
        echo "Please manually add this to your $SETTINGS_FILE:"
        echo ""
        cat "$(dirname "$0")/../settings.json.example"
        echo ""
    fi
fi

echo ""
echo "🎉 Configuration complete!"
echo "Your R2-D2 soundboard is ready to use!"

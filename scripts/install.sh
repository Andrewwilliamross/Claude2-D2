#!/bin/bash

# Claude2-D2 Installation Script
# Installs R2-D2 notification sounds for Claude Code

set -e

echo "🤖 Installing Claude2-D2 Soundboard..."
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Create Claude config directory if it doesn't exist
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/notification-sounds"

# Copy sound files
echo "📦 Copying sound files..."
cp "$PROJECT_DIR/sounds/"*.mp3 "$CLAUDE_DIR/notification-sounds/"
echo "✅ Copied $(ls "$CLAUDE_DIR/notification-sounds/"*.mp3 | wc -l | tr -d ' ') sound files"

# Copy R2-D2 icon
echo "🖼️  Copying R2-D2 icon..."
cp "$PROJECT_DIR/r2d2-icon.png" "$CLAUDE_DIR/r2d2-icon.png"
echo "✅ R2-D2 icon installed"

# Copy notification hook script
echo "📝 Installing notification hook..."
cp "$PROJECT_DIR/scripts/notification-hook.sh" "$CLAUDE_DIR/notification-hook.sh"
chmod +x "$CLAUDE_DIR/notification-hook.sh"
echo "✅ Notification hook installed"

# Check if settings.json exists
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    echo ""
    echo "⚠️  Settings file already exists at $SETTINGS_FILE"
    echo "To enable the soundboard, add this to your settings.json:"
    echo ""
    cat "$PROJECT_DIR/settings.json.example"
    echo ""
    echo "Or run: ./scripts/configure.sh to automatically update settings"
else
    # Create new settings file
    echo "📄 Creating settings.json..."
    cp "$PROJECT_DIR/settings.json.example" "$SETTINGS_FILE"
    echo "✅ Settings file created"
fi

echo ""
# Install Claude2-D2 app bundle
echo "📱 Installing Claude2-D2 app..."
if [ -d "$PROJECT_DIR/Claude2-D2.app" ]; then
    # Copy to ~/Applications (create if it doesn't exist)
    mkdir -p "$HOME/Applications"
    cp -R "$PROJECT_DIR/Claude2-D2.app" "$HOME/Applications/"
    echo "✅ Claude2-D2 app installed to ~/Applications"

    # Launch the app once to register it with macOS
    "$HOME/Applications/Claude2-D2.app/Contents/MacOS/Claude2-D2" &
    sleep 1
else
    echo "⚠️  Claude2-D2.app not found in project directory"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Your R2-D2 will now beep and boop when Claude Code sends notifications!"
echo ""
echo "To test the soundboard, run:"
echo "  ~/.claude/notification-hook.sh"
echo ""

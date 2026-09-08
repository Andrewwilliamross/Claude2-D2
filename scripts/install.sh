#!/bin/bash

# Claude2-D2 Multi-Droid Installation Script
# Installs multiple droid notification soundboards for Claude Code

set -e

echo "🤖 Installing Claude2-D2 Multi-Droid Soundboard..."
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Create Claude config directories
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/notification-sounds"
mkdir -p "$CLAUDE_DIR/icons"

# Check for existing old-style installation and migrate
migrate_old_installation() {
    if ls "$CLAUDE_DIR/notification-sounds/"*.mp3 >/dev/null 2>&1; then
        echo "📦 Migrating existing sounds to new structure..."
        mkdir -p "$CLAUDE_DIR/notification-sounds/r2d2"
        mv "$CLAUDE_DIR/notification-sounds/"*.mp3 "$CLAUDE_DIR/notification-sounds/r2d2/" 2>/dev/null || true
        echo "✅ Migrated existing sounds to r2d2 directory"
    fi

    # Migrate old icon location
    if [ -f "$CLAUDE_DIR/r2d2-icon.png" ] && [ ! -f "$CLAUDE_DIR/icons/r2d2-icon.png" ]; then
        mv "$CLAUDE_DIR/r2d2-icon.png" "$CLAUDE_DIR/icons/r2d2-icon.png"
        echo "✅ Migrated R2-D2 icon to icons directory"
    fi
}

migrate_old_installation

# Install droid sounds
install_droid_sounds() {
    local droid_name="$1"
    local source_dir="$PROJECT_DIR/droids/$droid_name"
    local dest_dir="$CLAUDE_DIR/notification-sounds/$droid_name"

    if [ -d "$source_dir" ]; then
        local sound_count=$(ls "$source_dir"/*.mp3 "$source_dir"/*.m4a 2>/dev/null | wc -l | tr -d ' ')
        if [ "$sound_count" -gt 0 ]; then
            mkdir -p "$dest_dir"
            cp "$source_dir"/*.mp3 "$source_dir"/*.m4a "$dest_dir/" 2>/dev/null || true
            local installed_count=$(ls "$dest_dir"/*.mp3 "$dest_dir"/*.m4a 2>/dev/null | wc -l | tr -d ' ')
            echo "✅ Installed $installed_count $droid_name sounds"
            return 0
        fi
    fi
    return 1
}

echo "📦 Installing droid sound packs..."
echo ""

# Install each droid's sounds
DROIDS_INSTALLED=0

if install_droid_sounds "r2d2"; then
    ((DROIDS_INSTALLED++))
else
    echo "⚠️  R2-D2 sounds not found in project"
fi

if install_droid_sounds "bd1"; then
    ((DROIDS_INSTALLED++))
else
    echo "ℹ️  BD-1 sounds not included (optional)"
fi

if install_droid_sounds "ig11"; then
    ((DROIDS_INSTALLED++))
else
    echo "ℹ️  IG-11 sounds not included (user-provided)"
fi

echo ""
echo "📊 Installed $DROIDS_INSTALLED droid sound pack(s)"
echo ""

# Copy icons
echo "🖼️  Installing droid icons..."
if [ -d "$PROJECT_DIR/icons" ]; then
    cp "$PROJECT_DIR/icons/"*.png "$CLAUDE_DIR/icons/" 2>/dev/null || true
    ICON_COUNT=$(ls "$CLAUDE_DIR/icons/"*.png 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Installed $ICON_COUNT icon(s)"
else
    # Fallback for old structure
    if [ -f "$PROJECT_DIR/r2d2-icon.png" ]; then
        cp "$PROJECT_DIR/r2d2-icon.png" "$CLAUDE_DIR/icons/r2d2-icon.png"
        echo "✅ Installed R2-D2 icon"
    fi
fi

# Copy configuration files
echo "📝 Installing configuration files..."

# Copy droid config
if [ -f "$PROJECT_DIR/droid-config.json" ]; then
    cp "$PROJECT_DIR/droid-config.json" "$CLAUDE_DIR/droid-config.json"
    echo "✅ Droid configuration installed"
else
    echo "⚠️  droid-config.json not found"
fi

# Create assignments file if it doesn't exist
if [ ! -f "$CLAUDE_DIR/droid-assignments.json" ]; then
    if [ -f "$PROJECT_DIR/droid-assignments.json.template" ]; then
        cp "$PROJECT_DIR/droid-assignments.json.template" "$CLAUDE_DIR/droid-assignments.json"
    else
        echo '{"assignments": {}, "next_assignment_index": 0}' > "$CLAUDE_DIR/droid-assignments.json"
    fi
    echo "✅ Droid assignments file created"
else
    echo "ℹ️  Existing droid assignments preserved"
fi

# Copy notification hook script
echo "📝 Installing notification hook..."
cp "$PROJECT_DIR/scripts/notification-hook.sh" "$CLAUDE_DIR/notification-hook.sh"
chmod +x "$CLAUDE_DIR/notification-hook.sh"
echo "✅ Notification hook installed"

# Copy click-to-focus helper (optional; used if terminal-notifier banners are
# enabled in System Settings > Notifications and -sender is dropped)
if [ -f "$PROJECT_DIR/scripts/droid-focus.sh" ]; then
    cp "$PROJECT_DIR/scripts/droid-focus.sh" "$CLAUDE_DIR/droid-focus.sh"
    chmod +x "$CLAUDE_DIR/droid-focus.sh"
    echo "✅ Click-to-focus helper installed"
fi

# Copy droid manager utility
if [ -f "$PROJECT_DIR/scripts/droid-manager.sh" ]; then
    cp "$PROJECT_DIR/scripts/droid-manager.sh" "$CLAUDE_DIR/droid-manager.sh"
    chmod +x "$CLAUDE_DIR/droid-manager.sh"
    echo "✅ Droid manager utility installed"
fi

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

# Show installed droids
echo "🤖 Installed Droids:"
for droid_dir in "$CLAUDE_DIR/notification-sounds"/*/; do
    if [ -d "$droid_dir" ]; then
        droid_name=$(basename "$droid_dir")
        sound_count=$(ls "$droid_dir"/*.mp3 "$droid_dir"/*.m4a 2>/dev/null | wc -l | tr -d ' ')
        echo "   - $droid_name ($sound_count sounds)"
    fi
done

echo ""
echo "Your droid companions are ready to beep and boop!"
echo ""

# Show droid manager usage
echo "📋 Manage your droids with:"
echo "   ~/.claude/droid-manager.sh list      # List all droids"
echo "   ~/.claude/droid-manager.sh current   # Show current project's droid"
echo "   ~/.claude/droid-manager.sh assign <droid>  # Assign specific droid"
echo ""

# Detect terminal and show appropriate setup instructions
case "$TERM_PROGRAM" in
    iTerm.app)
        echo "🖥️  iTerm2 detected! For best experience:"
        echo "   1. Open iTerm2 → Preferences → Profiles → Terminal"
        echo "   2. Enable 'Send Growl/Notification Center alerts'"
        echo "   3. Check System Settings → Notifications → iTerm2 is enabled"
        echo ""
        ;;
    Apple_Terminal)
        echo "🖥️  Terminal.app detected!"
        echo "   Make sure notifications are enabled in System Settings → Notifications → Claude2-D2"
        echo ""
        ;;
    *)
        echo "🖥️  Terminal: $TERM_PROGRAM"
        echo "   Claude2-D2 will use terminal-notifier for notifications"
        echo ""
        ;;
esac

echo "To test the soundboard, run:"
echo "  ~/.claude/notification-hook.sh"
echo ""

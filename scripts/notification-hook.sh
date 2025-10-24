#!/bin/bash

# Claude2-D2 Notification Hook
# Plays random R2-D2 sounds when Claude Code sends notifications

# Debug logging (optional - comment out if you don't want logs)
echo "=== Hook triggered at $(date) ===" >> ~/.claude/hook-debug.log
echo "CLAUDE_NOTIFICATION: $CLAUDE_NOTIFICATION" >> ~/.claude/hook-debug.log
echo "All env vars:" >> ~/.claude/hook-debug.log
env | grep CLAUDE >> ~/.claude/hook-debug.log

# Select a random sound file
SOUND_FILE=$(ls ~/.claude/notification-sounds/*.mp3 | sort -R | head -n 1)
SOUND_NAME=$(basename "$SOUND_FILE" .mp3)
echo "Selected sound: $SOUND_FILE" >> ~/.claude/hook-debug.log

# Play the sound in the background
if [ -n "$SOUND_FILE" ]; then
    echo "Playing sound..." >> ~/.claude/hook-debug.log
    # Play sound using afplay (no UI, works with AirPods)
    afplay "$SOUND_FILE" &
    echo "Sound playback initiated via afplay" >> ~/.claude/hook-debug.log
else
    echo "ERROR: No sound file selected!" >> ~/.claude/hook-debug.log
fi

# Show macOS notification
if command -v terminal-notifier &> /dev/null; then
    # Show notification with R2-D2 icon via app bundle sender
    terminal-notifier -title "Claude2-D2" -message "Ready for you, Master Jedi" -sender com.claude.claude2d2 -group "claude2d2-notification" >/dev/null 2>&1 &

    # Remove notification after 2 seconds to prevent clutter
    (sleep 2 && terminal-notifier -remove "claude2d2-notification" >/dev/null 2>&1) &
else
    # Fall back to osascript (requires Script Editor notification permissions)
    osascript -e "display notification \"Ready for you, Master Jedi\" with title \"Claude2-D2\""
fi

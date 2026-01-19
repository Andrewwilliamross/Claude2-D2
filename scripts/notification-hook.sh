#!/bin/bash

# Claude2-D2 Notification Hook
# Plays random R2-D2 sounds when Claude Code sends notifications
# Compatible with Terminal.app, iTerm2, and other macOS terminals

# Debug logging (optional - comment out if you don't want logs)
DEBUG_LOG=~/.claude/hook-debug.log
echo "=== Hook triggered at $(date) ===" >> "$DEBUG_LOG"
echo "CLAUDE_NOTIFICATION: $CLAUDE_NOTIFICATION" >> "$DEBUG_LOG"
echo "TERM_PROGRAM: $TERM_PROGRAM" >> "$DEBUG_LOG"
echo "All env vars:" >> "$DEBUG_LOG"
env | grep CLAUDE >> "$DEBUG_LOG"

# Select a random sound file
SOUND_FILE=$(ls ~/.claude/notification-sounds/*.mp3 | sort -R | head -n 1)
SOUND_NAME=$(basename "$SOUND_FILE" .mp3)
echo "Selected sound: $SOUND_FILE" >> "$DEBUG_LOG"

# Play the sound in the background
if [ -n "$SOUND_FILE" ]; then
    echo "Playing sound..." >> "$DEBUG_LOG"
    # Play sound using afplay (no UI, works with AirPods)
    afplay "$SOUND_FILE" &
    echo "Sound playback initiated via afplay" >> "$DEBUG_LOG"
else
    echo "ERROR: No sound file selected!" >> "$DEBUG_LOG"
fi

# Notification message
NOTIFICATION_TITLE="Claude2-D2"
NOTIFICATION_MESSAGE="Ready for you, Master Jedi"

# Function to send iTerm2 native notification via escape sequence
send_iterm2_notification() {
    # iTerm2 proprietary escape sequence for notifications
    # Format: OSC 9 ; message ST
    printf '\033]9;%s\007' "$NOTIFICATION_MESSAGE"
    echo "Sent iTerm2 native notification" >> "$DEBUG_LOG"
}

# Function to send notification via terminal-notifier (works with any terminal)
send_terminal_notifier() {
    if command -v terminal-notifier &> /dev/null; then
        # Show notification with R2-D2 icon via app bundle sender
        terminal-notifier -title "$NOTIFICATION_TITLE" -message "$NOTIFICATION_MESSAGE" -sender com.claude.claude2d2 -group "claude2d2-notification" >/dev/null 2>&1 &

        # Remove notification after 2 seconds to prevent clutter
        (sleep 2 && terminal-notifier -remove "claude2d2-notification" >/dev/null 2>&1) &
        echo "Sent terminal-notifier notification" >> "$DEBUG_LOG"
        return 0
    fi
    return 1
}

# Function to send notification via osascript (fallback)
send_osascript_notification() {
    osascript -e "display notification \"$NOTIFICATION_MESSAGE\" with title \"$NOTIFICATION_TITLE\""
    echo "Sent osascript notification" >> "$DEBUG_LOG"
}

# Detect terminal and send appropriate notification
echo "Detecting terminal type..." >> "$DEBUG_LOG"

case "$TERM_PROGRAM" in
    iTerm.app)
        echo "Detected iTerm2" >> "$DEBUG_LOG"
        # iTerm2: Use native escape sequence notification
        # This integrates with iTerm2's notification system
        send_iterm2_notification
        # Also send system notification for notification center integration
        send_terminal_notifier || send_osascript_notification
        ;;
    Apple_Terminal)
        echo "Detected Terminal.app" >> "$DEBUG_LOG"
        # Terminal.app: Use terminal-notifier or osascript
        send_terminal_notifier || send_osascript_notification
        ;;
    *)
        echo "Detected other terminal: $TERM_PROGRAM" >> "$DEBUG_LOG"
        # Other terminals: Try terminal-notifier first, then osascript
        send_terminal_notifier || send_osascript_notification
        ;;
esac

#!/bin/bash

# Claude2-D2 click-to-focus: jump to the iTerm2 tab whose session UUID is $1.
# Invoked by terminal-notifier -execute when a droid notification is clicked.
# Searches by UUID, so it finds the right tab even after tabs are reordered.

uuid="$1"
[ -z "$uuid" ] && exit 0

osascript <<EOF
tell application "iTerm2"
    activate
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if id of s contains "$uuid" then
                    select s
                    select t
                    select w
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell
EOF

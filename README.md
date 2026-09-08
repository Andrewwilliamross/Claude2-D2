# Claude2-D2 🤖

> Give your Claude Code notifications that signature droid charm!

A multi-droid notification soundboard for [Claude Code](https://claude.com/claude-code) that plays random droid sound effects whenever Claude needs your attention. Choose from R2-D2, BD-1, IG-11, or add your own droids!

## 🎵 Features

- **Multiple Droid Personas** - R2-D2, BD-1, IG-11, and more!
- **Per-Project Assignment** - Each Claude Code project gets its own unique droid
- **Auto-Assignment** - Droids are automatically assigned round-robin to new projects
- **Random Playback** - Each notification plays a different random sound
- **Silent Audio Playback** - Uses `afplay` with no UI popup
- **Custom Droid Icons** - Beautiful droid icons appear in notifications
- **macOS App Bundle** - Custom Claude2-D2 app for proper notification branding
- **Themed Notifications** - Each droid has its own message
- **Droid Manager Utility** - CLI tool to manage droid assignments
- **Easy Installation** - Automated setup scripts
- **Debug Logging** - Optional logging for troubleshooting
- **iTerm2 Support** - Native iTerm2 notification integration
- **Terminal Auto-Detection** - Automatically detects Terminal.app, iTerm2, and other terminals

## 🆕 What's New in v2

v2 rewrites the hook to actually read the JSON payload Claude Code sends, so notifications tell you *which* session wants you instead of playing a generic chirp:

- **Context-aware banners** — project name, the terminal/chat title (read live from iTerm2), and the agent + model (e.g. `Claude Code - Opus 5`), with a per-AI color swatch (Claude Code orange, Codex white, Grok black, Prime-Agent purple)
- **Three hook events** — `Stop` announces finished turns, `Notification` handles permission requests and idle reminders, `UserPromptSubmit` tracks turn timing (see `settings.json.example`)
- **Smart filtering** — quick interactive turns (< `min_turn_seconds`, default 30s) stay silent; the redundant 60s idle echo after a finished turn is suppressed; repeated idle/permission reminders are rate-limited per session (`idle_repeat_cooldown_seconds` / `permission_repeat_cooldown_seconds` in `droid-config.json`)
- **Semantic sounds** — finish, question, and idle events pick from different sound categories by filename prefix (`acknowledged`/`excited`/`happy`, `question`/`worried`, `chat`/`neutral`)
- **Delivery tracing & dry-run** — every event logs its decision to `~/.claude/hook-debug.log` (auto-rotated); `DROID_DRY_RUN=1` exercises the full pipeline without sound or banners
- **Click-to-focus helper** — `droid-focus.sh` jumps to the iTerm2 tab a notification came from (optional; requires enabling terminal-notifier banners in System Settings, since macOS allows either the droid icon or a click action, not both)

## 🤖 Included Droids

### R2-D2 (15 sounds)
The classic astromech droid! Includes beeps, boops, whistles, and more.
- Message: "Ready for you, Master Jedi"
- Sounds: `acknowledged`, `excited`, `chat`, `worried`, and more

### BD-1 (14 sounds)
The adorable explorer droid from Jedi: Fallen Order!
- Message: "Beep boop!"
- Sounds: `happy`, `surprise`, `alert`, `success`, `neutral`, and more

### IG-11 (user-provided)
The reformed bounty hunter droid from The Mandalorian.
- Message: "I am fulfilling my base function"
- Sounds: Add your own IG-11 sounds!

## 📋 Requirements

- **macOS** (uses afplay and terminal-notifier)
- **Claude Code** installed
- **Python 3** (for configuration management)
- **Bash** shell (default on macOS)
- **Homebrew** (for installing terminal-notifier)

## 🚀 Quick Start

### Installation

1. Clone or download this repository:
   ```bash
   git clone https://github.com/Andrewwilliamross/Claude2-D2.git
   cd Claude2-D2
   ```

2. Install terminal-notifier (for notifications):
   ```bash
   brew install terminal-notifier
   ```

3. Run the installation script:
   ```bash
   ./scripts/install.sh
   ```

4. Configure Claude Code settings:
   ```bash
   ./scripts/configure.sh
   ```

5. Enable notifications in System Settings:
   - Open **System Settings** → **Notifications**
   - Find **Claude2-D2** in the list
   - Enable "Allow Notifications"
   - Set Alert Style to "Banners" (recommended) or "Alerts"

That's it! Your droids will now beep and boop when Claude Code sends notifications!

## 🎮 Managing Droids

Use the droid manager to control which droid is assigned to each project:

```bash
# List all droids and their current assignments
~/.claude/droid-manager.sh list

# Show the current project's droid
~/.claude/droid-manager.sh current

# Assign a specific droid to the current project
~/.claude/droid-manager.sh assign bd1

# Remove assignment (will auto-assign on next notification)
~/.claude/droid-manager.sh unassign

# Reset all project assignments
~/.claude/droid-manager.sh reset

# Test the notification with current droid
~/.claude/droid-manager.sh test
```

### Auto-Assignment

When you use Claude Code in a new project, a droid is automatically assigned using round-robin selection from available droids. This means each project gets a unique droid companion!

### Manual Assignment

If you want a specific droid for a project:
```bash
cd /path/to/your/project
~/.claude/droid-manager.sh assign r2d2
```

## 📦 Adding Your Own Droids

### Adding IG-11 Sounds

The IG-11 droid is pre-configured but needs sound files:

1. Find IG-11 sound clips (MP3 or M4A format)
2. Copy them to the IG-11 sounds directory:
   ```bash
   cp your-ig11-sounds/*.mp3 ~/.claude/notification-sounds/ig11/
   ```
3. Test with: `~/.claude/droid-manager.sh test`

### Adding a New Droid

1. Create a sounds directory:
   ```bash
   mkdir ~/.claude/notification-sounds/your-droid
   ```

2. Add sound files (MP3 or M4A):
   ```bash
   cp your-sounds/*.mp3 ~/.claude/notification-sounds/your-droid/
   ```

3. Edit `~/.claude/droid-config.json` to add your droid:
   ```json
   {
     "droids": {
       "your-droid": {
         "name": "Your Droid",
         "title": "Your Droid",
         "message": "Your custom message",
         "sounds_dir": "your-droid",
         "icon": "your-droid-icon.png"
       }
     },
     "assignment_order": ["r2d2", "ig11", "bd1", "your-droid"],
     "default_droid": "r2d2"
   }
   ```

4. Optionally add an icon to `~/.claude/icons/`

## 🧪 Testing

Test the soundboard by running the notification hook directly:

```bash
~/.claude/notification-hook.sh
```

Or use the droid manager:

```bash
~/.claude/droid-manager.sh test
```

You should hear a random droid sound and see a macOS notification.

## 🛠️ Customization

### Change a Droid's Message

Edit `~/.claude/droid-config.json` and change the `message` field for any droid.

### Disable Debug Logging

By default, the hook logs debug information to `~/.claude/hook-debug.log`. To disable this:

1. Edit `~/.claude/notification-hook.sh`
2. Comment out or remove the logging lines

### Add More Sounds to a Droid

Simply add `.mp3` or `.m4a` files to the droid's directory:
```bash
cp new-sound.mp3 ~/.claude/notification-sounds/r2d2/
```

## 📁 Project Structure

```
Claude2-D2/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
├── settings.json.example        # Example Claude Code settings
├── droid-config.json           # Droid definitions
├── droid-assignments.json.template  # Assignment template
├── Claude2-D2.app/             # macOS app bundle
├── droids/                     # Droid sound packs
│   ├── r2d2/                   # R2-D2 sounds (15 files)
│   ├── bd1/                    # BD-1 sounds (14 files)
│   └── ig11/                   # IG-11 sounds (user-provided)
├── icons/                      # Droid icons
│   └── r2d2-icon.png          # R2-D2 icon
└── scripts/                    # Installation scripts
    ├── install.sh             # Main installation script
    ├── configure.sh           # Settings configuration script
    ├── notification-hook.sh   # The notification hook
    └── droid-manager.sh       # Droid management utility
```

### Installed Structure (~/.claude/)

After installation:
```
~/.claude/
├── notification-sounds/
│   ├── r2d2/                  # R2-D2 sounds
│   ├── bd1/                   # BD-1 sounds
│   └── ig11/                  # IG-11 sounds
├── icons/
│   └── r2d2-icon.png         # Droid icons
├── droid-config.json         # Droid definitions
├── droid-assignments.json    # Project-to-droid mappings
├── notification-hook.sh      # The notification hook
├── droid-manager.sh          # Management utility
└── settings.json             # Claude Code settings
```

## 🐛 Troubleshooting

### No sound is playing

1. Verify sound files exist: `ls ~/.claude/notification-sounds/*/`
2. Check that `afplay` works: `afplay ~/.claude/notification-sounds/r2d2/excited.mp3`
3. Check debug log: `tail -f ~/.claude/hook-debug.log`
4. Test the hook manually: `~/.claude/notification-hook.sh`

### Wrong droid is playing

1. Check current assignment: `~/.claude/droid-manager.sh current`
2. Reassign if needed: `~/.claude/droid-manager.sh assign <droid-id>`
3. Check assignments file: `cat ~/.claude/droid-assignments.json`

### No notification appearing

1. Check that terminal-notifier is installed: `which terminal-notifier`
2. Enable notifications for Claude2-D2 in System Settings → Notifications
3. Make sure Do Not Disturb / Focus mode is not blocking notifications

### Permission denied errors

Make sure the scripts are executable:

```bash
chmod +x ~/.claude/notification-hook.sh
chmod +x ~/.claude/droid-manager.sh
chmod +x scripts/*.sh
```

### Hook not triggering

1. Verify your `~/.claude/settings.json` has the correct hook configuration
2. Restart Claude Code after updating settings
3. Check that the hook path is correct: `~/.claude/notification-hook.sh`

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Add more droid sound packs
- Improve cross-platform compatibility
- Add new features
- Fix bugs
- Improve documentation

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- R2-D2 sound effects from the Star Wars franchise
- BD-1 sounds from the [BD-1 Sounds Collection](https://github.com/Ssxpn/Rip-BD-1-sounds-Collection)
- R2-D2 icon from [PNGMart](https://www.pngmart.com/image/170173)
- Built for [Claude Code](https://claude.com/claude-code) by Anthropic
- Inspired by the need to make coding more fun!

## ⭐ Show Your Support

If you enjoy having droid companions in your coding sessions, consider:
- Starring this repository
- Sharing it with other Star Wars fans
- Contributing improvements
- Adding new droid sound packs

---

**May the Force be with your code!** 🚀✨

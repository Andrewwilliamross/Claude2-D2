# Claude2-D2 🤖

> Give your Claude Code notifications that signature R2-D2 charm!

A custom notification soundboard for [Claude Code](https://claude.com/claude-code) that plays random R2-D2 sound effects whenever Claude needs your attention. Perfect for Star Wars fans who want their coding assistant to sound like everyone's favorite astromech droid!

## 🎵 Features

- **15 R2-D2 Sound Effects** - Beeps, boops, whistles, and more!
- **Random Playback** - Each notification plays a different random sound
- **Silent Audio Playback** - Uses `afplay` with no UI popup
- **Custom R2-D2 Icon** - Beautiful R2-D2 icon appears in notifications
- **macOS App Bundle** - Custom Claude2-D2 app for proper notification branding
- **Themed Notifications** - "Ready for you, Master Jedi" message
- **Easy Installation** - Automated setup scripts
- **Debug Logging** - Optional logging for troubleshooting

## 🔊 Included Sounds

The soundboard includes 15 different R2-D2 sounds:
- `r2d2-sing-sound-effect.mp3` - The signature R2-D2 singing
- `acknowledged.mp3` & `acknowledged-2.mp3` - Confirmation beeps
- `chat.mp3` - Communication chirps
- `excited.mp3` & `excited-2.mp3` - Happy beeps
- `worried.mp3` - Concerned whistles
- Plus 8 more numbered sound effects (`6.mp3`, `7.mp3`, `8.mp3`, `11.mp3`, `13.mp3`, `14.mp3`, `15.mp3`, `22.mp3`)

## 📋 Requirements

- **macOS** (uses afplay and terminal-notifier)
- **Claude Code** installed
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
   - Set Alert Style to "Banners" or "Alerts"

That's it! Your R2-D2 will now beep with a custom R2-D2 icon whenever Claude Code sends you a notification.

### Manual Installation

If you prefer to install manually:

1. Install terminal-notifier:
   ```bash
   brew install terminal-notifier
   ```

2. Copy sound files:
   ```bash
   mkdir -p ~/.claude/notification-sounds
   cp sounds/*.mp3 ~/.claude/notification-sounds/
   ```

3. Copy the R2-D2 icon:
   ```bash
   cp r2d2-icon.png ~/.claude/r2d2-icon.png
   ```

4. Install the Claude2-D2 app:
   ```bash
   mkdir -p ~/Applications
   cp -R Claude2-D2.app ~/Applications/
   ```

5. Copy the notification hook:
   ```bash
   cp scripts/notification-hook.sh ~/.claude/notification-hook.sh
   chmod +x ~/.claude/notification-hook.sh
   ```

6. Add to your `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "Notification": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/notification-hook.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## 🧪 Testing

Test the soundboard by running the notification hook directly:

```bash
~/.claude/notification-hook.sh
```

You should hear a random R2-D2 sound and see a macOS notification with:
- **Icon:** R2-D2 image (on the left)
- **Title:** Claude2-D2
- **Message:** Ready for you, Master Jedi

## 🛠️ Customization

### Change Notification Message

Want a different message? Edit `~/.claude/notification-hook.sh` and change line 29:

```bash
terminal-notifier -title "Claude2-D2" -message "Your custom message here" -sender com.claude.claude2d2
```

### Disable Debug Logging

By default, the hook logs debug information to `~/.claude/hook-debug.log`. To disable this:

1. Edit `~/.claude/notification-hook.sh`
2. Comment out or remove the logging lines (lines starting with `echo` and writing to `hook-debug.log`)

### Add Your Own Sounds

Want to add more R2-D2 sounds or use different sounds entirely?

1. Add `.mp3` files to `~/.claude/notification-sounds/`
2. The hook will automatically include them in the random selection!

### Change Playback Delay

The default playback delay is 3 seconds. To adjust:

1. Edit `~/.claude/notification-hook.sh`
2. Find the line `delay 3`
3. Change to your preferred delay (in seconds)

## 📁 Project Structure

```
Claude2-D2/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
├── settings.json.example        # Example Claude Code settings
├── r2d2-icon.png               # R2-D2 icon for notifications
├── Claude2-D2.app/             # macOS app bundle with R2-D2 icon
│   └── Contents/
│       ├── Info.plist          # App metadata
│       ├── MacOS/
│       │   └── Claude2-D2      # App executable
│       └── Resources/
│           └── AppIcon.icns    # R2-D2 icon file
├── sounds/                      # R2-D2 sound files
│   ├── r2d2-sing-sound-effect.mp3
│   ├── acknowledged.mp3
│   ├── acknowledged-2.mp3
│   ├── chat.mp3
│   ├── excited.mp3
│   ├── excited-2.mp3
│   ├── worried.mp3
│   └── [8 more sound files]
└── scripts/                     # Installation scripts
    ├── install.sh              # Main installation script
    ├── configure.sh            # Settings configuration script
    └── notification-hook.sh    # The notification hook
```

## 🐛 Troubleshooting

### No sound is playing

1. Verify sound files exist: `ls ~/.claude/notification-sounds/`
2. Check that `afplay` works: `afplay ~/.claude/notification-sounds/excited.mp3`
3. Check debug log: `tail -f ~/.claude/hook-debug.log`
4. Test the hook manually: `~/.claude/notification-hook.sh`

### No notification appearing

1. Check that terminal-notifier is installed: `which terminal-notifier`
2. Enable notifications for Claude2-D2 in System Settings → Notifications
3. Make sure Do Not Disturb / Focus mode is not blocking notifications
4. Check that the Claude2-D2 app is installed: `ls ~/Applications/Claude2-D2.app`

### Permission denied errors

Make sure the scripts are executable:

```bash
chmod +x ~/.claude/notification-hook.sh
chmod +x scripts/*.sh
```

### Hook not triggering

1. Verify your `~/.claude/settings.json` has the correct hook configuration
2. Restart Claude Code after updating settings
3. Check that the hook path is correct: `~/.claude/notification-hook.sh`

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Add more R2-D2 sounds
- Improve cross-platform compatibility
- Add new features
- Fix bugs
- Improve documentation

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- R2-D2 sound effects from the Star Wars franchise
- R2-D2 icon from [PNGMart](https://www.pngmart.com/image/170173)
- Built for [Claude Code](https://claude.com/claude-code) by Anthropic
- Inspired by the need to make coding more fun!

## ⭐ Show Your Support

If you enjoy having R2-D2 as your coding companion, consider:
- Starring this repository
- Sharing it with other Star Wars fans
- Contributing improvements

---

**May the Force be with your code!** 🚀✨

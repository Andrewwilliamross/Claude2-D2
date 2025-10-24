# Contributing to Claude2-D2

Thank you for your interest in contributing to Claude2-D2! We welcome contributions from the community.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce the issue
- Your macOS version
- Claude Code version
- Any relevant error messages or logs from `~/.claude/hook-debug.log`

### Suggesting Enhancements

Have an idea to make Claude2-D2 better? Open an issue with:
- A clear description of the enhancement
- Why it would be useful
- Any implementation ideas you have

### Adding New Sounds

Want to contribute more R2-D2 sounds?

1. Ensure the sound is:
   - A legitimate R2-D2 sound effect
   - In MP3 format
   - Good quality but reasonably sized (< 100KB preferred)
   - Properly licensed for distribution

2. Add the file to the `sounds/` directory with a descriptive name
3. Update the README.md to list the new sound
4. Submit a pull request!

### Code Contributions

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly on macOS
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include comments for complex logic
- Test on macOS (this project is macOS-specific)
- Follow existing code style
- Use `set -e` for scripts that should fail fast

### Documentation

- Keep README.md up to date
- Use clear, concise language
- Include examples where helpful
- Update troubleshooting section if you fix a common issue

### Testing

Before submitting a PR, please test:
1. Fresh installation with `./scripts/install.sh`
2. Configuration with `./scripts/configure.sh`
3. Manual hook execution: `~/.claude/notification-hook.sh`
4. Actual Claude Code notifications

## Questions?

Feel free to open an issue with your question, and we'll do our best to help!

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the project and community
- Help others when you can

Thank you for contributing to making Claude Code more fun! 🤖✨

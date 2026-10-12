# toddler.sh

A child-friendly interactive terminal application designed to help toddlers learn letters and numbers through visual feedback.

## What it does

When a child presses a letter or number key, the application displays large, colorful ASCII art of it with a row of rainbow hearts underneath. Every other key (space, Enter, arrows, punctuation) shows big hearts. Perfect for:

- Letter and number recognition and learning
- Keyboard familiarization
- Visual stimulation through colors and patterns
- Safe, child-proofed terminal interaction

## Quick Start

```bash
# Make it executable
chmod +x toddler.sh

# Run in interactive mode
./toddler.sh

# Test a specific character
./toddler.sh test A

# Display 3 characters per line
./toddler.sh -n 3
```

## Features

- **Interactive**: Press any key to see colorful ASCII art or hearts
- **Child-safe**: Only a quick z, 9, ! sequence exits (prevents accidental termination)
- **Portable**: Single file with minimal dependencies
- **Configurable**: Adjust character repetition count
- **Test mode**: Preview specific characters

## Requirements

- Bash shell (compatible with older versions)
- Unix-like operating system (Linux, macOS, BSD)
- Terminal with color support

## Usage

```bash
./toddler.sh [-n|--number COUNT] [test [CHARACTER]]
```

### Options:

- `-n, --number COUNT`: Number of characters per line (default: 5)
- `test [CHARACTER]`: Test mode - display one character and exit

### Examples:

```bash
# Interactive mode with default settings
./toddler.sh

# Display 3 characters per line
./toddler.sh -n 3

# Test the letter 'B'
./toddler.sh test B

# Test the number '5' with 7 repetitions
./toddler.sh -n 7 test 5
```

## Safety Features

- **Special keys are harmless**: Ctrl+C, Ctrl+Z, Ctrl+\, Ctrl+S (screen freeze), Ctrl+V and arrow/function keys can't stop or freeze the app
- **Adult exit**: press `z`, then `9`, then `!` (shift+1), each within a second. Nothing appears on screen while you do it
- **Mashing stays snappy**: keys pressed while drawing are dropped so the screen never lags behind
- **Terminal restoration**: terminal settings and the cursor come back on exit

## Kiosk mode (Linux)

Inside a desktop, the window manager still handles shortcuts like Alt+Tab or the Super key before `toddler.sh` sees them. `kiosk-setup.sh` turns a spare Linux laptop into a toddler-only machine:

```bash
sudo ./kiosk-setup.sh install    # then reboot
sudo ./kiosk-setup.sh uninstall  # then reboot
```

- Boots to the text console (no desktop) and auto-logs in a `toddler` user whose shell is `toddler.sh`
- Removes console switching (Ctrl+Alt+F1-F12, Alt+arrows), Ctrl+Alt+Del, Scroll Lock, and SysRq
- Ignores the power, suspend, hibernate and reboot keys (holding the power button still forces off)
- Uses a bigger console font if Terminus is installed (`console-setup` on Debian/Ubuntu, `terminus-font` on Fedora/Arch)
- Adult exit asks for the password of the account that ran `sudo ./kiosk-setup.sh install`. A wrong password, or exiting that shell, goes back to the game

Requires systemd and the kbd tools (`dumpkeys`, `loadkeys`).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2024 Nerd Tower LLC

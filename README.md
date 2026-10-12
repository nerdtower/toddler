# toddler.sh

A child-friendly interactive terminal application designed to help toddlers learn letters and numbers through visual feedback.

## What it does

When a child presses a letter or number key, a row of big solid letters glides up across the whole screen in rainbow order, with a strip of little hearts underneath. Every other key (space, Enter, arrows, punctuation) scrolls a row of big hearts; holding a key down speeds the rows up into rainbow stripes. Perfect for:

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

```

## Hacker mode

`./toddler.sh --hacker` starts in hacker mode: every key types the next few characters of a pretend terminal session, so button mashing looks like a grown-up typing. Enter finishes the current command.

- **Pretend tmux**: the session runs in a left pane, a pretend `htop` with CPU bars (they jump when keys are pressed) runs on the right, and a green status bar sits at the bottom. It's all drawn by the script; no real tmux runs. Big effects zoom the left pane to full screen like tmux zoom
- **Chapters**: git, ping, downloads with progress bars, a hex dump, a password crack in big letters, `ssh mainframe` ending in a giant ACCESS GRANTED, Matrix rain, a kitty and `kittysay`, a puppy and a duck, an aquarium, a choo-choo train, a flying rainbow kitty, and a rocket launch with a 3-2-1 countdown
- **Never the same twice**: chapters are shuffled on every loop
- A few commands (`uname -a`, `df -h`, `free -h`, `ps -e`) really run, so their output is real

The session lives in `HACKER_SESSION` in `toddler.sh`, one line per command, and is easy to edit.

Switch between hearts and hacker mode at any time with `z`, `9`, `@` (shift+2) within 2 seconds. This works in kiosk mode too.

## Features

- **Interactive**: Press any key to see colorful ASCII art or hearts
- **Child-safe**: Only a quick z, 9, ! sequence exits (prevents accidental termination)
- **Portable**: Single file with minimal dependencies
- **Test mode**: Preview specific characters

## Requirements

- Bash 5
- Unix-like operating system (Linux, macOS, BSD)
- Terminal with color support

## Usage

```bash
./toddler.sh [--hacker | test [CHARACTER]]
```

- `--hacker`: Start in hacker mode
- `test [CHARACTER]`: Test mode - print one row of a character and exit

### Examples:

```bash
# Interactive mode with default settings
./toddler.sh


# Test the letter 'B'
./toddler.sh test B

```

## Safety Features

- **Special keys are harmless**: Ctrl+C, Ctrl+Z, Ctrl+\, Ctrl+S (screen freeze), Ctrl+V and arrow/function keys can't stop or freeze the app
- **Adult exit**: type `z`, `9`, `!` (shift+1) within 2 seconds. Nothing special appears on screen while you do it
- **Mashing stays snappy**: only the newest key pressed while a row is drawing is kept, so the screen never lags behind
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

# toddler.sh

A child-friendly interactive terminal application designed to help toddlers learn letters and numbers through visual feedback.

## What it does

When a child presses any key, the application displays large, colorful ASCII art representations of letters and numbers in the terminal. Perfect for:

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

- **Interactive**: Press any key to see colorful ASCII art
- **Child-safe**: Only Ctrl+\ can exit (prevents accidental termination)
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

- **Signal blocking**: Disables Ctrl+C, Ctrl+Z, etc.
- **Adult exit**: Only Ctrl+\ (SIGQUIT) can exit
- **Terminal restoration**: Properly restores terminal settings
- **Input buffering**: Prevents terminal corruption

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2024 Nerd Tower LLC

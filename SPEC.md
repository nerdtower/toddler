# Toddler Specification

## Overview

`toddler.sh` is a child-friendly interactive terminal application designed to help toddlers learn letters and numbers through visual feedback. When a child presses any key, the application displays large, colorful ASCII art representations of letters and numbers in the terminal. The script is designed to be completely self-contained with minimal external dependencies for maximum portability.

## Purpose

The application serves as an educational tool for:

- Letter and number recognition and learning
- Keyboard familiarization
- Visual stimulation through colors and patterns
- Safe, child-proofed terminal interaction

## Features

### Core Functionality

- **Interactive Character Display**: Shows large ASCII art letters and numbers when keys are pressed
- **Color Variety**: Randomly cycles through 7 different colors (red, green, yellow, blue, magenta, cyan, white)
- **Character Repetition**: Configurable number of character repetitions per line (default: 5)
- **External Art Files**: Uses `letters.txt` and `numbers.txt` files for custom ASCII art representations
- **Fallback Patterns**: Creates simple block patterns for non-letter/non-number characters

### Child Safety Features

- **Signal Blocking**: Disables most interrupt signals (Ctrl+C, Ctrl+Z, etc.)
- **Adult Exit**: Allows exit only via Ctrl+\ (SIGQUIT)
- **Input Buffering**: Prevents input overflow and terminal corruption
- **Terminal Restoration**: Properly restores terminal settings on exit

### Technical Features

- **Test Mode**: Allows testing specific characters without interactive mode
- **Configurable Repetition**: Command-line option to set character repetition count
- **Terminal Compatibility**: Works with standard Unix-like terminals
- **Error Handling**: Graceful handling of missing files and edge cases

## Usage

### Basic Usage

```bash
./toddler.sh
```

Starts the interactive mode where pressing any key displays the corresponding letter or number.

### Command Line Options

```bash
./toddler.sh [-n|--number COUNT] [test [CHARACTER]]
```

#### Options:

- `-n, --number COUNT`: Set the number of character repetitions per line (default: 5)
- `test [CHARACTER]`: Test mode - display one character and exit (default character: A)

#### Examples:

```bash
# Display 3 characters per line
./toddler.sh -n 3

# Test the letter 'B' with default repetition
./toddler.sh test B

# Test the number '5' with default repetition
./toddler.sh test 5

# Test the letter 'A' with 7 repetitions
./toddler.sh -n 7 test A
```

## Dependencies

### Required Files

- **No external files required** - All ASCII art is embedded directly in the script
- The script is completely self-contained and portable

### System Requirements

- Bash shell (compatible with older versions)
- Unix-like operating system (Linux, macOS, BSD)
- Terminal with color support
- `stty` command for terminal control (usually available by default)

## Technical Implementation

### Terminal Control

- Uses `stty` to disable echo and canonical mode
- Restores terminal settings on exit via cleanup function
- Handles terminal signal management

### Color System

- ANSI color codes: 31-37 (red, green, yellow, blue, magenta, cyan, white)
- Random color selection for each keypress
- Proper color reset after each display

### Character Rendering

- **Letters A-Z**: Uses embedded ASCII art functions
- **Numbers 0-9**: Uses embedded ASCII art functions
- **Other Characters**: Generates simple block patterns
- **Padding**: Automatically pads lines to maintain alignment
- **Repetition**: Configurable horizontal repetition with spacing

## Error Handling

### Missing Files

- No external files required - all ASCII art is embedded
- Fallback to simple block patterns for unknown characters

### Terminal Issues

- Automatic terminal restoration on exit
- Input buffer clearing to prevent corruption
- Color reset to prevent terminal color bleeding

### Invalid Input

- Handles empty keypresses
- Processes both uppercase and lowercase letters
- Converts lowercase to uppercase for display
- Processes digits 0-9 for number display

## Security Considerations

### Child Safety

- Prevents accidental script termination
- Blocks common interrupt signals
- Requires specific key combination (Ctrl+\) for exit

### Terminal Safety

- Proper terminal state restoration
- Input buffering to prevent overflow
- Color reset to prevent display corruption

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The MIT License allows anyone to:

- Use the software for any purpose
- Modify and distribute the software
- Use it commercially
- Distribute modified versions

The only requirement is that the original copyright notice and license text be included in any substantial portions of the software.

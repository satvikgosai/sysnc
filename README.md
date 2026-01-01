# sysnc - System Shell Netcat Command Sender

A utility for system shell command execution via netcat, exploiting Android zygote injection for operation. Primarily designed to run in Termux on Android devices.

## Overview

`sysnc` is a bash wrapper around netcat that simplifies remote command execution and interactive shell access. It exploits Android zygote injection ([CVE-2024-31317][cve]) for system shell.

## Features

- **Interactive Mode**: Establish persistent netcat connections for interactive shell access
- **Command Execution**: Send single commands to remote servers and close connections
- **Pipe Support**: Execute piped shell script on the server

## Installation

### Quick Installation (Recommended)

   ```bash
   curl -fsSL https://raw.githubusercontent.com/satvikgosai/sysnc/main/install.sh | bash
   ```

### Manual Installation

1. Clone or download the script:
   ```bash
   git clone https://github.com/satvikgosai/sysnc.git
   cd sysnc
   ```

2. Make the script executable:
   ```bash
   chmod +x sysnc
   ```

3. Install dependencies:
   ```bash
   # Update package list
   pkg update
   
   # Install netcat
   pkg install netcat-openbsd
   ```

4. Add to PATH:
   ```bash
   # Copy to system bin directory
   cp sysnc $PREFIX/bin/
   
   # Or add current directory to PATH
   echo 'export PATH=$PATH:$(pwd)' >> ~/.bashrc
   source ~/.bashrc
   ```

### Verification

After installation, verify everything works:

```bash
# Check if sysnc is available
which sysnc

# Test help command
sysnc --help
```

## Usage

### Basic Usage

```bash
# Interactive mode (default)
sysnc

# Send a single command
sysnc -c "ls -la"

# Execute piped input
cat script.sh | sysnc

# Setup system shell netcat server
sysnc -s

# Show help
sysnc -h
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `-c, --command` | Send command to server and close connection |
| `-s, --setup` | Setup system shell netcat server |
| `-h, --help` | Show help message |
| *(no args)* | Interactive connection to server |

## Configuration

The script uses the following default configuration:

```bash
NC_HOST="localhost"
NC_PORT="1234"
```

To modify these settings, edit the script directly or set environment variables.

## Android Zygote Injection Exploitation

This tool exploits Android zygote injection ([CVE-2024-31317][cve]) to function. The `-s` option sets up the required netcat server using this exploitation technique.

### Prerequisites

1. **Shizuku and rish**: Install [Shizuku][shizuku] and setup rish with Shizuku for adb shell access, or run commands manually with adb 

### Setup Process

The `-s` option performs:

1. Stops the Android Settings app
2. Executes zygote injection with system UID 1000
3. Restarts the Settings app
4. Cleans up hidden API exemptions

## Contributing

Contributions welcome. Submit issues, feature requests, or pull requests.

## License

Educational purposes only. Use responsibly and in accordance with applicable laws.

## Disclaimer

This tool is for educational purposes only. I am not responsible for any misuse of this software. Users must have proper authorization before running these commands.

## References

- [Android Zygote Injection CVE-2024-31317](https://infosecwriteups.com/exploiting-android-zygote-injection-cve-2024-31317-d83f69265088)
- [Shizuku Project](https://github.com/RikkaApps/Shizuku)
- [Python-zygote-injection-toolkit](https://github.com/Anonymous941/zygote-injection-toolkit)

[cve]: https://infosecwriteups.com/exploiting-android-zygote-injection-cve-2024-31317-d83f69265088
[shizuku]: https://github.com/RikkaApps/Shizuku
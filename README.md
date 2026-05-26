# sysnc — System Shell Netcat Command Sender

A small bash wrapper around netcat that simplifies remote command execution and interactive shell access. It can also set up a system-level (UID 1000) shell on Android by exploiting [zygote injection (CVE-2024-31317)][cve]. Primarily designed to run in Termux on Android devices.

## Features

- **Interactive Mode** — persistent netcat connection with a coloured prompt set up automatically.
- **Command Execution** — send single commands (or full pipelines) to the server and close.
- **Pipe Support** — stream a script over stdin and execute it remotely.
- **Server Setup** — one-shot zygote-injection setup for an Android system shell, with optional `rish`/Shizuku automation.
- **Configurable** — host, port, and UID can all be overridden via flags or environment variables.

## Prerequisites

- **Termux** on Android ([Termux on F-Droid][termux]).
- **netcat-openbsd** (`pkg install netcat-openbsd`) — the installer handles this for you.
- For the `-s/--setup` flow:
  - [Shizuku][shizuku] with `rish` configured, **or** a working `adb shell` connection on which to paste the four setup commands manually.
  - An Android device whose patch level still includes CVE-2024-31317 (most pre-June-2024 builds).

## Installation

### Quick install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/satvikgosai/sysnc/main/install.sh | bash
```

### Manual install

1. Clone the repository:
   ```bash
   git clone https://github.com/satvikgosai/sysnc.git
   cd sysnc
   ```

2. Install dependencies:
   ```bash
   pkg update -y
   pkg install -y netcat-openbsd
   ```

3. Install the script:
   ```bash
   install -m 755 sysnc "$PREFIX/bin/sysnc"
   ```

   *(If you are not in Termux, copy `sysnc` to any directory on your `$PATH` and `chmod +x` it.)*

### Verify

```bash
sysnc --version
sysnc --help
```

### Uninstall

```bash
# Via the installer
curl -fsSL https://raw.githubusercontent.com/satvikgosai/sysnc/main/install.sh | bash -s -- --uninstall

# Or manually
rm "$PREFIX/bin/sysnc"
```

## Usage

```bash
sysnc                            # Interactive mode
sysnc -c "ls -la"                # Send a single command
sysnc -s                         # Setup system-shell netcat server (default UID 1000)
sysnc -s -u 1000                 # Setup with an explicit UID
sysnc -k                         # Kill the running server
sysnc --host 10.0.0.5 --port 4444 -c "id"
cat script.sh | sysnc            # Pipe a script and close
sysnc -h                         # Help
sysnc -v                         # Version
```

### Command line options

| Option | Description |
| --- | --- |
| `-c, --command CMD...` | Send command to server and close connection |
| `-s, --setup` | Setup netcat server via Android zygote injection |
| `-u, --uid UID` | UID for setup (must be **≥ 1000**, default `1000`) |
| `-k, --kill` | Kill the running netcat server |
| `--host HOST` | Server host (default `localhost`) |
| `--port PORT` | Server port (default `1234`) |
| `-v, --version` | Show version |
| `-h, --help` | Show help |
| *(no args)* | Interactive connection to server |

## Configuration

Defaults can be overridden two ways:

**Environment variables** (useful for shells/profiles):

```bash
export NC_HOST=10.0.0.5
export NC_PORT=4444
export NC_UID=1000
sysnc -c "id"
```

**CLI flags** (take precedence over env vars):

```bash
sysnc --host 10.0.0.5 --port 4444 -c "id"
```

| Variable | Flag | Default |
| --- | --- | --- |
| `NC_HOST` | `--host` | `localhost` |
| `NC_PORT` | `--port` | `1234` |
| `NC_UID` | `-u`, `--uid` | `1000` |

## Android zygote injection setup

The `-s` option uses [CVE-2024-31317][cve] to launch a netcat listener as a system-UID process. The flow is:

1. Best-effort kill of any prior server listening on `$NC_PORT`.
2. `am force-stop com.android.settings` — stops the Settings app.
3. Writes a crafted `hidden_api_blacklist_exemptions` value containing a zygote-fork argv that spawns `toybox nc -L /system/bin/sh -l` on the configured port.
4. `am start -a android.settings.SETTINGS` — restarts the Settings app, which forks the malicious zygote and inherits the system UID.
5. Two-second pause to let the spawn settle.
6. `settings delete global hidden_api_blacklist_exemptions` — cleans up so the device is no longer in an inconsistent hidden-API state.

If `rish` is unavailable, `sysnc -s` prints all four commands so you can paste them into `adb shell` manually.

## Troubleshooting

**`Error: Failed to connect to localhost:1234`**
The server isn't running, was killed, or is bound to a different host/port. Run `sysnc -s` to set it up, or override with `--host`/`--port`.

**`Error: rish (Shizuku) is not installed or not in PATH`**
Install [Shizuku][shizuku] and set up `rish`, or paste the four commands `sysnc -s` prints into an `adb shell`.

**`Error: UID must be a number >= 1000`**
Android forbids zygote-fork into UIDs below 1000 for app processes. Use `1000` (system) or any app UID ≥ 10000.

**The interactive shell looks plain / no colours**
The remote shell needs to support ANSI escapes (`TERM=xterm-256color`). Some minimal `sh` builds may not honour `PS1` substitutions — try `sysnc -c "bash -i"` if `bash` is available remotely.

**`nc: invalid option` or unexpected flag errors**
sysnc relies on OpenBSD-netcat semantics (`-N`, `-w`). On macOS the bundled `nc` is different — install `netcat` from Homebrew or use Termux. On Termux, `pkg install netcat-openbsd`.

## Contributing

Issues, feature requests, and pull requests welcome. Please run `shellcheck sysnc install.sh` before sending a PR — the scripts are expected to be lint-clean.

## Security

This is an offensive-security utility. See [SECURITY.md](SECURITY.md) for the disclosure policy and intended use.

## License

[MIT](LICENSE).

## Disclaimer

This tool is for educational and authorised security-testing purposes only. The authors accept no responsibility for misuse. Users must have explicit permission to run these commands against any device that is not their own.

## References

- [Exploiting Android Zygote Injection (CVE-2024-31317)][cve]
- [Shizuku][shizuku]
- [zygote-injection-toolkit (Python)](https://github.com/Anonymous941/zygote-injection-toolkit)

[cve]: https://infosecwriteups.com/exploiting-android-zygote-injection-cve-2024-31317-d83f69265088
[shizuku]: https://github.com/RikkaApps/Shizuku
[termux]: https://f-droid.org/en/packages/com.termux/

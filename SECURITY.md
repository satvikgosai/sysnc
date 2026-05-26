# Security Policy

`sysnc` is an offensive-security utility. It wraps a public exploit (CVE-2024-31317) for local research, authorised pentesting, and education. The notes below describe the intended use, what to do if you find a vulnerability *in* `sysnc` itself, and what is out of scope.

## Intended use

- Devices you own.
- Devices you have **written authorisation** to test.
- Lab environments, CTFs, and controlled training scenarios.
- Defensive research (e.g. validating that a patched device is no longer vulnerable).

Running `sysnc` against any device without the owner's explicit permission is illegal in most jurisdictions. The authors will not provide support for unauthorised use.

## Reporting a vulnerability in sysnc

If you find a bug in `sysnc`, `install.sh`, or the documentation that could put a user at risk — for example, a command-injection flaw in argument parsing, an installer that fetches an unverified script, or a documentation step that leaks credentials — please report it privately first.

- Open a [GitHub Security Advisory](https://github.com/satvikgosai/sysnc/security/advisories/new) on the repository, **or**
- Email the maintainer (see git log / commit metadata) with subject `sysnc security:`.

Please include:

1. A short description of the issue and its impact.
2. Steps to reproduce (a minimal script or command sequence is ideal).
3. The affected version (`sysnc --version`) and platform (Termux version, Android version).
4. Suggested mitigation, if any.

A maintainer will acknowledge the report within 7 days and aim to publish a fix or workaround within 30 days for high-severity issues. Lower-severity issues will be tracked in the public issue tracker once an initial fix is in place.

## Out of scope

The following are **not** vulnerabilities in `sysnc`; please do not report them as such:

- The existence of CVE-2024-31317 itself. Report Android platform issues to [Google's Android Security team](https://source.android.com/docs/security/overview/updates-resources#report-issues).
- Misuse of `sysnc` against devices you do not own or are not authorised to test.
- The fact that the netcat listener is unauthenticated. This is a deliberate design choice for a local-research tool; bind it to `127.0.0.1` (the default) or place it behind your own access controls.
- General Termux or Shizuku bugs. Report those to the respective upstream projects.

## Supply-chain notes for users

- The quick-install one-liner pipes a remote script into `bash`. If you do not trust the network path or the GitHub `main` branch state at the moment of install, prefer the manual install: clone, inspect, then `install -m 755 sysnc "$PREFIX/bin/sysnc"`.
- The installer validates that the downloaded `sysnc` script starts with a bash shebang before installing, but does **not** currently verify a checksum or signature. Tracked as an open improvement.
- Always run `sysnc -v` after install to confirm the version you expected.

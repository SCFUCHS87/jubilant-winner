# jubilant-winner

# update-proton-ge.sh

A small Bash script that keeps [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom) up to date in Steam's compatibility tools directory, with version checking, checksum verification, and automatic cleanup of old versions.

## What it does

1. Checks the latest GE-Proton release on GitHub.
2. If that version is already installed, exits immediately — no download.
3. Otherwise, downloads the tarball and its `.sha512sum` checksum file.
4. Verifies the tarball against the checksum before doing anything else.
5. Removes any older `GE-Proton*` installs from `compatibilitytools.d`.
6. Extracts the new version into Steam's compatibility tools directory.

## Requirements

- `bash`
- `curl`
- `tar`
- `sha512sum` (part of GNU coreutils, included on virtually all Linux distros)
- A Steam install with `~/.steam/steam/compatibilitytools.d` (created automatically if missing)

## Installation

```bash
sudo curl -L -o /usr/local/bin/update-proton-ge.sh \
  https://raw.githubusercontent.com/SCFUCHS87/jubilant-winner/main/update-proton-ge.sh
sudo chmod +x /usr/local/bin/update-proton-ge.sh
```

Or just create the file yourself and make it executable:

```bash
sudo nano /usr/local/bin/update-proton-ge.sh
sudo chmod +x /usr/local/bin/update-proton-ge.sh
```

## Usage

```bash
update-proton-ge.sh
```

Run it anytime — it's safe to run repeatedly. If you're already on the latest version, it'll tell you and exit without touching the network beyond the one API check.

### Example: already up to date

```
Checking latest release...
Latest version available: GE-Proton10-34
GE-Proton10-34 is already installed in /home/scfuchs/.steam/steam/compatibilitytools.d. Nothing to do.
```

### Example: installing a new version

```
Checking latest release...
Latest version available: GE-Proton10-34
Creating temporary working directory...
Downloading tarball: GE-Proton10-34.tar.gz...
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100  492M  100  492M    0     0  9.51M      0  00:51  00:51         24.5M
Downloading checksum: GE-Proton10-34.sha512sum...
Verifying tarball GE-Proton10-34.tar.gz with checksum GE-Proton10-34.sha512sum...
GE-Proton10-34.tar.gz: OK
Checking for old Proton-GE versions in /home/scfuchs/.steam/steam/compatibilitytools.d...
  Removing old version: GE-Proton10-27
Extracting GE-Proton10-34.tar.gz to /home/scfuchs/.steam/steam/compatibilitytools.d...
All done :)
```

## After running

Restart Steam (or just relaunch the client) so it picks up the new compatibility tool. Then in a game's Properties → Compatibility tab, select the new GE-Proton version from the dropdown.

## Notes

- Only one GE-Proton version is kept at a time. If you need to keep an older version around for a specific game, rename its folder in `compatibilitytools.d` (e.g. add a `.keep` suffix) so it no longer matches the `GE-Proton*` glob — the script will leave it alone.
- The script makes a single GitHub API call to fetch release metadata (version tag + both download URLs), rather than querying twice.
- Temporary download files live in `/tmp/proton-ge-custom` and are wiped at the start of each run.

## Automation (optional)

To check for updates automatically, add a user-level systemd timer or a cron entry, e.g.:

```bash
# crontab -e
0 12 * * 0 /usr/local/bin/update-proton-ge.sh >> ~/.local/share/update-proton-ge.log 2>&1
```

This checks weekly (Sundays at noon) and logs output. Since the script exits cleanly with no side effects when already up to date, it's safe to run on a schedule.

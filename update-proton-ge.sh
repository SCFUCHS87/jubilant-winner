#!/bin/bash
set -euo pipefail

STEAM_COMPAT_DIR="$HOME/.steam/steam/compatibilitytools.d"
mkdir -p "$STEAM_COMPAT_DIR"

# fetch release info once (avoids hitting the GitHub API twice)
echo "Checking latest release..."
release_json=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest)
tag_name=$(echo "$release_json" | grep '"tag_name"' | cut -d\" -f4)
echo "Latest version available: $tag_name"

# if we already have this version installed, skip everything else
if [ -d "$STEAM_COMPAT_DIR/$tag_name" ]; then
    echo "$tag_name is already installed in $STEAM_COMPAT_DIR. Nothing to do."
    exit 0
fi

# make temp working directory
echo "Creating temporary working directory..."
rm -rf /tmp/proton-ge-custom
mkdir /tmp/proton-ge-custom
cd /tmp/proton-ge-custom

# pull download URLs out of the release info we already fetched
tarball_url=$(echo "$release_json" | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
tarball_name=$(basename "$tarball_url")
echo "Downloading tarball: $tarball_name..."
curl -L "$tarball_url" -o "$tarball_name"

checksum_url=$(echo "$release_json" | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
checksum_name=$(basename "$checksum_url")
echo "Downloading checksum: $checksum_name..."
curl -L "$checksum_url" -o "$checksum_name"

# check tarball with checksum
echo "Verifying tarball $tarball_name with checksum $checksum_name..."
sha512sum -c "$checksum_name"

# remove old GE-Proton installs before extracting the new one
echo "Checking for old Proton-GE versions in $STEAM_COMPAT_DIR..."
old_found=0
for dir in "$STEAM_COMPAT_DIR"/GE-Proton*; do
    [ -d "$dir" ] || continue
    if [ "$(basename "$dir")" != "$tag_name" ]; then
        old_found=1
        echo "  Removing old version: $(basename "$dir")"
        rm -rf "$dir"
    fi
done
if [ "$old_found" -eq 0 ]; then
    echo "  No old versions found to remove."
fi

# extract proton tarball to steam directory
echo "Extracting $tarball_name to $STEAM_COMPAT_DIR..."
tar -xzf "$tarball_name" -C "$STEAM_COMPAT_DIR"
echo "All done :)"

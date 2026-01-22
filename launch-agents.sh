#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

LAUNCH_AGENTS_DIR=~/Library/LaunchAgents
# IMPORTANT: plist filename must match the <key>Label</key> value inside the plist
PLIST_NAME="com.quantisan.claude-auto-renew.plist"
REPO_PLIST="$(pwd)/launch-agents/${PLIST_NAME}"
TARGET_PLIST="${LAUNCH_AGENTS_DIR}/${PLIST_NAME}"

function doIt() {
    echo "Setting up LaunchAgents..."

    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "${LAUNCH_AGENTS_DIR}"

    # Unload existing agent if it's loaded (ignore errors if not loaded)
    launchctl bootout gui/$(id -u)/"${PLIST_NAME%.plist}" 2>/dev/null || true

    # Remove old symlink/file if it exists
    rm -f "${TARGET_PLIST}"

    # Create symlink from repo to LaunchAgents
    ln -s "${REPO_PLIST}" "${TARGET_PLIST}"
    echo "✓ Symlinked ${PLIST_NAME} to ${LAUNCH_AGENTS_DIR}"

    # Load the agent
    launchctl bootstrap gui/$(id -u) "${TARGET_PLIST}"

    # Verify it's loaded
    if launchctl print gui/$(id -u)/"${PLIST_NAME%.plist}" &>/dev/null; then
        echo "✓ Successfully loaded ${PLIST_NAME}"
        echo ""
        echo "Schedule defined in ${PLIST_NAME}"
        echo "Logs are written to ~/.claude-cron.log"
    else
        echo "✗ Failed to load ${PLIST_NAME}"
        exit 1
    fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt
else
    read -p "This will set up the claude-auto-renew LaunchAgent. Continue? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt
    fi
fi
unset doIt

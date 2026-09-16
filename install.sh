#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RULE_FILE="$SCRIPT_DIR/99-sh53d-adb-fastboot.rules"
TARGET_RULE="/etc/udev/rules.d/99-sh53d-adb-fastboot.rules"

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    SUDO=()
else
    SUDO=(sudo)
fi

if [[ ! -f "$RULE_FILE" ]]; then
    printf 'Rules not found: %s\n' "$RULE_FILE" >&2
    exit 1
fi

if ! getent group plugdev >/dev/null; then
    "${SUDO[@]}" groupadd plugdev
fi

"${SUDO[@]}" install -m 0644 "$RULE_FILE" "$TARGET_RULE"
"${SUDO[@]}" usermod -aG plugdev "$USER"
"${SUDO[@]}" udevadm control --reload-rules
"${SUDO[@]}" udevadm trigger --subsystem-match=usb

adb devices -l
fastboot devices -l

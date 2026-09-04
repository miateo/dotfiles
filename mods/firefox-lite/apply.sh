#!/usr/bin/env bash
# Apply firefox-lite/user.js into a Firefox profile.
#
# Usage:
#   ./apply.sh                # auto-detect default profile from installs.ini
#   ./apply.sh lite           # explicit profile path (relative to ~/.mozilla/firefox)
#
# Backs up any existing user.js as user.js.bak.<timestamp> before overwriting.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
ff_dir="$HOME/.mozilla/firefox"

if [ $# -ge 1 ]; then
  profile="$1"
else
  # installs.ini lives at the firefox root and stores Default=<path>
  # for each install. We grab the first match.
  profile="$(awk -F= '/^Default=/{print $2; exit}' "$ff_dir/installs.ini" 2>/dev/null || true)"
fi

if [ -z "${profile:-}" ]; then
  echo "could not determine target profile — pass it as an argument" >&2
  exit 1
fi

target="$ff_dir/$profile"
if [ ! -d "$target" ]; then
  echo "no profile directory at $target" >&2
  exit 1
fi

if [ -f "$target/user.js" ]; then
  cp "$target/user.js" "$target/user.js.bak.$(date +%s)"
  echo "backed up existing user.js"
fi

cp "$script_dir/user.js" "$target/user.js"
echo "applied to $target"
echo "restart Firefox for changes to take effect"

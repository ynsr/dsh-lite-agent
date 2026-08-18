#!/usr/bin/env bash
# Install the dsh-lite-agent preset (and optionally the companion profile).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"

# 1. Agent preset
mkdir -p "$DSH_HOME/.agent-presets"
rm -rf "$DSH_HOME/.agent-presets/lite"
cp -r "$ROOT/agent-presets/lite" "$DSH_HOME/.agent-presets/lite"
echo "Installed agent preset -> $DSH_HOME/.agent-presets/lite"

# 2. Companion profile (optional, opt in with --profile)
if [[ "${1:-}" == "--profile" ]]; then
  mkdir -p "$DSH_HOME/profiles"
  rm -rf "$DSH_HOME/profiles/lite"
  cp -r "$ROOT/profiles/lite" "$DSH_HOME/profiles/lite"
  echo "Installed profile -> $DSH_HOME/profiles/lite"
  echo "Boot with: dsh --profile lite"
fi

echo "Done. Start a NEW session and pick the 'Lite Agent' preset."

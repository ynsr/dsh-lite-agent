#!/usr/bin/env bash
# Install the dsh-lite-agent preset (and optionally the companion profile).
set -euo pipefail

REPO="ynsr/dsh-lite-agent"
BRANCH="main"

# Resolve the repo root. When run from a local checkout (`./install.sh`) the
# files live next to this script; when piped in via `curl | bash` there is no
# local copy, so fetch the tarball from GitHub into a temp dir instead.
# (`BASH_SOURCE` is unset/empty under `bash -s`, hence the default.)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/agent-presets/lite" ]]; then
  ROOT="$SCRIPT_DIR"
else
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP_DIR"
  ROOT="$TMP_DIR/${REPO##*/}-$BRANCH"
fi

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

  # 3. Shell function (add to rc file)
  add_shell_function() {
    local rc_file
    local func_def='port_free() {
  local port="$1"
  if command -v lsof &> /dev/null; then
    ! lsof -iTCP:"$port" -sTCP:LISTEN -P -n &> /dev/null
  else
    ! (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null
  fi
}

dsh-lite() {
  local port=3080
  while ! port_free "$port"; do
    ((port++))
  done
  if command -v dsh &> /dev/null; then
    dsh --profile lite --port "$port" "$@"
  else
    npx @deepseek-ai/dsh --profile lite --port "$port" "$@"
  fi
}'

    # Detect active shell and its rc file
    if [[ -n "${ZSH_VERSION:-}" ]]; then
      rc_file="${ZDOTDIR:-$HOME}/.zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
      rc_file="$HOME/.bashrc"
    else
      rc_file="$HOME/.bashrc"
    fi

    # Check if function already exists in rc file
    if grep -q "^dsh-lite()" "$rc_file" 2>/dev/null; then
      echo "Function dsh-lite() already exists in $rc_file"
      return 0
    fi

    # Append function to rc file
    {
      echo ""
      echo "# dsh-lite function"
      echo "$func_def"
    } >> "$rc_file"

    echo "Added dsh-lite() function to $rc_file"
    echo "Run: source $rc_file (or start a new shell session)"
  }

  add_shell_function
fi

echo "Done. Start a NEW session and pick the 'Lite Agent' preset."

#!/usr/bin/env bash
set -euo pipefail

# Sync AgentDK command specs to local agent prompt directories.
#
# Usage:
#   sync_agent_commands.sh [SOURCE_DIR]
#
# If SOURCE_DIR is omitted, the script will use:
#   - <repo_root>/commands (resolved relative to this script's location)
#
# Destinations:
#   - ${HOME}/.claude/commands
#   - ${HOME}/.codex/prompts

log() { printf "[sync] %s\n" "$*"; }
err() { printf "[sync][error] %s\n" "$*" >&2; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEFAULT_ABS_SOURCE="${SCRIPT_DIR}/commands"

SOURCE_DIR="${1:-${DEFAULT_ABS_SOURCE}}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  err "Source directory not found: ${SOURCE_DIR}"
  err "Provide an explicit path: sync_agent_commands.sh /path/to/commands"
  exit 1
fi

CLAUDE_DIR="${HOME}/.claude/commands"
CODEX_DIR="${HOME}/.codex/prompts"

mkdir -p "${CLAUDE_DIR}" "${CODEX_DIR}"

copy_to() {
  local src="$1" dest="$2"
  if command -v rsync >/dev/null 2>&1; then
    # Trailing slash copies contents of src into dest
    rsync -a --info=NAME,STATS "${src}/" "${dest}/"
  else
    # cp fallback; "." includes hidden files in src
    cp -a "${src}/." "${dest}/"
  fi
}

log "Source: ${SOURCE_DIR}"
log "-> Claude: ${CLAUDE_DIR}"
copy_to "${SOURCE_DIR}" "${CLAUDE_DIR}"
log "Synced to ${CLAUDE_DIR}"

log "-> Codex: ${CODEX_DIR}"
copy_to "${SOURCE_DIR}" "${CODEX_DIR}"
log "Synced to ${CODEX_DIR}"

log "Done. Files available for agents."

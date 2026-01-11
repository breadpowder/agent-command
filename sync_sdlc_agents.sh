#!/usr/bin/env bash
set -euo pipefail

# Sync SDLC agents to user-level ~/.claude/agents/
#
# Usage:
#   sync_sdlc_agents.sh [--dry-run]
#
# Options:
#   --dry-run    Show what would be synced without actually copying

log() { printf "[sync-agents] %s\n" "$*"; }
err() { printf "[sync-agents][error] %s\n" "$*" >&2; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/agents"
DEST_DIR="${HOME}/.claude/agents"

DRY_RUN=false

# Parse arguments
case "${1:-}" in
  --dry-run)
    DRY_RUN=true
    log "Dry run mode - no files will be modified"
    ;;
  --help|-h)
    echo "Sync SDLC agents to ~/.claude/agents/"
    echo ""
    echo "Usage: sync_sdlc_agents.sh [--dry-run]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be synced without copying"
    echo ""
    echo "Agents synced:"
    echo "  - sdlc-understand-requirement.md (sonnet)"
    echo "  - sdlc-prd-feature.md (opus)"
    echo "  - sdlc-plan-first.md (opus)"
    echo "  - sdlc-task-breakdown.md (opus)"
    echo "  - sdlc-implement-feature.md (opus)"
    exit 0
    ;;
esac

# Validate source directory
if [[ ! -d "${SOURCE_DIR}" ]]; then
  err "Source directory not found: ${SOURCE_DIR}"
  err "Make sure you're running this from the agent-command repository"
  exit 1
fi

# Count SDLC agents to sync
agent_count=$(find "${SOURCE_DIR}" -name "sdlc-*.md" -type f 2>/dev/null | wc -l)
if [[ "${agent_count}" -eq 0 ]]; then
  err "No SDLC agents found in ${SOURCE_DIR}"
  exit 1
fi

log "Found ${agent_count} SDLC agents in: ${SOURCE_DIR}"

# Create destination directory
if [[ "${DRY_RUN}" == "false" ]]; then
  mkdir -p "${DEST_DIR}"
fi

# Wipe existing SDLC agents (Always Overwrite Rule)
log "Removing existing SDLC agents from ${DEST_DIR}..."
if [[ "${DRY_RUN}" == "false" ]]; then
  find "${DEST_DIR}" -name "sdlc-*.md" -type f -delete 2>/dev/null || true
else
  find "${DEST_DIR}" -name "sdlc-*.md" -type f 2>/dev/null | while read -r f; do
    log "  Would remove: ${f}"
  done
fi

# Copy new SDLC agents
log "Syncing SDLC agents to ${DEST_DIR}..."
for agent_file in "${SOURCE_DIR}"/sdlc-*.md; do
  if [[ -f "${agent_file}" ]]; then
    agent_name=$(basename "${agent_file}")
    if [[ "${DRY_RUN}" == "false" ]]; then
      cp "${agent_file}" "${DEST_DIR}/${agent_name}"
      log "  Synced: ${agent_name}"
    else
      log "  Would sync: ${agent_name}"
    fi
  fi
done

# Also sync README if exists
if [[ -f "${SOURCE_DIR}/README.md" ]]; then
  if [[ "${DRY_RUN}" == "false" ]]; then
    cp "${SOURCE_DIR}/README.md" "${DEST_DIR}/SDLC-README.md"
    log "  Synced: README.md -> SDLC-README.md"
  else
    log "  Would sync: README.md -> SDLC-README.md"
  fi
fi

log ""
log "SDLC Agents synced successfully!"
log ""
log "Workflow order (sequential with human review):"
log "  1. sdlc-understand-requirement (sonnet) → REVIEW"
log "  2. sdlc-prd-feature (opus) → REVIEW"
log "  3. sdlc-plan-first (opus) → REVIEW"
log "  4. sdlc-task-breakdown (opus) → REVIEW"
log "  5. sdlc-implement-feature (opus, can run in background)"
log ""
log "Usage: Each agent pauses with 'reveal' gate for human review."
log "Artifacts persist in task_<name>/ between phases."

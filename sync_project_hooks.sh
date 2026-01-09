#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# sync_project_hooks.sh - Sync project-specific hooks to PROJECT LEVEL
# ============================================================================
#
# This script syncs project-specific components to .claude/ (project level):
#   - user-prompt-logger hook (logs to project/prompt-logs/)
#   - post-tool-use-tracker hook (tracks to project/.claude/tsc-cache/)
#   - Project settings.json
#
# Run this script for EACH project you want to enable hooks in.
#
# Usage:
#   sync_project_hooks.sh [OPTIONS]
#
# Options:
#   --help, -h           Show this help message
#   --project-dir DIR    Target project directory (default: current directory)
#
# Requirements:
#   - git repository (project must be git-initialized)
#   - jq (recommended for automatic settings.json configuration)
# ============================================================================

log() { printf "[sync_project_hooks] %s\n" "$*"; }
err() { printf "[sync_project_hooks][error] %s\n" "$*" >&2; }
warn() { printf "[sync_project_hooks][warn] %s\n" "$*" >&2; }

PROJECT_DIR="${PWD}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h|help)
      echo "Sync project-specific hooks to PROJECT LEVEL (.claude/)"
      echo ""
      echo "Usage: sync_project_hooks.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h           Show this help message"
      echo "  --project-dir DIR    Target project directory (default: current)"
      echo ""
      echo "Hooks Installed:"
      echo "  user-prompt-logger     Logs prompts to project/prompt-logs/"
      echo "  post-tool-use-tracker  Tracks file edits to project/.claude/tsc-cache/"
      echo ""
      echo "Run this script for EACH project you want hooks in."
      exit 0
      ;;
    --project-dir)
      shift
      PROJECT_DIR="$1"
      shift
      ;;
    *)
      err "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validate project directory
if [[ ! -d "${PROJECT_DIR}" ]]; then
  err "Project directory does not exist: ${PROJECT_DIR}"
  exit 1
fi

if [[ ! -d "${PROJECT_DIR}/.git" ]]; then
  err "Not a git repository: ${PROJECT_DIR}"
  err "Initialize git first: cd ${PROJECT_DIR} && git init"
  exit 1
fi

# Define paths
PROJECT_HOOKS_DIR="${PROJECT_DIR}/.claude/hooks"
PROJECT_SETTINGS_FILE="${PROJECT_DIR}/.claude/settings.json"

# Determine script directory (source of hooks)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
LOCAL_HOOKS_DIR="${SCRIPT_DIR}/.claude/hooks"

# Create directories
mkdir -p "${PROJECT_HOOKS_DIR}"

log "Installing project hooks to: ${PROJECT_DIR}"
echo ""

# ============================================================================
# Install post-tool-use-tracker
# ============================================================================
install_post_tool_use_tracker() {
  log "Installing post-tool-use-tracker..."

  local source_file="${LOCAL_HOOKS_DIR}/post-tool-use-tracker.sh"
  local dest_file="${PROJECT_HOOKS_DIR}/post-tool-use-tracker.sh"

  if [[ ! -f "${source_file}" ]]; then
    err "post-tool-use-tracker.sh not found at ${source_file}"
    return 1
  fi

  # Skip if source and destination are the same file
  if [[ "$(realpath "${source_file}" 2>/dev/null)" == "$(realpath "${dest_file}" 2>/dev/null)" ]]; then
    log "✓ post-tool-use-tracker.sh already in place"
    return 0
  fi

  cp "${source_file}" "${dest_file}"
  chmod +x "${dest_file}"
  log "✓ Installed post-tool-use-tracker.sh"
}

# ============================================================================
# Install user-prompt-logger
# ============================================================================
install_user_prompt_logger() {
  log "Installing user-prompt-logger..."

  local source_file="${LOCAL_HOOKS_DIR}/user-prompt-logger.sh"
  local dest_file="${PROJECT_HOOKS_DIR}/user-prompt-logger.sh"

  if [[ ! -f "${source_file}" ]]; then
    warn "user-prompt-logger.sh not found, skipping"
    return 1
  fi

  # Skip if source and destination are the same file
  if [[ "$(realpath "${source_file}" 2>/dev/null)" == "$(realpath "${dest_file}" 2>/dev/null)" ]]; then
    log "✓ user-prompt-logger.sh already in place"
    return 0
  fi

  cp "${source_file}" "${dest_file}"
  chmod +x "${dest_file}"
  log "✓ Installed user-prompt-logger.sh"
}

# ============================================================================
# Update Project Settings
# ============================================================================
update_project_settings() {
  log "Updating ${PROJECT_SETTINGS_FILE}..."

  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - manual configuration required"
    return 1
  fi

  # Helper function to check if hook exists
  hook_exists() {
    local hook_type=$1
    local hook_name=$2
    if [[ ! -f "${PROJECT_SETTINGS_FILE}" ]]; then
      echo "false"
      return
    fi
    local exists=$(jq -r --arg ht "${hook_type}" --arg hn "${hook_name}" \
      '.hooks[$ht]?[]?.hooks?[]? | select(.command? | contains($hn)) | .command' \
      "${PROJECT_SETTINGS_FILE}" 2>/dev/null)
    if [[ -n "${exists}" ]]; then echo "true"; else echo "false"; fi
  }

  local has_post_tool=$(hook_exists "PostToolUse" "post-tool-use-tracker")
  local has_logger=$(hook_exists "UserPromptSubmit" "user-prompt-logger")

  # Create new settings if doesn't exist
  if [[ ! -f "${PROJECT_SETTINGS_FILE}" ]]; then
    cat > "${PROJECT_SETTINGS_FILE}" <<'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/user-prompt-logger.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
          }
        ]
      }
    ]
  }
}
EOF
    log "✓ Created project settings.json"
    return 0
  fi

  # Update existing settings
  local temp=$(mktemp)
  local updated=false

  # Ensure .hooks exists
  jq '.hooks //= {}' "${PROJECT_SETTINGS_FILE}" > "${temp}" && mv "${temp}" "${PROJECT_SETTINGS_FILE}"

  # Add PostToolUse if missing
  if [[ "${has_post_tool}" == "false" ]]; then
    jq '.hooks.PostToolUse = [{
      "matcher": "Edit|MultiEdit|Write",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
      }]
    }]' "${PROJECT_SETTINGS_FILE}" > "${temp}" && mv "${temp}" "${PROJECT_SETTINGS_FILE}"
    log "✓ Added PostToolUse hook"
    updated=true
  else
    log "✓ PostToolUse already configured"
  fi

  # Add user-prompt-logger if missing
  if [[ "${has_logger}" == "false" ]]; then
    jq '
      if .hooks.UserPromptSubmit then
        .hooks.UserPromptSubmit[0].hooks += [{
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/user-prompt-logger.sh"
        }]
      else
        .hooks.UserPromptSubmit = [{
          "hooks": [{
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/user-prompt-logger.sh"
          }]
        }]
      end
    ' "${PROJECT_SETTINGS_FILE}" > "${temp}" && mv "${temp}" "${PROJECT_SETTINGS_FILE}"
    log "✓ Added user-prompt-logger hook"
    updated=true
  else
    log "✓ user-prompt-logger already configured"
  fi

  if [[ "${updated}" == "false" ]]; then
    log "✓ Project settings already configured"
  fi
}

# ============================================================================
# Main
# ============================================================================
install_post_tool_use_tracker
install_user_prompt_logger
echo ""
update_project_settings

echo ""
log "✓ Project hooks installed!"
echo ""
log "Installed to: ${PROJECT_DIR}/.claude/"
log "  Hooks:    ${PROJECT_HOOKS_DIR}"
log "  Settings: ${PROJECT_SETTINGS_FILE}"

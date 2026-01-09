#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# sync_user_skills.sh - Sync skills and skill-activation-prompt to USER LEVEL
# ============================================================================
#
# This script syncs shared components to ~/.claude/ (user level):
#   - Skills directory (~/.claude/skills/)
#   - skill-activation-prompt hook (~/.claude/hooks/)
#   - User settings.json (~/.claude/settings.json)
#
# Run this script ONCE to set up skills for ALL projects.
# No project directory needed - works globally.
#
# Usage:
#   sync_user_skills.sh [OPTIONS]
#
# Options:
#   --help, -h    Show this help message
#   --skills-only Only sync skills (skip hook installation)
#
# Requirements:
#   - npm (required for skill-activation-prompt hook)
#   - jq (recommended for automatic settings.json configuration)
# ============================================================================

log() { printf "[sync_user_skills] %s\n" "$*"; }
err() { printf "[sync_user_skills][error] %s\n" "$*" >&2; }
warn() { printf "[sync_user_skills][warn] %s\n" "$*" >&2; }

SKILLS_ONLY="false"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h|help)
      echo "Sync skills and skill-activation-prompt to USER LEVEL (~/.claude/)"
      echo ""
      echo "Usage: sync_user_skills.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h     Show this help message"
      echo "  --skills-only  Only sync skills (skip hook installation)"
      echo ""
      echo "Components Synced:"
      echo "  ~/.claude/skills/          All skill directories + skill-rules.json"
      echo "  ~/.claude/hooks/           skill-activation-prompt hook"
      echo "  ~/.claude/settings.json    Hook configuration"
      echo ""
      echo "Run this script ONCE to enable skills for ALL projects."
      exit 0
      ;;
    --skills-only)
      SKILLS_ONLY="true"
      shift
      ;;
    *)
      err "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Define user-level paths
USER_CLAUDE_DIR="${HOME}/.claude"
USER_SKILLS_DIR="${USER_CLAUDE_DIR}/skills"
USER_HOOKS_DIR="${USER_CLAUDE_DIR}/hooks"
USER_SETTINGS_FILE="${USER_CLAUDE_DIR}/settings.json"

# Determine script directory (source of skills)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
LOCAL_SKILLS_DIR="${SCRIPT_DIR}/.claude/skills"
LOCAL_HOOKS_DIR="${SCRIPT_DIR}/.claude/hooks"

# Create directories
mkdir -p "${USER_SKILLS_DIR}"
mkdir -p "${USER_HOOKS_DIR}"

# ============================================================================
# Sync Skills
# ============================================================================
sync_skills() {
  log "Syncing skills to ${USER_SKILLS_DIR}..."

  # Skills to skip (dependencies not universally available)
  SKIP_SKILLS=("skill-creator-from-youtube")

  if [[ ! -d "${LOCAL_SKILLS_DIR}" ]]; then
    err "Local skills directory not found: ${LOCAL_SKILLS_DIR}"
    return 1
  fi

  # Wipe and replace entire skills directory
  log "Replacing skills directory..."
  rm -rf "${USER_SKILLS_DIR}"
  mkdir -p "${USER_SKILLS_DIR}"

  # Copy skill-rules.json
  if [[ -f "${LOCAL_SKILLS_DIR}/skill-rules.json" ]]; then
    cp "${LOCAL_SKILLS_DIR}/skill-rules.json" "${USER_SKILLS_DIR}/"
    log "✓ Synced skill-rules.json"
  fi

  # Copy each skill directory
  for skill_source in "${LOCAL_SKILLS_DIR}"/*/ ; do
    if [[ -d "${skill_source}" ]]; then
      skill_name=$(basename "${skill_source}")

      # Check if skill should be skipped
      skip=false
      for skip_skill in "${SKIP_SKILLS[@]}"; do
        if [[ "${skill_name}" == "${skip_skill}" ]]; then
          skip=true
          break
        fi
      done

      if [[ "${skip}" == "true" ]]; then
        log "⊘ Skipping: ${skill_name} (missing dependencies)"
      else
        cp -r "${skill_source}" "${USER_SKILLS_DIR}/${skill_name}"
        log "✓ Synced: ${skill_name}"
      fi
    fi
  done

  log "✓ Skills sync complete"
}

# ============================================================================
# Install skill-activation-prompt Hook
# ============================================================================
install_skill_activation_hook() {
  log "Installing skill-activation-prompt hook to ${USER_HOOKS_DIR}..."

  if ! command -v npm >/dev/null 2>&1; then
    err "npm not found. Please install Node.js and npm first."
    return 1
  fi

  # Copy hook files
  if [[ -f "${LOCAL_HOOKS_DIR}/skill-activation-prompt.sh" ]]; then
    cp "${LOCAL_HOOKS_DIR}/skill-activation-prompt.sh" "${USER_HOOKS_DIR}/"
    chmod +x "${USER_HOOKS_DIR}/skill-activation-prompt.sh"
    log "✓ Synced skill-activation-prompt.sh"
  else
    err "skill-activation-prompt.sh not found"
    return 1
  fi

  if [[ -f "${LOCAL_HOOKS_DIR}/skill-activation-prompt.ts" ]]; then
    cp "${LOCAL_HOOKS_DIR}/skill-activation-prompt.ts" "${USER_HOOKS_DIR}/"
    log "✓ Synced skill-activation-prompt.ts"
  else
    err "skill-activation-prompt.ts not found"
    return 1
  fi

  if [[ -f "${LOCAL_HOOKS_DIR}/package.json" ]]; then
    cp "${LOCAL_HOOKS_DIR}/package.json" "${USER_HOOKS_DIR}/"
    log "✓ Synced package.json"
  fi

  # Install npm dependencies
  log "Installing npm dependencies..."
  cd "${USER_HOOKS_DIR}" || return 1
  if ! npm install --silent 2>/dev/null; then
    err "Failed to install npm dependencies"
    return 1
  fi
  cd - >/dev/null

  log "✓ skill-activation-prompt hook installed"
}

# ============================================================================
# Update User Settings
# ============================================================================
update_user_settings() {
  log "Updating ${USER_SETTINGS_FILE}..."

  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - manual configuration required"
    warn "Add to ${USER_SETTINGS_FILE}:"
    echo '{"hooks":{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"$HOME/.claude/hooks/skill-activation-prompt.sh"}]}]}}'
    return 1
  fi

  # Check if hook already configured
  if [[ -f "${USER_SETTINGS_FILE}" ]]; then
    local exists=$(jq -r '.hooks.UserPromptSubmit?[]?.hooks?[]? | select(.command? | contains("skill-activation-prompt")) | .command' "${USER_SETTINGS_FILE}" 2>/dev/null)
    if [[ -n "${exists}" ]]; then
      log "✓ skill-activation-prompt already configured"
      return 0
    fi
  fi

  # Create or update settings
  if [[ ! -f "${USER_SETTINGS_FILE}" ]] || [[ "$(cat "${USER_SETTINGS_FILE}" 2>/dev/null)" == "{}" ]]; then
    cat > "${USER_SETTINGS_FILE}" <<EOF
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ]
  }
}
EOF
    log "✓ Created user settings.json"
  else
    # Append to existing settings
    local temp=$(mktemp)
    jq '.hooks //= {} |
      if .hooks.UserPromptSubmit then
        .hooks.UserPromptSubmit[0].hooks += [{
          "type": "command",
          "command": "$HOME/.claude/hooks/skill-activation-prompt.sh"
        }]
      else
        .hooks.UserPromptSubmit = [{
          "hooks": [{
            "type": "command",
            "command": "$HOME/.claude/hooks/skill-activation-prompt.sh"
          }]
        }]
      end
    ' "${USER_SETTINGS_FILE}" > "${temp}" && mv "${temp}" "${USER_SETTINGS_FILE}"
    log "✓ Updated user settings.json"
  fi
}

# ============================================================================
# Main
# ============================================================================
log "Starting user-level sync..."
echo ""

sync_skills

if [[ "${SKILLS_ONLY}" == "false" ]]; then
  echo ""
  install_skill_activation_hook
  echo ""
  update_user_settings
fi

echo ""
log "✓ User-level sync complete!"
echo ""
log "Installed to:"
log "  Skills:   ${USER_SKILLS_DIR}"
if [[ "${SKILLS_ONLY}" == "false" ]]; then
  log "  Hooks:    ${USER_HOOKS_DIR}"
  log "  Settings: ${USER_SETTINGS_FILE}"
fi
echo ""
log "Skills are now available in ALL projects."

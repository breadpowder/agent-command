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
      echo "Sync skills and hooks to USER LEVEL (~/.claude/)"
      echo ""
      echo "Usage: sync_user_skills.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h     Show this help message"
      echo "  --skills-only  Only sync skills (skip hook installation)"
      echo ""
      echo "Components Synced:"
      echo "  ~/.claude/skills/          All skill directories + skill-rules.json"
      echo "  ~/.claude/hooks/           Shared hooks:"
      echo "    - skill-activation-prompt.sh  Auto-activate skills on prompt"
      echo "    - notify.sh                   Task completion notifications"
      echo "  ~/.claude/settings.json    Hook configuration"
      echo ""
      echo "Cleanup:"
      echo "  After syncing, removes duplicate skills from project-level .claude/skills/"
      echo "  to prevent conflicts with user-level skills."
      echo ""
      echo "Notify Hook Prerequisites:"
      echo "  macOS:  Built-in (osascript) - enable in System Settings > Notifications"
      echo "  Linux:  sudo apt install libnotify-bin"
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
# Clean Legacy Project Skills (remove duplicates after user-level sync)
# ============================================================================
# After syncing skills to user level, check if the current project has
# legacy skills in .claude/skills/ that now exist at user level.
# Remove duplicates to prevent conflicts.
# ============================================================================
cleanup_project_skills() {
  local project_skills_dir="${SCRIPT_DIR}/.claude/skills"

  # Only cleanup if project-level skills directory exists
  if [[ ! -d "${project_skills_dir}" ]]; then
    log "No project-level skills directory found - skipping cleanup"
    return 0
  fi

  log "Checking for legacy project-level skills in ${project_skills_dir}..."

  local cleaned_count=0

  # Check each skill in user level, remove from project if exists
  for user_skill in "${USER_SKILLS_DIR}"/*/ ; do
    if [[ -d "${user_skill}" ]]; then
      local skill_name=$(basename "${user_skill}")
      local project_skill="${project_skills_dir}/${skill_name}"

      if [[ -d "${project_skill}" ]]; then
        rm -rf "${project_skill}"
        log "✓ Removed legacy: ${skill_name}"
        cleaned_count=$((cleaned_count + 1))
      fi
    fi
  done

  # Also clean skill-rules.json if exists at project level and user level
  if [[ -f "${project_skills_dir}/skill-rules.json" ]] && [[ -f "${USER_SKILLS_DIR}/skill-rules.json" ]]; then
    rm -f "${project_skills_dir}/skill-rules.json"
    log "✓ Removed legacy: skill-rules.json"
    cleaned_count=$((cleaned_count + 1))
  fi

  # Remove empty .claude/skills directory
  if [[ -d "${project_skills_dir}" ]]; then
    if [[ -z "$(ls -A "${project_skills_dir}" 2>/dev/null)" ]]; then
      rmdir "${project_skills_dir}"
      log "✓ Removed empty project skills directory"
    fi
  fi

  if [[ ${cleaned_count} -gt 0 ]]; then
    log "✓ Cleaned ${cleaned_count} legacy project-level skill(s)"
  else
    log "No legacy project-level skills to clean"
  fi
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
# Install notify Hook (Cross-platform task completion notifications)
# ============================================================================
install_notify_hook() {
  log "Installing notify hook to ${USER_HOOKS_DIR}..."

  if [[ -f "${LOCAL_HOOKS_DIR}/notify.sh" ]]; then
    cp "${LOCAL_HOOKS_DIR}/notify.sh" "${USER_HOOKS_DIR}/"
    chmod +x "${USER_HOOKS_DIR}/notify.sh"
    log "✓ Synced notify.sh"
  else
    warn "notify.sh not found in ${LOCAL_HOOKS_DIR} - skipping"
    return 0
  fi

  log "✓ notify hook installed"
}

# ============================================================================
# Update User Settings (MERGE strategy - never overwrites existing settings)
# ============================================================================
# This function uses a MERGE strategy:
#   - Checks if each hook already exists before adding
#   - Preserves ALL existing user settings (env, plugins, etc.)
#   - Only adds missing hooks, never removes or modifies existing ones
#   - Safe to run multiple times (idempotent)
# ============================================================================
update_user_settings() {
  log "Updating ${USER_SETTINGS_FILE} (merge mode - preserves existing settings)..."

  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - manual configuration required"
    warn "Add to ${USER_SETTINGS_FILE}:"
    echo '{"hooks":{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"$HOME/.claude/hooks/skill-activation-prompt.sh"}]}],"Stop":[{"matcher":"*","hooks":[{"type":"command","command":"$HOME/.claude/hooks/notify.sh Task finished","timeout":5}]}]}}'
    return 1
  fi

  local settings_updated=false

  # Initialize settings file if needed (preserves existing content)
  if [[ ! -f "${USER_SETTINGS_FILE}" ]]; then
    echo '{}' > "${USER_SETTINGS_FILE}"
    log "Created new settings file"
  elif [[ "$(cat "${USER_SETTINGS_FILE}" 2>/dev/null)" == "{}" ]]; then
    log "Settings file exists but empty, will add hooks"
  else
    log "Existing settings detected, merging (preserving user settings)..."
  fi

  # Check and add skill-activation-prompt hook
  local skill_exists=$(jq -r '.hooks.UserPromptSubmit?[]?.hooks?[]? | select(.command? | contains("skill-activation-prompt")) | .command' "${USER_SETTINGS_FILE}" 2>/dev/null)
  if [[ -z "${skill_exists}" ]]; then
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
    log "✓ Added skill-activation-prompt hook"
    settings_updated=true
  else
    log "✓ skill-activation-prompt already configured"
  fi

  # Check and add notify hook (Stop event)
  local notify_exists=$(jq -r '.hooks.Stop?[]?.hooks?[]? | select(.command? | contains("notify.sh")) | .command' "${USER_SETTINGS_FILE}" 2>/dev/null)
  if [[ -z "${notify_exists}" ]]; then
    local temp=$(mktemp)
    jq '.hooks //= {} |
      if .hooks.Stop then
        .hooks.Stop += [{
          "matcher": "*",
          "hooks": [{
            "type": "command",
            "command": "$HOME/.claude/hooks/notify.sh Task finished",
            "timeout": 5
          }]
        }]
      else
        .hooks.Stop = [{
          "matcher": "*",
          "hooks": [{
            "type": "command",
            "command": "$HOME/.claude/hooks/notify.sh Task finished",
            "timeout": 5
          }]
        }]
      end
    ' "${USER_SETTINGS_FILE}" > "${temp}" && mv "${temp}" "${USER_SETTINGS_FILE}"
    log "✓ Added notify hook (Stop event)"
    settings_updated=true
  else
    log "✓ notify hook already configured"
  fi

  if [[ "${settings_updated}" == "true" ]]; then
    log "✓ Updated user settings.json"
  fi
}

# ============================================================================
# Main
# ============================================================================
log "Starting user-level sync..."
echo ""

sync_skills

# Clean legacy project-level skills that are now at user level
echo ""
cleanup_project_skills

if [[ "${SKILLS_ONLY}" == "false" ]]; then
  echo ""
  install_skill_activation_hook
  echo ""
  install_notify_hook
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
  log "    - skill-activation-prompt.sh (UserPromptSubmit)"
  log "    - notify.sh (Stop - task completion notifications)"
  log "  Settings: ${USER_SETTINGS_FILE}"
fi
echo ""
log "Skills are now available in ALL projects."
echo ""
log "Notify hook prerequisites:"
log "  macOS:  Built-in (osascript) - enable notifications in System Settings"
log "  Linux:  sudo apt install libnotify-bin"

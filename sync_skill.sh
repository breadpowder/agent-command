#!/usr/bin/env bash
set -euo pipefail

# Sync Claude Code hooks to current project
#
# Usage:
#   sync_skill.sh [OPTIONS]
#
# Options:
#   --help, -h              Show this help message
#   --project-dir DIR       Specify project directory (default: current directory)
#   --hook-type TYPE        Hook type: skill-activation-prompt, post-tool-use-tracker, or all (default: all)
#
# Features:
#   - Clones claude-code-infrastructure-showcase repository for latest hooks
#   - Installs hook files to .claude/hooks/ directory
#   - Automatically configures .claude/settings.json (creates or updates)
#   - Uses jq for safe JSON merging (falls back to manual instructions if jq unavailable)
#   - Detects already-installed hooks and skips unnecessary operations
#   - Zero manual configuration required when jq is installed
#
# Requirements:
#   - git (required)
#   - npm (required for skill-activation-prompt hook)
#   - jq (optional but recommended for automatic settings.json merging)

log() { printf "[sync_skill] %s\n" "$*"; }
err() { printf "[sync_skill][error] %s\n" "$*" >&2; }
warn() { printf "[sync_skill][warn] %s\n" "$*" >&2; }

# Default values
PROJECT_DIR="${PWD}"
HOOK_TYPE="all"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h|help)
      echo "Sync Claude Code hooks to current project"
      echo ""
      echo "Usage: sync_skill.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h              Show this help message"
      echo "  --project-dir DIR       Specify project directory (default: current directory)"
      echo "  --hook-type TYPE        Hook type to install (default: all)"
      echo ""
      echo "Hook Types:"
      echo "  skill-activation-prompt    UserPromptSubmit hook for skill suggestions"
      echo "  post-tool-use-tracker      PostToolUse hook for file modification tracking"
      echo "  all                        Install both hooks (default)"
      echo ""
      echo "Features:"
      echo "  • Automatically installs hook files to .claude/hooks/"
      echo "  • Automatically creates or updates .claude/settings.json"
      echo "  • Zero manual configuration when jq is installed"
      echo "  • Detects and skips already-installed hooks"
      echo ""
      echo "Requirements:"
      echo "  • git (required)"
      echo "  • npm (required for skill-activation-prompt)"
      echo "  • jq (recommended for automatic JSON configuration)"
      echo ""
      echo "Examples:"
      echo "  sync_skill.sh                                      # Install all hooks to current directory"
      echo "  sync_skill.sh --hook-type post-tool-use-tracker   # Install only post-tool-use-tracker"
      echo "  sync_skill.sh --project-dir /path/to/project      # Install to specific directory"
      exit 0
      ;;
    --project-dir)
      shift
      PROJECT_DIR="$1"
      shift
      ;;
    --hook-type)
      shift
      HOOK_TYPE="$1"
      shift
      ;;
    *)
      err "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validate hook type
case "${HOOK_TYPE}" in
  skill-activation-prompt|post-tool-use-tracker|all)
    ;;
  *)
    err "Invalid hook type: ${HOOK_TYPE}"
    echo "Valid types: skill-activation-prompt, post-tool-use-tracker, all"
    exit 1
    ;;
esac

# Validate project directory
if [[ ! -d "${PROJECT_DIR}" ]]; then
  err "Project directory does not exist: ${PROJECT_DIR}"
  exit 1
fi

log "Installing Claude Code hooks to: ${PROJECT_DIR}"

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
  err "git command not found. Please install git first."
  exit 1
fi

# Define paths
HOOKS_DIR="${PROJECT_DIR}/.claude/hooks"
SETTINGS_FILE="${PROJECT_DIR}/.claude/settings.json"

# Create hooks directory if it doesn't exist
mkdir -p "${HOOKS_DIR}"

# Create temporary directory for cloning
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

# Clone the infrastructure showcase repository (only once)
log "Cloning claude-code-infrastructure-showcase repository..."
if ! git clone --depth 1 --quiet "https://github.com/breadpowder/claude-code-infrastructure-showcase.git" "${TEMP_DIR}" 2>/dev/null; then
  err "Failed to clone claude-code-infrastructure-showcase repository"
  err "Please check your internet connection and try again"
  exit 1
fi

# Function to install skill-activation-prompt hook
install_skill_activation_prompt() {
  log "Installing skill-activation-prompt hook..."

  # Check if already installed
  if [[ -f "${HOOKS_DIR}/skill-activation-prompt.sh" ]]; then
    log "✓ skill-activation-prompt already installed"
    return 0
  fi

  # Check if npm is available (required for this hook)
  if ! command -v npm >/dev/null 2>&1; then
    err "npm command not found. Please install Node.js and npm first."
    echo "Visit: https://nodejs.org"
    return 1
  fi

  # Copy hook files
  if [[ -f "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.sh" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.sh" "${HOOKS_DIR}/"
    chmod +x "${HOOKS_DIR}/skill-activation-prompt.sh"
    log "✓ Copied skill-activation-prompt.sh"
  else
    err "skill-activation-prompt.sh not found in repository"
    return 1
  fi

  if [[ -f "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.ts" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.ts" "${HOOKS_DIR}/"
    log "✓ Copied skill-activation-prompt.ts"
  else
    err "skill-activation-prompt.ts not found in repository"
    return 1
  fi

  # Copy package.json if it exists
  if [[ -f "${TEMP_DIR}/.claude/hooks/package.json" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/package.json" "${HOOKS_DIR}/"
    log "✓ Copied package.json"
  fi

  # Install npm dependencies
  log "Installing npm dependencies..."
  cd "${HOOKS_DIR}" || return 1

  NPM_OUTPUT=$(npm install 2>&1)
  NPM_EXIT_CODE=$?

  cd "${PROJECT_DIR}" || return 1

  if [[ ${NPM_EXIT_CODE} -ne 0 ]]; then
    err "Failed to install npm dependencies (exit code: ${NPM_EXIT_CODE})"
    echo ""
    echo "npm install output:"
    echo "${NPM_OUTPUT}"
    echo ""
    return 1
  fi

  log "✓ Successfully installed npm dependencies"
  log "✓ skill-activation-prompt hook installed"
  return 0
}

# Function to install post-tool-use-tracker hook
install_post_tool_use_tracker() {
  log "Installing post-tool-use-tracker hook..."

  # Check if already installed
  if [[ -f "${HOOKS_DIR}/post-tool-use-tracker.sh" ]]; then
    log "✓ post-tool-use-tracker already installed"
    return 0
  fi

  # Copy hook file
  if [[ -f "${TEMP_DIR}/.claude/hooks/post-tool-use-tracker.sh" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/post-tool-use-tracker.sh" "${HOOKS_DIR}/"
    chmod +x "${HOOKS_DIR}/post-tool-use-tracker.sh"
    log "✓ Copied post-tool-use-tracker.sh"
  else
    err "post-tool-use-tracker.sh not found in repository"
    return 1
  fi

  log "✓ post-tool-use-tracker hook installed"
  return 0
}

# Function to update settings.json with hook configurations
update_settings_json() {
  local needs_skill_activation=$1
  local needs_post_tool_use=$2

  # Check if jq is available for JSON manipulation
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - using basic JSON generation"
    warn "Install jq for better JSON merging: sudo apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)"
    use_jq=false
  else
    use_jq=true
  fi

  if [[ ! -f "${SETTINGS_FILE}" ]]; then
    log "Creating settings.json with hook configurations..."

    # Build JSON based on which hooks are needed
    if [[ "${needs_skill_activation}" == "true" && "${needs_post_tool_use}" == "true" ]]; then
      cat > "${SETTINGS_FILE}" <<'SETTINGS_EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
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
SETTINGS_EOF
    elif [[ "${needs_skill_activation}" == "true" ]]; then
      cat > "${SETTINGS_FILE}" <<'SETTINGS_EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
    elif [[ "${needs_post_tool_use}" == "true" ]]; then
      cat > "${SETTINGS_FILE}" <<'SETTINGS_EOF'
{
  "hooks": {
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
SETTINGS_EOF
    fi

    log "✓ Created settings.json with hook configuration"
  else
    # Settings file exists - merge configurations automatically
    log "Updating existing settings.json..."

    # Check what's already configured
    local has_skill_activation=$(grep -q "skill-activation-prompt.sh" "${SETTINGS_FILE}" && echo "true" || echo "false")
    local has_post_tool_use=$(grep -q "post-tool-use-tracker.sh" "${SETTINGS_FILE}" && echo "true" || echo "false")

    local changes_made=false

    if [[ "${use_jq}" == "true" ]]; then
      # Use jq for proper JSON merging
      TEMP_SETTINGS=$(mktemp)

      # Add skill-activation-prompt if needed
      if [[ "${needs_skill_activation}" == "true" && "${has_skill_activation}" == "false" ]]; then
        log "Adding UserPromptSubmit hook configuration..."
        jq '.hooks.UserPromptSubmit = [
          {
            "hooks": [
              {
                "type": "command",
                "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
              }
            ]
          }
        ]' "${SETTINGS_FILE}" > "${TEMP_SETTINGS}"
        mv "${TEMP_SETTINGS}" "${SETTINGS_FILE}"
        changes_made=true
        log "✓ Added UserPromptSubmit hook configuration"
      fi

      # Add post-tool-use-tracker if needed
      if [[ "${needs_post_tool_use}" == "true" && "${has_post_tool_use}" == "false" ]]; then
        log "Adding PostToolUse hook configuration..."
        jq '.hooks.PostToolUse = [
          {
            "matcher": "Edit|MultiEdit|Write",
            "hooks": [
              {
                "type": "command",
                "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
              }
            ]
          }
        ]' "${SETTINGS_FILE}" > "${TEMP_SETTINGS}"
        mv "${TEMP_SETTINGS}" "${SETTINGS_FILE}"
        changes_made=true
        log "✓ Added PostToolUse hook configuration"
      fi

      rm -f "${TEMP_SETTINGS}"
    else
      # Fallback: manual instructions if jq is not available
      if [[ "${needs_skill_activation}" == "true" && "${has_skill_activation}" == "false" ]]; then
        warn "settings.json exists but doesn't include skill-activation-prompt hook"
        echo "Please add the UserPromptSubmit hook configuration manually or install jq"
      fi

      if [[ "${needs_post_tool_use}" == "true" && "${has_post_tool_use}" == "false" ]]; then
        warn "settings.json exists but doesn't include post-tool-use-tracker hook"
        echo "Please add the PostToolUse hook configuration manually or install jq"
      fi
    fi

    # Report final status
    if [[ "${changes_made}" == "true" ]]; then
      log "✓ Updated settings.json with new hook configurations"
    elif [[ "${has_skill_activation}" == "true" && "${has_post_tool_use}" == "true" ]]; then
      log "✓ settings.json already configured with both hooks"
    elif [[ "${has_skill_activation}" == "true" || "${has_post_tool_use}" == "true" ]]; then
      log "✓ settings.json already configured with requested hooks"
    fi
  fi
}

# Install hooks based on type
INSTALL_SUCCESS=true

case "${HOOK_TYPE}" in
  skill-activation-prompt)
    if ! install_skill_activation_prompt; then
      INSTALL_SUCCESS=false
    fi
    update_settings_json "true" "false"
    ;;
  post-tool-use-tracker)
    if ! install_post_tool_use_tracker; then
      INSTALL_SUCCESS=false
    fi
    update_settings_json "false" "true"
    ;;
  all)
    SKILL_SUCCESS=true
    POST_SUCCESS=true

    if ! install_skill_activation_prompt; then
      SKILL_SUCCESS=false
      INSTALL_SUCCESS=false
    fi

    if ! install_post_tool_use_tracker; then
      POST_SUCCESS=false
      INSTALL_SUCCESS=false
    fi

    update_settings_json "${SKILL_SUCCESS}" "${POST_SUCCESS}"
    ;;
esac

# Summary
echo ""
if [[ "${INSTALL_SUCCESS}" == "true" ]]; then
  log "✓ Successfully installed hooks"
  log "Hooks location: ${HOOKS_DIR}"
  log "Settings file: ${SETTINGS_FILE}"
  exit 0
else
  warn "Some hooks failed to install. Check errors above."
  exit 1
fi

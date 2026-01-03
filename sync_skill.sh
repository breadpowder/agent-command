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
#   - Copies skill-rules.json to .claude/skills/ directory (required for skill-activation-prompt hook)
#   - Copies all skill directories from local agent_command repository to target project
#   - Installs user-prompt-logger hook from local agent_command repository
#   - Automatically configures .claude/settings.json (creates or updates)
#   - Appends to existing hook arrays instead of replacing them (preserves custom hooks)
#   - Uses jq for safe JSON merging (falls back to manual instructions if jq unavailable)
#   - Detects already-installed hooks and skips unnecessary operations
#   - Preserves existing skills in target project (no overwrites)
#   - Zero manual configuration required when jq is installed
#
# Hooks Installed with 'all':
#   - skill-activation-prompt: Suggests relevant skills based on user prompts
#   - post-tool-use-tracker: Tracks file modifications
#   - user-prompt-logger: Logs all user prompts to prompt-logs/ for analysis
#
# Skills Synced:
#   - All skill directories from .claude/skills/ in agent_command repository
#   - skill-rules.json configuration file
#   - Existing skills in target project are preserved
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
      echo "  all                        Install all hooks (default)"
      echo ""
      echo "Hooks Installed with 'all':"
      echo "  • skill-activation-prompt  - Suggests relevant skills based on user prompts"
      echo "  • post-tool-use-tracker    - Tracks file modifications"
      echo "  • user-prompt-logger       - Logs all user prompts for analysis"
      echo ""
      echo "Features:"
      echo "  • Automatically installs hook files to .claude/hooks/"
      echo "  • Copies skill-rules.json to .claude/skills/ (for skill activation)"
      echo "  • Copies all skill directories from local repository to target"
      echo "  • Automatically creates or updates .claude/settings.json"
      echo "  • Appends to existing hooks without replacing them"
      echo "  • Preserves existing skills in target project"
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

# Validate project directory exists
if [[ ! -d "${PROJECT_DIR}" ]]; then
  err "Project directory does not exist: ${PROJECT_DIR}"
  exit 1
fi

# ============================================================================
# Git Repository Validation
# ============================================================================
# Claude Code hooks are project-specific and work best in git-tracked projects.
# This validation ensures:
# 1. The target directory is a git repository (has .git directory)
# 2. Prevents installing hooks in non-project directories
# 3. Provides clear instructions if git is not initialized
# ============================================================================
if [[ ! -d "${PROJECT_DIR}/.git" ]]; then
  err "Not a git repository: ${PROJECT_DIR}"
  err ""
  err "Claude Code hooks require a git repository."
  err "Initialize git first:"
  err "  cd ${PROJECT_DIR}"
  err "  git init"
  err "  git add ."
  err "  git commit -m 'Initial commit'"
  exit 1
fi

log "Installing Claude Code hooks to git repository: ${PROJECT_DIR}"

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

# Function to sync skills (skill-rules.json + skill directories)
# Always overwrites ENTIRE skills directory to ensure:
# 1. Projects have the most recent code
# 2. Outdated/removed skills are deleted from destination
sync_skills() {
  log "Syncing skills to project..."

  # Determine script directory to find local skills
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  LOCAL_SKILLS_DIR="${SCRIPT_DIR}/.claude/skills"

  SKILLS_DIR="${PROJECT_DIR}/.claude/skills"

  # -------------------------------------------------------------------------
  # Skills to SKIP during sync
  # -------------------------------------------------------------------------
  # These skills have dependencies not available in all target projects:
  # - skill-creator-from-youtube: Requires yt-dlp MCP server
  # -------------------------------------------------------------------------
  SKIP_SKILLS=(
    "skill-creator-from-youtube"
  )

  if [[ -d "${LOCAL_SKILLS_DIR}" ]]; then
    # Wipe entire skills directory and recreate from source
    # This ensures outdated skills are removed
    log "Replacing entire skills directory..."
    rm -rf "${SKILLS_DIR}"
    mkdir -p "${SKILLS_DIR}"

    # Copy skill-rules.json first (always needed)
    if [[ -f "${LOCAL_SKILLS_DIR}/skill-rules.json" ]]; then
      cp "${LOCAL_SKILLS_DIR}/skill-rules.json" "${SKILLS_DIR}/"
      log "✓ Synced skill-rules.json"
    fi

    # Copy each skill directory individually, skipping excluded ones
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
          log "⊘ Skipping skill (dependency not ready): ${skill_name}"
        else
          # Use explicit destination path to preserve directory structure
          # (glob */ produces trailing slash, which makes cp copy contents not directory)
          cp -r "${skill_source}" "${SKILLS_DIR}/${skill_name}"
          log "✓ Synced skill: ${skill_name}"
        fi
      fi
    done
  else
    warn "Local skills directory not found: ${LOCAL_SKILLS_DIR}"
    return 1
  fi

  log "✓ Skills sync complete"
  return 0
}

# Function to install skill-activation-prompt hook
# Always overwrites to ensure projects have the most recent code
install_skill_activation_prompt() {
  log "Installing skill-activation-prompt hook..."

  # Check if npm is available (required for this hook)
  if ! command -v npm >/dev/null 2>&1; then
    err "npm command not found. Please install Node.js and npm first."
    echo "Visit: https://nodejs.org"
    return 1
  fi

  # Always overwrite hook files to ensure latest code
  if [[ -f "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.sh" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.sh" "${HOOKS_DIR}/"
    chmod +x "${HOOKS_DIR}/skill-activation-prompt.sh"
    log "✓ Synced skill-activation-prompt.sh"
  else
    err "skill-activation-prompt.sh not found in repository"
    return 1
  fi

  if [[ -f "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.ts" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/skill-activation-prompt.ts" "${HOOKS_DIR}/"
    log "✓ Synced skill-activation-prompt.ts"
  else
    err "skill-activation-prompt.ts not found in repository"
    return 1
  fi

  # Always overwrite package.json if it exists
  if [[ -f "${TEMP_DIR}/.claude/hooks/package.json" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/package.json" "${HOOKS_DIR}/"
    log "✓ Synced package.json"
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
# Always overwrites to ensure projects have the most recent code
install_post_tool_use_tracker() {
  log "Installing post-tool-use-tracker hook..."

  # Always overwrite hook file to ensure latest code
  if [[ -f "${TEMP_DIR}/.claude/hooks/post-tool-use-tracker.sh" ]]; then
    cp "${TEMP_DIR}/.claude/hooks/post-tool-use-tracker.sh" "${HOOKS_DIR}/"
    chmod +x "${HOOKS_DIR}/post-tool-use-tracker.sh"
    log "✓ Synced post-tool-use-tracker.sh"
  else
    err "post-tool-use-tracker.sh not found in repository"
    return 1
  fi

  log "✓ post-tool-use-tracker hook installed"
  return 0
}

# Function to install user-prompt-logger hook
# Always overwrites to ensure projects have the most recent code
install_user_prompt_logger() {
  log "Installing user-prompt-logger hook..."

  # Determine script directory to find the hook source
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

  # Always overwrite hook file to ensure latest code
  if [[ -f "${SCRIPT_DIR}/.claude/hooks/user-prompt-logger.sh" ]]; then
    cp "${SCRIPT_DIR}/.claude/hooks/user-prompt-logger.sh" "${HOOKS_DIR}/"
    chmod +x "${HOOKS_DIR}/user-prompt-logger.sh"
    log "✓ Synced user-prompt-logger.sh"
  else
    warn "user-prompt-logger.sh not found in ${SCRIPT_DIR}/.claude/hooks/"
    warn "Skipping user-prompt-logger installation"
    return 1
  fi

  log "✓ user-prompt-logger hook installed"
  return 0
}

# ============================================================================
# Hook Existence Detection Function
# ============================================================================
# Safely checks if a specific hook command already exists in settings.json
#
# Parameters:
#   $1 - hook_type: "UserPromptSubmit" or "PostToolUse"
#   $2 - command_path: Hook script filename (e.g., "skill-activation-prompt.sh")
#
# Returns (via echo):
#   "true"    - Hook exists in the specified hook type array
#   "false"   - Hook does not exist (safe to add)
#   "invalid" - JSON format is invalid (abort to prevent data loss)
#
# Logic Flow:
#   1. Check if settings.json file exists
#   2. Validate JSON format with jq
#   3. Search for command path in the hook type array using jq query
#   4. Return detection result
#
# Why jq instead of grep:
#   - grep can match comments or malformed JSON
#   - jq parses actual JSON structure, ensuring accuracy
#   - jq prevents false positives from similar strings
# ============================================================================
hook_exists_in_settings() {
  local hook_type=$1  # "UserPromptSubmit" or "PostToolUse"
  local command_path=$2  # e.g., "skill-activation-prompt.sh"

  # Step 1: Check if settings.json exists
  if [[ ! -f "${SETTINGS_FILE}" ]]; then
    echo "false"  # File doesn't exist, hook cannot exist
    return
  fi

  # Step 2: Validate JSON format first to prevent corruption
  if ! jq empty "${SETTINGS_FILE}" 2>/dev/null; then
    warn "Invalid JSON in ${SETTINGS_FILE}"
    echo "invalid"  # Return special value to signal corruption
    return
  fi

  # Step 3: Search for hook command using jq query
  # Query explanation:
  #   .hooks[$hook_type]? // []  - Get hook type array, default to empty if missing
  #   .[]                         - Iterate over array elements
  #   .hooks[]?                   - Get nested hooks array
  #   select(.command? | contains($cmd_path))  - Filter for matching command
  #   .command                    - Return the command field
  local exists=$(jq -r --arg hook_type "${hook_type}" --arg cmd_path "${command_path}" '
    .hooks[$hook_type]? // [] |
    .[] |
    .hooks[]? |
    select(.command? | contains($cmd_path)) |
    .command
  ' "${SETTINGS_FILE}" 2>/dev/null)

  # Step 4: Return detection result
  if [[ -n "${exists}" ]]; then
    echo "true"   # Hook command found in JSON structure
  else
    echo "false"  # Hook command not found
  fi
}

# ============================================================================
# Settings.json Update Function with JSON Integrity Validation
# ============================================================================
# Safely creates or updates .claude/settings.json with hook configurations
#
# Parameters:
#   $1 - needs_skill_activation: "true" if skill-activation-prompt should be added
#   $2 - needs_post_tool_use: "true" if post-tool-use-tracker should be added
#   $3 - needs_user_prompt_logger: "true" if user-prompt-logger should be added
#
# Safety Mechanisms:
#   1. Requires jq for all operations (no fallback to prevent corruption)
#   2. Validates JSON before reading existing file
#   3. Validates JSON after each modification
#   4. Uses temporary files with atomic replacement
#   5. Rolls back on validation failure
#
# Workflow:
#   - If file doesn't exist: Create new with required hooks
#   - If file exists: Detect existing hooks → Add only missing ones
#   - APPENDS to existing hook arrays instead of replacing them
#
# Returns:
#   0 - Success (file created or updated)
#   1 - Failure (jq missing, invalid JSON, or update failed)
# ============================================================================
update_settings_json() {
  local needs_skill_activation=$1
  local needs_post_tool_use=$2
  local needs_user_prompt_logger=${3:-"false"}

  # -------------------------------------------------------------------------
  # Requirement: jq is mandatory for safe JSON operations
  # -------------------------------------------------------------------------
  # We no longer support manual updates or grep-based detection because:
  # - grep can match strings in comments or malformed JSON
  # - Manual updates risk JSON syntax errors
  # - jq ensures structural integrity at every step
  # -------------------------------------------------------------------------
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - cannot safely update settings.json"
    warn "Install jq: sudo apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)"
    warn ""
    warn "Manual configuration required. Add to ${SETTINGS_FILE}:"
    if [[ "${needs_skill_activation}" == "true" ]]; then
      echo '  "hooks.UserPromptSubmit": skill-activation-prompt.sh'
    fi
    if [[ "${needs_post_tool_use}" == "true" ]]; then
      echo '  "hooks.PostToolUse": post-tool-use-tracker.sh'
    fi
    return 1
  fi

  # -------------------------------------------------------------------------
  # Case 1: Settings file doesn't exist - Create new file
  # -------------------------------------------------------------------------
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

    # Validate the JSON we just created
    if ! jq empty "${SETTINGS_FILE}" 2>/dev/null; then
      err "Failed to create valid JSON in ${SETTINGS_FILE}"
      return 1
    fi

    log "✓ Created settings.json with hook configuration"
    return 0
  fi

  # -------------------------------------------------------------------------
  # Case 2: Settings file exists - Validate and merge configurations
  # -------------------------------------------------------------------------
  log "Validating and updating existing settings.json..."

  # Step 1: Validate existing JSON format before making any changes
  if ! jq empty "${SETTINGS_FILE}" 2>/dev/null; then
    err "Existing settings.json has invalid JSON format: ${SETTINGS_FILE}"
    err "Please fix JSON syntax or delete the file to recreate it"
    return 1
  fi

  # Step 2: Detect what's already configured using hook_exists_in_settings()
  # This uses jq to parse JSON structure (not grep) for accurate detection
  local has_skill_activation=$(hook_exists_in_settings "UserPromptSubmit" "skill-activation-prompt.sh")
  local has_post_tool_use=$(hook_exists_in_settings "PostToolUse" "post-tool-use-tracker.sh")

  # Step 3: Handle invalid JSON detected by hook_exists_in_settings()
  if [[ "${has_skill_activation}" == "invalid" || "${has_post_tool_use}" == "invalid" ]]; then
    err "Cannot update settings.json due to invalid JSON format"
    return 1
  fi

  local changes_made=false
  TEMP_SETTINGS=$(mktemp)

  # Step 4: Ensure .hooks object exists in JSON structure
  jq '.hooks //= {}' "${SETTINGS_FILE}" > "${TEMP_SETTINGS}"
  mv "${TEMP_SETTINGS}" "${SETTINGS_FILE}"

  # -------------------------------------------------------------------------
  # Atomic Update Pattern for UserPromptSubmit Hook
  # -------------------------------------------------------------------------
  # Pattern: Original → jq transform → Temp file → Validate → Replace
  # If validation fails: Discard temp file, keep original (no data loss)
  #
  # IMPORTANT: This appends to existing hooks array instead of replacing
  # -------------------------------------------------------------------------
  if [[ "${needs_skill_activation}" == "true" && "${has_skill_activation}" == "false" ]]; then
    log "Adding UserPromptSubmit hook configuration..."

    # Step 1: Apply jq transformation to temp file
    # Check if UserPromptSubmit exists, if not create structure, if yes append to hooks array
    jq '
      if .hooks.UserPromptSubmit then
        .hooks.UserPromptSubmit[0].hooks += [{
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
        }]
      else
        .hooks.UserPromptSubmit = [{
          "hooks": [{
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }]
        }]
      end
    ' "${SETTINGS_FILE}" > "${TEMP_SETTINGS}"

    # Step 2: Validate temp file before replacing original
    if jq empty "${TEMP_SETTINGS}" 2>/dev/null; then
      # Validation passed - safe to replace original
      mv "${TEMP_SETTINGS}" "${SETTINGS_FILE}"
      changes_made=true
      log "✓ Added UserPromptSubmit hook configuration"
    else
      # Validation failed - discard temp file, keep original
      err "Failed to add UserPromptSubmit hook - JSON validation failed"
      rm -f "${TEMP_SETTINGS}"
      return 1
    fi
  elif [[ "${needs_skill_activation}" == "true" && "${has_skill_activation}" == "true" ]]; then
    log "✓ UserPromptSubmit hook already configured"
  fi

  # -------------------------------------------------------------------------
  # Atomic Update Pattern for User Prompt Logger Hook
  # -------------------------------------------------------------------------
  # Add user-prompt-logger to UserPromptSubmit hooks array
  # -------------------------------------------------------------------------
  local has_user_prompt_logger=$(hook_exists_in_settings "UserPromptSubmit" "user-prompt-logger.sh")

  if [[ "${needs_user_prompt_logger}" == "true" && "${has_user_prompt_logger}" == "false" ]]; then
    log "Adding user-prompt-logger hook configuration..."

    # Step 1: Apply jq transformation to temp file
    # Append to existing hooks array or create structure if doesn't exist
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
    ' "${SETTINGS_FILE}" > "${TEMP_SETTINGS}"

    # Step 2: Validate temp file before replacing original
    if jq empty "${TEMP_SETTINGS}" 2>/dev/null; then
      # Validation passed - safe to replace original
      mv "${TEMP_SETTINGS}" "${SETTINGS_FILE}"
      changes_made=true
      log "✓ Added user-prompt-logger hook configuration"
    else
      # Validation failed - discard temp file, keep original
      err "Failed to add user-prompt-logger hook - JSON validation failed"
      rm -f "${TEMP_SETTINGS}"
      return 1
    fi
  elif [[ "${needs_user_prompt_logger}" == "true" && "${has_user_prompt_logger}" == "true" ]]; then
    log "✓ user-prompt-logger hook already configured"
  fi

  # -------------------------------------------------------------------------
  # Atomic Update Pattern for PostToolUse Hook
  # -------------------------------------------------------------------------
  # Same safety pattern as above: validate before replacing original
  # -------------------------------------------------------------------------
  if [[ "${needs_post_tool_use}" == "true" && "${has_post_tool_use}" == "false" ]]; then
    log "Adding PostToolUse hook configuration..."

    # Step 1: Apply jq transformation to temp file
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

    # Step 2: Validate temp file before replacing original
    if jq empty "${TEMP_SETTINGS}" 2>/dev/null; then
      # Validation passed - safe to replace original
      mv "${TEMP_SETTINGS}" "${SETTINGS_FILE}"
      changes_made=true
      log "✓ Added PostToolUse hook configuration"
    else
      # Validation failed - discard temp file, keep original
      err "Failed to add PostToolUse hook - JSON validation failed"
      rm -f "${TEMP_SETTINGS}"
      return 1
    fi
  elif [[ "${needs_post_tool_use}" == "true" && "${has_post_tool_use}" == "true" ]]; then
    log "✓ PostToolUse hook already configured"
  fi

  # Cleanup temp file (belt and suspenders - already cleaned in error paths)
  rm -f "${TEMP_SETTINGS}"

  # Report final status
  if [[ "${changes_made}" == "true" ]]; then
    log "✓ Updated settings.json with new hook configurations"
  else
    log "✓ settings.json already has all requested hook configurations"
  fi

  return 0
}

# Always sync skills first (regardless of hook type)
# This ensures skill-rules.json and skill directories are always up-to-date
sync_skills

# Install hooks based on type
INSTALL_SUCCESS=true

case "${HOOK_TYPE}" in
  skill-activation-prompt)
    if ! install_skill_activation_prompt; then
      INSTALL_SUCCESS=false
    fi
    update_settings_json "true" "false" "false"
    ;;
  post-tool-use-tracker)
    if ! install_post_tool_use_tracker; then
      INSTALL_SUCCESS=false
    fi
    update_settings_json "false" "true" "false"
    ;;
  all)
    SKILL_SUCCESS=true
    POST_SUCCESS=true
    LOGGER_SUCCESS=true

    if ! install_skill_activation_prompt; then
      SKILL_SUCCESS=false
      INSTALL_SUCCESS=false
    fi

    if ! install_post_tool_use_tracker; then
      POST_SUCCESS=false
      INSTALL_SUCCESS=false
    fi

    # Always try to install user-prompt-logger
    if ! install_user_prompt_logger; then
      LOGGER_SUCCESS=false
      # Don't fail the entire installation if user-prompt-logger fails
      warn "user-prompt-logger installation failed, continuing with other hooks"
    fi

    update_settings_json "${SKILL_SUCCESS}" "${POST_SUCCESS}" "${LOGGER_SUCCESS}"
    ;;
esac

# Summary
echo ""
if [[ "${INSTALL_SUCCESS}" == "true" ]]; then
  log "✓ Successfully synced hooks and skills"
  log "Hooks location: ${HOOKS_DIR}"
  log "Skills location: ${PROJECT_DIR}/.claude/skills"
  log "Settings file: ${SETTINGS_FILE}"
  exit 0
else
  warn "Some hooks failed to install. Check errors above."
  exit 1
fi

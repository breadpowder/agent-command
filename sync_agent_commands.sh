#!/usr/bin/env bash
set -euo pipefail

# Sync AgentDK command specs to local agent prompt directories.
#
# Usage:
#   sync_agent_commands.sh [SOURCE_DIR|--github] [--install-deps]
#
# Options:
#   --github                Clone from GitHub repo and sync from there
#   --install-deps          Install required CLI tools (ripgrep, fd/fdfind, jq)
#   SOURCE_DIR              Use explicit local directory path
#   (no args)               Use <repo_root>/commands (relative to script location)
#
# GitHub Repository: https://github.com/breadpowder/agent-command
#
# Destinations:
#   - ${HOME}/.claude/commands
#   - ${HOME}/.codex/prompts
#   - ${HOME}/.claude/CLAUDE.md (from USER_LEVEL_CLAUDE.md)

log() { printf "[sync] %s\n" "$*"; }
err() { printf "[sync][error] %s\n" "$*" >&2; }
warn() { printf "[sync][warn] %s\n" "$*" >&2; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEFAULT_ABS_SOURCE="${SCRIPT_DIR}/commands"
GITHUB_REPO="https://github.com/breadpowder/agent-command.git"
TEMP_CLONE_DIR=""
INSTALL_DEPS=false

# Cleanup function for temporary directory
cleanup() {
  if [[ -n "${TEMP_CLONE_DIR}" && -d "${TEMP_CLONE_DIR}" ]]; then
    log "Cleaning up temporary clone directory: ${TEMP_CLONE_DIR}"
    rm -rf "${TEMP_CLONE_DIR}"
  fi
}
trap cleanup EXIT

# Handle help and options
case "${1:-}" in
  --help|-h|help)
    echo "Sync AgentDK command specs to local agent prompt directories."
    echo ""
    echo "Usage: sync_agent_commands.sh [SOURCE_DIR|--github] [--install-deps]"
    echo ""
    echo "Options:"
    echo "  --github              Clone from GitHub repo and sync from there"
    echo "  --install-deps        Install ripgrep, fd/fdfind, jq based on OS"
    echo "  SOURCE_DIR            Use explicit local directory path"
    echo "  (no arguments)        Use <repo_root>/commands (relative to script)"
    echo ""
    echo "GitHub Repository: ${GITHUB_REPO}"
    echo ""
    echo "Destinations:"
    echo "  - \${HOME}/.claude/commands"
    echo "  - \${HOME}/.codex/prompts"
    echo "  - \${HOME}/.claude/CLAUDE.md (from USER_LEVEL_CLAUDE.md)"
    echo ""
    echo "Note: sdlc_* commands are excluded (replaced by subagents)."
    echo "Use sync_sdlc_agents.sh to sync SDLC agents instead."
    echo ""
    echo "Additional Setup:"
    echo "  - Context7 MCP server installation guidance (requires API key)"
    echo "  - MCP server configuration for Codex CLI (if available)"
    echo ""
    echo "Examples:"
    echo "  sync_agent_commands.sh                           # Use local commands/"
    echo "  sync_agent_commands.sh --github                  # Clone from GitHub"
    echo "  sync_agent_commands.sh --install-deps           # Install tools"
    echo "  sync_agent_commands.sh /path/to/commands         # Use custom path"
    exit 0
    ;;
  --github)
    USE_GITHUB=true
    ;;
  *)
    USE_GITHUB=false
    ;;
esac

# Optional argument: --install-deps (accept in either position)
if [[ "${2:-}" == "--install-deps" || "${1:-}" == "--install-deps" ]]; then
  INSTALL_DEPS=true
fi

# Support --github passed as the second argument (after --install-deps)
if [[ "${2:-}" == "--github" ]]; then
  USE_GITHUB=true
fi

# Detect OS and package manager for optional installs
detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
    return 0
  fi
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID_LIKE:-$ID}" in
      *debian*|*ubuntu*|debian|ubuntu)
        echo "debian"
        return 0
        ;;
    esac
  fi
  echo "unknown"
}

ensure_fd_alias() {
  # On Debian/Ubuntu, fd is installed as fdfind; create a user-level shim if needed
  if command -v fd >/dev/null 2>&1; then
    return 0
  fi
  if command -v fdfind >/dev/null 2>&1; then
    local target
    target="$(command -v fdfind)"
    mkdir -p "${HOME}/.local/bin"
    if [[ ! -e "${HOME}/.local/bin/fd" ]]; then
      ln -s "${target}" "${HOME}/.local/bin/fd"
      log "Created user-level symlink: ${HOME}/.local/bin/fd -> ${target}"
    fi
    case ":${PATH}:" in
      *":${HOME}/.local/bin:"*) : ;;
      *)
        warn "~/.local/bin not in PATH. Add: export PATH=\"${HOME}/.local/bin:\$PATH\""
        ;;
    esac
  fi
}

install_deps() {
  local os
  os="$(detect_os)"
  case "${os}" in
    macos)
      if ! command -v brew >/dev/null 2>&1; then
        err "Homebrew not found. Install from https://brew.sh then re-run with --install-deps"
        return 1
      fi
      log "Installing ripgrep, fd, jq via Homebrew"
      brew install ripgrep fd jq || {
        err "brew install failed"
        return 1
      }
      ;;
    debian)
      if ! command -v sudo >/dev/null 2>&1; then
        warn "sudo not found; attempting apt without sudo (may fail)"
        log "Running: apt update && apt install -y ripgrep fd-find jq"
        apt update && apt install -y ripgrep fd-find jq || {
          err "apt install failed"
          return 1
        }
      else
        log "Installing ripgrep, fd-find, jq via apt"
        sudo apt update && sudo apt install -y ripgrep fd-find jq || {
          err "apt install failed"
          return 1
        }
      fi
      ensure_fd_alias
      ;;
    *)
      warn "Unknown OS. Please install manually:"
      echo "  macOS: brew install ripgrep fd jq"
      echo "  Debian/Ubuntu: sudo apt update && sudo apt install -y ripgrep fd-find jq"
      echo "  Then ensure \"fd\" is available (alias/symlink to fdfind)."
      return 1
      ;;
  esac
  log "Dependency installation complete"
}

# Handle GitHub clone option
if [[ "${USE_GITHUB}" == "true" ]]; then
  log "Cloning from GitHub repository: ${GITHUB_REPO}"
  
  # Check if git is available
  if ! command -v git >/dev/null 2>&1; then
    err "git command not found. Please install git or use a local source directory."
    exit 1
  fi
  
  # Create temporary directory
  TEMP_CLONE_DIR=$(mktemp -d)
  log "Using temporary directory: ${TEMP_CLONE_DIR}"
  
  # Clone the repository
  if ! git clone --depth 1 --quiet "${GITHUB_REPO}" "${TEMP_CLONE_DIR}/agent-command" 2>/dev/null; then
    err "Failed to clone repository from ${GITHUB_REPO}"
    err "Please check your internet connection and try again, or use a local source directory."
    exit 1
  fi
  
  SOURCE_DIR="${TEMP_CLONE_DIR}/agent-command/commands"
  USER_LEVEL_CLAUDE_FILE="${TEMP_CLONE_DIR}/agent-command/USER_LEVEL_CLAUDE.md"
  log "Successfully cloned repository"
else
  # Use provided directory or default local directory
  SOURCE_DIR="${1:-${DEFAULT_ABS_SOURCE}}"
  USER_LEVEL_CLAUDE_FILE="${SCRIPT_DIR}/USER_LEVEL_CLAUDE.md"
fi

# Validate source directory exists
if [[ ! -d "${SOURCE_DIR}" ]]; then
  err "Source directory not found: ${SOURCE_DIR}"
  if [[ "${USE_GITHUB}" == "true" ]]; then
    err "Repository may not contain a 'commands' directory"
  else
    err "Usage: sync_agent_commands.sh [SOURCE_DIR|--github] [--install-deps]"
    err "  --github: Clone from GitHub and sync"
    err "  SOURCE_DIR: Provide explicit path to commands directory"
    err "Use --help for more information"
  fi
  exit 1
fi

CLAUDE_DIR="${HOME}/.claude/commands"
CODEX_DIR="${HOME}/.codex/prompts"

mkdir -p "${CLAUDE_DIR}" "${CODEX_DIR}"

copy_to() {
  local src="$1" dest="$2"
  # Wipe destination and replace from source
  # This ensures outdated files are removed
  rm -rf "${dest}"
  mkdir -p "${dest}"
  if command -v rsync >/dev/null 2>&1; then
    # Trailing slash copies contents of src into dest
    # Exclude sdlc_* commands (replaced by subagents)
    rsync -av --exclude='sdlc_*.md' "${src}/" "${dest}/"
  else
    # cp fallback; "." includes hidden files in src
    cp -a "${src}/." "${dest}/"
    # Remove sdlc_* commands (replaced by subagents)
    find "${dest}" -name 'sdlc_*.md' -type f -delete 2>/dev/null || true
  fi
}

# Optionally install dependencies before syncing
if [[ "${INSTALL_DEPS}" == "true" ]]; then
  log "--install-deps requested"
  install_deps || warn "Dependency installation encountered issues; continuing sync"
fi

# Count files to be synced (prefer ripgrep if available)
# Exclude sdlc_* commands (replaced by subagents)
if command -v rg >/dev/null 2>&1; then
  file_count=$(rg --files -g '*.md' -g '!sdlc_*.md' "${SOURCE_DIR}" | wc -l)
  skipped_count=$(rg --files -g 'sdlc_*.md' "${SOURCE_DIR}" | wc -l)
else
  file_count=$(find "${SOURCE_DIR}" -name "*.md" ! -name "sdlc_*.md" | wc -l)
  skipped_count=$(find "${SOURCE_DIR}" -name "sdlc_*.md" | wc -l)
fi
log "Found ${file_count} command files in: ${SOURCE_DIR}"
if [[ "${skipped_count}" -gt 0 ]]; then
  log "Skipping ${skipped_count} sdlc_* commands (replaced by subagents)"
fi

log "-> Syncing to Claude: ${CLAUDE_DIR}"
copy_to "${SOURCE_DIR}" "${CLAUDE_DIR}"
log "✓ Synced to ${CLAUDE_DIR}"

log "-> Syncing to Codex: ${CODEX_DIR}"
copy_to "${SOURCE_DIR}" "${CODEX_DIR}"
log "✓ Synced to ${CODEX_DIR}"

# Handle USER_LEVEL_CLAUDE.md - add to project CLAUDE.md if user-level exists
if [[ -f "${USER_LEVEL_CLAUDE_FILE}" ]]; then
  if [[ -f "${HOME}/.claude/CLAUDE.md" ]]; then
    log "Existing user-level CLAUDE.md found at ${HOME}/.claude/CLAUDE.md"
    echo -n "Add USER_LEVEL_CLAUDE.md to current project CLAUDE.md instead? [y/N]: "
    read -r choice
    choice_lower=$(echo "${choice}" | tr '[:upper:]' '[:lower:]')
    case "${choice_lower}" in
      y|yes)
        PROJECT_CLAUDE="${SCRIPT_DIR}/../CLAUDE.md"
        log "-> Adding USER_LEVEL_CLAUDE.md to project CLAUDE.md at ${PROJECT_CLAUDE}"
        if [[ -f "${PROJECT_CLAUDE}" ]]; then
          echo "" >> "${PROJECT_CLAUDE}"
          echo "# === PROJECT-SPECIFIC PYTHON STANDARDS ===" >> "${PROJECT_CLAUDE}"
          echo "" >> "${PROJECT_CLAUDE}"
          cat "${USER_LEVEL_CLAUDE_FILE}" >> "${PROJECT_CLAUDE}"
          log "✓ Appended USER_LEVEL_CLAUDE.md to project CLAUDE.md"
        else
          cp "${USER_LEVEL_CLAUDE_FILE}" "${PROJECT_CLAUDE}"
          log "✓ Created project CLAUDE.md with USER_LEVEL_CLAUDE.md content"
        fi
        ;;
      *)
        log "Skipping project CLAUDE.md update (user choice)"
        ;;
    esac
  else
    log "-> Copying USER_LEVEL_CLAUDE.md to ~/.claude/CLAUDE.md"
    cp "${USER_LEVEL_CLAUDE_FILE}" "${HOME}/.claude/CLAUDE.md"
    log "✓ Copied USER_LEVEL_CLAUDE.md to ${HOME}/.claude/CLAUDE.md"
  fi
else
  warn "USER_LEVEL_CLAUDE.md not found at: ${USER_LEVEL_CLAUDE_FILE}"
fi

if [[ "${USE_GITHUB}" == "true" ]]; then
  log "✓ Successfully synced ${file_count} commands from GitHub repository"
else
  log "✓ Successfully synced ${file_count} commands from local directory"
fi
log "Commands and user-level CLAUDE.md are now available for AI agents."

# Setup codex profiles (macOS only - uses sandbox-exec -p <profile>)
setup_codex_profiles() {
  # Only setup profiles on macOS where Codex uses sandbox-exec -p <profile>
  # On Linux, Codex uses kernel sandboxing (Landlock + seccomp) directly
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "Skipping codex profiles setup (not macOS - Linux uses kernel sandboxing directly)"
    return 0
  fi
  
  local config_file="${HOME}/.codex/config.toml"
  local temp_file="${config_file}.tmp"
  
  # Create .codex directory if it doesn't exist
  mkdir -p "${HOME}/.codex"
  
  # Touch config file if it doesn't exist
  if [[ ! -f "${config_file}" ]]; then
    touch "${config_file}"
  fi
  
  # Check if each profile exists and add if missing
  local profiles_to_add=()
  
  # Check for [profiles.safe]
  if ! grep -q "^\[profiles\.safe\]" "${config_file}"; then
    profiles_to_add+=("safe")
  fi
  
  # Check for [profiles.default]
  if ! grep -q "^\[profiles\.default\]" "${config_file}"; then
    profiles_to_add+=("default")
  fi
  
  # Check for [profiles.danger]
  if ! grep -q "^\[profiles\.danger\]" "${config_file}"; then
    profiles_to_add+=("danger")
  fi
  
  # If no profiles need to be added, return
  if [[ ${#profiles_to_add[@]} -eq 0 ]]; then
    log "All codex profiles already exist in ${config_file}"
    return 0
  fi
  
  log "Adding missing codex profiles: ${profiles_to_add[*]}"
  
  # Copy existing content to temp file
  cp "${config_file}" "${temp_file}"
  
  # Add missing profiles
  for profile in "${profiles_to_add[@]}"; do
    case "${profile}" in
      safe)
        cat >> "${temp_file}" << 'EOF'

[profiles.safe]
sandbox_mode = "read_only"
approval_policy = "on-request"
EOF
        ;;
      default)
        cat >> "${temp_file}" << 'EOF'

[profiles.default]
sandbox_mode = "workspace-write"
approval_policy = "on-request"
EOF
        ;;
      danger)
        cat >> "${temp_file}" << 'EOF'

[profiles.danger]
sandbox_mode = "danger-full-access"
approval_policy = "never"
EOF
        ;;
    esac
  done
  
  # Replace original with updated file
  mv "${temp_file}" "${config_file}"
  log "✓ Updated ${config_file} with missing profiles"
}

# Setup codex profiles
setup_codex_profiles

# Setup Codex MCP configuration
setup_codex_mcp() {
  # Check if Codex CLI is available
  if ! command -v codex >/dev/null 2>&1; then
    log "Codex CLI not available - skipping MCP setup"
    return 0
  fi
  
  local config_file="${HOME}/.codex/config.toml"
  
  # Create .codex directory if it doesn't exist
  mkdir -p "${HOME}/.codex"
  
  # Touch config file if it doesn't exist
  if [[ ! -f "${config_file}" ]]; then
    touch "${config_file}"
  fi
  
  # Track if any configurations were added
  local configs_added=false
  
  # Setup Context7 MCP server configuration
  if ! grep -q "^\\[mcp_servers\\.context7\\]" "${config_file}"; then
    # Prompt for API key
    echo ""
    echo "Codex CLI Context7 MCP Setup:"
    echo "Visit https://github.com/upstash/context7 to get your API key."
    echo ""
    echo -n "Enter your Context7 API key for Codex CLI (or press Enter to skip): "
    read -r api_key
    
    if [[ -n "${api_key}" ]]; then
      # Append Context7 MCP configuration
      log "Adding Context7 MCP configuration to Codex..."
      echo "" >> "${config_file}"
      echo "[mcp_servers.context7]" >> "${config_file}"
      echo "args = [\"-y\", \"@upstash/context7-mcp\", \"--api-key\", \"${api_key}\"]" >> "${config_file}"
      echo "command = \"npx\"" >> "${config_file}"
      log "✓ Successfully configured Context7 MCP server for Codex CLI"
      configs_added=true
    else
      echo ""
      echo "Manual installation instructions for Context7 on Codex CLI:"
      echo "Add the following to ${config_file}:"
      echo ""
      echo "[mcp_servers.context7]"
      echo "args = [\"-y\", \"@upstash/context7-mcp\", \"--api-key\", \"YOUR_API_KEY\"]"
      echo "command = \"npx\""
      echo ""
    fi
  else
    log "✓ Context7 MCP server already configured for Codex CLI"
  fi

  if [[ "${configs_added}" == "false" ]]; then
    log "All MCP servers already configured for Codex CLI"
  fi
}

# Call the new MCP setup function
setup_codex_mcp

# Legacy setup function (kept for backward compatibility)
setup_codex_mcp_config() {
  local config_file="${HOME}/.codex/config.toml"
  
  # Check if Codex CLI is available
  if ! command -v codex >/dev/null 2>&1; then
    echo ""
    echo "Codex CLI Setup (Optional):"
    echo "If you plan to use Codex CLI, install it first and then add MCP server configurations."
    echo ""
    return 0
  fi
  
  # Create .codex directory if it doesn't exist
  mkdir -p "${HOME}/.codex"
  
  # Touch config file if it doesn't exist
  if [[ ! -f "${config_file}" ]]; then
    touch "${config_file}"
  fi
  
  # Check if Context7 MCP server configuration exists
  if grep -q "^\[mcp_servers\.context7\]" "${config_file}"; then
    log "Context7 MCP server already configured in ${config_file}"
    return 0
  fi
  
  echo ""
  echo "Codex CLI MCP Setup:"
  echo "Add the following configuration to ${config_file}:"
  echo ""
  echo "# Context7 MCP server (requires API key)"
  echo "[mcp_servers.context7]"
  echo "args = [\"-y\", \"@upstash/context7-mcp\", \"--api-key\", \"YOUR_API_KEY\"]"
  echo "command = \"npx\""
  echo ""
  echo "Replace YOUR_API_KEY with your actual Context7 API key."
  echo ""
  
  # Optionally add the configuration automatically (commented out for user control)
  # echo "" >> "${config_file}"
  # echo "[mcp_servers.context7]" >> "${config_file}"
  # echo "args = [\"-y\", \"@upstash/context7-mcp\", \"--api-key\", \"YOUR_API_KEY\"]" >> "${config_file}"
  # echo "command = \"npx\"" >> "${config_file}"
  # log "✓ Added Context7 MCP configuration to ${config_file} (update YOUR_API_KEY)"
}

# Install Context7 MCP server with user interaction
install_context7_mcp() {
  log "Setting up Context7 MCP server"
  
  # Check if Claude Code CLI is available
  if ! command -v claude >/dev/null 2>&1; then
    warn "Claude Code CLI not found. Install Claude Code CLI first:"
    echo "  Visit: https://claude.ai/code for installation instructions"
    echo ""
    return 1
  fi
  
  # Check if context7 MCP server already exists
  if claude mcp list 2>/dev/null | grep -q "context7"; then
    log "✓ Context7 MCP server already installed"
    return 0
  fi
  
  # Prompt for API key
  echo ""
  echo "Context7 MCP Server Setup:"
  echo "Visit https://github.com/upstash/context7 to get your API key."
  echo ""
  echo -n "Enter your Context7 API key (or press Enter to skip): "
  read -r api_key
  
  if [[ -z "${api_key}" ]]; then
    echo ""
    echo "Manual installation instructions:"
    echo "  claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp --header \"CONTEXT7_API_KEY: YOUR_API_KEY\""
    echo ""
    return 0
  fi
  
  # Install Context7 MCP server for Claude Code CLI
  log "Installing Context7 MCP server..."
  if claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: ${api_key}" 2>/dev/null; then
    log "✓ Successfully installed Context7 MCP server"
  else
    err "Failed to install Context7 MCP server"
    echo "Try manual installation:"
    echo "  claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp --header \"CONTEXT7_API_KEY: ${api_key}\""
  fi
  
}

# Install Context7 MCP server
install_context7_mcp

# Install skill-activation-prompt hook to current project
log "Installing skill-activation-prompt hook..."
if [[ -x "${SCRIPT_DIR}/sync_skill.sh" ]]; then
  "${SCRIPT_DIR}/sync_skill.sh" --project-dir "${PWD}" || warn "Failed to install skill-activation-prompt hook"
else
  warn "sync_skill.sh not found or not executable at: ${SCRIPT_DIR}/sync_skill.sh"
  warn "Skipping skill-activation-prompt installation"
fi

# Helpful guidance for agent CLI usage (tooling best practices)
cat <<'EOF'
[sync] Tips for local CLI usage:
- Prefer ripgrep and fd over legacy tools:
  - grep -> rg
  - find -> rg --files / fd
  - ls -R -> rg --files
  - cat file | grep pattern -> rg pattern file
- Cap file reads at 250 lines; use: rg -n -A 3 -B 3 for context
- Use jq for JSON parsing instead of regex
EOF

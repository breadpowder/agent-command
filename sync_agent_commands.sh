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
  if command -v rsync >/dev/null 2>&1; then
    # Trailing slash copies contents of src into dest
    # Use -v for verbose output on older rsync versions (macOS default)
    rsync -av "${src}/" "${dest}/"
  else
    # cp fallback; "." includes hidden files in src
    cp -a "${src}/." "${dest}/"
  fi
}

# Optionally install dependencies before syncing
if [[ "${INSTALL_DEPS}" == "true" ]]; then
  log "--install-deps requested"
  install_deps || warn "Dependency installation encountered issues; continuing sync"
fi

# Count files to be synced (prefer ripgrep if available)
if command -v rg >/dev/null 2>&1; then
  file_count=$(rg --files -g '*.md' "${SOURCE_DIR}" | wc -l)
else
  file_count=$(find "${SOURCE_DIR}" -name "*.md" | wc -l)
fi
log "Found ${file_count} command files in: ${SOURCE_DIR}"

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

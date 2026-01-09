#!/usr/bin/env bash
set -euo pipefail

# Sync Claude Code sub-agent definitions to user-level config
#
# Usage:
#   sync_sub_agents.sh [OPTIONS]
#
# Options:
#   --help, -h              Show this help message
#   --agent NAME            Sync specific agent by name (default: all)
#   --list                  List available agents without syncing
#   --github                Clone from GitHub repo (default: uses local cache)
#   --project-level         Sync to project .claude/agents/ instead of user-level
#   --project-dir DIR       Specify project directory (requires --project-level)
#
# Features:
#   - Syncs agent definitions to ~/.claude/agents/ (user-level, default)
#   - Agents are available globally across all projects
#   - Caches repository locally for faster subsequent syncs
#   - Optional project-level sync with --project-level flag
#
# Requirements:
#   - git (required)
#
# Examples:
#   sync_sub_agents.sh                              # Sync all agents to ~/.claude/agents/
#   sync_sub_agents.sh --list                       # List available agents
#   sync_sub_agents.sh --agent code-reviewer       # Sync only code-reviewer agent
#   sync_sub_agents.sh --github                    # Force clone from GitHub
#   sync_sub_agents.sh --project-level             # Sync to current project's .claude/agents/
#   sync_sub_agents.sh --project-level --project-dir /path/to/project

log() { printf "[sync_agents] %s\n" "$*" >&2; }
err() { printf "[sync_agents][error] %s\n" "$*" >&2; }
warn() { printf "[sync_agents][warn] %s\n" "$*" >&2; }

# Default values
USER_LEVEL_DIR="${HOME}/.claude/agents"
PROJECT_DIR="${PWD}"
PROJECT_LEVEL=false
AGENT_NAME=""
LIST_ONLY=false
FORCE_GITHUB=false

# GitHub repository
GITHUB_REPO="https://github.com/breadpowder/claude-code-infrastructure-showcase.git"
CACHE_DIR="${HOME}/.cache/claude-code-showcase"
TEMP_DIR=""

# Cleanup function
cleanup() {
  if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
}
trap cleanup EXIT

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h|help)
      echo "Sync Claude Code sub-agent definitions to local project"
      echo ""
      echo "Usage: sync_sub_agents.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h              Show this help message"
      echo "  --agent NAME            Sync specific agent by name (default: all)"
      echo "  --list                  List available agents without syncing"
      echo "  --github                Force clone from GitHub (default: uses cached repo)"
      echo "  --project-level         Sync to project .claude/agents/ instead of user-level"
      echo "  --project-dir DIR       Specify project directory (requires --project-level)"
      echo ""
      echo "Features:"
      echo "  • Syncs agent definitions to ~/.claude/agents/ (user-level, default)"
      echo "  • User-level agents are available globally across all projects"
      echo "  • Caches repository locally for faster syncing"
      echo "  • Supports syncing individual or all agents"
      echo "  • Optional project-level sync with --project-level flag"
      echo ""
      echo "Requirements:"
      echo "  • git (required)"
      echo ""
      echo "Examples:"
      echo "  sync_sub_agents.sh                              # Sync all agents to ~/.claude/agents/"
      echo "  sync_sub_agents.sh --list                       # List available agents"
      echo "  sync_sub_agents.sh --agent code-reviewer       # Sync only code-reviewer agent"
      echo "  sync_sub_agents.sh --github                    # Force fresh clone from GitHub"
      echo "  sync_sub_agents.sh --project-level             # Sync to current project's .claude/agents/"
      echo "  sync_sub_agents.sh --project-level --project-dir /path/to/project"
      exit 0
      ;;
    --project-level)
      PROJECT_LEVEL=true
      shift
      ;;
    --project-dir)
      shift
      PROJECT_DIR="$1"
      shift
      ;;
    --agent)
      shift
      AGENT_NAME="$1"
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --github)
      FORCE_GITHUB=true
      shift
      ;;
    *)
      err "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validate --project-dir requires --project-level
if [[ "${PROJECT_DIR}" != "${PWD}" && "${PROJECT_LEVEL}" == "false" ]]; then
  err "--project-dir requires --project-level flag"
  echo "Use: sync_sub_agents.sh --project-level --project-dir ${PROJECT_DIR}"
  exit 1
fi

# Validate project directory (only for project-level sync)
if [[ "${PROJECT_LEVEL}" == "true" && "${LIST_ONLY}" == "false" && ! -d "${PROJECT_DIR}" ]]; then
  err "Project directory does not exist: ${PROJECT_DIR}"
  exit 1
fi

# Determine target directory
if [[ "${PROJECT_LEVEL}" == "true" ]]; then
  TARGET_DIR="${PROJECT_DIR}/.claude/agents"
else
  TARGET_DIR="${USER_LEVEL_DIR}"
fi

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
  err "git command not found. Please install git first."
  exit 1
fi

# Function to clone or update repository
get_repository() {
  local use_cache=true

  if [[ "${FORCE_GITHUB}" == "true" ]]; then
    use_cache=false
    log "Forcing fresh clone from GitHub..."
  elif [[ -d "${CACHE_DIR}/.git" ]]; then
    log "Using cached repository at: ${CACHE_DIR}"
    log "Updating cached repository..."
    cd "${CACHE_DIR}" || return 1
    if ! git pull --quiet 2>/dev/null; then
      warn "Failed to update cached repository, re-cloning..."
      cd - >/dev/null || return 1
      rm -rf "${CACHE_DIR}"
      use_cache=false
    else
      cd - >/dev/null || return 1
    fi
  else
    use_cache=false
    log "No cached repository found, cloning..."
  fi

  if [[ "${use_cache}" == "false" ]]; then
    log "Cloning claude-code-infrastructure-showcase repository..."
    rm -rf "${CACHE_DIR}"
    mkdir -p "$(dirname "${CACHE_DIR}")"
    if ! git clone --depth 1 --quiet "${GITHUB_REPO}" "${CACHE_DIR}" 2>/dev/null; then
      err "Failed to clone repository"
      err "Please check your internet connection and try again"
      return 1
    fi
    log "✓ Repository cloned to cache"
  fi

  echo "${CACHE_DIR}"
}

# Function to extract description from YAML frontmatter
extract_description() {
  local file="$1"
  local in_frontmatter=false
  local in_description=false
  local description=""

  while IFS= read -r line; do
    # Check for frontmatter delimiters
    if [[ "$line" == "---" ]]; then
      if [[ "$in_frontmatter" == "false" ]]; then
        in_frontmatter=true
        continue
      else
        # End of frontmatter
        break
      fi
    fi

    if [[ "$in_frontmatter" == "true" ]]; then
      # Check for description field
      if [[ "$line" =~ ^description:[[:space:]]* ]]; then
        in_description=true
        # Extract description value (everything after "description: ")
        description="${line#description:*([[:space:]])}"
        # Remove quotes if present
        description="${description%\"}"
        description="${description#\"}"
        # Extract first sentence or up to 100 chars
        description=$(echo "$description" | sed 's/\\n.*//' | cut -c1-100)
        break
      fi
    fi
  done < "$file"

  echo "$description"
}

# Function to list available agents
list_agents() {
  local repo_dir="$1"
  local agents_dir="${repo_dir}/.claude/agents"

  if [[ ! -d "${agents_dir}" ]]; then
    warn "No agents directory found in repository: ${agents_dir}"
    return 1
  fi

  log "Available agents:"
  echo ""

  # List all .md files in agents directory (excluding README)
  local agent_count=0
  while IFS= read -r -d '' agent_file; do
    local agent_name=$(basename "${agent_file}" .md)

    # Skip README
    if [[ "${agent_name}" == "README" ]]; then
      continue
    fi

    agent_count=$((agent_count + 1))

    # Extract description from frontmatter
    local description=$(extract_description "${agent_file}")

    if [[ -n "${description}" ]]; then
      printf "  • %-30s %s\n" "${agent_name}" "${description}"
    else
      printf "  • %s\n" "${agent_name}"
    fi
  done < <(find "${agents_dir}" -maxdepth 1 -name "*.md" -type f -print0 | sort -z)

  echo ""
  log "Total agents available: ${agent_count}"

  if [[ ${agent_count} -eq 0 ]]; then
    warn "No agent definition files found"
    return 1
  fi

  return 0
}

# Function to sync agents
sync_agents() {
  local repo_dir="$1"
  local target_dir="${TARGET_DIR}"
  local agents_source="${repo_dir}/.claude/agents"

  if [[ ! -d "${agents_source}" ]]; then
    err "No agents directory found in repository: ${agents_source}"
    return 1
  fi

  # Create target directory
  mkdir -p "${target_dir}"

  if [[ -n "${AGENT_NAME}" ]]; then
    # Sync specific agent
    local agent_file="${agents_source}/${AGENT_NAME}.md"

    if [[ ! -f "${agent_file}" ]]; then
      err "Agent not found: ${AGENT_NAME}"
      echo ""
      log "Available agents:"
      list_agents "${repo_dir}"
      return 1
    fi

    log "Syncing agent: ${AGENT_NAME}"
    cp "${agent_file}" "${target_dir}/"
    log "✓ Synced ${AGENT_NAME}.md to ${target_dir}/"
  else
    # Sync all agents
    local agent_count=0
    while IFS= read -r -d '' agent_file; do
      agent_count=$((agent_count + 1))
      local agent_name=$(basename "${agent_file}")
      cp "${agent_file}" "${target_dir}/"
    done < <(find "${agents_source}" -maxdepth 1 -name "*.md" -type f -print0)

    if [[ ${agent_count} -eq 0 ]]; then
      warn "No agent files found to sync"
      return 1
    fi

    log "✓ Synced ${agent_count} agent(s) to ${target_dir}/"
  fi

  return 0
}

# Main execution
log "Getting repository..."
REPO_DIR=$(get_repository)

if [[ $? -ne 0 ]]; then
  err "Failed to get repository"
  exit 1
fi

if [[ "${LIST_ONLY}" == "true" ]]; then
  list_agents "${REPO_DIR}"
  exit $?
fi

if [[ "${PROJECT_LEVEL}" == "true" ]]; then
  log "Target: project-level at ${TARGET_DIR}"
else
  log "Target: user-level at ${TARGET_DIR}"
fi

if ! sync_agents "${REPO_DIR}"; then
  err "Failed to sync agents"
  exit 1
fi

echo ""
log "✓ Successfully synced agents"
log "Agents location: ${TARGET_DIR}"
echo ""
if [[ "${PROJECT_LEVEL}" == "true" ]]; then
  log "Usage: Reference agents in this project's Claude Code workflows"
else
  log "Usage: Agents are now available globally across all projects"
fi
log "  Example: 'Use the code-reviewer agent to review my changes'"

#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# sync_skill.sh - Master orchestrator for Claude Code hooks and skills
# ============================================================================
#
# This script orchestrates the sync of both user-level and project-level
# components. For more granular control, use the individual scripts:
#
#   sync_user_skills.sh   - User-level: skills, skill-activation-prompt
#   sync_project_hooks.sh - Project-level: user-prompt-logger, post-tool-use-tracker
#
# HYBRID ARCHITECTURE:
#   USER LEVEL (~/.claude/) - Shared across all projects:
#     - skills/              All skills + skill-rules.json
#     - hooks/               skill-activation-prompt
#     - settings.json        skill-activation hook config
#
#   PROJECT LEVEL (.claude/) - Per-project:
#     - hooks/               user-prompt-logger, post-tool-use-tracker
#     - settings.json        project-specific hook config
#
# Usage:
#   sync_skill.sh [OPTIONS]
#
# Options:
#   --help, -h           Show this help message
#   --project-dir DIR    Target project directory (default: current)
#   --user-only          Only sync user-level components (skills + skill-activation)
#   --project-only       Only sync project-level components (hooks)
#
# Requirements:
#   - git repository for project-level sync
#   - npm for skill-activation-prompt hook
#   - jq (recommended for automatic settings configuration)
# ============================================================================

log() { printf "[sync_skill] %s\n" "$*"; }
err() { printf "[sync_skill][error] %s\n" "$*" >&2; }

# Determine script directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

PROJECT_DIR="${PWD}"
USER_ONLY="false"
PROJECT_ONLY="false"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h|help)
      echo "Master orchestrator for Claude Code hooks and skills"
      echo ""
      echo "Usage: sync_skill.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --help, -h           Show this help message"
      echo "  --project-dir DIR    Target project directory (default: current)"
      echo "  --user-only          Only sync user-level (skills + skill-activation)"
      echo "  --project-only       Only sync project-level (hooks)"
      echo ""
      echo "HYBRID ARCHITECTURE:"
      echo ""
      echo "  USER LEVEL (~/.claude/) - Run once, works everywhere:"
      echo "    • skills/         All skills + skill-rules.json"
      echo "    • hooks/          skill-activation-prompt"
      echo "    • settings.json   skill-activation hook config"
      echo ""
      echo "  PROJECT LEVEL (.claude/) - Run per project:"
      echo "    • hooks/          user-prompt-logger, post-tool-use-tracker"
      echo "    • settings.json   project-specific hook config"
      echo ""
      echo "Individual Scripts:"
      echo "  sync_user_skills.sh   - User-level sync only"
      echo "  sync_project_hooks.sh - Project-level sync only"
      echo ""
      echo "Examples:"
      echo "  sync_skill.sh                     # Sync everything"
      echo "  sync_skill.sh --user-only         # Just user-level (run once)"
      echo "  sync_skill.sh --project-only      # Just project-level"
      echo "  sync_skill.sh --project-dir /path # Sync to specific project"
      exit 0
      ;;
    --project-dir)
      shift
      PROJECT_DIR="$1"
      shift
      ;;
    --user-only)
      USER_ONLY="true"
      shift
      ;;
    --project-only)
      PROJECT_ONLY="true"
      shift
      ;;
    *)
      err "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validate mutually exclusive options
if [[ "${USER_ONLY}" == "true" && "${PROJECT_ONLY}" == "true" ]]; then
  err "Cannot use --user-only and --project-only together"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Claude Code Hooks & Skills Sync                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# Sync User-Level Components
# ============================================================================
if [[ "${PROJECT_ONLY}" != "true" ]]; then
  log "═══ USER-LEVEL SYNC ═══"
  echo ""

  if [[ -x "${SCRIPT_DIR}/sync_user_skills.sh" ]]; then
    "${SCRIPT_DIR}/sync_user_skills.sh"
  else
    err "sync_user_skills.sh not found or not executable"
    exit 1
  fi

  echo ""
fi

# ============================================================================
# Sync Project-Level Components
# ============================================================================
if [[ "${USER_ONLY}" != "true" ]]; then
  log "═══ PROJECT-LEVEL SYNC ═══"
  echo ""

  if [[ -x "${SCRIPT_DIR}/sync_project_hooks.sh" ]]; then
    "${SCRIPT_DIR}/sync_project_hooks.sh" --project-dir "${PROJECT_DIR}"
  else
    err "sync_project_hooks.sh not found or not executable"
    exit 1
  fi

  echo ""
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    ✓ Sync Complete!                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [[ "${PROJECT_ONLY}" != "true" ]]; then
  log "USER LEVEL (~/.claude/):"
  log "  Skills and skill-activation-prompt are now available globally."
fi

if [[ "${USER_ONLY}" != "true" ]]; then
  log "PROJECT LEVEL (${PROJECT_DIR}/.claude/):"
  log "  user-prompt-logger and post-tool-use-tracker are installed."
fi

echo ""

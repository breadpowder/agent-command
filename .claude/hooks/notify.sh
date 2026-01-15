#!/usr/bin/env bash
# Cross-platform Claude Code notification hook
# - Shows terminal program, unique session ID, and project
# - Fails silently if no permission
#
# Usage: This hook is triggered on Claude Code "Stop" events
# Deploy: Run sync_user_skills.sh to install to ~/.claude/hooks/
#
# Override terminal name: Set CLAUDE_TERMINAL_NAME env var
#   export CLAUDE_TERMINAL_NAME="my-terminal"

MESSAGE="${1:-Task completed}"

# Get terminal program name
get_terminal_program() {
    if [[ -n "$TERM_PROGRAM" ]]; then
        echo "$TERM_PROGRAM"
    elif [[ -n "$TERMINAL_EMULATOR" ]]; then
        echo "$TERMINAL_EMULATOR"
    elif [[ "$TERM" == "xterm-kitty" ]]; then
        echo "kitty"
    elif [[ -n "$ALACRITTY_SOCKET" ]]; then
        echo "Alacritty"
    elif [[ -n "$WT_SESSION" ]]; then
        echo "Windows Terminal"
    else
        echo "${TERM:-term}"
    fi
}

# Get unique session ID (last 4 digits of ancestor PID)
# Each terminal has a unique shell process, so PPID is unique per terminal
get_session_id() {
    # Use PPID which is unique per terminal session
    # Take last 4 digits to keep it short
    if [[ -n "$PPID" ]]; then
        echo "${PPID: -4}"
    else
        echo ""
    fi
}

# Get project name from path
get_project_name() {
    if [[ -n "$CLAUDE_PROJECT_DIR" ]]; then
        basename "$CLAUDE_PROJECT_DIR"
    elif [[ -n "$PWD" ]]; then
        basename "$PWD"
    else
        echo "unknown"
    fi
}

# Build terminal identifier
# Format: "custom_name" or "program:session_id"
get_terminal_id() {
    if [[ -n "$CLAUDE_TERMINAL_NAME" ]]; then
        # User override
        echo "$CLAUDE_TERMINAL_NAME"
    else
        local program=$(get_terminal_program)
        local session=$(get_session_id)
        if [[ -n "$session" ]]; then
            echo "${program}:${session}"
        else
            echo "$program"
        fi
    fi
}

TERMINAL=$(get_terminal_id)
PROJECT=$(get_project_name)
TITLE="Claude Code"
BODY="[$TERMINAL] $PROJECT: $MESSAGE"

case "$(uname -s)" in
    Darwin)
        # macOS - fails silently if no permission
        osascript -e "display notification \"$BODY\" with title \"$TITLE\" sound name \"Glass\"" 2>/dev/null || true
        ;;
    Linux)
        # Linux - fails silently if notify-send not installed or no permission
        notify-send "$TITLE" "$BODY" --urgency=normal 2>/dev/null || true
        ;;
esac

# Always exit 0 so Claude Code continues normally
exit 0

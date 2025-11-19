#!/bin/bash

# UserPromptSubmit hook to log user prompts for later analysis
# Saves prompts to user_prompt_yyyy_mm_dd.txt files

# Read the input JSON
INPUT=$(cat)

# Extract the user prompt from the JSON input
USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Only proceed if we have a prompt
if [ -n "$USER_PROMPT" ]; then
    # Determine project directory (fallback to current directory if not set)
    PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

    # Create logs directory in project root
    LOG_DIR="$PROJECT_DIR/prompt-logs"
    mkdir -p "$LOG_DIR"

    # Generate filename with current date
    FILENAME="user_prompt_$(date +%Y_%m_%d).txt"
    LOG_FILE="$LOG_DIR/$FILENAME"

    # Append prompt with simple timestamp format: hh:mm:ss <message>
    echo "[$(date '+%H:%M:%S')] $USER_PROMPT" >> "$LOG_FILE"
fi

# Return JSON to allow the prompt to continue
echo '{}'

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is the AgentDK SDLC Commands repository - a universal, project-agnostic development workflow framework that provides standardized commands for comprehensive software development lifecycle management. These commands work across any technology stack, programming language, and team size, providing structured workflows for feature development, bug fixing, code review, refactoring, testing, and deployment. The repository contains documentation-based command specifications that can be synced to AI agent environments for consistent development practices.

### Context7 MCP Integration
The framework now integrates Context7 Model Context Protocol (MCP) for real-time documentation retrieval and validation:
- **Library Resolution**: Automatic resolution of library/framework names to Context7-compatible IDs using `mcp_context7_resolve-library-id`
- **Documentation Retrieval**: Real-time access to current documentation during all development phases using `mcp_context7_get-library-docs`
- **Best Practices Validation**: Code validation against current framework standards and patterns
- **Topic-Specific Guidance**: Focused documentation retrieval for specific implementation topics (e.g., 'authentication', 'routing', 'database', 'testing')
- **Pseudocode Generation**: Structured code examples and architectural patterns in planning phases to aid understanding and implementation

## Build and Development Commands
- **No build process required** - this is a documentation-first repository
- **Preview markdown**: Use your editor's preview or `glow README.md` (optional)
- **Lint markdown** (optional): `npx markdownlint-cli "**/*.md"` if available
- **Quick command audit**: `rg -n 'sdlc_' commands/` to search command documentation
- **Sync commands to agent environments**: 
  - `./sync_agent_commands.sh` - sync from local commands directory
  - `./sync_agent_commands.sh --github` - clone from GitHub and sync latest commands
  - Copies command specs to `~/.claude/commands` and `~/.codex/prompts`

## Repository Architecture

### Core Structure
- **`commands/`**: Command specifications in Markdown format, one file per command
  - SDLC commands follow pattern: `sdlc_<verb>_<scope>.md` (e.g., `sdlc_implement_feature.md`)
  - Utility commands: `code_review.md`, `refactor.md`, `release_and_publish.md`
  - Meta-command: `_meta_reflection.md` for workflow analysis
- **`README.md`**: Primary user guide, workflows, and examples (source of truth)
- **`AGENTS.md`**: Repository guidelines and contribution standards
- **`scripts/`**: Currently empty utility directory
- **`sync_agent_commands.sh`**: Bash script for syncing commands to agent directories

### Command Categories
**Feature Development Workflow:**
1. `sdlc_prd_feature` - Product Requirements Document creation
2. `sdlc_plan_feature` - Feature architecture and design planning  
3. `sdlc_implement_feature` - Feature implementation and integration

**Bug Fix Workflow:**
1. `sdlc_analyze_bug` - Bug analysis and root cause investigation
2. `sdlc_reproduce_bug` - Bug reproduction steps and environment setup
3. `sdlc_plan_bug` - Bug fix planning and strategy development
4. `sdlc_implement_bug` - Surgical bug fix implementation

**Shared Operations:**
1. `sdlc_test` - Testing infrastructure and test execution
2. `sdlc_deploy` - Deployment and release management
3. `sdlc_workflow` - Master orchestrator for complete workflows

## Command Structure and Patterns

### Universal Parameters
All SDLC commands use standardized parameters:
- `--name <descriptive-name>` - Workspace name (creates `<project_root>/<name>/`)
- `--source <github|local|bitbucket>` - Input source (optional, defaults to local)
- `--type <context-specific>` - Command-specific type (optional, auto-detected)
- `--id <identifier>` - External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>` - Additional context file(s) or directory (optional)
- `--prompt "<instruction>"` - Inline user task prompt (optional)

### Workspace Organization
Each command creates standardized workspace structure:
```
<project_root>/<name>/
├── plan/                  # Planning documents and strategies
│   ├── main-plan.md       # Primary plan and approach
│   ├── task-breakdown.md  # Detailed task breakdown (2-hour rule)
│   ├── decision-log.md    # Options, pros/cons, decisions with rationale
│   ├── architecture.md    # High-level diagrams and contracts
│   └── implementation.md  # Step-by-step implementation strategy
├── issue/                 # Issue analysis and requirements
│   ├── analysis.md        # Problem/requirement analysis
│   ├── research.md        # Background research and prior art
│   └── requirements.md    # Specific requirements and acceptance criteria
└── context/               # Additional context and references
    ├── source-reference.md # Original source context and links
    └── dependencies.md     # Dependencies and relationships
```

### Git Integration Requirements
**Automatic Commits**: All SDLC commands create automatic git commits with consistent patterns:
- Feature commits: `sdlc: <action> feature <name> - <summary>`
- Bug fix commits: `sdlc: <action> bug <name> - <summary>`
- Shared operation commits: `sdlc: <action> <name> - <summary>`

IMPORTANT RULE: for commits, 
1. Only commits files you updated in this session, MUST NOT add untracked files
2. Review changes before commits, check file deletions and ask user for clarity, e.g. if important files like CLAUDE.md are deleled, do ask user to confirm before commit changes.

**Rollback Policy**: 
- **SECURITY POLICY**: `git reset` is strictly forbidden
- Always use `git revert <commit_hash>` to maintain complete traceability
- View workflow history with `git log --oneline --grep="sdlc: <name>"`

## Development Standards and Practices

### Markdown Conventions
- **Headers**: Use ATX headings (`#`, `##`), sentence case
- **Code blocks**: Use fenced blocks with language hints (`bash`, `text`)
- **Lists**: Hyphen-prefixed (`- `), keep bullets concise, wrap around ~100 chars
- **File naming**: snake_case, commands as `sdlc_<verb>_<topic>.md`

### Documentation Requirements
- **Examples must be safe and idempotent**: All examples should be copy-pasteable
- **Consistent parameter usage**: Always use standard flags (`--name`, `--source`, `--type`, `--id`)
- **Workspace alignment**: Keep outputs aligned with README's "Workspace Organization"
- **No destructive examples**: Prefer safe alternatives or add cautionary notes

### Security Guidelines
- **No secrets in documentation**: Never include tokens, API keys, or internal URLs
- **Safe command demonstrations**: Mark destructive commands clearly
- **Rollback over reset**: Always demonstrate `git revert` over history rewrites

## Key Workflow Principles

### Context7-Enhanced Development Workflow
All SDLC commands now integrate Context7 MCP for documentation-driven development:
- **Planning Phase**: Library resolution and documentation retrieval inform architecture decisions
- **Implementation Phase**: Topic-specific documentation guides development patterns
- **Code Review Phase**: Validation against current framework standards and best practices
- **Pseudocode Integration**: Structured code examples aid understanding and implementation

### 2-Hour Task Rule
All complex tasks are automatically broken into ≤2 hour chunks with:
- Clear validation criteria for each chunk
- Regular checkpoint commits for progress tracking
- Comprehensive planning before implementation
- **Pseudocode Examples**: Each task includes structured pseudocode showing implementation approach

### Quality Gates
- Built-in validation steps in each command
- Security and performance considerations integrated
- Comprehensive testing strategies for both features and bug fixes

### Workflow Differentiation
**Feature Development Focus:**
- User-centered design with PRD creation
- Scalable architecture and long-term design
- Business impact analysis and success metrics

**Bug Fix Focus:**
- Surgical precision with minimal code changes
- Root cause analysis and comprehensive investigation  
- Regression prevention and extensive rollback planning

## Multi-Source Support
Commands support GitHub, Bitbucket, and local development with appropriate CLI integration (`gh` for GitHub, Bitbucket CLI/API, local git tools).

## Testing and Validation
- Validate examples against AgentDK CLI where installed
- Ensure workspace outputs match documented structure
- Test command parameters and flag combinations
- Verify git integration and commit patterns work correctly






## Skills & Hooks Hybrid Architecture

The skill system uses a **hybrid architecture** separating user-level (global) and project-level (per-project) components:

### Architecture Overview

```
USER LEVEL (~/.claude/) - Run once, works everywhere:
├── skills/                    # All skills + skill-rules.json
│   ├── playwright-skill/      # UI testing with Playwright
│   ├── pptx/                  # PowerPoint manipulation
│   ├── xlsx/                  # Excel manipulation
│   ├── mcp-builder/           # MCP server builder
│   ├── skill-creator/         # Skill creation guide
│   └── skill-rules.json       # Skill activation triggers
├── hooks/                     # Shared hooks
│   ├── skill-activation-prompt.sh  # Auto-activate skills on prompt
│   ├── skill-activation-prompt.ts
│   ├── notify.sh              # Task completion notifications (cross-platform)
│   └── package.json + node_modules/
└── settings.json              # Hook configurations (UserPromptSubmit, Stop)

PROJECT LEVEL (.claude/) - Per-project:
├── hooks/                     # Project-specific hooks
│   ├── user-prompt-logger.sh  # Logs to project/prompt-logs/
│   └── post-tool-use-tracker.sh # Tracks to project/.claude/tsc-cache/
└── settings.json              # Project hook config
```

### Sync Scripts

| Script | Purpose | Frequency |
|--------|---------|-----------|
| `sync_skill.sh` | Master orchestrator (both levels) | As needed |
| `sync_user_skills.sh` | User-level: skills + skill-activation | Run **once** globally |
| `sync_project_hooks.sh` | Project-level: logger + tracker | Run **per project** |

### Usage

```bash
# First time setup (install skills globally)
./sync_user_skills.sh

# For each new project
./sync_project_hooks.sh --project-dir /path/to/project

# Or sync everything at once
./sync_skill.sh

# Update skills only (faster, no npm)
./sync_user_skills.sh --skills-only
```

### Rationale

- **skill-activation-prompt** reads `skill-rules.json` → must be at same level (user)
- **user-prompt-logger** writes to `project/prompt-logs/` → project level
- **post-tool-use-tracker** writes to `project/.claude/tsc-cache/` → project level

### Sub-Agents

Sub-agents are synced to `~/.claude/agents/` (user-level) by default using `sync_sub_agents.sh`.

**Note**: Agents are NOT auto-discovered. To use synced agents:
- Reference directly in prompts: "Use the code-reviewer agent to review my changes"
- Or use CLI flag: `claude --agents @from ~/.claude/agents/`

## Sync Script Design Principles

When creating or modifying sync scripts (e.g., `sync_skill.sh`, `sync_agent_commands.sh`), follow these mandatory rules:

### Always Overwrite Rule (Non-Negotiable)
All customized code MUST be overwritten on every sync to ensure target projects always have the most recent code:

1. **Hook files** (.sh, .ts, .js): Always overwrite, never skip if exists
2. **Skill directories**: Always `rm -rf` existing and `cp -r` fresh copy
3. **Configuration files** (skill-rules.json, package.json): Always overwrite
4. **No "already installed" early returns** that skip updates

### Anti-Pattern (DO NOT DO THIS)
```bash
# WRONG: Skips update if file exists
if [[ -f "${HOOKS_DIR}/my-hook.sh" ]]; then
  log "✓ my-hook already installed"
  return 0  # ← This prevents updates!
fi
```

### Correct Pattern
```bash
# CORRECT: Always overwrite to ensure latest code
if [[ -f "${SOURCE_DIR}/my-hook.sh" ]]; then
  cp "${SOURCE_DIR}/my-hook.sh" "${HOOKS_DIR}/"
  chmod +x "${HOOKS_DIR}/my-hook.sh"
  log "✓ Synced my-hook.sh"
fi
```

### Directory Sync Patterns

**Pattern 1: Wipe and Replace** (for framework-only directories)
Use for: `skills/`, `commands/`, `prompts/`
```bash
# Wipe entire directory and replace from source
# Ensures outdated/removed items are deleted
rm -rf "${DEST_DIR}"
mkdir -p "${DEST_DIR}"
cp -r "${SOURCE_DIR}/"* "${DEST_DIR}/"
```

**Pattern 2: Copy and Overwrite** (for mixed user/framework directories)
Use for: `hooks/` (users may have custom hooks)
```bash
# Overwrite framework files, preserve user-created files
# Does NOT delete files that don't exist in source
cp -r "${SOURCE_DIR}/"* "${DEST_DIR}/"
```

| Directory | Pattern | Reason |
|-----------|---------|--------|
| `~/.claude/skills/` | Wipe and Replace | Framework-only, shared across projects |
| `~/.claude/hooks/` | Wipe and Replace | skill-activation-prompt only |
| `~/.claude/commands/` | Wipe and Replace | Framework-only, no user content |
| `~/.codex/prompts/` | Wipe and Replace | Framework-only, no user content |
| `.claude/hooks/` | Copy and Overwrite | Users may have custom project hooks |

### Rationale
- Source repository (agent-command) is the **single source of truth**
- Target projects should always receive the latest hooks, skills, and configurations
- Stale code in target projects causes debugging nightmares
- "Preserve existing" logic only applies to **user-created** content, not **framework-provided** code

## Hook Debugging

When creating or debugging Claude Code hooks, follow these systematic debugging practices to identify and resolve issues efficiently.

### Configuration Validation
Always validate JSON configuration files before debugging hook logic:
```bash
# Validate user-level and project-level configurations
cat ~/.claude/settings.json | jq .
cat .claude/settings.json | jq .
```

### Research-First Approach
- Read official documentation before implementing custom hooks
- Use WebFetch to retrieve current documentation: `https://docs.claude.com/en/docs/claude-code/hooks.md`
- Validate hook schemas and field names against documented examples
- Verify hook event types and required output fields

### Debug Logging Pattern
Add logging to capture actual input and output during hook execution:
```bash
# Log hook invocations for debugging
INPUT=$(cat)
echo "Hook called: $INPUT" >> /tmp/hook-debug.log
# ... rest of script logic
```

### Isolated Testing
Test hooks with sample data before relying on live automation:
```bash
# Test PreToolUse hook with sample JSON input
echo '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git push"}}' | .claude/hooks/your-hook.sh
```

### Common Hook Issues
- **Incorrect JSON field names**: Verify field names match documented schema
- **Missing required output fields**: Ensure all required fields are present in hook responses
- **Global configuration syntax errors**: JSON syntax errors break all settings
- **Permission issues**: Ensure hook scripts are executable (`chmod +x`)

## Notify Hook (Task Completion Notifications)

Cross-platform desktop notification hook that alerts when Claude Code completes tasks.

### Features
- **Cross-platform**: Works on macOS (osascript) and Linux (notify-send)
- **Terminal-aware**: Shows which terminal triggered the notification (VS Code, iTerm2, etc.)
- **Project-aware**: Displays project name in notification
- **Silent failure**: No errors if notifications aren't enabled - Claude Code continues normally

### Notification Format
```
Title: Claude Code
Body:  [terminal_name] project_name: Task finished
```

Example: `[vscode] my-app: Task finished`

### Prerequisites

| OS | Requirement | Install |
|----|-------------|---------|
| macOS | osascript | Built-in |
| macOS | Notification permission | System Settings → Notifications → Script Editor |
| Linux | notify-send | `sudo apt install libnotify-bin` |

### Hook Location
- **Source**: `.claude/hooks/notify.sh` (tracked in git)
- **Deployed to**: `~/.claude/hooks/notify.sh` (user level)
- **Event**: `Stop` (triggers when Claude finishes tool execution)

### Deployment
Run `./sync_user_skills.sh` to deploy the notify hook along with other user-level components.

### Settings Merge Strategy

The sync script uses a **MERGE** strategy for `~/.claude/settings.json`:

| Behavior | Description |
|----------|-------------|
| **Preserves existing** | All user settings (env, plugins, other hooks) are kept |
| **Adds missing hooks** | Only adds hooks that don't already exist |
| **Never overwrites** | Existing hooks are never modified or removed |
| **Idempotent** | Safe to run multiple times |

**Example**: If a host already has custom hooks configured:
```json
{
  "env": { "MY_VAR": "value" },
  "hooks": {
    "PreToolUse": [{ "matcher": "Bash", "hooks": [...] }]
  }
}
```

After running `sync_user_skills.sh`, the result is:
```json
{
  "env": { "MY_VAR": "value" },           // Preserved
  "hooks": {
    "PreToolUse": [...],                   // Preserved
    "UserPromptSubmit": [...],             // Added
    "Stop": [...]                          // Added
  }
}
```

### Testing
```bash
# Test directly
~/.claude/hooks/notify.sh "Test message"

# Verify settings.json includes Stop hook
cat ~/.claude/settings.json | jq '.hooks.Stop'
```

### When you commit to repo, your message must be one line, no bullet point. Never metion Claude as coauthor
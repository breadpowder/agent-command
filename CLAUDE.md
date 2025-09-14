# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is the AgentDK SDLC Commands repository - a universal, project-agnostic development workflow framework that provides standardized commands for comprehensive software development lifecycle management. These commands work across any technology stack, programming language, and team size, providing structured workflows for feature development, bug fixing, code review, refactoring, testing, and deployment. The repository contains documentation-based command specifications that can be synced to AI agent environments for consistent development practices.

## Build and Development Commands
- **No build process required** - this is a documentation-first repository
- **Preview markdown**: Use your editor's preview or `glow README.md` (optional)
- **Lint markdown** (optional): `npx markdownlint-cli "**/*.md"` if available
- **Quick command audit**: `rg -n 'sdlc_' commands/` to search command documentation
- **Sync commands to agent environments**: `./sync_agent_commands.sh` - copies command specs to `~/.claude/commands` and `~/.codex/prompts`

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

### 2-Hour Task Rule
All complex tasks are automatically broken into ≤2 hour chunks with:
- Clear validation criteria for each chunk
- Regular checkpoint commits for progress tracking
- Comprehensive planning before implementation

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
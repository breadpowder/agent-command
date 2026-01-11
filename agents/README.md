# SDLC Agents

Subagent-based SDLC workflow commands that run with isolated context windows and support background execution.

## Overview

These agents replace the traditional `/command` style SDLC commands with Task tool subagents. Each agent:

- Runs in its own isolated context window
- Produces artifacts in `task_<name>/` for handoff
- Pauses with "reveal" gate for human review
- Supports sequential workflow with checkpoints

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `sdlc-understand-requirement` | sonnet | Transform raw input into validated requirements |
| `sdlc-prd-feature` | opus | Create PRD with user stories and acceptance criteria |
| `sdlc-plan-first` | opus | Architecture, strategy, integration contracts (NO CODE) |
| `sdlc-task-breakdown` | opus | JIRA-format task breakdown with TDD specs |
| `sdlc-implement-feature` | opus | TDD implementation (can run in background) |

## Sequential Workflow

```
sdlc-understand-requirement
         │
         ▼
    [HUMAN REVIEW] ← Review requirement analysis
         │
         ▼
sdlc-prd-feature
         │
         ▼
    [HUMAN REVIEW] ← Approve PRD and scope
         │
         ▼
sdlc-plan-first
         │
         ▼
    [HUMAN REVIEW] ← Approve architecture and contracts
         │
         ▼
sdlc-task-breakdown
         │
         ▼
    [HUMAN REVIEW] ← Approve task breakdown
         │
         ▼
sdlc-implement-feature
         │
         ▼
    [HUMAN REVIEW] ← Review each task (reveal-gated)
```

## Usage

### Starting a New Feature

```
User: "Start requirement analysis for user-auth feature"

Claude: I'll launch the requirement understanding agent.
[Task tool invokes sdlc-understand-requirement]

Agent completes and pauses...

Claude: Requirement analysis complete. Please review:
- task_user-auth/requirement/analysis/requirement_analysis.md

Say "reveal" to proceed to PRD phase.
```

### Continuing to Next Phase

```
User: "reveal"

Claude: Proceeding to PRD phase...
[Task tool invokes sdlc-prd-feature]
```

### Background Implementation

```
User: "Run implementation in background"

Claude: [Task tool with run_in_background: true]

User can continue other work and check progress later.
```

## Artifact Flow

Each agent reads artifacts from the prior phase and writes new artifacts:

```
sdlc-understand-requirement
  └── WRITES: task_<name>/requirement/
                  ├── analysis/requirement_analysis.md
                  └── user-stories/stories.md

sdlc-prd-feature
  ├── READS: task_<name>/requirement/
  └── WRITES: task_<name>/specs/
                  ├── feature-spec.md
                  └── user-stories.md

sdlc-plan-first
  ├── READS: task_<name>/specs/
  └── WRITES: task_<name>/plan/
                  ├── strategy/implementation_plan.md
                  ├── strategy/architecture.md
                  └── decision-log.md

sdlc-task-breakdown
  ├── READS: task_<name>/plan/strategy/
  └── WRITES: task_<name>/plan/tasks/
                  ├── tasks.md
                  └── tasks_details.md

sdlc-implement-feature
  ├── READS: task_<name>/plan/tasks/
  └── WRITES: task_<name>/implementation/
                  └── status.md
              + actual code changes
```

## Installation

Run from the agent-command repository:

```bash
./sync_sdlc_agents.sh
```

This syncs agents to `~/.claude/agents/`.

## Human Review Gates

Each agent pauses and waits for "reveal" before proceeding. During the pause:

1. **Review artifacts** created by the agent
2. **Validate assumptions** and decisions
3. **Provide feedback** or corrections
4. **Say "reveal"** to continue to next phase

## Key Principles

1. **Sequential execution** - Phases run one at a time with human checkpoints
2. **Isolated context** - Each agent has fresh context (no bloat)
3. **Artifact-based handoff** - Files in `task_<name>/` persist between phases
4. **TDD-driven implementation** - Tests written before code
5. **Background option** - Implementation can run asynchronously

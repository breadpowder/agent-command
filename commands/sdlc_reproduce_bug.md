# SDLC Reproduce Bug $ARGUMENTS

## Purpose
Specialized bug reproduction to create reliable, minimal steps and artifacts that consistently
trigger the issue. This command establishes controlled environments and documents procedures; it
does not implement fixes.

## Command Usage
```bash
# GitHub bug reproduction
sdlc_reproduce_bug --source github --name payment-failure --type production --id 456

# Local bug reproduction
sdlc_reproduce_bug --source local --name ui-crash --type development

# Bitbucket bug reproduction
sdlc_reproduce_bug --source bitbucket --name api-timeout --type staging --id 789

# Simple usage (auto-detects everything)
sdlc_reproduce_bug --name data-corruption-bug
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Bug workspace name (creates <project_root>/feature_<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <production|staging|development>`: Environment type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus reproduction (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: reproduce bug <name> - environment setup complete"`
- `git commit -m "sdlc: <name> - minimal reproduction steps documented"`
- `git commit -m "sdlc: <name> - automated test case created"`
- `git commit -m "sdlc: <name> - bug reproduction complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
### 1. Information collection
- Parse bug reports, logs, stack traces, user actions, environment details, and any supplied
  `--context` files and `--prompt` guidance.
- Assess severity, frequency, and patterns.

### 2. Environment preparation
- Match affected versions of code, dependencies, and configuration.
- Prepare data and fixtures; enable targeted logging/observability.
- Isolation strategy: clean baseline and reset capability.

### 3. Minimal reproduction design
- Remove non-essential steps; isolate required conditions and variables.
- Choose reproduction level with trade-offs:
  - Unit-level (fast, narrow) vs integration/e2e (realistic, broader).
- Document expected vs actual outcomes and evidence to collect.

### 4. Execution and validation
- Run steps multiple times to establish reliability (>90% consistency).
- Capture evidence: logs, traces, screenshots, state dumps.
- Automate where feasible (scripts/tests) and record artifacts.

### Workspace structure
```
<project_root>/feature_<name>/
├── plan/
│   ├── reproduction-plan.md  # Step-by-step reproduction strategy
│   ├── test-cases.md         # Automated/manual test cases
│   └── environment-setup.md  # Configuration requirements
├── issue/
│   ├── bug-analysis.md       # Original report summary and impact
│   ├── error-logs.md         # Logs and traces
│   └── conditions.md         # System and data conditions
└── context/
    └── source-reference.md   # Links to tickets and reports
```

## Collaboration checkpoints
- Confirm target environment and constraints.
- Review proposed minimal steps and level (unit/integration/e2e) with pros/cons.
- Validate automated artifacts are sufficient for downstream analysis.

## Outputs
- Reproduction steps with evidence and reliability notes.
- Automated scripts/tests and reset utilities.
- Artifacts ready for `sdlc_analyze_bug` and `sdlc_plan_bug`.

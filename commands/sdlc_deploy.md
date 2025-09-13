# SDLC Deploy Changes $ARGUMENTS

## Purpose
Specialized deployment workflow that executes safe, reliable, rollback-ready releases. This command
prepares, executes, and validates deployments; it does not implement features or author tests.

## Command Usage
```bash
# GitHub deployment
sdlc_deploy_changes --source github --name api-release --type production --id 101

# Local deployment
sdlc_deploy_changes --source local --name hotfix-deploy --type hotfix

# Bitbucket deployment
sdlc_deploy_changes --source bitbucket --name feature-rollout --type staging

# Simple usage (auto-detects everything)
sdlc_deploy_changes --name production-release
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <production|staging|hotfix>`: Deployment type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus deployment (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: <name> - deployment plan complete"`
- `git commit -m "sdlc: <name> - pre-deployment validation complete"`
- `git commit -m "sdlc: <name> - deployment executed successfully"`
- `git commit -m "sdlc: <name> - post-deployment validation complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
- ### 1. Context and readiness
- Analyze change set, dependencies, and environment readiness, including any `--context` files and
  objectives captured in `--prompt`.
- Verify approvals and quality gates from testing and review.

### 2. Strategy options and decision
- Choose deployment strategy with pros/cons:
  - Blue/green (fast rollback, higher infra cost)
  - Canary (gradual exposure, more orchestration)
  - Rolling (steady rollout, slower rollback)
- Decision gate: record selected strategy and rationale in `plan/decision-log.md`.

### 3. Risk and rollback
- Validate backups, DB migration plans, and monitoring coverage.
- Define rollback triggers and procedures; rehearse where feasible.

### 4. Task breakdown (2-hour rule)
- Pre-deploy validation, execution steps, post-verify, and monitoring activation.
- Clear owner, command/checklist, and exit criteria for each step.

### Workspace structure
```
<project_root>/<name>/
├── plan/
│   ├── deployment-plan.md   # Steps, roles, runbook
│   ├── decision-log.md      # Strategy and rationale
│   └── rollback-plan.md     # Triggers and procedures
└── context/
    └── change-log.md        # Changes included and references
```

## 🔹 EXECUTE
### Pre-deployment
- Tag/versioning, backups, feature flag defaults, config validation.
- Smoke test in staging; dry-run migrations.

### Deployment
- Execute per chosen strategy with live monitoring and checkpoints.
- Pause points for metrics and error budgets; proceed or rollback.

### Post-deployment
- Smoke tests, health checks, performance validation, and error-rate review.
- Activate enhanced monitoring and alerts for a defined bake period.

## Collaboration checkpoints
- Confirm strategy selection and rollback plan.
- Announce deployment window and owners; align with stakeholders.
- Review results and decide on promotion/rollback/post-actions together.

## Outputs
- Deployment plan and decision log.
- Execution records and validation results.
- Rollback status and follow-up actions (if any).

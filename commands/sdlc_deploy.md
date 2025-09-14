# SDLC Deploy $ARGUMENTS

## Purpose
Specialized deployment workflow that executes safe, reliable, rollback-ready releases. This command
prepares, executes, and validates deployments; it does not implement features or author tests.

## Command Usage
```bash
# GitHub deployment
sdlc_deploy --source github --name api-release --type production --id 101

# Local deployment
sdlc_deploy --source local --name hotfix-deploy --type hotfix

# Bitbucket deployment
sdlc_deploy --source bitbucket --name feature-rollout --type staging

# Simple usage (auto-detects everything)
sdlc_deploy --name production-release
```

**Simplified Parameters:**
Files are created ONLY if applicable, e.g. feature new features or simple feature, there is no rollbacl-plan.md and rollout-config.yaml, obervability.yaml nor runbook.yaml.
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
│   ├── deployment-plan.md   # Steps, roles, runbook with observability
│   ├── decision-log.md      # Strategy and rationale
│   └── rollback-plan.md     # Triggers, procedures, and recovery steps
├── specs/                   # Machine-readable deployment specifications
│   ├── rollout-config.yaml  # Feature flags, gating checks, backout steps
│   ├── observability.yaml  # Enhanced monitoring, alerts, SLO tracking
│   └── runbook.yaml         # Operational procedures and escalation paths
└── context/
    └── change-log.md        # Changes included and references with impact analysis
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

### 5. Comprehensive Deployment Requirements

**Observability and Monitoring:**
- Enhanced monitoring activated during deployment window
- SLO tracking with error budget enforcement and alerting
- Dashboards configured for real-time deployment health visibility
- Log aggregation and trace collection for troubleshooting
- Performance metrics baseline and anomaly detection

**Rollout and Rollback Strategy:**
- Phased rollout with feature flags and kill switches
- Gating checks at each phase with automated quality gates
- Clear rollback triggers: error rates, performance degradation, SLO violations
- Automated backout procedures with data integrity validation
- Capacity planning and resource scaling considerations

**Operability Requirements:**
- Runbook updated with operational procedures and troubleshooting steps
- On-call team briefed with escalation paths and contact information
- Support documentation updated with feature changes and common issues
- Post-deployment validation checklist with acceptance criteria
- Incident response procedures ready with communication templates

## Outputs
- Comprehensive deployment plan with observability and rollback procedures
- Machine-readable deployment configurations (feature flags, monitoring, runbook)
- Execution records with validation results and quality gate attestations
- Live monitoring and alerting with SLO tracking and error budget management

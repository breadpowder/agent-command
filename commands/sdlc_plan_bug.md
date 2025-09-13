# SDLC Plan Bug $ARGUMENTS

## Purpose
Specialized bug fix planning that converts confirmed analysis into a precise, low-risk fix plan
with risk mitigation and rollback strategies. This command does not implement or test the fix.

## Command Usage
```bash
# GitHub bug fix planning
sdlc_plan_bug --source github --name payment-failure --type critical --id 456

# Local bug fix planning
sdlc_plan_bug --source local --name ui-crash --type high

# Bitbucket bug fix planning
sdlc_plan_bug --source bitbucket --name api-timeout --type medium --id 789

# Simple usage (auto-detects everything)
sdlc_plan_bug --name data-corruption-bug
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Bug fix workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <critical|high|medium|low>`: Bug severity (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus planning (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: plan bug <name> - fix strategy analysis complete"`
- `git commit -m "sdlc: <name> - risk assessment and mitigations documented"`
- `git commit -m "sdlc: <name> - rollback plan ready"`
- `git commit -m "sdlc: <name> - bug fix planning complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
- ### 1. Inputs and confirmation
- Import artifacts from `sdlc_reproduce_bug` and `sdlc_analyze_bug`, plus any `--context` files
  and `--prompt` guidance provided by the user.
- Confirm root cause, constraints, and acceptance criteria for resolution.

### 2. Fix options with trade-offs
- Draft 2–3 fix approaches with pros/cons, risk profile, and estimated effort.
- Consider scope minimization, compatibility, and regression prevention.
- Decision gate: present options and record selected approach in `plan/decision-log.md`.

### 3. Risk assessment and mitigation
- Identify technical, data integrity, performance, and integration risks.
- Define mitigations: feature flags, phased rollout, additional monitoring.
- Define quality gates to pass during implementation/testing.

### 4. Rollback and recovery plan
- Clear rollback triggers and procedures.
- Data recovery needs and verification steps.
- Communication and incident management notes.

### 5. Task breakdown (2-hour rule)
- Decompose into ≤2h tasks with measurable validation criteria.
- Map dependencies and order for lowest risk first.

### Workspace structure
```
<project_root>/<name>/
├── plan/
│   ├── fix-strategy.md      # Chosen approach and rationale
│   ├── risk-assessment.md   # Risks and mitigations
│   ├── rollback-plan.md     # Recovery procedures
│   └── decision-log.md      # Options considered and decision
├── issue/
│   ├── root-cause.md        # Summary from analysis
│   └── validation-plan.md   # What testing must prove
└── context/
    └── source-reference.md  # Links to analysis/reproduction
```

## Collaboration checkpoints
- Validate understanding of root cause and constraints with the user.
- Present fix options with pros/cons; request selection before proceeding.
- Confirm rollback triggers and risk mitigations align with business impact.

## Outputs
- Approved fix strategy with decision log and rationale.
- Risk and rollback plans ready for implementation.
- Ordered task breakdown ready for `sdlc_implement_bug`.

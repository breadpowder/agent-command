# SDLC Analyze Bug $ARGUMENTS

## Purpose
Specialized bug analysis focused on understanding symptoms, isolating the root cause, and
assessing impact. This command does not implement fixes; it produces actionable analysis and
solution options for planning.

## Command Usage
```bash
# GitHub bug analysis
sdlc_analyze_bug --source github --name payment-failure --type production --id 456

# Local bug analysis
sdlc_analyze_bug --source local --name ui-crash --type development

# Bitbucket bug analysis
sdlc_analyze_bug --source bitbucket --name api-timeout --type staging --id 789

# Simple usage (auto-detects everything)
sdlc_analyze_bug --name data-corruption-bug
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Bug workspace name (creates <project_root>/feature_<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <production|staging|development>`: Environment type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus analysis (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: analyze bug <name> - initial triage complete"`
- `git commit -m "sdlc: <name> - hypotheses documented and experiments planned"`
- `git commit -m "sdlc: <name> - root cause confirmed"`
- `git commit -m "sdlc: <name> - impact assessment complete"`
- `git commit -m "sdlc: <name> - bug analysis complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
- ### 1. Context gathering and triage
- Collect bug reports, logs, stack traces, user actions, and environment details, plus any
  provided `--context` materials and `--prompt` intent.
- Verify reproduction exists; if not, run `sdlc_reproduce_bug` first and link artifacts.
- Identify affected components, versions, and dependencies.

### 2. Hypothesis and experiment design
- Form 2–3 hypotheses for the likely root cause.
- For each hypothesis: define a minimal experiment to confirm or refute it, expected outcome,
  and evidence to collect.
- Record in `issue/analysis.md` and `plan/experiments.md`.

### 3. Root cause confirmation
- Execute experiments safely in isolated or test environments.
- Confirm or reject hypotheses; iterate as needed to isolate the root cause.
- Capture definitive evidence (logs, traces, diffs) and update documentation.

### 4. Impact assessment
- Scope analysis: affected users, components, data integrity, and performance.
- Risk analysis: blast radius, regression risks, and compatibility concerns.
- Preconditions for planning: what must be addressed during fix planning.

### 5. Solution options (for planning handoff)
- Propose 2–3 fix approaches with pros/cons, risk profile, and estimated effort.
- Decision gate: present options to the user; selected option is carried forward to
  `sdlc_plan_bug` and recorded in `plan/decision-log.md`.

### Workspace structure
```
<project_root>/feature_<name>/
├── plan/
│   ├── experiments.md      # Hypotheses and experiments
│   └── decision-log.md     # Options and selected decision for planning
├── issue/
│   ├── analysis.md         # Symptom analysis and evidence
│   ├── impact.md           # Impact assessment
│   └── timeline.md         # When it started, frequency, conditions
└── context/
    └── source-reference.md # Links and references to reports and tickets
```

## Collaboration checkpoints
- Clarify reproduction steps and environment details with the user.
- Review hypotheses and experiments before executing.
- Present solution options with trade-offs; request user selection for planning.

## Outputs
- Confirmed root cause with evidence and impact assessment.
- Documented hypotheses, experiments, and results.
- Fix options with pros/cons ready for `sdlc_plan_bug`.

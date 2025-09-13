# SDLC Setup Testing $ARGUMENTS

## Purpose
Specialized testing setup and execution that establishes frameworks, writes tests, and validates
quality gates for a change. This command does not implement features or deploy to production.

## Command Usage
```bash
# GitHub testing setup
sdlc_setup_testing --source github --name api-testing --type integration --id 456

# Local testing setup
sdlc_setup_testing --source local --name ui-testing --type e2e

# Bitbucket testing setup
sdlc_setup_testing --source bitbucket --name unit-testing --type pytest --id 789

# Simple usage (auto-detects everything)
sdlc_setup_testing --name comprehensive-testing
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <unit|integration|e2e|performance>`: Testing type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus testing (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: <name> - testing framework setup complete"`
- `git commit -m "sdlc: <name> - tests implemented and organized"`
- `git commit -m "sdlc: <name> - CI integration and quality gates configured"`
- `git commit -m "sdlc: <name> - testing setup complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
### 1. Context and scope
- Load planning/implementation artifacts and any `--context` files; enumerate target modules and
  behaviors, and incorporate `--prompt` guidance.
- Choose testing level (unit/integration/e2e/performance) appropriate to scope.

### 2. Framework and tooling options
- Present 2–3 framework/tooling choices (e.g., pytest/jest/playwright) with pros/cons.
- Decision gate: record selected tooling and rationale in `plan/decision-log.md`.

### 3. Test design and coverage goals
- Define coverage targets and quality metrics.
- Identify fixtures, mocks/stubs, and data strategies.
- Outline test cases to implement with acceptance criteria.

## 🔹 CREATE
### Directory and configuration
- Establish or validate test directory structure and configuration files.
- Add base utilities, fixtures, and helpers.

### Test implementation
- Implement unit/integration/e2e/perf tests per design.
- Ensure determinism and isolation; add teardown/cleanup.

### CI/CD integration
- Configure automated execution, coverage reporting, and quality gates.
- Add badges or reports as appropriate.

## 🔹 EXECUTE
### Run and validate
- Execute tests locally and in CI, iterate to meet quality gates.
- Collect results and produce a concise summary report.

### Workspace structure
```
<project_root>/<name>/
├── plan/
│   ├── decision-log.md     # Tooling and strategy decisions
│   └── test-plan.md        # Scope, cases, coverage goals
├── tests/                  # Implemented tests and fixtures
└── reports/                # Coverage and test reports (if generated)
```

## Collaboration checkpoints
- Confirm scope and testing level(s) with the user.
- Present tooling options with trade-offs; request selection.
- Review coverage and outcomes; agree on any follow-up work.

## Outputs
- Test suites, fixtures, and utilities.
- CI-integrated execution with quality gates.
- Coverage and test reports for review.

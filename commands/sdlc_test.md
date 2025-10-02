# SDLC Test $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify APIs.

## Purpose
Specialized testing setup and execution that establishes frameworks, writes tests, and validates
quality gates for a change. Clarification‑First: confirm scope and assumptions before testing.
Use Context7 to validate framework/library usage and patterns. This command does not implement
features or deploy to production.

## Command Usage
```bash
# GitHub testing execution
sdlc_test --source github --name api-testing --type integration --id 456

# Local testing execution  
sdlc_test --source local --name ui-testing --type e2e

# Bitbucket testing execution
sdlc_test --source bitbucket --name unit-testing --type pytest --id 789

# Simple usage (auto-detects everything)
sdlc_test --name comprehensive-testing
```

**Simplified Parameters:**
 - `--name <descriptive-name>`: Workspace name (creates <project_root>/task_<name>/)
 - `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
 - `--type <unit|integration|e2e|performance>`: Testing type (optional, auto-detected)
 - `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
 - `--context <file|dir>`: Additional context file(s) or directory (optional)
 - `--prompt "<instruction>"`: Inline task prompt to focus testing (optional)
 - `--complexity <small|medium|large>`: Optional; if omitted, auto-detected

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
<project_root>/task_<name>/
├── plan/
│   ├── decision-log.md     # Tooling and strategy decisions
│   └── test-strategy.md    # Comprehensive test strategy with coverage goals
├── specs/                  # Machine-readable test specifications
│   ├── acceptance-tests.json   # Structured acceptance criteria and test cases
│   └── test-config.yaml    # Test framework configuration and CI integration
├── tests/                  # Implemented tests and fixtures
│   ├── unit/              # Unit tests with clear isolation
│   ├── integration/       # Integration tests for API and data flows
│   ├── e2e/              # End-to-end tests for critical user paths
│   └── performance/       # Performance tests with budget enforcement
└── reports/               # Coverage and test reports with quality metrics
```

## Collaboration checkpoints
- Confirm scope and testing level(s) with the user.
- Present tooling options with trade-offs; request selection.
- Review coverage and outcomes; agree on any follow-up work.

### 4. Comprehensive Test Strategy Requirements

**Test Coverage and Quality Metrics:**
- Unit tests: 80%+ code coverage with clear isolation and mocking
- Integration tests: All API endpoints and critical data flows covered
- E2E tests: Primary user scenarios and acceptance criteria validated
- Performance tests: Response times, throughput, scalability within budgets
- Security tests: Authentication, authorization, input validation, data protection

**Test Organization and Traceability:**
- Map tests to acceptance criteria with F-### identifiers
- Organize tests by scope (unit/integration/e2e/performance)
- Maintain fixtures, mocks, and test data strategies
- Ensure test determinism and isolation with proper cleanup

**CI Integration and Quality Gates:**
- Automated execution in CI pipeline with quality gates
- Test results traceability to requirements and user stories
- Coverage reporting with thresholds and trend analysis
- Performance budgets enforced with threshold violations
- Security test integration with vulnerability scanning

## Outputs
- Comprehensive test suites with multi-level coverage (unit/integration/e2e/performance)
- CI-integrated execution with automated quality gates and reporting
- Traceability matrix linking tests to requirements and acceptance criteria
- Coverage and performance reports meeting quality thresholds
### Outputs
- `task_<name>/test/results/results.md`
- Optional: `task_<name>/test/plan/plan.md`

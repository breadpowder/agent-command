# SDLC Implement Bug $ARGUMENTS

## Purpose
Specialized bug fix implementation that executes the approved plan safely and minimally. This
command focuses on code changes and configuration; testing and deployment are handled by separate
commands. Follows development standards from USER_LEVEL_CLAUDE.md for testing, logging, security, and code quality.

## Command Usage
```bash
# GitHub bug fix implementation
sdlc_implement_bug --source github --name payment-failure --type hotfix --id 456

# Local bug fix implementation
sdlc_implement_bug --source local --name ui-crash --type patch

# Bitbucket bug fix implementation
sdlc_implement_bug --source bitbucket --name api-timeout --type critical --id 789

# Simple usage (auto-detects everything)
sdlc_implement_bug --name data-corruption-bug
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Bug fix workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <hotfix|patch|critical>`: Fix type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus implementation (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: implement bug <name> - implementation plan confirmed"`
- `git commit -m "sdlc: <name> - minimal fix applied"`
- `git commit -m "sdlc: <name> - logging/guardrails updated"`
- `git commit -m "sdlc: <name> - bug fix implementation complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
### 1. Scope and safety confirmation
- Load `sdlc_plan_bug` artifacts (fix-strategy, risk, rollback) along with any `--context` files
  and `--prompt` details.
- Confirm acceptance criteria and risk mitigations with the user.

### 2. Option considerations (if ambiguous)
- Present tightly scoped alternatives (e.g., patch vs refactor) with pros/cons.
- Decision gate: record selected option in `<name>/plan/decision-log.md`.

### 3. Task breakdown (2-hour rule)
- Sequence precise, minimal changes with measurable outcomes.
- Identify guardrails: flags, assertions, additional logging.

## 🔹 CREATE
### Branch management
- Create a bugfix branch (e.g., `bugfix/<name>` or `hotfix/<ticket>`). Commit atomically.

### Implementation steps
1. Reproduce locally with artifacts; add temporary logging if required.
2. Apply the minimal code change addressing the root cause.
3. Add/adjust logging and safeguards for observability and prevention.
4. Update configuration and documentation where relevant.

### Quality guidelines
- Follow project patterns and style; avoid scope creep.
- Defensive programming for edge cases; avoid performance regressions.
- Keep changes reversible and well-isolated to simplify rollback.

### 4. Quality Gates and Definition of Done

**Bug Fix Quality Gates:**
- Root cause addressed with minimal, surgical changes
- No regression introduced with comprehensive validation
- Rollback procedures validated and remain functional
- Enhanced monitoring/logging added for fix validation
- Test coverage includes regression prevention scenarios
- Documentation updated with fix details and preventive measures

**Validation Requirements:**
- Reproduction scenario no longer triggers the bug
- Related functionality remains unaffected (regression testing)  
- Performance impact measured and within acceptable bounds
- Security implications assessed and addressed
- Backward compatibility maintained

## Handoff
- Open PR for `code_review` and coordinate with `sdlc_test` (renamed)
- Ensure rollback instructions remain valid given the final implementation
- Machine-readable specs updated with fix validation requirements

## Collaboration checkpoints
- Confirm scope and acceptance before code changes.
- Present any necessary trade-offs; request user decision.
- Walk through the diff with user if requested.

## Outputs
- Minimal, well-isolated code changes on a bugfix branch.
- Updated documentation and decision log.
- Ready for testing and deployment commands.

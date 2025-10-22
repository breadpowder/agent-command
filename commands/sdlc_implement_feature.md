# SDLC Implement Feature $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ structure before planning or executing any task.
- Context7 references are highly recommended; use them only when you need to refer to or verify APIs.

## Purpose
Specialized feature implementation that turns a plan into code. This spec defines the
prompting and collaboration model; it does not auto‑run a workflow. Clarification‑first:
reflect user intent, bundle clarifying questions, wait for confirmation, and record
assumptions as “unconfirmed”. Focus on backward compatibility. Use Context7 to validate
APIs/configs during coding.

## Prompt template
- Use a reveal‑gated cadence: after each subtask is completed and self‑verified,
  summarize results and pause. Do not proceed until the user explicitly says "reveal"
  or gives a go‑ahead.
- At each pause, provide short manual verification instructions so the user can
  validate locally before revealing the next step. Include: what to run, expected
  outputs, affected files/paths, and how to roll back if needed.
- Reference the "Expected behavior" captured during planning and state what was observed so the user can compare quickly.
- Commit after each verified subtask: make an atomic commit with message
  `sdlc: <name> - <task summary> complete`, including the updated status log.
- Keep updates brief and actionable; surface blockers and decisions needed.

Recommended prompt (copy/paste):
```text
You are assisting with SDLC feature implementation.
Follow a reveal‑gated flow: after you finish and self‑verify a subtask,
summarize the outcome and stop. Wait for me to reply "reveal" (or give
explicit direction) before you continue. Do not batch steps or proceed
without my go‑ahead. Prioritize backward compatibility and verify API usage
against current documentation. Record assumptions as "unconfirmed" until
validated.

Before pausing, add a "Manual verification" note with steps and commands
I can run to confirm results (and expected outputs). Then wait for me to say
"reveal" to proceed.
```

## Status logging
- Location: `task_<name>/implementation/status.md`
- Purpose: traceable subtask progress and verification notes.
- Tie each entry back to the planning artifact (`tasks.md` task id, expected behavior, guardrail notes) so every commit links to the originating spec item.
- Capture evidence pointers: link Playwright screenshots/videos or API request/response logs that prove the expected behavior.
- Suggested log snippet:
  - `2025-01-01T12:34:56Z — PLAN-01 Setup feature branch`
    - Status: completed (commit abc1234)
    - Expected: new branch `feat/user-auth` exists
    - Observed: `git branch --show-current` -> `feat/user-auth`
    - Evidence: `logs/plan-01-branch.txt`, screenshot `artifacts/plan-01.png` (if applicable)
    - Guardrails: intact (no prod data touched)

- Per-task sections:

```markdown
### PLAN-01 Setup feature branch
Status: completed (commit abc1234) — 2025-01-01T12:34:56Z
Expected behavior: new branch `feat/user-auth` exists and tracks `origin/main`
Observed behavior: `git branch --show-current` outputs `feat/user-auth`; `git rev-parse HEAD` matches plan baseline
Guardrail check: no prod credentials or protected files modified
Verification commands: `git status --short`, `git branch --show-current`
Notes: based off `main@def5678`.
```

## Command Usage
```bash
# GitHub feature implementation
sdlc_implement_feature --source github --name user-auth --type backend --id 123

# Local feature implementation
sdlc_implement_feature --source local --name ui-components --type frontend

# Bitbucket feature implementation
sdlc_implement_feature --source bitbucket --name api-refactor --id 456

# Simple usage (auto-detects everything)
sdlc_implement_feature --name payment-system

# Passing a reveal-gated prompt inline
sdlc_implement_feature --name user-dashboard \
  --prompt "Follow reveal-gated flow; stop after each verified subtask and wait for 'reveal'."
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/task_<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <backend|frontend|fullstack>`: Implementation type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus implementation (optional)
 - `--complexity <small|medium|large>`: Controls optional depth; if omitted, auto-detected

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: <name> - implementation plan confirmed"`
- `git commit -m "sdlc: <name> - core functionality implemented"`
- `git commit -m "sdlc: <name> - configuration and docs updated"`
- `git commit -m "sdlc: <name> - feature implementation complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

Per-task atomic commits
- After each completed and verified subtask, create an atomic commit that includes the
  code changes and the updated `implementation/status.md` entry.
- Recommended message:
  `git commit -m "sdlc: <name> - <task summary> complete"`
- Keep commits focused (one subtask per commit). Reference external IDs when available
  (e.g., `Refs: <id>`) and include a task key (e.g., `TASK-003`) if applicable.

### Outputs
- `task_<name>/implementation/changes/changes.md`
- `task_<name>/implementation/status.md` (with plan task ids, expected vs observed behavior, guardrail checks)

## 🔹 PLAN
### 1. Scope confirmation
- Load planning artifacts: requirements, decision log, task breakdown, pseudocode examples, and any `--context` files
  or `--prompt` details provided.
- **Context7 Documentation Sync**: Refresh library documentation using `mcp_context7_get-library-docs` for any libraries identified in planning to ensure latest API information.
- **Pseudocode Review**: Validate pseudocode examples from planning phase and prepare for implementation.
- Confirm acceptance criteria and out-of-scope items with the user.
- Cross-check the plan's guardrail checklist and unresolved assumptions; get explicit confirmation or updated guidance before coding.
- Link each upcoming implementation subtask to its `plan/tasks/tasks.md` entry, capturing task id, expected behavior, and validation commands in the status log template.
- Initialize status log: create `task_<name>/implementation/status.md` if missing.

### 2. Design choices and options
- **Documentation-Informed Design**: Present focused choices where relevant (API shape, storage format, error strategy) with
  pros/cons and impact on complexity, performance, and compatibility, validated against current Context7 documentation.
- **Topic-Specific Documentation Retrieval**: Use `mcp_context7_get-library-docs` with specific topics (e.g., 'authentication', 'routing', 'database') as implementation needs arise.
- **Pseudocode Refinement**: Update and refine pseudocode based on latest documentation patterns and best practices.
- Decision gate (if needed): briefly record selected options with Context7 references.

### 3. Task breakdown (2-hour rule)
- Sequence tasks for incremental value; keep tasks ≤2h with clear validation criteria.
- Identify integration points and required feature flags or config toggles.
- For each task, restate the "Expected behavior" and "Manual verification" details from planning inside `implementation/status.md` before starting work.

## 🔹 CREATE
### Branch management
- Create a feature branch from the correct base and follow naming conventions
  (`feature/<name>` or `feat/<ticket>`). Commit incrementally and atomically.

### Implementation steps
Follow the vetted plan-first AI breakdown. For each numbered step, reference the corresponding task id, guardrails, and expected behaviors, then log completion details (observed behavior, tests, commit) before proceeding.
1. **Foundation with Context7 Guidance**: Data models, interfaces, configuration scaffolding using current framework patterns from Context7 documentation.
2. **Business logic**: Core functionality behind feature flags where appropriate, implementing pseudocode patterns with Context7-informed best practices.
3. **API/surface**: Endpoints, handlers, UI components, or CLIs as applicable, following current API design patterns from documentation.
4. **Integration**: Connect to dependencies and existing modules using Context7-documented integration patterns and compatibility guidelines.
5. **Observability**: Add logging, metrics, traces with SLO tracking following framework-specific observability patterns.
6. **Backward compatibility**: API versioning, schema evolution, migration safety using documented migration strategies.
7. **Edge cases and failure modes**: Timeouts, retries, idempotency, partial failures following framework error handling patterns.
8. **Rollout preparation**: Feature flags, kill switches, configuration validation using documented deployment strategies.

### Automation-based verification
- **UI layout & behavior**: Use Playwright (or equivalent) to exercise the specified interactions (clicks, form fills, navigation). Capture screenshots after each critical state and compare them against the layout/UI behavior spec; store the diff artifacts in the task workspace and reference them in the status log.
- **API behavior**: Spin up the service (locally or in test env) and run the documented request suites (e.g., Playwright APIRequestContext, HTTP client scripts, curl collections). Validate status codes, payload shapes, headers, and error responses against the API contract, recording the evidence (logs, JSON clips) alongside the status entry.

### Context7 Integration During Implementation
- **Just-in-Time Documentation**: Retrieve specific documentation topics as each implementation step begins
- **Pattern Validation**: Compare implementation against current best practices and patterns
- **API Compatibility**: Validate API usage against latest library documentation
- **Error Handling**: Use documented error handling patterns and exception hierarchies

### Quality guidelines (in-implementation)
- **Error handling**: Follow patterns from USER_LEVEL_CLAUDE.md § "Error Handling and Resilience" (exception hierarchy, graceful degradation) enhanced with Context7-documented framework-specific patterns
- **Security standards**: Apply USER_LEVEL_CLAUDE.md § "Security Standards" (input validation, secrets management, security checklist) validated against current security best practices from Context7
- **Logging**: Use standards from USER_LEVEL_CLAUDE.md § "Logging Standards" (centralized logging, appropriate levels, structured format) following framework-specific logging patterns
- **Testing**: Follow USER_LEVEL_CLAUDE.md § "Testing Guidelines" (pytest, 80% coverage, TDD patterns) using Context7-documented testing frameworks and patterns
- **Performance**: Avoid hotspots, follow USER_LEVEL_CLAUDE.md § "Performance Guidelines" enhanced with framework-specific optimization patterns from Context7
- **Documentation**: Inline docstrings and updates per USER_LEVEL_CLAUDE.md § "Code Quality Standards" following current documentation standards from Context7
- **Context7 Validation**: Continuously validate implementation patterns against latest documentation and best practices

## Handoff
- Open a PR and request review using the repository’s checklist.
- Trigger testing via `sdlc_test` and update coverage where needed.

## Collaboration checkpoints
- Confirm scope and acceptance criteria before coding.
- Present design option trade-offs and request user selection.
- Walk through the PR diff with the user if requested.
- Use reveal‑gated progression: after each completed and verified task,
  pause and wait for an explicit "reveal" from the user before starting the next.
 - After each verified task, append a status entry to
   `task_<name>/implementation/status.md` capturing time, task name, status, commit,
   verification notes, expected vs. observed behavior, and guardrail status.

### 4. Quality Gates and Definition of Done

**Implementation Quality Gates:**
- All acceptance criteria implemented and testable
- API contracts match specifications with examples and error handling
- Observability instrumentation complete (metrics, logs, traces)
- Feature flags configured with kill switches and rollback capability
- Backward compatibility maintained with proper API versioning
- Edge cases handled: timeouts, retries, idempotency, partial failures
- Security validations: input sanitization, auth/authz, secrets management
- Performance considerations: no hotspots, resource-conscious design

**Test Strategy Integration:**
- Unit tests for business logic with clear isolation
- Integration tests for API endpoints and data flows  
- E2E tests for critical user paths and acceptance criteria
- Performance smoke tests with budget enforcement
- Security tests for auth, input validation, and data protection

## Outputs
- Implemented code and configuration on a feature branch
- Updated documentation and decision log with implementation decisions
- Machine-readable specs validated and aligned with implementation
- Ready for `code_review`, `sdlc_test`, and `sdlc_deploy`

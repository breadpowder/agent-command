# SDLC Implement Feature $ARGUMENTS

## Purpose
Specialized feature implementation that turns an approved plan into code. This command focuses on
writing code and related configuration only; testing and deployment are handled by separate
commands.

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
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/feature_<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <backend|frontend|fullstack>`: Implementation type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus implementation (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: <name> - implementation plan confirmed"`
- `git commit -m "sdlc: <name> - core functionality implemented"`
- `git commit -m "sdlc: <name> - configuration and docs updated"`
- `git commit -m "sdlc: <name> - feature implementation complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
### 1. Scope confirmation
- Load planning artifacts: requirements, decision log, task breakdown, pseudocode examples, and any `--context` files
  or `--prompt` details provided.
- **Context7 Documentation Sync**: Refresh library documentation using `mcp_context7_get-library-docs` for any libraries identified in planning to ensure latest API information.
- **Pseudocode Review**: Validate pseudocode examples from planning phase and prepare for implementation.
- Confirm acceptance criteria and out-of-scope items with the user.

### 2. Design choices and options
- **Documentation-Informed Design**: Present focused choices where relevant (API shape, storage format, error strategy) with
  pros/cons and impact on complexity, performance, and compatibility, validated against current Context7 documentation.
- **Topic-Specific Documentation Retrieval**: Use `mcp_context7_get-library-docs` with specific topics (e.g., 'authentication', 'routing', 'database') as implementation needs arise.
- **Pseudocode Refinement**: Update and refine pseudocode based on latest documentation patterns and best practices.
- Decision gate: record selected options in `<name>/plan/decision-log.md` with Context7 documentation references before coding.

### 3. Task breakdown (2-hour rule)
- Sequence tasks for incremental value; keep tasks ≤2h with clear validation criteria.
- Identify integration points and required feature flags or config toggles.

## 🔹 CREATE
### Branch management
- Create a feature branch from the correct base and follow naming conventions
  (`feature/<name>` or `feat/<ticket>`). Commit incrementally and atomically.

### Implementation steps
1. **Foundation with Context7 Guidance**: Data models, interfaces, configuration scaffolding using current framework patterns from Context7 documentation.
2. **Business logic**: Core functionality behind feature flags where appropriate, implementing pseudocode patterns with Context7-informed best practices.
3. **API/surface**: Endpoints, handlers, UI components, or CLIs as applicable, following current API design patterns from documentation.
4. **Integration**: Connect to dependencies and existing modules using Context7-documented integration patterns and compatibility guidelines.
5. **Observability**: Add logging, metrics, traces with SLO tracking following framework-specific observability patterns.
6. **Backward compatibility**: API versioning, schema evolution, migration safety using documented migration strategies.
7. **Edge cases and failure modes**: Timeouts, retries, idempotency, partial failures following framework error handling patterns.
8. **Rollout preparation**: Feature flags, kill switches, configuration validation using documented deployment strategies.

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

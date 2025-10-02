# SDLC Plan Bug $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify APIs.

## Purpose
Specialized bug fix planning that converts confirmed analysis into a concise, low-risk fix plan. Clarification‑First: confirm assumptions, scope, and acceptance criteria. Focus on backward compatibility and rollback. Use Context7 for framework/library best practices. This command does not implement or test the fix.

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
 - `--name <descriptive-name>`: Bug fix workspace name (creates <project_root>/task_<name>/)
 - `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
 - `--type <critical|high|medium|low>`: Bug severity (optional, auto-detected)
 - `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
 - `--context <file|dir>`: Additional context file(s) or directory (optional)
 - `--prompt "<instruction>"`: Inline task prompt to focus planning (optional)
 - `--complexity <small|medium|large>`: Optional; if omitted, auto-detected

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: plan bug <name> - fix strategy analysis complete"`
- `git commit -m "sdlc: <name> - risk assessment and mitigations documented"`
- `git commit -m "sdlc: <name> - rollback plan ready"`
- `git commit -m "sdlc: <name> - bug fix planning complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

### Outputs
- `task_<name>/debug/plan/plan.md` (optional for small bugs if plan is trivial)

## 🔹 PLAN
### 1. Inputs and confirmation
- Import artifacts from `sdlc_reproduce_bug` and `sdlc_analyze_bug`, plus any `--context` files
  and `--prompt` guidance provided by the user.
- **Context7 Documentation Sync**: Resolve library/framework IDs for technologies involved in the bug and retrieve current documentation using `mcp_context7_get-library-docs`.
- **Best Practices Review**: Access current bug fix patterns and error handling documentation for the affected frameworks.
- Confirm root cause, constraints, and acceptance criteria for resolution with documentation-informed analysis.

### 2. Fix options with trade-offs
- **Documentation-Informed Fix Approaches**: Draft 2–3 fix approaches with pros/cons, risk profile, and estimated effort, validated against current framework documentation and best practices.
- **Compatibility Analysis**: Consider scope minimization, compatibility, and regression prevention using Context7-documented migration and compatibility guidelines.
- **Pseudocode Fix Examples**: Generate pseudocode examples for each fix approach showing:
  - Root cause resolution strategy
  - Error handling and validation patterns
  - Integration points and side effects
  - Rollback and recovery mechanisms
- Decision gate: present options with pseudocode examples and record selected approach with Context7 documentation references in `plan/decision-log.md`.

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
<project_root>/task_<name>/
├── plan/
│   ├── fix-strategy.md      # Chosen approach and rationale with Context7 references
│   ├── risk-assessment.md   # Risks and mitigations using framework-specific patterns
│   ├── rollback-plan.md     # Recovery procedures following documented best practices
│   ├── decision-log.md      # Options considered and decision with Context7 documentation
│   └── pseudocode-fixes.md  # Detailed pseudocode for each fix approach and implementation
├── specs/                   # Machine-readable fix specifications
│   ├── test-cases.json      # Regression tests and validation scenarios
│   ├── rollback-config.yaml # Automated rollback triggers and procedures
│   └── monitoring.yaml      # Enhanced monitoring for fix validation
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

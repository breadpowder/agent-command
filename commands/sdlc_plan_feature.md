# SDLC Plan Feature $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify third-party
  APIs.

## Purpose
Translate user requirements into a technical plan focused on implementation feasibility, trade-offs,
and decisions. Produce a clear, scoped task breakdown with acceptance criteria and explicit
technology choices. Avoid heavy architecture unless complexity demands it. Feed the approved spec
into plan-first AI tooling, capture the generated plan artifacts, and hold execution until a human
approves the auditable plan and guardrails.

Clarification‑First: reflect user intent, bundle clarifying questions, wait for confirmation, and record assumptions as “unconfirmed” before proceeding.

## Command Usage
```bash
# GitHub feature planning
sdlc_plan_feature --source github --name user-dashboard --type frontend --id 789

# Local feature planning
sdlc_plan_feature --source local --name payment-system --type backend

# Bitbucket feature planning
sdlc_plan_feature --source bitbucket --name api-redesign --id 456

# Simple usage (auto-detects everything)
sdlc_plan_feature --name mobile-app
```

**Simplified Parameters:**
 - `--name <descriptive-name>`: Workspace name (creates <project_root>/task_<name>/)
 - `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
 - `--type <frontend|backend|fullstack>`: Feature type (optional, auto-detected)
 - `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
 - `--context <file|dir>`: Additional context file(s) or directory (optional)
 - `--prompt "<instruction>"`: Inline task prompt to focus planning (optional)
 - `--complexity <small|medium|large>`: Controls optional artifacts; if omitted, auto-detected

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: plan feature <name> - requirements analysis complete"`
- `git commit -m "sdlc: <name> - architecture options documented"`
- `git commit -m "sdlc: <name> - decision recorded and rationale"`
- `git commit -m "sdlc: <name> - task breakdown complete"`
- `git commit -m "sdlc: <name> - feature planning complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
### Outputs
- `task_<name>/plan/tasks/tasks.md`
- `task_<name>/plan/status.md` (chronological log of tools runs, human approvals, and outstanding guardrails and section with current task execution steps and status)
- Optional (medium/large): `task_<name>/plan/strategy/strategy.md`

### 1. Context gathering and analysis
- Requirement analysis: parse stories, acceptance criteria, constraints, assumptions, plus any
  provided `--context` materials and `--prompt` intent.
- **Library/Framework Identification**: Extract mentioned technologies, libraries, and frameworks from requirements.
- **Context7 Documentation Retrieval**: Use `mcp_context7_resolve-library-id` to resolve library names, then `mcp_context7_get-library-docs` to fetch current documentation for identified technologies.
- Stakeholder mapping: users, internal teams, compliance, external integrations.
- Technical feasibility: identify complexity hot-spots and integration points with documentation-informed analysis.
- Business impact: value, scope boundaries, out-of-scope items.

### 2. Plan-first AI orchestration handshake
- Maintain `task_<name>/plan/status.md` as a running log: timestamp, activity, tool invoked, output summary, and whether human review is required.
- Annotate each extracted task with "Expected behavior" and "Manual verification" sub-sections that the implementation phase must echo back to the user once completed.
- Specify logging expectations per task (which status fields to update after commits, which guardrails to reaffirm) so downstream agents can link actions to the originating spec.
- Flag automation expectations: UI tasks must call out required Playwright skills (clicks, form fills, screenshots to compare against layout specs); API tasks must list the exact request scripts or HTTP clients to validate responses against the contract.
- Flag any AI-generated assumptions or guardrail gaps in `plan/status.md` for immediate human resolution before proceeding.
- Pause for a Human Review Gate: present the synthesized plan, unresolved assumptions, and guardrail checklist and verifiable steps to the user; proceed only after explicit approval.

### 3. Options analysis and decision (Optional for medium+ complexity)
- **Documentation-Informed Architecture**: Use Context7 mcp and documentation to evaluate 2–3 viable approaches with current best practices, pros/cons, and risks.
- **Technology choices**: Alternatives with trade-offs and constraints, validated against latest documentation and compatibility matrices.
- **Data model options**: Implications for migrations and compatibility, informed by current framework documentation.
- **Pseudocode Architecture Generation**: Create high-level pseudocode showing:
  - Main component structure and interactions
  - Data flow patterns between components
  - Integration points with external systems
  - Error handling and recovery patterns
- Decision gate: present options with pseudocode examples to the user and record the selection and rationale in
  `plan/decision-log.md` before proceeding.

### 4. Task breakdown (2-hour rule)
- **Documentation-Enhanced Task Decomposition**: Decompose into independent, verifiable tasks ≤2h each, with Context7 documentation informing implementation approach.
- **Task-Level Pseudocode Generation**: For each task, create structured pseudocode showing:
  - Step-by-step implementation approach
  - Key function/method signatures and structure
  - Data transformation patterns
  - Error handling and validation logic
  - Integration patterns with dependencies
- **Behavioral description**: Capture expected human- and agent-verifiable behaviors per task (inputs, observable outputs, validation commands) so the implementation stage can hand users concrete checks post-commit. For UI tasks, specify the target layout/interaction states and the Playwright actions + screenshot comparisons required; for API tasks, define request/response pairs (including status codes, payload shapes, and error cases) that must be exercised once the service is running.
- **Validation Criteria**: Define validation criteria per task with specific test cases and acceptance criteria.
- **Dependency Mapping**: Explicit dependencies with Context7-informed integration patterns.
- **Risk-Ordered Implementation**: Order for incremental value and early risk reduction based on documentation complexity analysis.

### 5. Planning artifacts and structure
Store planning in a standarized structure
Minimal, one-file-per-leaf (create optional files only when complexity warrants it):
```
<project_root>/task_<name>/
- plan/
  - tasks/tasks.md          # jira format with title, description, dependancies,acceptantace criteria
  - tasks/tasks_details.md # for complicated tasks detail descriptions and limitations, also can use context7 mcp  to explore 3rd party solution and api
  - status.md              # Running log of AI tooling runs and approvals
  - decision-log.md        # Options, pros/cons, with external reference
  - strategy/strategy.md   # optional
```

## Collaboration checkpoints
- Clarify requirements, assumptions, and guardrails with the user; confirm or reclassify unresolved items before analysis continues.
- Present 2–3 option sets with pros/cons; request user selection and record it in `plan/status.md`.
- Share the AI-generated plan artifacts, highlight any guardrail gaps, and wait for explicit human approval before locking the plan.
- Share task breakdown; request approval before freezing the plan.
 - When presenting artifacts, include a brief "Manual verification" guide so the user can
   check outcomes (which files to open, commands to run, expected results) before giving
   the go‑ahead.

### 6. Definition of Ready & Quality Standards

**Definition of Ready - Before Implementation:**
- Requirements analysis complete with clear boundaries and constraints
- **Context7 mcp Documentation Integration**: Resolve libraries/frameworks and fetch current docs for coding tasks
- Architecture options documented only if complexity demands it
- Technology choices justified briefly with latest documentation references (if applicable)
- Task breakdown complete with ≤2h tasks and validation criteria
- Tasks annotated with expected behaviors and user verification cues
- Dependencies mapped with explicit ordering and risk assessment using documentation-informed integration patterns
- Machine-readable specs created (API contracts, config schemas) validated against current standards
- Observability plan defined with metrics, alerts, and SLO targets following framework best practices
- Rollout strategy planned with feature flags and backout procedures
- Decision log updated with selected options, rationale, and Context7 documentation references
- **Pseudocode Validation**: All major components and tasks have clear, implementable pseudocode examples
- Plan status log updated with latest AI tooling runs and human approvals, confirming Guardrails Ready state

**Traceability Requirements:**
- Map Goals → Requirements → Tests → Tasks
- Maintain lightweight matrix (CSV/Markdown) or tags for CI validation
- Each task must reference specific requirements and acceptance criteria

## Outputs
- `task_<name>/plan/tasks/tasks.md`
- `task_<name>/plan/tasks/tasks_details.md`_
- `task_<name>/plan/status.md`
- Optional: `task_<name>/plan/strategy/strategy.md`

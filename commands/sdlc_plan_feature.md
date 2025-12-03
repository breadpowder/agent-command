# SDLC Plan Feature $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify third-party
  APIs.

## Purpose
Translate user requirements into a technical plan focused on implementation feasibility, trade-offs,
and decisions using **Test-Driven Development (TDD)** methodology. Produce a clear, scoped task
breakdown with acceptance criteria, explicit technology choices, and **TDD test specifications**.
Avoid heavy architecture unless complexity demands it. Feed the approved spec into plan-first AI
tooling, capture the generated plan artifacts, and hold execution until a human approves the
auditable plan and guardrails.

Clarification‑First: reflect user intent, bundle clarifying questions, wait for confirmation, and record assumptions as "unconfirmed" before proceeding.

## TDD Planning Mandate
**CRITICAL**: All planning MUST incorporate TDD (Red-Green-Refactor) methodology:

- **Every task** must define tests BEFORE implementation details
- **Acceptance criteria** must be expressed as testable behaviors
- **Task breakdown** must include specific test cases for RED phase
- **Behavior testing** must be planned for each acceptance criterion

The implementation phase will follow strict TDD: write failing tests first (RED), implement
minimal code to pass (GREEN), then refactor while tests stay green.

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

### 4. Task breakdown (2-hour rule) with TDD Specifications
- **Documentation-Enhanced Task Decomposition**: Decompose into independent, verifiable tasks ≤2h each, with Context7 documentation informing implementation approach.

- **TDD Test Specifications (REQUIRED for each task)**:
  Each task MUST include a TDD section specifying:
  ```markdown
  #### TDD Specifications
  **RED Phase - Tests to Write First:**
  - `test_<behavior>`: Tests that <expected behavior from acceptance criteria>
  - `test_<edge_case>`: Tests that <edge case handling>
  - `test_<error_case>`: Tests that <error response>

  **GREEN Phase - Minimal Implementation:**
  - Implement only what's needed to pass the above tests
  - No extra functionality beyond test requirements

  **REFACTOR Phase - Improvements:**
  - Areas to consider: <code structure, naming, DRY>

  **Behavior Tests (Acceptance Criteria Mapping):**
  | Acceptance Criterion | Test Case | Expected Result |
  |---------------------|-----------|-----------------|
  | User can login | `test_login_success` | 200 + JWT token |
  | Invalid creds rejected | `test_login_invalid` | 401 + error msg |
  ```

- **Task-Level Pseudocode Generation**: For each task, create structured pseudocode showing:
  - **Test pseudocode FIRST** (what to test, assertions expected)
  - Step-by-step implementation approach
  - Key function/method signatures and structure
  - Data transformation patterns
  - Error handling and validation logic
  - Integration patterns with dependencies

- **Behavioral description**: Capture expected human- and agent-verifiable behaviors per task (inputs, observable outputs, validation commands) so the implementation stage can hand users concrete checks post-commit. For UI tasks, specify the target layout/interaction states and the Playwright actions + screenshot comparisons required; for API tasks, define request/response pairs (including status codes, payload shapes, and error cases) that must be exercised once the service is running.

- **Acceptance Criteria as Testable Behaviors**:
  - Each acceptance criterion MUST be expressed as a testable behavior
  - Define the test that will verify the criterion
  - Specify expected inputs and outputs
  - Criterion is not complete until its behavior test passes

- **Validation Criteria**: Define validation criteria per task with specific test cases and acceptance criteria.
- **Dependency Mapping**: Explicit dependencies with Context7-informed integration patterns.
- **Risk-Ordered Implementation**: Order for incremental value and early risk reduction based on documentation complexity analysis.

### 5. Planning artifacts and structure
Store planning in a standarized structure
Minimal, one-file-per-leaf (create optional files only when complexity warrants it):
```
<project_root>/task_<name>/
- plan/
  - tasks/tasks.md          # jira format with title, description, dependencies, acceptance criteria, TDD specs
  - tasks/tasks_details.md  # for complicated tasks: detail descriptions, TDD test cases, behavior tests
  - status.md               # Running log of AI tooling runs and approvals
  - decision-log.md         # Options, pros/cons, with external reference
  - strategy/strategy.md    # optional
```

### Task Format with TDD (tasks.md)
Each task in tasks.md MUST follow this TDD-enhanced format:
```markdown
## TASK-01: <Task Title>
**Description**: <What this task accomplishes>
**Dependencies**: <List of prerequisite tasks>
**Estimated Time**: ≤2 hours

### Acceptance Criteria
- [ ] AC1: <Testable behavior description>
- [ ] AC2: <Testable behavior description>

### TDD Specifications
#### RED Phase (Write Failing Tests First)
| Test Name | Tests That | Expected Failure |
|-----------|------------|------------------|
| `test_ac1_happy_path` | AC1 is satisfied | NotImplementedError |
| `test_ac1_edge_case` | Edge case handled | AssertionError |
| `test_ac2_validation` | AC2 validation | ValidationError |

#### GREEN Phase (Minimal Implementation)
- Implement only what's needed to pass above tests
- No extra features beyond test requirements

#### REFACTOR Phase
- Code cleanup while tests stay green
- Consider: naming, DRY, structure

### Behavior Tests (Required)
| Acceptance Criterion | Behavior Test | Verification Command |
|---------------------|---------------|---------------------|
| AC1 | `test_ac1_behavior` | `pytest tests/test_feature.py::test_ac1_behavior -v` |
| AC2 | `test_ac2_behavior` | `pytest tests/test_feature.py::test_ac2_behavior -v` |

### Verification
- Manual verification steps: <commands to run>
- Expected output: <what success looks like>
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
- **TDD Specifications Complete**: Each task has RED/GREEN/REFACTOR phases defined
- **Behavior Tests Mapped**: Every acceptance criterion has a corresponding behavior test
- Tasks annotated with expected behaviors and user verification cues
- Dependencies mapped with explicit ordering and risk assessment using documentation-informed integration patterns
- Machine-readable specs created (API contracts, config schemas) validated against current standards
- Observability plan defined with metrics, alerts, and SLO targets following framework best practices
- Rollout strategy planned with feature flags and backout procedures
- Decision log updated with selected options, rationale, and Context7 documentation references
- **Pseudocode Validation**: All major components and tasks have clear, implementable pseudocode examples
- **Test Pseudocode First**: Test cases defined before implementation pseudocode
- Plan status log updated with latest AI tooling runs and human approvals, confirming Guardrails Ready state

**Traceability Requirements:**
- Map Goals → Requirements → Tests → Tasks
- Maintain lightweight matrix (CSV/Markdown) or tags for CI validation
- Each task must reference specific requirements and acceptance criteria

## Outputs
- `task_<name>/plan/tasks/tasks.md` - Task breakdown with TDD specifications for each task
- `task_<name>/plan/tasks/tasks_details.md` - Critical task details including:
  - TDD test case specifications
  - Behavior test definitions for acceptance criteria
  - Integration patterns and 3rd party API references
  - (No real code implementation - refer to file names to be created)
- `task_<name>/plan/status.md` - Running log with TDD readiness confirmation
- Optional: `task_<name>/plan/strategy/strategy.md`

## TDD Readiness Checklist (Must be verified before implementation)
- [ ] Every task has RED phase tests defined
- [ ] Every acceptance criterion has a behavior test mapped
- [ ] Test verification commands are specified
- [ ] Expected test outputs are documented
- [ ] status.md confirms TDD specifications are complete

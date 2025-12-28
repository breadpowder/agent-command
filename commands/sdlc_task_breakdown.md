# SDLC Task Breakdown $ARGUMENTS

## Context First
- Gather relevant context from the existing `task_<name>/` structure, specifically the Phase 1 outputs from `sdlc_plan_first`.
- This command requires Phase 1 (Planning and Strategy) to be completed first.

## Purpose
Execute the **second phase** of feature planning: transform the implementation strategy into a detailed, JIRA-formatted task breakdown. All output is documented exclusively in `tasks.md` - no "busy work" coding files.

**Two-Phase Approach**: This command focuses exclusively on Task Breakdown. Use `sdlc_plan_first` for Phase 1 (Planning and Strategy).

**Key Principles**:
- All work documented exclusively in `tasks.md`
- JIRA format for every task
- Pseudocode limited to 10 lines maximum per case
- Goal: Simplify review without generating busy work

Clarification-First: reflect user intent, bundle clarifying questions, wait for confirmation, and record assumptions as "unconfirmed" before proceeding.

## Command Usage
```bash
# Continue from Phase 1 planning
sdlc_task_breakdown --name user-dashboard

# With additional context
sdlc_task_breakdown --name payment-system --context additional-requirements.md

# With inline prompt for focus
sdlc_task_breakdown --name api-redesign --prompt "focus on authentication tasks first"
```

**Parameters:**
- `--name <descriptive-name>`: Workspace name (reads from `<project_root>/task_<name>/`)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus breakdown (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: <name> - task breakdown complete"`
- `git commit -m "sdlc: <name> - feature planning complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## Outputs
- `task_<name>/plan/tasks/tasks.md` - Complete task breakdown in JIRA format (PRIMARY OUTPUT)
- `task_<name>/plan/tasks/tasks_details.md` - For complicated tasks: detail descriptions, TDD test cases, behavior tests
- `task_<name>/plan/status.md` - Updated with Phase 2 activities and approvals

---

## 🔹 PHASE 2: TASK BREAKDOWN

### Prerequisites - Phase 1 & Review Outputs Required

Before running this command, verify these outputs exist:

**From `sdlc_plan_first` (Phase 1)**:
| File | Purpose | Required |
|------|---------|----------|
| `task_<name>/plan/status.md` | Running log of planning activities | Yes |
| `task_<name>/plan/decision-log.md` | Technology decisions and rationale | Yes |
| `task_<name>/plan/strategy/architecture.md` | Component diagrams and data flow | Yes |
| `task_<name>/plan/strategy/implementation_plan.md` | **PRIMARY**: Integration contracts and feature details | Yes |

**From `sdlc_review_plan` (Review Gate)**:
| File | Purpose | Required |
|------|---------|----------|
| `task_<name>/plan/review/review-report.md` | Review verdict, proposed updates, deletion approvals | Yes |

**Workflow Order**:
```
sdlc_prd_feature → sdlc_plan_first → sdlc_review_plan → sdlc_task_breakdown
```

If missing, run upstream commands first:
```bash
sdlc_plan_first --name <name>    # Create implementation plan
sdlc_review_plan --name <name>   # Review and approve plan
```

**IMPORTANT**: Task breakdown should only proceed if review verdict is 🟢 Approved or 🟡 Concerns (with user acknowledgment). Do NOT proceed if 🔴 Blocked.

---

### Step 1: Read Phase 1 & Review Context

**Activities**:
- Read `task_<name>/plan/review/review-report.md` for:
  - **Review verdict** (must be 🟢 Approved or 🟡 Concerns acknowledged)
  - **Proposed file updates** (Section 6) - ensure these were applied to input files
  - **Approved deletion candidates** (Section 6.5) - these become cleanup tasks
- Read `task_<name>/plan/strategy/implementation_plan.md` for:
  - Problem statement and goals
  - Feature planning details
  - **Integration contracts** (API endpoints, data contracts, component specs, user input specs)
  - Data models (schema)
- Read `task_<name>/plan/strategy/architecture.md` for:
  - Component diagrams
  - Data flow diagrams
  - Control flow
- Read `task_<name>/plan/decision-log.md` for:
  - Technology choices and rationale
  - Alternatives considered
- Note dependencies and integration points from contracts

**Review Report Validation**:
| Check | Action if Failed |
|-------|------------------|
| Verdict is 🔴 Blocked | STOP - return to `sdlc_plan_first` to fix issues |

---

### Step 2: Decompose into Tasks (2-hour rule)

**Objective**: Break implementation plan into independent, verifiable tasks.

**Task Decomposition Rules**:
1. Each task ≤2 hours estimated effort
2. Each task independently verifiable
3. Clear dependency ordering
4. Risk-ordered implementation (high-risk first)
5. Incremental value delivery

**TDD Planning Mandate**:
- **Every task** must define tests BEFORE implementation details
- **Acceptance criteria** must be expressed as testable behaviors
- **Task breakdown** must include specific test cases for RED phase

**Integration Contract Mapping**:
- Each API endpoint from `implementation_plan.md` → at least one task
- Each component integration spec → task with contract reference
- Each data model → schema/migration task
- Each user input spec → validation task

---

### Step 3: Document in JIRA Format

**Output File**: `task_<name>/plan/tasks/tasks.md`

Each task MUST follow this JIRA format:

```markdown
# Task Breakdown: <Feature Name>

**Generated From**: Phase 1 Implementation Plan (`implementation_plan.md`)
**Total Tasks**: <count>
**Estimated Total Effort**: <hours>

---

## References (from Phase 1)
- **Implementation Plan**: `plan/strategy/implementation_plan.md`
- **Architecture**: `plan/strategy/architecture.md`
- **Decisions**: `plan/decision-log.md`

---

## TASK-001: <Task Title>

### Task Description
<Clear, concise description of what this task accomplishes. 2-3 sentences maximum.>

### Task Priority
**Priority**: P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)

### Dependencies
- **Blocked By**: <TASK-XXX or "None">
- **Blocks**: <TASK-XXX or "None">

### Integration Contract Reference
- **Contract**: <Reference to specific contract in implementation_plan.md Section 4>
- **Type**: API Endpoint / Data Contract / Component Spec / User Input Spec

### Task Steps
1. <Step 1 - specific action>
2. <Step 2 - specific action>
3. <Step 3 - specific action>
4. <Step 4 - specific action>
5. <Step 5 - specific action>

### Acceptance Criteria
- [ ] AC1: <Specific, testable criterion>
- [ ] AC2: <Specific, testable criterion>
- [ ] AC3: <Specific, testable criterion>

### Pseudocode (Optional - Max 10 lines)
```pseudo
// Only include if implementation approach needs clarification
// Maximum 10 lines
function example():
    input = get_user_input()
    validated = validate(input)
    if not validated:
        return error
    result = process(validated)
    return result
```

---

## TASK-002: <Next Task Title>
<same structure>
```

---

### Step 4: Document Task Details (for complicated tasks)

**Output File**: `task_<name>/plan/tasks/tasks_details.md`

For complicated tasks that need more detail, document:

```markdown
# Task Details: <Feature Name>

## TASK-XXX: <Task Title> - Details

### Integration Contract Implementation
**From Strategy Section 4.x**: <contract name>

**Contract Spec**:
| Field | Type | Validation | Notes |
|-------|------|------------|-------|
<copy relevant fields from implementation_plan.md>

### TDD Specifications

#### RED Phase (Write Failing Tests First)
| Test Name | Tests That | Expected Failure |
|-----------|------------|------------------|
| `test_ac1_happy_path` | AC1 is satisfied | NotImplementedError |
| `test_ac1_edge_case` | Edge case handled | AssertionError |

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

### Integration Patterns
- <Integration point 1>: <pattern to use>
- <Integration point 2>: <pattern to use>

### 3rd Party API References
- <API name>: <Context7 doc reference or link>
```

**Note**: No real code implementation - refer to file names to be created.

---

## JIRA Field Definitions

### Task Title
- Format: Verb + Object + Context
- Examples:
  - "Implement POST /api/v1/users endpoint"
  - "Add validation for registration form"
  - "Create users table migration"
- Keep under 80 characters

### Task Description
- What this task accomplishes (not how)
- Reference to integration contract
- 2-3 sentences maximum
- No implementation details here

### Task Priority

| Priority | Definition | Examples |
|----------|------------|----------|
| P0 (Critical) | Blocks all other work, security issue | Auth system, core API |
| P1 (High) | Core functionality, many dependents | Main features, data models |
| P2 (Medium) | Important but not blocking | UI polish, optimizations |
| P3 (Low) | Nice to have, can defer | Documentation, minor UX |

### Integration Contract Reference
Each task should reference the specific contract from `implementation_plan.md`:
- `Section 4.1`: API Endpoints
- `Section 4.2`: Frontend-Backend Data Contracts
- `Section 4.3`: Component Integration Specs
- `Section 4.4`: User Input Specs
- `Section 5`: Data Models

### Task Steps
- 5-10 specific, actionable steps
- Each step is a discrete action
- Steps should be completable in order
- Include file paths where relevant
- Reference architecture.md for component locations
- No pseudocode in steps (use Pseudocode section)

### Acceptance Criteria
- Testable and verifiable
- Written as "Given/When/Then" or checkbox format
- Each criterion maps to a specific behavior
- Include edge cases and error scenarios
- Must match contract specs from implementation_plan.md

### Pseudocode Constraints
**STRICT LIMIT**: Maximum 10 lines per task

When to include pseudocode:
- Complex algorithms or logic flows
- Non-obvious integration patterns
- Data transformation sequences
- Error handling approaches

When NOT to include:
- Standard CRUD operations
- Simple UI components
- Straightforward API calls
- Well-documented library usage

---

## Task Ordering Strategy

### Dependency Graph Based on Architecture
Reference `architecture.md` for component dependencies:
```
TASK-001: Database Schema (No dependencies)
    └── TASK-002: Backend API Endpoints (Depends on schema)
        └── TASK-004: Frontend API Integration (Depends on API)
    └── TASK-003: Data Models (Depends on schema)
        └── TASK-005: Business Logic (Depends on models)
```

### Contract-Driven Ordering
1. **Data Models first**: Tasks implementing Section 5 schemas
2. **API Endpoints**: Tasks implementing Section 4.1 contracts
3. **Data Contracts**: Tasks implementing Section 4.2 contracts
4. **Component Integration**: Tasks implementing Section 4.3 specs
5. **User Input**: Tasks implementing Section 4.4 validation

### Risk-First Ordering
Within each dependency level, order by risk:
1. **High-risk tasks first**: Unknowns, integrations, new tech
2. **Core functionality**: Main features that others depend on
3. **Standard work**: Well-understood, low-risk tasks
4. **Polish and optimization**: UI improvements, performance

---

## Collaboration Checkpoints

1. **After Initial Breakdown**: Present task list for structure review
2. **After Contract Mapping**: Verify all contracts have corresponding tasks
3. **After Priority Assignment**: Confirm priority ordering is correct
4. **After Dependency Mapping**: Verify dependency graph makes sense
5. **Final Review**: Get explicit approval before considering planning complete

---

## Definition of Ready for Implementation

Before proceeding to `sdlc_implement_feature`, verify:

**Review Gate (from `sdlc_review_plan`)**:
- [ ] Review verdict is 🟢 Approved or 🟡 Concerns (acknowledged)
- [ ] Proposed file updates (Section 6) applied to input files
- [ ] All deletion candidates approved, rejected, or deferred
- [ ] Deletion tasks created for approved candidates

**Phase 1 & 2 Artifacts**:
- [ ] All Phase 1 artifacts read and understood
- [ ] All tasks in JIRA format in `tasks.md`
- [ ] Each task ≤2 hours estimated
- [ ] **All integration contracts mapped to tasks**:
  - [ ] Every API endpoint has implementation task(s)
  - [ ] Every data contract has implementation task(s)
  - [ ] Every component spec has integration task(s)
  - [ ] Every user input spec has validation task(s)
  - [ ] Every data model has schema/migration task(s)
- [ ] All dependencies mapped correctly (using architecture.md)
- [ ] Priorities assigned and justified
- [ ] Acceptance criteria are testable and match contract specs
- [ ] Pseudocode within 10-line limit where included
- [ ] TDD specifications complete for each task
- [ ] Behavior tests mapped to acceptance criteria
- [ ] `tasks_details.md` created for complicated tasks
- [ ] `status.md` updated with Phase 2 completion
- [ ] User has approved the task breakdown

---

## TDD Readiness Checklist

- [ ] Every task has RED phase tests defined
- [ ] Every acceptance criterion has a behavior test mapped
- [ ] Test verification commands are specified
- [ ] Expected test outputs are documented
- [ ] status.md confirms TDD specifications are complete

---

## Contract Coverage Verification

Before finalizing, verify all contracts from `implementation_plan.md` are covered:

| Contract Type | Section | Tasks Covering |
|--------------|---------|----------------|
| API Endpoints | 4.1 | TASK-xxx, TASK-xxx |
| Data Contracts | 4.2 | TASK-xxx, TASK-xxx |
| Component Specs | 4.3 | TASK-xxx, TASK-xxx |
| User Input Specs | 4.4 | TASK-xxx, TASK-xxx |
| Data Models | 5 | TASK-xxx, TASK-xxx |

---

## Deletion/Cleanup Tasks (From Review Report)

For each **approved** deletion candidate from `review-report.md` Section 6.5, create a cleanup task:

```markdown
## TASK-XXX: Remove deprecated <component>

### Task Description
Remove outdated component that has been replaced by new implementation.
Approved in plan review on <date>.

### Task Priority
**Priority**: P3 (Low) - Execute AFTER new implementation is verified

### Dependencies
- **Blocked By**: TASK-xxx (new replacement must be deployed first)
- **Blocks**: None

### Task Steps
1. Verify new replacement is deployed and working
2. Search for remaining references to old component
3. Update/remove references found
4. Delete the deprecated file(s)
5. Run full test suite to verify no regressions
6. Update documentation to remove old references

### Acceptance Criteria
- [ ] AC1: New replacement is verified working in production
- [ ] AC2: No remaining imports/references to old component
- [ ] AC3: All tests pass after deletion
- [ ] AC4: Documentation updated
```

**IMPORTANT**: Deletion tasks should be scheduled AFTER the new implementation tasks are complete and verified.

---

## Next Steps

Once Phase 2 is complete and approved, proceed to implementation:
```bash
sdlc_implement_feature --name <same-name>
```

This will read the task breakdown and implement each task following TDD methodology, using the integration contracts from `implementation_plan.md` as the source of truth.

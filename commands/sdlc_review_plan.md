# SDLC Review Plan $ARGUMENTS

## Context First
- Gather relevant context from the existing `task_<name>/` structure before executing review.
- This command requires outputs from `sdlc_prd_feature` (specs) and `sdlc_plan_first` (implementation plan).

## Purpose
Execute a **mandatory review gate** between planning (Phase 1) and task breakdown (Phase 2). Reviews specs and implementation plan for consistency, completeness, and feasibility through three sequential reviewer personas: Product, Architecture, and QA.

**Key Principle**: No task breakdown until plan is reviewed and approved. Blocking issues must be resolved before proceeding.

## Command Usage
```bash
# Review plan for a feature
sdlc_review_plan --name user-dashboard

# With additional context
sdlc_review_plan --name payment-system --context tech-constraints.md

# With inline prompt for focus
sdlc_review_plan --name api-redesign --prompt "focus on security aspects"
```

**Parameters:**
- `--name <descriptive-name>`: Workspace name (reads from `<project_root>/task_<name>/`)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline prompt to focus review (optional)

**Automatic Git Commits:**
- `git commit -m "sdlc: review plan <name> - review report complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## Prerequisites - Required Input Files

### From `sdlc_prd_feature` (Specs)
| File | Purpose | Required |
|------|---------|----------|
| `task_<name>/specs/feature-spec.md` | PRD: user requirements and value | Yes |
| `task_<name>/specs/user-stories.md` | User stories and acceptance criteria | Yes |
| `task_<name>/specs/business-case.md` | Business justification | Optional |

### From `sdlc_plan_first` (Implementation Plan)
| File | Purpose | Required |
|------|---------|----------|
| `task_<name>/plan/strategy/implementation_plan.md` | Integration contracts and feature details | Yes |
| `task_<name>/plan/strategy/architecture.md` | Component diagrams and data flow | Yes |
| `task_<name>/plan/decision-log.md` | Technology decisions and rationale | Yes |
| `task_<name>/plan/status.md` | Planning activities log | Yes |

If missing, run upstream commands first:
```bash
sdlc_prd_feature --name <name>      # Create specs
sdlc_plan_first --name <name>       # Create implementation plan
```

## Output

### Primary Output
- `task_<name>/plan/review/review-report.md` - Comprehensive review report with verdict

### Proposed Updates to Input Files
The review generates actionable updates for each input file. These are appended to the review report under "Proposed File Updates" section:

| Input File | Update Type | Content |
|------------|-------------|---------|
| `plan/strategy/implementation_plan.md` | Section additions | Missing contracts, error scenarios, edge cases |
| `plan/strategy/architecture.md` | Diagram updates | Missing components, data flow corrections |
| `plan/decision-log.md` | New decisions | Unresolved assumptions, technology choices |
| `plan/status.md` | Status entries | Review findings, blocking issues, next actions |

**Format in Review Report**:
```markdown
## 6. Proposed File Updates

### 6.1 Updates to `implementation_plan.md`
#### Add to Section 4.1 (API Endpoints)
- Add error response for 429 Rate Limited
- Add timeout handling specification

#### Add to Section 4.4 (User Input Specs)
- Add validation for edge case: empty string vs null

### 6.2 Updates to `architecture.md`
#### Add to Component Diagram
- Add CacheService component between API Gateway and Services

### 6.3 Updates to `decision-log.md`
#### New Decision Required
- Decision: Retry strategy for external API calls
- Options: Exponential backoff vs fixed interval vs circuit breaker

### 6.4 Updates to `status.md`
#### Append Review Entry
- [DATE] Review completed - 2 blocking issues, 5 warnings
- Action: Address blocking issues before task breakdown

### 6.5 Deletion Tasks (User Approved)
#### Files/Components to Remove
| Component | Action | Approved |
|-----------|--------|----------|
| `services/auth_v1.py` | Delete after new auth deployed | ✅ Yes |
| `utils/legacy.js` | Remove deprecated functions | ✅ Yes |
```

---

## 🔹 REVIEW PIPELINE (Sequential)

```
┌─────────────────────────────────────────────────────────────────┐
│                    REVIEW PIPELINE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Stage 1: PRODUCT REVIEW                                        │
│   ├── Specs vs Implementation Plan alignment                     │
│   ├── User story coverage validation                             │
│   └── Assumption verification                                    │
│            │                                                     │
│            ▼ (findings passed)                                   │
│   Stage 2: ARCHITECTURE REVIEW                                   │
│   ├── Plan-Architecture consistency                              │
│   ├── Integration contract completeness                          │
│   ├── Codebase scan: patterns, anti-patterns, standards          │
│   ├── Impact analysis: deletion candidates (⚠️ user approval)    │
│   └── Technical feasibility assessment                           │
│            │                                                     │
│            ▼ (findings passed)                                   │
│   Stage 3: QA REVIEW                                             │
│   ├── Acceptance criteria testability                            │
│   ├── Test coverage gaps                                         │
│   └── Edge cases and failure modes                               │
│            │                                                     │
│            ▼                                                     │
│   GENERATE VERDICT + REPORT                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Stage 1: Product Review

**Persona**: Product Reviewer - ensures plan delivery aligns with product requirements.

### 1.1 Spec-Plan Alignment Check

**Objective**: Verify every user story and requirement is addressed in the implementation plan.

**Activities**:
- Read `specs/feature-spec.md` and `specs/user-stories.md`
- Read `plan/strategy/implementation_plan.md` Section 3 (Feature Planning Details)
- Map each user story to implementation plan sections
- Identify gaps where stories are not addressed

**Checklist**:
| Check | Question |
|-------|----------|
| US Coverage | Is every user story mapped to implementation plan sections? |
| AC Coverage | Are all acceptance criteria addressable by the plan? |
| Scope Match | Does plan scope match spec scope (no scope creep or omissions)? |
| Priority Alignment | Are high-priority stories addressed first in plan phases? |

### 1.2 Assumption Validation

**Objective**: Verify planning assumptions align with product intent and are validated.

**Activities**:
- Extract assumptions from `plan/status.md` and `plan/decision-log.md`
- Cross-reference with `specs/feature-spec.md` constraints and requirements
- Flag unvalidated assumptions that could impact delivery

**Checklist**:
| Check | Question |
|-------|----------|
| Assumption Source | Are assumptions traced back to specs or user research? |
| Validation Status | Are critical assumptions validated or still "unconfirmed"? |
| Risk Impact | Do unvalidated assumptions pose delivery risk? |

### 1.3 Product Verdict

**Output findings for Stage 1**:
- List of user stories with coverage status
- List of assumptions with validation status
- Blocking issues (if any)
- Warnings and recommendations

---

## Stage 2: Architecture Review

**Persona**: Architecture Reviewer - ensures technical plan is sound and consistent.

### 2.1 Plan-Architecture Consistency

**Objective**: Verify implementation plan and architecture diagram are aligned.

**Activities**:
- Read `plan/strategy/implementation_plan.md` Section 3-5
- Read `plan/strategy/architecture.md` component and data flow diagrams
- Verify all planned components appear in architecture
- Verify data flows match integration contracts

**Checklist**:
| Check | Question |
|-------|----------|
| Component Coverage | Does every planned feature have architecture components? |
| Data Flow Match | Do architecture data flows match contract definitions? |
| Integration Points | Are all external integrations shown in architecture? |
| Consistency | No contradictions between plan and architecture? |

### 2.2 Integration Contract Completeness

**Objective**: Verify all integration contracts are fully specified.

**Activities**:
- Review `implementation_plan.md` Section 4 (Integration Contracts)
- Check API endpoints have request/response specs
- Check data contracts have field definitions
- Check component specs have props/events defined
- Check user input specs have validation rules

**Checklist**:
| Contract Type | Complete Spec Includes |
|--------------|------------------------|
| API Endpoints | Method, path, request body, response, error codes |
| Data Contracts | All fields with types, nullability, validation |
| Component Specs | Props interface, events emitted, data flow |
| User Input Specs | Fields, validation rules, error messages |
| Data Models | Schema, constraints, indexes, relationships |

### 2.3 Codebase Scan (Medium Depth)

**Objective**: Scan existing codebase for patterns, anti-patterns, and standardization issues.

**Activities**:
- Explore existing code structure and patterns
- Identify reusable components/services relevant to the plan
- Search for anti-patterns that plan should avoid or address
- Check naming conventions and standards for consistency

**Scan Categories**:

| Category | What to Look For |
|----------|------------------|
| 🔴 **Red Flags** | Security issues, hardcoded secrets, deprecated APIs |
| 🟡 **Caveats** | Missing error handling, no retry logic, tight coupling |
| 🟢 **Good Practices** | Consistent patterns to follow, reusable abstractions |
| 📏 **Standards** | Naming conventions, file structure, import patterns |

**Anti-Pattern Search**:
```
Search for:
- Hardcoded URLs/ports/secrets
- Empty catch blocks
- Missing null checks
- Duplicate code that should be abstracted
- Inconsistent naming (snake_case vs camelCase)
- Direct dependencies that should be injected
```

**Standardization Check**:
```
Verify plan follows existing patterns for:
- API endpoint naming conventions
- Error response format
- Logging patterns
- Test file organization
- Component structure
```

### 2.4 Impact Analysis - Codebase Refresh

**Objective**: Identify outdated components that can be removed/deprecated due to the new feature.

**Activities**:
- Search for code that will be replaced by new implementation
- Identify deprecated patterns the new feature supersedes
- Find dead code paths that new feature makes obsolete
- Locate duplicate functionality being consolidated
- Check for legacy workarounds that new architecture eliminates

**Search Targets**:
```
Identify candidates for removal:
- Old implementations being replaced by new feature
- Deprecated API endpoints superseded by new contracts
- Legacy components the new architecture obsoletes
- Workaround code that proper implementation eliminates
- Redundant utilities consolidated in new design
- Unused imports/dependencies after migration
```

**Output Format - Deletion Candidates**:
| Component | Location | Reason for Removal | Confidence | Requires Approval |
|-----------|----------|-------------------|------------|-------------------|
| `OldAuthService` | `services/auth_v1.py` | Replaced by new JWT implementation | High | ⚠️ Yes |
| `legacyValidation()` | `utils/validate.js:45` | New validation in form contracts | Medium | ⚠️ Yes |
| `/api/v1/users` | `routes/users_old.py` | Superseded by `/api/v2/users` | High | ⚠️ Yes |

**IMPORTANT**: All deletion candidates require explicit user approval before proceeding. Do NOT recommend removal without user confirmation.

**Codebase Refresh Checklist**:
| Check | Question |
|-------|----------|
| Replacement Ready | Is the new implementation complete before removing old? |
| Backward Compat | Are there external consumers of the old code? |
| Migration Path | Is there a clear migration from old to new? |
| Rollback Safety | Can we restore if deletion causes issues? |

### 2.5 Architecture Verdict

**Output findings for Stage 2**:
- Plan-architecture consistency issues
- Contract completeness gaps
- Codebase scan findings (red flags, caveats, good practices)
- Standardization recommendations
- **Deletion candidates identified (pending user approval)**
- Blocking issues (if any)

---

## Stage 3: QA Review

**Persona**: QA Reviewer - ensures plan is testable and quality standards are met.

### 3.1 Testability Assessment

**Objective**: Verify all acceptance criteria can be tested.

**Activities**:
- Review acceptance criteria from `specs/user-stories.md`
- Review implementation plan for test strategy
- Identify criteria that are vague or untestable
- Recommend test types for each criterion

**Checklist**:
| Check | Question |
|-------|----------|
| Measurable | Can each criterion be measured/verified? |
| Automatable | Can tests be automated (E2E, integration)? |
| Independent | Can criteria be tested independently? |
| Repeatable | Will tests produce consistent results? |

### 3.2 Test Coverage Gap Analysis

**Objective**: Identify testing gaps in the plan.

**Activities**:
- Map acceptance criteria to planned test types
- Identify criteria without test coverage
- Check for missing integration test scenarios
- Verify E2E happy path and error paths covered

**Coverage Matrix**:
| Scenario Type | Should Have |
|--------------|-------------|
| Happy Path | E2E test for main user flow |
| Error Handling | Tests for each error response in contracts |
| Edge Cases | Tests for boundary conditions |
| Integration | Tests for each external integration |
| Performance | Load/stress tests if NFRs defined |

### 3.3 Edge Cases and Failure Modes

**Objective**: Identify unaddressed edge cases and failure scenarios.

**Activities**:
- Review contracts for missing error scenarios
- Identify failure modes not addressed in plan
- Check for timeout, retry, idempotency considerations
- Verify rollback/recovery scenarios planned

**Common Failure Modes to Check**:
| Failure Mode | Plan Should Address |
|--------------|---------------------|
| Network timeout | Retry logic, timeout values |
| Invalid input | Validation and error messages |
| Partial failure | Transaction rollback, consistency |
| Rate limiting | Backoff strategy |
| Concurrent access | Locking, optimistic concurrency |
| Data corruption | Validation, recovery procedures |

### 3.4 QA Verdict

**Output findings for Stage 3**:
- Testability issues with acceptance criteria
- Test coverage gaps
- Unaddressed edge cases and failure modes
- Blocking issues (if any)

---

## Issue Severity Levels

| Level | Icon | Definition | Blocks Proceeding? |
|-------|------|------------|-------------------|
| **Critical** | 🔴 | User story not addressed, security gap, architectural flaw | **Yes** |
| **Warning** | 🟡 | Missing error handling, incomplete contract, coverage gap | No (flagged) |
| **Info** | 🟢 | Suggestion for improvement, optimization opportunity | No |

---

## Output: Review Report Structure

**File**: `task_<name>/plan/review/review-report.md`

```markdown
# Plan Review Report: <feature-name>

**Review Date**: <date>
**Reviewer**: AI Plan Reviewer (Product → Architecture → QA)
**Status**: 🔴 Blocked / 🟡 Concerns / 🟢 Approved

---

## Executive Summary

<2-3 sentence summary of review findings and recommendation>

---

## 1. Product Review

### 1.1 Spec-Plan Alignment

| User Story | Status | Implementation Ref | Gap/Issue |
|------------|--------|-------------------|-----------|
| US-001: <title> | ✅ Covered | Section 3.1 | - |
| US-002: <title> | ⚠️ Partial | Section 3.2 | Missing error scenario |
| US-003: <title> | 🔴 Missing | - | Not addressed in plan |

### 1.2 Assumption Validation

| Assumption | Source | Status | Risk |
|------------|--------|--------|------|
| <assumption 1> | Spec Section 2 | ✅ Validated | Low |
| <assumption 2> | Decision-log | ⚠️ Unconfirmed | Medium |
| <assumption 3> | Implicit | 🔴 Unvalidated | High |

### 1.3 Product Verdict

**Status**: ✅ Pass / ⚠️ Concerns / 🔴 Blocking Issues

**Summary**: <findings summary>

**Blocking Issues**:
- <issue 1 if any>

**Warnings**:
- <warning 1>

---

## 2. Architecture Review

### 2.1 Plan-Architecture Consistency

| Component | In Plan | In Architecture | Aligned |
|-----------|---------|-----------------|---------|
| <component 1> | ✅ | ✅ | ✅ |
| <component 2> | ✅ | ❌ Missing | 🔴 Gap |

### 2.2 Integration Contract Completeness

| Contract | Section | Status | Missing |
|----------|---------|--------|---------|
| API: POST /api/users | 4.1 | ⚠️ Incomplete | Error responses |
| Data: UserDTO | 4.2 | ✅ Complete | - |
| Component: FormInput | 4.3 | ✅ Complete | - |

### 2.3 Codebase Scan Findings

#### 🔴 Red Flags
| Location | Issue | Recommendation |
|----------|-------|----------------|
| `services/auth.py:45` | Hardcoded API key | Move to .env, plan should use config pattern |

#### 🟡 Caveats
| Location | Issue | Recommendation |
|----------|-------|----------------|
| `lib/api/client.ts` | No retry logic | Plan should include retry strategy |

#### 🟢 Good Practices to Follow
| Location | Pattern | Apply To |
|----------|---------|----------|
| `components/forms/` | Consistent validation pattern | New form components |

#### 📏 Standardization Notes
| Standard | Current | Plan Should |
|----------|---------|-------------|
| API naming | `/api/v1/<resource>` | Follow same pattern |
| Error format | `{error, message, details}` | Use same structure |

### 2.4 Deletion Candidates (Requires User Approval)

| Component | Location | Reason for Removal | Confidence | Approved |
|-----------|----------|-------------------|------------|----------|
| `OldService` | `services/old.py` | Replaced by new implementation | High | ⏳ Pending |
| `legacyFunc()` | `utils/legacy.js:23` | Superseded by new contracts | Medium | ⏳ Pending |

**⚠️ User Action Required**: Review each candidate and confirm approval before task breakdown.

### 2.5 Architecture Verdict

**Status**: ✅ Pass / ⚠️ Concerns / 🔴 Blocking Issues

**Summary**: <findings summary>

**Blocking Issues**:
- <issue 1 if any>

**Warnings**:
- <warning 1>

---

## 3. QA Review

### 3.1 Testability Assessment

| Acceptance Criterion | Testable | Test Type | Issue |
|---------------------|----------|-----------|-------|
| AC-001: User can login | ✅ | E2E | - |
| AC-002: Handle timeout | ⚠️ | Integration | Timeout value not specified |
| AC-003: Show error msg | 🔴 | ? | "Appropriate message" is vague |

### 3.2 Test Coverage Gaps

| Gap | Severity | Recommendation |
|-----|----------|----------------|
| No error path tests defined | 🟡 Warning | Add tests for each error in Section 4.1 |
| Missing integration test for <X> | 🟡 Warning | Add to test plan |

### 3.3 Edge Cases / Failure Modes

| Scenario | Addressed | Location | Issue |
|----------|-----------|----------|-------|
| Network timeout | ❌ | - | No retry strategy defined |
| Invalid input | ✅ | Section 4.4 | - |
| Concurrent edit | ❌ | - | No locking strategy |

### 3.4 QA Verdict

**Status**: ✅ Pass / ⚠️ Concerns / 🔴 Blocking Issues

**Summary**: <findings summary>

**Blocking Issues**:
- <issue 1 if any>

**Warnings**:
- <warning 1>

---

## 4. Overall Verdict

| Review Stage | Status | Critical | Warnings |
|--------------|--------|----------|----------|
| Product | ✅/⚠️/🔴 | <count> | <count> |
| Architecture | ✅/⚠️/🔴 | <count> | <count> |
| QA | ✅/⚠️/🔴 | <count> | <count> |
| **Overall** | **✅/⚠️/🔴** | **<total>** | **<total>** |

### Deletion Candidates Summary

| Total Candidates | Approved | Pending | Rejected |
|------------------|----------|---------|----------|
| <count> | <count> | <count> | <count> |

**⚠️ BLOCKING**: All deletion candidates must be approved or rejected before proceeding to task breakdown.

### Recommendation

- [ ] 🟢 **Proceed to Task Breakdown** - No blocking issues, deletions approved
- [ ] 🟡 **Address Warnings First** - Recommended before proceeding
- [ ] 🔴 **Revise Plan** - Blocking issues must be resolved
- [ ] ⏳ **Pending Approvals** - Deletion candidates require user decision

### Action Items (Ordered by Priority)

| # | Priority | Action | Owner | Stage |
|---|----------|--------|-------|-------|
| 1 | 🔴 Critical | <action> | - | Product/Arch/QA |
| 2 | 🟡 Warning | <action> | - | Product/Arch/QA |
| 3 | 🟢 Info | <action> | - | Product/Arch/QA |

---

## 5. Next Steps

Once all blocking issues are resolved:

```bash
# If 🔴 Blocked - Revise plan and re-review
sdlc_plan_first --name <name>  # Update plan
sdlc_review_plan --name <name>  # Re-review

# If 🟢 Approved - Proceed to task breakdown
sdlc_task_breakdown --name <name>
```

---

## 6. Proposed File Updates

### 6.1 Updates to `implementation_plan.md`

#### Add to Section 4.1 (API Endpoints)
| Endpoint | Missing Element | Proposed Addition |
|----------|-----------------|-------------------|
| `POST /api/<resource>` | Error response | Add 429 Rate Limited |
| `GET /api/<resource>` | Timeout spec | Add 30s timeout |

#### Add to Section 4.4 (User Input Specs)
| Field | Missing Validation | Proposed Addition |
|-------|-------------------|-------------------|
| `<field>` | Edge case | Handle empty string vs null |

### 6.2 Updates to `architecture.md`

#### Component Diagram Updates
| Location | Change Type | Description |
|----------|-------------|-------------|
| Services Layer | Add component | Add `CacheService` between Gateway and Services |
| Data Flow | Add arrow | Show cache hit/miss path |

### 6.3 Updates to `decision-log.md`

#### New Decisions Required
| Decision ID | Topic | Options to Evaluate |
|-------------|-------|---------------------|
| DEC-XXX | <topic> | Option A vs Option B |

### 6.4 Updates to `status.md`

#### Append Entry
```
[DATE] Plan Review Completed
- Reviewer: AI Plan Reviewer (Product → Architecture → QA)
- Status: <verdict>
- Critical Issues: <count>
- Warnings: <count>
- Deletion Candidates: <count> (pending approval)
- Next Action: <action>
```

### 6.5 Deletion Tasks (After User Approval)

| Component | Location | Action | Status |
|-----------|----------|--------|--------|
| `<component>` | `<path>` | Delete/Deprecate | ⏳ Pending / ✅ Approved / ❌ Rejected |

**Note**: Apply these updates to input files before running `sdlc_task_breakdown`.
```

---

## Collaboration Checkpoint

After generating the review report:
1. Present executive summary and overall verdict to user
2. Highlight all blocking issues that must be resolved
3. **Present deletion candidates for explicit user approval**
4. List warnings that are recommended to address
5. Wait for user acknowledgment and deletion approvals before proceeding

**Deletion Approval Process**:
- Present each deletion candidate with location, reason, and confidence
- User must explicitly approve (✅), reject (❌), or defer (⏳) each candidate
- Rejected candidates: Keep in codebase, update plan to work with existing code
- Deferred candidates: Can be addressed in future iteration

---

## Definition of Ready for Task Breakdown

Before proceeding to `sdlc_task_breakdown`, verify:
- [ ] All 🔴 Critical/Blocking issues resolved
- [ ] Review report generated and saved
- [ ] User has acknowledged the review findings
- [ ] **All deletion candidates approved, rejected, or deferred by user**
- [ ] Plan files updated if issues were found (re-run `sdlc_plan_first` if needed)

---

## Workflow Integration

```
sdlc_prd_feature ──► sdlc_plan_first ──► sdlc_review_plan ──► sdlc_task_breakdown
     (specs)         (impl plan)         (THIS COMMAND)        (JIRA tasks)
                                               │
                                               ▼
                                    Review Report + Verdict
                                               │
                                    ┌──────────┴──────────┐
                                    │                     │
                                 🟢 Pass              🔴 Block
                                    │                     │
                                    ▼                     ▼
                           Task Breakdown           Fix Plan & Re-review
```

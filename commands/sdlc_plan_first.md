# SDLC Plan First $ARGUMENTS

## Context First
- Gather relevant context from the existing `task_<name>/` structure before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify third-party APIs.

## Purpose
Execute the **first phase** of feature planning: understand requirements, analyze the codebase, research solutions, and synthesize an implementation strategy. This phase produces **NO code** - MUST only analysis, research findings, and a clear plan.

**Two-Phase Approach**: This command focuses exclusively on Planning and Strategy. Use `sdlc_task_breakdown` for Phase 2 (Task Breakdown).

**Key Principle**: No coding initially. Do not write any functional code during the planning phase.

Clarification-First: reflect user intent, bundle clarifying questions, wait for confirmation, and record assumptions as "unconfirmed" before proceeding.

## Command Usage
```bash
# GitHub feature planning
sdlc_plan_first --source github --name user-dashboard --type frontend --id 789

# Local feature planning
sdlc_plan_first --source local --name payment-system --type backend

# Bitbucket feature planning
sdlc_plan_first --source bitbucket --name api-redesign --id 456

# Simple usage (auto-detects everything)
sdlc_plan_first --name mobile-app
```

**Parameters:**
- `--name <descriptive-name>`: Workspace name (creates `<project_root>/task_<name>/`)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <frontend|backend|fullstack>`: Feature type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus planning (optional)
- `--complexity <small|medium|large>`: Controls optional artifacts; if omitted, auto-detected

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: plan feature <name> - requirements analysis complete"`
- `git commit -m "sdlc: <name> - architecture documented"`
- `git commit -m "sdlc: <name> - decision recorded and rationale"`
- `git commit -m "sdlc: <name> - strategy complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## Outputs
- `task_<name>/plan/status.md` - Running log of planning activities (planning only), approvals, and outstanding guardrails
- `task_<name>/plan/decision-log.md` - Options, pros/cons, decisions with rationale
- `task_<name>/plan/strategy/architecture.md` - ASCII diagrams for component control and data flow
- `task_<name>/plan/strategy/implementation_plan.md` - **PRIMARY OUTPUT**: Implementation plan with integration contracts (critical for user review)

---

## 🔹 PHASE 1: PLANNING AND STRATEGY

### Step 1: Understand the Use Case and Goal

**Objective**: Develop a clear understanding of what needs to be built and why.

**Activities**:
- Requirement analysis: parse stories, acceptance criteria, constraints, assumptions, plus any provided `--context` materials and `--prompt` intent
- **Library/Framework Identification**: Extract mentioned technologies, libraries, and frameworks from requirements
- **Context7 Documentation Retrieval**: Use `mcp_context7_resolve-library-id` to resolve library names, then `mcp_context7_get-library-docs` to fetch current documentation for identified technologies
- Stakeholder mapping: users, internal teams, compliance, external integrations
- Technical feasibility: identify complexity hot-spots and integration points with documentation-informed analysis
- Business impact: value, scope boundaries, out-of-scope items

**Update**: `task_<name>/plan/status.md` with requirements analysis findings

**Collaboration Checkpoint**: Present understanding to user; clarify any ambiguities before proceeding.

---

### Step 2: Gap Analysis

**Objective**: Explore the current codebase and identify gaps between current state and desired state.

**Activities**:
- Explore existing codebase structure and patterns
- Identify relevant existing components, modules, and utilities
- Map current architecture and data flows
- Identify technical gaps that need to be filled
- Document reusable components vs. new development needed
- Identify integration points with existing systems

**Update**: `task_<name>/plan/status.md` with gap analysis findings

---

### Step 3: Open Source Research

**Objective**: Search for and prioritize highly-rated GitHub open-source solutions to avoid building from scratch.

**Activities**:
- Search GitHub for relevant open-source solutions
- Evaluate libraries/frameworks by: stars, maintenance activity, documentation quality
- Check license compatibility (MIT/Apache/BSD/PSF only - NO GPL)
- Assess integration complexity with current stack
- Document pros/cons of each candidate solution
- Use Context7 MCP to retrieve current documentation for shortlisted libraries

**Update**: `task_<name>/plan/status.md` with research findings

---

### Step 4: Impact Assessment

**Objective**: Analyze the impact of the new feature on the existing architecture.

**Activities**:
- Identify components that will be modified
- Assess data model changes and migration needs
- Evaluate performance implications
- Identify security considerations
- Document backward compatibility concerns
- Assess testing impact and requirements
- Risk assessment with mitigation strategies

**Update**: `task_<name>/plan/status.md` with impact assessment

---

### Step 5: Options Analysis and Decision

**Objective**: Present viable approaches and record decisions.

**Activities**:
- **Documentation-Informed Architecture**: Use Context7 MCP and documentation to evaluate 2–3 viable approaches with current best practices, pros/cons, and risks
- **Technology choices**: Alternatives with trade-offs and constraints, validated against latest documentation and compatibility matrices
- **Data model options**: Implications for migrations and compatibility, informed by current framework documentation
- Decision gate: present options to the user and record the selection and rationale

**Output**: `task_<name>/plan/decision-log.md`
```markdown
## Decision Log

### Decision 1: <Decision Title>
**Date**: <date>
**Status**: Pending/Approved

#### Options Considered
| Option | Pros | Cons | Risk Level |
|--------|------|------|------------|
| Option A | <pros> | <cons> | High/Med/Low |
| Option B | <pros> | <cons> | High/Med/Low |

#### Selected Option
<Which option was selected>

#### Rationale
<Why this option was chosen>

#### References
- <Context7 docs, external references>
```

---

### Step 6: Architecture Diagram

**Objective**: Create ASCII architecture diagrams showing component control and data flow.

**Output**: `task_<name>/plan/strategy/architecture.md`
```markdown
# Architecture Diagram

## System Overview
<Brief description of the system architecture>

## Component Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend                                 │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   Component A   │   Component B   │        Component C          │
│   (Pages/Views) │   (Forms/Input) │        (Display)            │
└────────┬────────┴────────┬────────┴─────────────┬───────────────┘
         │                 │                      │
         ▼                 ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway / Router                        │
└────────┬────────────────┬───────────────────────┬───────────────┘
         │                │                       │
         ▼                ▼                       ▼
┌────────────────┐ ┌────────────────┐  ┌─────────────────────────┐
│   Service A    │ │   Service B    │  │      Service C          │
│   (Auth)       │ │   (Business)   │  │      (Data)             │
└────────┬───────┘ └────────┬───────┘  └───────────┬─────────────┘
         │                  │                      │
         ▼                  ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram
```
User Input ──► [Validation] ──► [Transform] ──► [API Call]
                                                    │
                                                    ▼
[UI Update] ◄── [State Update] ◄── [Response] ◄── [Backend]
```

## Control Flow
```
1. User Action
   │
   ▼
2. Event Handler ──► Validate Input
   │                      │
   │                      ▼
   │                 Valid? ──No──► Show Error
   │                      │
   │                     Yes
   │                      │
   ▼                      ▼
3. Dispatch Action ──► API Request
   │                      │
   │                      ▼
   │                 Success? ──No──► Handle Error
   │                      │
   │                     Yes
   │                      │
   ▼                      ▼
4. Update State ◄─── Response Data
   │
   ▼
5. Re-render UI
```

## Component Interactions
<Describe key component interactions and responsibilities>
```

---

### Step 7: Implementation Plan (PRIMARY OUTPUT)

**Objective**: Synthesize findings into the primary implementation plan with integration contracts.

**CRITICAL**: This is the most important output file for user review. It must contain all integration points and data contracts.

**Output**: `task_<name>/plan/strategy/implementation_plan.md`
```markdown
# Implementation Plan

## 1. Problem Statement Summary
<Clear, concise summary of the problem being solved>

### Goals
- <Goal 1>
- <Goal 2>

### Success Criteria
- <Criterion 1>
- <Criterion 2>

---

## 2. Reference Documents
- **Architecture**: See `architecture.md` for component diagrams and data flow
- **Decisions**: See `decision-log.md` for technology choices and rationale

---

## 3. Feature Planning Details

### Feature 1: <Feature Name>

#### Description
<What this feature does>

#### Implementation Steps
1. <Step 1>
2. <Step 2>
3. <Step 3>

#### Components Involved
- Frontend: <component names>
- Backend: <service names>
- Database: <table/collection names>

---

### Feature 2: <Feature Name>
<Same structure>

---

## 4. Integration Contracts (CRITICAL FOR REVIEW)

### 4.1 API Endpoints

#### Endpoint: `POST /api/v1/<resource>`
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `field_name` | string | Yes | <description> |
| `field_name` | number | No | <description> |

**Request Example**:
```json
{
  "field_name": "value",
  "field_name": 123
}
```

**Response (200 OK)**:
```json
{
  "id": "uuid",
  "status": "success",
  "data": { }
}
```

**Error Responses**:
| Status | Code | Description |
|--------|------|-------------|
| 400 | VALIDATION_ERROR | Invalid input |
| 401 | UNAUTHORIZED | Missing/invalid token |
| 404 | NOT_FOUND | Resource not found |

---

### 4.2 Frontend-Backend Data Contracts

#### Contract: <Contract Name>
**Direction**: Frontend → Backend / Backend → Frontend

| Field | Type | Nullable | Validation | Description |
|-------|------|----------|------------|-------------|
| `id` | string (UUID) | No | UUID format | Unique identifier |
| `name` | string | No | 1-100 chars | Display name |
| `status` | enum | No | active/inactive | Current status |
| `created_at` | ISO8601 | No | - | Creation timestamp |

---

### 4.3 Component Integration Specs

#### Integration: <Component A> ↔ <Component B>

**Data Flow**:
```
ComponentA ──[EventName]──► ComponentB
           └─ payload: { field1, field2 }
```

**Props Interface**:
| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `onSubmit` | (data) => void | Yes | - | Callback on submit |
| `initialData` | DataType | No | null | Initial form values |
| `isLoading` | boolean | No | false | Loading state |

**Events Emitted**:
| Event | Payload | When |
|-------|---------|------|
| `submit` | FormData | Form submitted |
| `cancel` | - | User cancels |
| `error` | ErrorInfo | Validation fails |

---

### 4.4 User Input Specs

#### Input: <Form/Input Name>

**Fields**:
| Field | Type | Required | Validation Rules | Error Message |
|-------|------|----------|------------------|---------------|
| `email` | email | Yes | Valid email format | "Invalid email" |
| `password` | password | Yes | Min 8 chars, 1 upper, 1 number | "Weak password" |
| `name` | text | Yes | 2-50 chars, no special chars | "Invalid name" |

**Submission Behavior**:
- On success: <what happens>
- On error: <how errors are displayed>
- Loading state: <what shows during submission>

---

## 5. Data Models (Schema Only - No Code)

### Model: <Model Name>
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK, auto-gen | Primary key |
| `user_id` | UUID | FK → users.id | Owner reference |
| `status` | enum | active/inactive/pending | Current state |
| `created_at` | timestamp | NOT NULL, default NOW | Creation time |
| `updated_at` | timestamp | NOT NULL | Last modification |

**Indexes**:
- `idx_<table>_user_id` on (user_id)
- `idx_<table>_status` on (status)

**Relationships**:
- `<Model> belongs_to User`
- `<Model> has_many Items`

---

## 6. Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| <risk> | High/Med/Low | High/Med/Low | <strategy> |

---

## 7. Next Steps
1. User approval of this strategy and integration contracts
2. Proceed to Phase 2: Task Breakdown (use `sdlc_task_breakdown`)
```

---

## Plan-First AI Orchestration Handshake

- Maintain `task_<name>/plan/status.md` as a running log: timestamp, activity, tool invoked, output summary, and whether human review is required
- Flag any AI-generated assumptions or guardrail gaps in `plan/status.md` for immediate human resolution before proceeding
- Pause for a Human Review Gate: present the synthesized plan, unresolved assumptions, and guardrail checklist to the user; proceed only after explicit approval

---

## Collaboration Checkpoints

1. **After Understanding**: Present use case understanding; clarify ambiguities
2. **After Gap Analysis**: Share findings; confirm existing components to reuse
3. **After Research**: Present options; get user preference on build vs. buy
4. **After Impact Assessment**: Review risks; confirm acceptable trade-offs
5. **After Architecture**: Review component diagrams and data flow
6. **After Implementation Plan**: Get explicit approval of integration contracts before proceeding

---

## Definition of Ready for Phase 2

Before proceeding to `sdlc_task_breakdown`, verify:
- [ ] Requirements analysis complete with clear boundaries and constraints
- [ ] Gap analysis complete with reusable components identified
- [ ] Open source research complete with recommendations
- [ ] Impact assessment complete with risks identified
- [ ] **Architecture documented**: Component diagrams and data flow in `architecture.md`
- [ ] **Context7 Documentation Integration**: Resolve libraries/frameworks and fetch current docs
- [ ] Decision log updated with selected options, rationale, and references
- [ ] **Implementation plan complete with ALL integration contracts**:
  - [ ] API endpoints with request/response specs
  - [ ] Frontend-backend data contracts
  - [ ] Component integration specs
  - [ ] User input validation specs
  - [ ] Data models (schema only)
- [ ] Plan status log updated with latest activities and human approvals
- [ ] All assumptions clarified or marked as unconfirmed
- [ ] User has approved the implementation plan and integration contracts

---

## Phase 2 Handoff

Once Phase 1 is complete and approved, proceed to:
```bash
sdlc_task_breakdown --name <same-name>
```

This will read the Phase 1 artifacts (`implementation_plan.md`, `architecture.md`, `decision-log.md`) and create the detailed task breakdown in JIRA format.

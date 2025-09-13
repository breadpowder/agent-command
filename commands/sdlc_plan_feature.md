# SDLC Plan Feature $ARGUMENTS

## Purpose
Specialized feature planning that performs requirements analysis, technical feasibility, option
evaluation, and task breakdown. This command produces a clear, agreed plan without writing code
or running tests.

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
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <frontend|backend|fullstack>`: Feature type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus planning (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: plan feature <name> - requirements analysis complete"`
- `git commit -m "sdlc: <name> - architecture options documented"`
- `git commit -m "sdlc: <name> - decision recorded and rationale"`
- `git commit -m "sdlc: <name> - task breakdown complete"`
- `git commit -m "sdlc: <name> - feature planning complete"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
### 1. Context gathering and analysis
- Requirement analysis: parse stories, acceptance criteria, constraints, assumptions, plus any
  provided `--context` materials and `--prompt` intent.
- Stakeholder mapping: users, internal teams, compliance, external integrations.
- Technical feasibility: identify complexity hot-spots and integration points.
- Business impact: value, scope boundaries, out-of-scope items.

### 2. Options analysis and decision
- Architecture options: list 2–3 viable approaches with pros/cons and risks.
- Technology choices: alternatives with trade-offs and constraints.
- Data model options: implications for migrations and compatibility.
- Decision gate: present options to the user and record the selection and rationale in
  `plan/decision-log.md` before proceeding.

### 3. Task breakdown (2-hour rule)
- Decompose into independent, verifiable tasks ≤2h each.
- Define validation criteria per task and explicit dependencies.
- Order for incremental value and early risk reduction.

### 4. Planning artifacts and structure
Store planning in a standardized structure:
```
<project_root>/<name>/
├── plan/
│   ├── main-plan.md        # Strategy, scope, milestones
│   ├── task-breakdown.md   # 2-hour tasks with acceptance criteria
│   ├── decision-log.md     # Options, pros/cons, chosen decisions
│   └── architecture.md     # High-level diagrams and contracts
├── issue/
│   ├── requirements.md     # Functional and non-functional requirements
│   └── risks.md            # Risks, mitigations, open questions
└── context/
    └── source-reference.md # Links, tickets, prior art
```

## Collaboration checkpoints
- Clarify requirements and constraints; confirm understanding before analysis.
- Present 2–3 option sets with pros/cons; request user selection.
- Share task breakdown; request approval before freezing the plan.

## Outputs
- Updated planning workspace as above.
- Recorded decisions with rationale and impact.
- Finalized task breakdown ready for implementation handoff.

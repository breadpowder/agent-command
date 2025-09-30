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
- `--name <descriptive-name>`: Workspace name (creates <project_root>/feature_<name>/)
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
- **Library/Framework Identification**: Extract mentioned technologies, libraries, and frameworks from requirements.
- **Context7 Documentation Retrieval**: Use `mcp_context7_resolve-library-id` to resolve library names, then `mcp_context7_get-library-docs` to fetch current documentation for identified technologies.
- Stakeholder mapping: users, internal teams, compliance, external integrations.
- Technical feasibility: identify complexity hot-spots and integration points with documentation-informed analysis.
- Business impact: value, scope boundaries, out-of-scope items.

### 2. Options analysis and decision
- **Documentation-Informed Architecture**: Use Context7 documentation to evaluate 2–3 viable approaches with current best practices, pros/cons, and risks.
- **Technology choices**: Alternatives with trade-offs and constraints, validated against latest documentation and compatibility matrices.
- **Data model options**: Implications for migrations and compatibility, informed by current framework documentation.
- **Pseudocode Architecture Generation**: Create high-level pseudocode showing:
  - Main component structure and interactions
  - Data flow patterns between components
  - Integration points with external systems
  - Error handling and recovery patterns
- Decision gate: present options with pseudocode examples to the user and record the selection and rationale in
  `plan/decision-log.md` before proceeding.

### 3. Task breakdown (2-hour rule)
- **Documentation-Enhanced Task Decomposition**: Decompose into independent, verifiable tasks ≤2h each, with Context7 documentation informing implementation approach.
- **Task-Level Pseudocode Generation**: For each task, create structured pseudocode showing:
  - Step-by-step implementation approach
  - Key function/method signatures and structure
  - Data transformation patterns
  - Error handling and validation logic
  - Integration patterns with dependencies
- **Validation Criteria**: Define validation criteria per task with specific test cases and acceptance criteria.
- **Dependency Mapping**: Explicit dependencies with Context7-informed integration patterns.
- **Risk-Ordered Implementation**: Order for incremental value and early risk reduction based on documentation complexity analysis.

### 4. Planning artifacts and structure
Store planning in a standardized structure:
Files are created ONLY if applicable, e.g. feature new features or simple feature or non-api task, there might be no api-contract. observability.yaml,rollout-config.yaml.
```
<project_root>/feature_<name>/
├── plan/
│   ├── implementation-plan.md  # Strategy, scope, milestones (separate from PRD)
│   ├── task-breakdown.md       # 2-hour tasks with acceptance criteria and pseudocode
│   ├── decision-log.md         # Options, pros/cons, chosen decisions with Context7 references
│   ├── architecture.md         # High-level diagrams and contracts with pseudocode examples
│   └── pseudocode-examples.md  # Detailed pseudocode for each major component and task
├── specs/                      # Machine-readable specifications  
│   ├── api-contract.yaml       # OpenAPI spec with examples and error shapes
│   ├── config-schema.yaml      # Configuration schema with defaults and validation
│   ├── observability.yaml     # Metrics, alerts, dashboards, SLOs
│   └── rollout-config.yaml     # Feature flags, gating checks, backout steps
├── issue/
│   ├── requirements.md         # Functional and non-functional requirements
│   └── risks.md                # Risks, mitigations, open questions
└── context/
    └── source-reference.md     # Links, tickets, prior art
```

## Collaboration checkpoints
- Clarify requirements and constraints; confirm understanding before analysis.
- Present 2–3 option sets with pros/cons; request user selection.
- Share task breakdown; request approval before freezing the plan.

### 5. Definition of Ready & Quality Standards

**Definition of Ready - Before Implementation:**
- Requirements analysis complete with clear boundaries and constraints
- **Context7 Documentation Integration**: All identified libraries/frameworks resolved and current documentation retrieved
- Architecture options evaluated with 2-3 viable approaches documented with Context7-informed best practices
- Technology choices justified with trade-offs and constraints analysis using latest documentation
- Data model implications assessed for migrations and compatibility with framework-specific patterns
- **Comprehensive Pseudocode Generation**: Task breakdown complete with ≤2h tasks, validation criteria, and detailed pseudocode examples
- Dependencies mapped with explicit ordering and risk assessment using documentation-informed integration patterns
- Machine-readable specs created (API contracts, config schemas) validated against current standards
- Observability plan defined with metrics, alerts, and SLO targets following framework best practices
- Rollout strategy planned with feature flags and backout procedures
- Decision log updated with selected options, rationale, and Context7 documentation references
- **Pseudocode Validation**: All major components and tasks have clear, implementable pseudocode examples

**Traceability Requirements:**
- Map Goals → Requirements → Tests → Tasks
- Maintain lightweight matrix (CSV/Markdown) or tags for CI validation
- Each task must reference specific requirements and acceptance criteria

## Outputs
- Updated planning workspace as above with machine-readable specs
- Recorded decisions with rationale and impact assessment
- Finalized task breakdown ready for implementation handoff
- Quality gates and CI automation guidance established

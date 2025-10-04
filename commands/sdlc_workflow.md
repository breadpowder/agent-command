# SDLC Workflow Orchestrator $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 MCP references are mandatory for technical feasibility validation during planning phases.

## Purpose
Master orchestrator that guides developers through the full SDLC using specialized commands. It
identifies intent, proposes a sequence, and ensures context flows cleanly between commands while
adding collaboration checkpoints and quality gates.

## Command Usage
```bash
# GitHub feature development
sdlc_workflow --source github --name user-authentication --type feature --id 123 --complexity small

# Local bug fix workflow
sdlc_workflow --source local --name payment-issue --type bugfix --complexity small

# Bitbucket improvement workflow
sdlc_workflow --source bitbucket --name performance-optimization --type improvement --complexity medium

# Simple usage (auto-detects everything)
sdlc_workflow --name api-enhancement
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/task_<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <feature|bugfix|improvement|release>`: Workflow type (optional, auto-detected)
- `--complexity <small|medium|large>`: Controls which phases are included
- `--id <identifier>`: External ID (issue#, PR#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt guiding orchestration (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: <name> - workflow planning complete"`
- `git commit -m "sdlc: <name> - phase execution complete"`
- `git commit -m "sdlc: <name> - quality gates passed"`
- `git commit -m "sdlc: <name> - workflow completed successfully"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN
Clarification‑First (applies to all phases): reflect user intent, bundle clarifying questions, wait for confirmation, and record assumptions as “unconfirmed”.

### 1. Intent analysis and sequence proposal
```
Feature Development:
├── New functionality → sdlc_understand_requirement → sdlc_prd_feature → sdlc_plan_feature → sdlc_implement_feature → code_review → sdlc_test → sdlc_deploy
├── Complex requirements → sdlc_understand_requirement → sdlc_prd_feature → sdlc_plan_feature → sdlc_implement_feature → code_review → sdlc_test → sdlc_deploy
├── Enhancement → sdlc_plan_feature → sdlc_implement_feature → sdlc_test → sdlc_deploy
└── Integration → sdlc_plan_feature → sdlc_implement_feature → sdlc_test → sdlc_deploy

Bug Resolution:
├── Critical bug → sdlc_reproduce_bug (optional) → sdlc_analyze_bug → sdlc_plan_bug → sdlc_implement_bug → code_review → sdlc_test → sdlc_deploy (expedited)
├── Standard bug → sdlc_reproduce_bug (optional) → sdlc_analyze_bug → sdlc_plan_bug → sdlc_implement_bug → code_review → sdlc_test → sdlc_deploy
└── Complex bug → sdlc_reproduce_bug → sdlc_analyze_bug → sdlc_plan_bug → sdlc_implement_bug → code_review → sdlc_test → sdlc_deploy

Release Management:
└── Release → code_review → sdlc_test → sdlc_deploy → release_and_publish
```

### 2. Context gathering and validation
- Fetch and correlate context (issues, PRs, code, configs) based on `--source`, plus any provided
  `--context` files and `--prompt` intent.
- Validate completeness; identify and request missing information.

Clarification checkpoint: pause after Understand/Analyze phases to ask bundled questions and wait for confirmation.

## Technical Feasibility Validation with Context7 MCP

### When to Use Context7 MCP
Context7 MCP MUST be used for technical feasibility validation in the following scenarios:
- **API Integration**: When integrating with external APIs or services
- **Architecture Changes**: When modifying system architecture or introducing new components  
- **Technology Stack Changes**: When adopting new technologies, frameworks, or libraries
- **Performance Requirements**: When performance, scalability, or resource constraints are critical
- **Security Considerations**: When implementing security features or handling sensitive data
- **Infrastructure Changes**: When modifying cloud resources, deployment patterns, or infrastructure
- **Third-party Dependencies**: When adding or updating external dependencies
- **Cross-system Integration**: When integrating with existing systems or services

### Context7 MCP Integration Points
```
Phase Integration:
├── PRD Phase → Context7 MCP validation for requirements feasibility
├── Planning Phase → Context7 MCP validation for technical approach
├── Implementation Phase → Context7 MCP validation for specific technical decisions
└── Review Phase → Context7 MCP validation for architectural compliance
```

### Context7 MCP Validation Process
1. **Identify Validation Needs**: Determine which aspects require Context7 MCP validation
2. **Query Context7 MCP**: Use MCP tools to fetch relevant documentation and specifications
3. **Analyze Feasibility**: Compare requirements against Context7 MCP findings
4. **Document Findings**: Record validation results in `task_<name>/context7/`
5. **Update Plans**: Modify implementation plans based on Context7 MCP insights
6. **Quality Gate**: Context7 MCP validation must pass before proceeding to next phase

### Context7 MCP Documentation Structure
```
task_<name>/context7/
├── feasibility-validation.md     # Main validation report
├── api-specifications/           # API docs and specs from Context7 MCP
├── architecture-constraints/     # System architecture limitations
├── performance-benchmarks/       # Performance data and requirements
├── security-requirements/        # Security specifications and compliance
└── integration-patterns/         # Integration approaches and best practices
```

### Context7 MCP Quality Gates
- **PRD Gate**: All external dependencies and APIs validated via Context7 MCP
- **Planning Gate**: Technical approach confirmed feasible via Context7 MCP
- **Implementation Gate**: Specific implementation details verified via Context7 MCP
- **Review Gate**: Final solution complies with Context7 MCP specifications

### 3. Complexity auto-detection (when `--complexity` omitted)
- small: short/clear task prompt, single module/file, no external API/schema change, low risk keywords
- medium: multiple modules, config or light API surface change, moderate risk or “integration” keywords
- large: cross-cutting changes, schema or public API changes, performance/security critical, “migration/refactor” keywords
- Heuristics consider prompt length, number of impacted areas in `--context`, and presence of words like “schema”, “breaking”, “migration”, “critical”, “prototype”, “MVP”, “hotfix”

The orchestrator proposes a complexity and shows the planned phases; user can override.

### 3. Workflow templates
```yaml
feature_workflow:
  phases:
    - name: "PRD"
      commands: [sdlc_prd_feature]
      gates: [requirements_captured,]
    - name: "Planning"
      commands: [sdlc_plan_feature]
      gates: [scope_defined, decisions_recorded, context7_mcp_technical_approach_validated]
    - name: "Implementation"
      commands: [sdlc_implement_feature]
      gates: [code_complete, context7_mcp_implementation_validated]
    - name: "Quality"
      commands: [code_review]
      gates: [review_approved, security_clear, context7_mcp_compliance_validated]
    - name: "Testing"
      commands: [sdlc_test]
      gates: [coverage_adequate, integration_passing, performance_within_budgets]
    - name: "Deployment"
      commands: [sdlc_deploy]
      gates: [staging_verified, production_ready, observability_active]

bugfix_workflow:
  phases:
    - name: "Reproduction"
      commands: [sdlc_reproduce_bug]
      gates: [repro_reliable]
    - name: "Analysis"
      commands: [sdlc_analyze_bug]
      gates: [root_cause_identified, impact_assessed, context7_mcp_root_cause_validated]
    - name: "Planning"
      commands: [sdlc_plan_bug]
      gates: [solution_decided, rollback_ready, context7_mcp_solution_validated]
    - name: "Implementation"
      commands: [sdlc_implement_bug]
      gates: [fix_implemented, context7_mcp_fix_validated]
    - name: "Quality"
      commands: [code_review]
      gates: [review_approved, context7_mcp_compliance_validated]
    - name: "Testing"
      commands: [sdlc_test]
      gates: [fix_verified, no_side_effects, regression_tests_pass]
    - name: "Deployment"
      commands: [sdlc_deploy]
      gates: [hotfix_ready, rollback_plan, enhanced_monitoring_active]
```

### 4. Context flow
- Pass enriched context and artifacts between commands (repro → analysis → planning → implementation → review → testing → deployment).
- Persist state and decisions to keep the chain auditable.
- **Context7 MCP Integration**: Context7 MCP validation results flow between phases and inform subsequent decisions.
- **Context7 MCP Artifacts**: All Context7 MCP findings are persisted in `task_<name>/context7/` for audit trail.

## Collaboration checkpoints
- At plan/analysis phases: present options with pros/cons and request user selection.
- Before risky transitions (implementation, deployment): confirm quality gates and rollback.
- After each phase: summarize outputs and next steps for user approval.
- **Context7 MCP Checkpoints**: Present Context7 MCP validation findings and confirm technical feasibility before proceeding.

## Artifacts
- PRD outputs: `task_<name>/specs/*`
- Plan outputs: `task_<name>/plan/*`
- **Context7 MCP outputs**: `task_<name>/context7/*` (feasibility validation, API specs, architecture constraints)

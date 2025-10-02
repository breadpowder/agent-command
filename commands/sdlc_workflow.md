# SDLC Workflow Orchestrator $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify APIs.

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
      gates: [requirements_captured]
    - name: "Planning"
      commands: [sdlc_plan_feature]
      gates: [scope_defined, decisions_recorded]
    - name: "Implementation"
      commands: [sdlc_implement_feature]
      gates: [code_complete]
    - name: "Quality"
      commands: [code_review]
      gates: [review_approved, security_clear]
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
      gates: [root_cause_identified, impact_assessed]
    - name: "Planning"
      commands: [sdlc_plan_bug]
      gates: [solution_decided, rollback_ready]
    - name: "Implementation"
      commands: [sdlc_implement_bug]
      gates: [fix_implemented]
    - name: "Quality"
      commands: [code_review]
      gates: [review_approved]
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

## Collaboration checkpoints
- At plan/analysis phases: present options with pros/cons and request user selection.
- Before risky transitions (implementation, deployment): confirm quality gates and rollback.
- After each phase: summarize outputs and next steps for user approval.

## Artifacts
- PRD outputs: `task_<name>/specs/*`
- Plan outputs: `task_<name>/plan/*`

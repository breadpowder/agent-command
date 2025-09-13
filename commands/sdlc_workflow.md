# SDLC Development Workflow Orchestrator $ARGUMENTS

## Purpose
Master orchestrator that guides developers through the full SDLC using specialized commands. It
identifies intent, proposes a sequence, and ensures context flows cleanly between commands while
adding collaboration checkpoints and quality gates.

## Command Usage
```bash
# GitHub feature development
sdlc_development_workflow --source github --name user-authentication --type feature --id 123

# Local bug fix workflow
sdlc_development_workflow --source local --name payment-issue --type bugfix

# Bitbucket improvement workflow
sdlc_development_workflow --source bitbucket --name performance-optimization --type improvement

# Simple usage (auto-detects everything)
sdlc_development_workflow --name api-enhancement
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <feature|bugfix|improvement|release>`: Workflow type (optional, auto-detected)
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
### 1. Intent analysis and sequence proposal
```
Feature Development:
├── New functionality → sdlc_prd_feature → sdlc_plan_feature → sdlc_implement_feature → code_review → sdlc_setup_testing → sdlc_deploy_changes
├── Enhancement → sdlc_plan_feature → sdlc_implement_feature → code_review → sdlc_setup_testing → sdlc_deploy_changes
└── Integration → sdlc_plan_feature → sdlc_implement_feature → code_review → sdlc_setup_testing → sdlc_deploy_changes

Bug Resolution:
├── Critical bug → sdlc_reproduce_bug → sdlc_analyze_bug → sdlc_plan_bug → sdlc_implement_bug → code_review → sdlc_setup_testing → sdlc_deploy_changes (expedited)
├── Standard bug → sdlc_reproduce_bug → sdlc_analyze_bug → sdlc_plan_bug → sdlc_implement_bug → code_review → sdlc_setup_testing → sdlc_deploy_changes
└── Complex bug → sdlc_reproduce_bug → sdlc_analyze_bug → sdlc_plan_bug → sdlc_implement_bug → code_review → sdlc_setup_testing → sdlc_deploy_changes

Release Management:
└── Release → code_review → sdlc_setup_testing → sdlc_deploy_changes → release_and_publish
```

### 2. Context gathering and validation
- Fetch and correlate context (issues, PRs, code, configs) based on `--source`, plus any provided
  `--context` files and `--prompt` intent.
- Validate completeness; identify and request missing information.

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
      commands: [sdlc_setup_testing]
      gates: [coverage_adequate, integration_passing]
    - name: "Deployment"
      commands: [sdlc_deploy_changes]
      gates: [staging_verified, production_ready]

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
      commands: [sdlc_setup_testing]
      gates: [fix_verified, no_side_effects]
    - name: "Deployment"
      commands: [sdlc_deploy_changes]
      gates: [hotfix_ready, rollback_plan]
```

### 4. Context flow
- Pass enriched context and artifacts between commands (repro → analysis → planning → implementation → review → testing → deployment).
- Persist state and decisions to keep the chain auditable.

## Collaboration checkpoints
- At plan/analysis phases: present options with pros/cons and request user selection.
- Before risky transitions (implementation, deployment): confirm quality gates and rollback.
- After each phase: summarize outputs and next steps for user approval.

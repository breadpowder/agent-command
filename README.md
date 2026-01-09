# AgentDK SDLC Commands - User Guide

## Overview

The AgentDK SDLC (Software Development Lifecycle) commands provide a comprehensive development workflow system optimized for both feature development and bug fixing. Commands are organized by workflow type with clear separation of concerns.

## 🔄 Quick Setup - Sync Commands, Skills & Hooks

To use these commands with AI agents (Claude, Codex, etc.), sync them to your local agent directories.

### **Sync SDLC Commands**
```bash
# Sync commands from GitHub (recommended)
./sync_agent_commands.sh --github

# Or sync from local repository
./sync_agent_commands.sh
```

### **Sync Skills & Hooks (Hybrid Architecture)**

The skill system uses a **hybrid architecture** for optimal performance:

| Component | Location | Frequency | Script |
|-----------|----------|-----------|--------|
| Skills + skill-activation | `~/.claude/` (user) | Run **once** | `sync_user_skills.sh` |
| Project hooks (logger, tracker) | `.claude/` (project) | Run **per project** | `sync_project_hooks.sh` |

```bash
# Option 1: Sync everything (user + project)
./sync_skill.sh

# Option 2: Sync user-level only (run once globally)
./sync_user_skills.sh
# or
./sync_skill.sh --user-only

# Option 3: Sync project-level only (run per project)
./sync_project_hooks.sh --project-dir /path/to/project
# or
./sync_skill.sh --project-only
```

### **What Gets Synced:**

**User Level (`~/.claude/`)** - Shared across ALL projects:
- 📁 `skills/` - All skill directories + skill-rules.json (including playwright-skill)
- 📁 `hooks/` - skill-activation-prompt hook
- ⚙️ `settings.json` - skill-activation hook configuration

**Project Level (`.claude/`)** - Per-project:
- 📁 `hooks/` - user-prompt-logger, post-tool-use-tracker
- ⚙️ `settings.json` - project-specific hook configuration

**Commands:**
- 📁 `~/.claude/commands/` - SDLC command specifications
- 📁 `~/.codex/prompts/` - Codex prompt specifications

### **Usage Examples:**
```bash
# First time setup (install skills globally)
./sync_user_skills.sh

# For each new project (install project hooks)
cd /path/to/my-project
/path/to/agent-command/sync_project_hooks.sh

# Update skills only (no npm install if unchanged)
./sync_user_skills.sh --skills-only

# Full sync with custom project directory
./sync_skill.sh --project-dir /path/to/project
```

**💡 Pro tip**: Run `sync_user_skills.sh` once after cloning this repo. Then use `sync_project_hooks.sh` for each project you work on.

## 🎯 Refactored Command Structure

### **Feature Development Commands:**
- `sdlc_understand_requirement`: Requirement understanding and clarification from raw user input
- `sdlc_prd_feature`: Product requirements from the user perspective (benefits, usage, value)
- `sdlc_plan_feature`: Technical plan from the implementation perspective (feasibility, trade-offs, decisions)
- `sdlc_implement_feature`: Feature implementation (Context7 for coding references)

### **Bug Fix Commands:**
- `sdlc_analyze_bug`: Root-cause analysis (Context7 allowed; optional for small)
- `sdlc_reproduce_bug`: Reproduction steps and environment notes
- `sdlc_plan_bug`: Minimal fix plan (optional for small)
- `sdlc_implement_bug`: Targeted fix (Context7 for coding references)

### **Shared Commands:**
- `sdlc_test`: Test execution and regression checks (Context7 for framework patterns)
- `sdlc_deploy`: Deployment and release/hotfix execution
- `sdlc_workflow`: Orchestrator for complete workflows with complexity-aware steps

## 📋 Complete Workflows

### **Feature Development Lifecycle:**
```bash
# Step 1: Understand and clarify initial requirements (for complex/unclear requirements)
sdlc_understand_requirement --name user-authentication --source github --prompt "Need better user login system"

# Step 2: Create Product Requirements Document
sdlc_prd_feature --name user-authentication --source github --type backend --id 123

# Step 3: Plan feature architecture and design
sdlc_plan_feature --name user-authentication --source github --type backend --id 123 --complexity medium

# Step 4: Implement the feature
sdlc_implement_feature --name user-authentication --source github --type backend --id 123

# Step 5: Setup comprehensive testing
sdlc_test --name user-authentication --type feature

# Step 6: Deploy the feature
sdlc_deploy --name user-authentication --type release
```

### **Bug Fix Lifecycle:**
```bash
# Step 1: Analyze bug and investigate root cause
sdlc_analyze_bug --name payment-failure --source github --type production --id 456

# Step 2: Create systematic reproduction steps
sdlc_reproduce_bug --name payment-failure --source github --type production --id 456

# Step 3: Plan surgical fix strategy
sdlc_plan_bug --name payment-failure --source github --type critical --id 456

# Step 4: Implement targeted fix
sdlc_implement_bug --name payment-failure --source github --type hotfix --id 456

# Step 5: Test fix and prevent regression
sdlc_test --name payment-failure --type regression

# Step 6: Deploy the fix
sdlc_deploy --name payment-failure --type hotfix
```

### **Orchestrated Workflows:**
```bash
# Feature development with guided workflow (complexity-aware)
sdlc_workflow --name user-dashboard --source github --type feature --id 789 --complexity small

# Bug fix with guided workflow
sdlc_workflow --name critical-bug --source github --type bug --id 101 --complexity small
```

## 🔧 Universal Parameters

All SDLC commands use standardized parameters:

```bash
--name <descriptive-name>    # Workspace name (creates <project_root>/<name>/)
--source <github|local|bitbucket>  # Input source (optional, defaults to local)
--type <context-specific>    # Command-specific type (optional, auto-detected)
--id <identifier>           # External ID (issue#, PR#, etc) (optional)
--context <file|dir>        # Additional context file(s) or directory (optional)
--prompt "<instruction>"    # Inline user task prompt to focus the run (optional)
```

### **Context-Specific Types:**

**Feature Commands:**
- `--type <frontend|backend|fullstack|mobile>`: Feature implementation type

**Bug Commands:**
- `--type <production|staging|development>`: Environment context
- `--type <critical|high|medium|low>`: Bug severity level
- `--type <hotfix|patch|critical>`: Fix urgency type

**Shared Commands:**
- `--type <feature|regression|integration>`: Testing type
- `--type <release|hotfix|patch>`: Deployment type

## 🏗️ Workspace Organization

Minimal, one-file-per-leaf, shared for features and bugs:

```
<project_root>/task_<name>/
├── requirement/
│   ├── analysis/requirement_analysis.md
│   ├── user-stories/stories.md                  # optional (features)
│   ├── requirements/requirements.md            # optional (medium/large)
│   └── handoff/handoff_requirements.md         # optional (medium/large)
├── specs/
│   ├── feature-spec.md                          # PRD: user perspective
│   ├── user-stories.md                          # user stories + acceptance criteria
│   ├── business-case.md                         # business value and success metrics
│   ├── api-contract.yaml                        # OpenAPI (if applicable)
│   ├── acceptance-tests.json                    # structured acceptance criteria
│   ├── observability.yaml                       # SLOs, alerts, dashboards
│   └── rollout-config.yaml                      # feature flags and rollout
├── plan/
│   ├── tasks/tasks.md
│   └── strategy/strategy.md                    # optional (medium/large)
├── design/
│   └── architecture/architecture.md            # optional (medium/large)
├── implementation/
│   └── changes/changes.md
├── debug/
│   ├── repro/repro.md
│   ├── analysis/rca.md                         # optional
│   └── plan/plan.md                            # optional
├── test/
│   ├── plan/plan.md                            # optional
│   └── results/results.md
└── deploy/
    ├── release/release.md                      # feature
    └── hotfix/hotfix.md                        # bug
```

Small complexity defaults to the essential leaves only.

### **Feature-Specific Additions:**
- **PRD (user perspective)**: `task_<name>/specs/*`
- **Plan (technical perspective)**: `task_<name>/plan/*` for task breakdown and decisions
- **Architecture Design**: Technical architecture and system integration plans
- **Business Case**: ROI analysis and success metrics

### **Bug-Specific Additions:**
- Root cause summary (lightweight)
- Reproduction procedures and test cases
- Minimal fix plan when needed

## 🔒 Git Integration & Traceability

### **Automatic Git Commits**
All SDLC commands create automatic git commits with consistent patterns:

```bash
# Feature Development Commits
sdlc: prd feature <name> - stakeholder analysis complete
sdlc: plan feature <name> - architecture design complete
sdlc: implement feature <name> - core functionality complete

# Bug Fix Commits  
sdlc: analyze bug <name> - root cause investigation complete
sdlc: reproduce bug <name> - reproduction steps documented
sdlc: plan bug <name> - fix strategy complete
sdlc: implement bug <name> - surgical fix complete

# Shared Command Commits
sdlc: test <name> - testing framework setup complete
sdlc: deploy <name> - deployment execution complete
```

### **Secure Rollback Policy**
```bash
# View workflow commit history
git log --oneline --grep="sdlc: <name>"

# Safe rollback (preserves history)
git revert <commit_hash>

# SECURITY POLICY: git reset is strictly forbidden
# Always use git revert to maintain complete traceability
```

### **Agent Commit Requirements**
**IMPORTANT FOR AGENTS**: Every command includes explicit instructions to commit after each major step, ensuring:
- Complete development process traceability
- Safe rollback capabilities with full history
- Clear audit trail for debugging and compliance
- Checkpoint recovery for interrupted workflows

### Clarification‑First Policy (applies to all commands)
- Reflect the user’s intent in your own words before acting.
- Ask bundled clarifying questions for any ambiguities or assumptions.
- Wait for confirmation before coding.
- Record assumptions as “unconfirmed” until resolved.

Context7 usage: For coding tasks (plan, implement, analyze, test), use Context7 library resolution and docs retrieval to reduce hallucinations and validate APIs/configs. PRD uses Context7 only when verifying third‑party terms or external constraints.

### Complexity selection
- Use `--complexity <small|medium|large>` to control how many phases/artifacts are produced.
- If omitted, the orchestrator auto-detects complexity from input size, impacted areas, and risk keywords:
  - small: single module, no API/schema change, low risk
  - medium: multiple modules or light API/config change
  - large: cross-cutting, schema/public API changes, or critical risk
  The proposed complexity is shown for confirmation and can be overridden.

## 🚀 Multi-Source Support

### **GitHub Integration**
```bash
# Feature development from GitHub issue
sdlc_prd_feature --source github --name api-v2 --type backend --id 123

# Bug fix from GitHub issue
sdlc_analyze_bug --source github --name payment-bug --type production --id 456
```

### **Bitbucket Integration**
```bash
# Feature development from Bitbucket
sdlc_plan_feature --source bitbucket --name dashboard --type frontend --id 789

# Bug fix from Bitbucket
sdlc_reproduce_bug --source bitbucket --name timeout-issue --type staging --id 101
```

### **Local Development**
```bash
# Local feature development
sdlc_implement_feature --name local-enhancement --source local --type fullstack

# Local bug investigation
sdlc_plan_bug --name local-bug --source local --type development
```

## 🎨 Workflow Differentiation

### **Feature Development Focus:**
- **User-Centered Design**: PRD creation with user stories and business value
- **Scalable Architecture**: Long-term design and system integration
- **Business Impact**: ROI analysis and success metrics
- **Market Research**: Competitive analysis and user research

### **Bug Fix Focus:**
- **Surgical Precision**: Minimal code changes with maximum safety
- **Root Cause Analysis**: Deep technical investigation and diagnosis
- **Regression Prevention**: Comprehensive testing to prevent similar issues
- **Risk Mitigation**: Extensive rollback planning and safety measures

### **Shared Operations:**
- **Type-Aware Testing**: Feature testing vs regression testing
- **Context-Aware Deployment**: Production releases vs hotfixes
- **Quality Gates**: Appropriate validation for workflow type
- **Monitoring**: Tailored monitoring for different change types

## 🛠️ Best Practices

### **1. Clear Intent and Naming**
- Use descriptive names that indicate purpose and scope
- Choose appropriate command based on workflow type
- Specify context through meaningful parameters

### **2. Systematic Task Breakdown (2-Hour Rule)**
- All complex tasks automatically broken into ≤2 hour chunks
- Comprehensive planning before implementation
- Regular checkpoint commits for progress tracking

### **3. Quality-First Approach**
- Built-in quality gates and validation steps
- Comprehensive testing strategies
- Security and performance considerations integrated

### **4. Collaboration and Documentation**
- Standardized documentation in predictable locations
- Clear handoff procedures between workflow phases
- Knowledge transfer and team communication built-in

## 📊 Quick Start Examples

### **New Feature (Quick)**
```bash
# All-in-one feature development
sdlc_workflow --name payment-integration --source github --type feature --id 123
```

### **Critical Bug (Quick)**
```bash
# Emergency bug fix workflow
sdlc_workflow --name production-outage --source github --type bug --id 456
```

### **Step-by-Step Feature**
```bash
# Detailed feature development process
sdlc_prd_feature --name mobile-checkout
sdlc_plan_feature --name mobile-checkout \
  --context docs/user-flows.md \
  --prompt "Prioritize MVP scope with clear guardrails"
sdlc_implement_feature --name mobile-checkout
sdlc_test --name mobile-checkout --type feature
sdlc_deploy --name mobile-checkout --type release
```

### **Step-by-Step Bug Fix**
```bash
# Detailed bug fix process
sdlc_reproduce_bug --name api-crash --context logs/error.log
sdlc_analyze_bug --name api-crash --prompt "Focus on concurrency edge cases"
sdlc_plan_bug --name api-crash --type high \
  --prompt "Minimize blast radius with a feature flag"
sdlc_implement_bug --name api-crash
sdlc_test --name api-crash --type regression
sdlc_deploy --name api-crash --type hotfix
```

## 🔧 Troubleshooting

### **Common Issues**
1. **Wrong Command Choice**: Use feature commands for new functionality, bug commands for fixes
2. **Workspace Conflicts**: Each `--name` creates unique workspace - use different names
3. **Type Mismatches**: Specify appropriate `--type` for command context
4. **Source Detection**: Explicitly specify `--source` if auto-detection fails

### **Recovery Procedures**
1. **Interrupted Workflow**: Check `git log --grep="sdlc:"` and resume from last checkpoint
2. **Wrong Command Used**: Use `git revert <commit_hash>` to safely undo and restart
3. **Workspace Issues**: Delete `<project_root>/<name>/` directory and restart workflow

## 📚 Support Commands

### **Utility Commands (Non-SDLC)**
- **`code_review.md`**: Comprehensive code review workflow
- **`refactor.md`**: Code refactoring and improvement
- **`release_and_publish.md`**: Release management and publishing
- **`_meta_reflection.md`**: Meta-command for workflow analysis

## 🎯 Command Selection Guide

### **When to Use Feature Commands:**
- Building new functionality
- Adding new capabilities
- Expanding system features
- Creating user-facing enhancements

### **When to Use Bug Commands:**
- Fixing existing functionality
- Resolving user-reported issues
- Addressing system errors
- Correcting defective behavior

### **When to Use Shared Commands:**
- Testing any type of change (feature or bug)
- Deploying any type of change
- Orchestrating complete workflows

## 🚀 Advanced Usage

### **Custom Workflow Combinations**
```bash
# Feature with immediate bug fix
sdlc_implement_feature --name new-api
sdlc_analyze_bug --name new-api-bug  
sdlc_implement_bug --name new-api-bug
```

### **Parallel Development**
```bash
# Multiple features in development
sdlc_prd_feature --name feature-a
sdlc_prd_feature --name feature-b
sdlc_plan_feature --name feature-a
sdlc_plan_feature --name feature-b
```

---

**AgentDK SDLC Commands v3.0**
*Specialized Development Lifecycle Management*
*Feature Development + Bug Fix Workflows*
*Built for GitHub, Bitbucket, and Local Development*

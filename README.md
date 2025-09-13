# AgentDK SDLC Commands - User Guide

## Overview

The AgentDK SDLC (Software Development Lifecycle) commands provide a comprehensive development workflow system optimized for both feature development and bug fixing. Commands are organized by workflow type with clear separation of concerns.

## 🎯 Refactored Command Structure

### **Feature Development Commands:**
- **`sdlc_prd_feature`**: Product Requirements Document creation for new features
- **`sdlc_plan_feature`**: Feature architecture and design planning
- **`sdlc_implement_feature`**: Feature implementation and integration

### **Bug Fix Commands:**
- **`sdlc_analyze_bug`**: Bug analysis and root cause investigation
- **`sdlc_reproduce_bug`**: Bug reproduction steps and environment setup
- **`sdlc_plan_bug`**: Bug fix planning and strategy development
- **`sdlc_implement_bug`**: Surgical bug fix implementation

### **Shared Commands:**
- **`sdlc_setup_testing`**: Testing infrastructure and test execution (features & bugs)
- **`sdlc_deploy_changes`**: Deployment and release management (features & bugs)
- **`sdlc_development_workflow`**: Master orchestrator for complete workflows

## 📋 Complete Workflows

### **Feature Development Lifecycle:**
```bash
# Step 1: Create Product Requirements Document
sdlc_prd_feature --name user-authentication --source github --type backend --id 123

# Step 2: Plan feature architecture and design
sdlc_plan_feature --name user-authentication --source github --type backend --id 123

# Step 3: Implement the feature
sdlc_implement_feature --name user-authentication --source github --type backend --id 123

# Step 4: Setup comprehensive testing
sdlc_setup_testing --name user-authentication --type feature

# Step 5: Deploy the feature
sdlc_deploy_changes --name user-authentication --type release
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
sdlc_setup_testing --name payment-failure --type regression

# Step 6: Deploy the fix
sdlc_deploy_changes --name payment-failure --type hotfix
```

### **Orchestrated Workflows:**
```bash
# Feature development with guided workflow
sdlc_development_workflow --name user-dashboard --source github --type feature --id 789

# Bug fix with guided workflow
sdlc_development_workflow --name critical-bug --source github --type bug --id 101
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

Each command creates a standardized workspace structure:

```
<project_root>/<name>/
├── plan/                  # Planning documents and strategies
│   ├── main-plan.md       # Primary plan and approach
│   ├── task-breakdown.md  # Detailed task breakdown (2-hour rule)
│   ├── decision-log.md    # Options, pros/cons, selected decisions with rationale
│   ├── architecture.md    # High-level diagrams and contracts (features)
│   └── implementation.md  # Step-by-step implementation strategy (if planning impl)
├── issue/                 # Issue analysis and requirements
│   ├── analysis.md        # Problem/requirement analysis
│   ├── research.md        # Background research and prior art
│   └── requirements.md    # Specific requirements and acceptance criteria
└── context/               # Additional context and references
    ├── source-reference.md # Original source context and links
    └── dependencies.md     # Dependencies and relationships
```

### **Feature-Specific Additions:**
- **PRD Documentation**: Complete product requirements and user stories
- **Architecture Design**: Technical architecture and system integration plans
- **Business Case**: ROI analysis and success metrics

### **Bug-Specific Additions:**
- **Root Cause Analysis**: Deep technical investigation and diagnosis
- **Reproduction Procedures**: Systematic reproduction steps and test cases
- **Fix Strategy**: Surgical fix plans with risk assessment

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
sdlc_setup_testing --name mobile-checkout --type feature
sdlc_deploy_changes --name mobile-checkout --type release
```

### **Step-by-Step Bug Fix**
```bash
# Detailed bug fix process
sdlc_reproduce_bug --name api-crash --context logs/error.log
sdlc_analyze_bug --name api-crash --prompt "Focus on concurrency edge cases"
sdlc_plan_bug --name api-crash --type high \
  --prompt "Minimize blast radius with a feature flag"
sdlc_implement_bug --name api-crash
sdlc_setup_testing --name api-crash --type regression
sdlc_deploy_changes --name api-crash --type hotfix
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

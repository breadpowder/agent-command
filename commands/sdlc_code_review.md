# SDLC Code Review $ARGUMENTS

## Purpose
Comprehensive code review workflow for development lifecycle that supports multiple sources (GitHub, Bitbucket, local commits, feature branches) with systematic analysis and structured testing validation.

## Command Usage
```bash
# GitHub Issues/PRs
sdlc_code_review --source github --type issue --id 123 --name review-auth-fix
sdlc_code_review --source github --type pr --id 456 --name review-api-changes

# Local Git Commits
sdlc_code_review --source local --scope commits --id HEAD~3..HEAD --name review-recent-changes
sdlc_code_review --source local --scope files --id "src/**/*.py" --name review-python-files

# Bitbucket PRs
sdlc_code_review --source bitbucket --type pr --id 789 --name review-bitbucket-pr

# Standalone code review
sdlc_code_review --source file --scope "src/agents/" --name agent-module-review
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket|file>`: Input source (defaults to local)
- `--scope <files|modules|component>`: Focus area when reviewing local sources
- `--type <issue|pr|feature|bug|etc>`: Specific review context when needed
- `--id <identifier>`: External ID (issue#, PR#, etc) or file/commit identifiers
- `--context <file|dir>`: Extra documentation or logs to preload into the workspace
- `--prompt "<instruction>"`: Inline guidance to clarify review goals

**Automatic Git Commits:**
This command checkpoints review artifacts for traceability:
- `git commit -m "sdlc: code review <name> - context gathered"`
- `git commit -m "sdlc: code review <name> - findings documented"`
- `git commit -m "sdlc: code review <name> - recommendations finalized"`
- Rollback: use `git revert <commit_hash>` (never `git reset`).

## 🔹 PLAN

### 1. Context Gathering & Analysis

**Source-Specific Data Collection:**
- **GitHub**: Use `gh issue view <id>` or `gh pr view <id>` for comprehensive details
- **Bitbucket**: Leverage Bitbucket CLI/API for PR information and context
- **Local Git**: Analyze commit ranges, branches, or specific files with git tools
- **File**: Direct analysis of specified files, directories, or code patterns

**Review Analysis Framework:**
- Extract code changes, comments, and development context
- Identify patterns, anti-patterns, and improvement opportunities
- Research related issues, previous reviews, and established patterns
- Map dependencies, impacts, and potential regression risks

### 2. Context Storage (Standard Structure)

**Structured Workspace Creation:**
```
<project_root>/<name>/
├── plan/
│   ├── main-plan.md           # Primary review strategy and approach
│   ├── task-breakdown.md      # Detailed task breakdown (2-hour rule)
│   └── implementation.md      # Step-by-step fix implementation strategy
├── issue/
│   ├── analysis.md            # Code quality analysis results
│   ├── research.md            # Security findings and performance analysis
│   └── requirements.md        # Fix requirements and acceptance criteria
└── context/
    ├── source-reference.md    # Original source context and links
    └── dependencies.md        # Related changes, commits, and dependencies
```

**Cross-Reference Integration:**
- Search existing review patterns and similar code issues
- Document relationships between code problems and system architecture
- Link to previous fixes and established development patterns

### 3. Requirements Analysis & Planning

**Review Scope Definition:**
- **Security Analysis**: Vulnerability assessment and security best practices
- **Performance Review**: Optimization opportunities and resource efficiency
- **Code Quality**: Maintainability, readability, and design pattern compliance
- **Testing Coverage**: Test completeness and quality assessment

**Priority Classification:**
- **Critical**: Security vulnerabilities, breaking bugs, major performance issues
- **High**: Significant code quality issues, architectural problems
- **Medium**: Minor bugs, style inconsistencies, missing tests
- **Low**: Documentation improvements, minor optimizations

### 4. Task Breakdown (2-Hour Rule)

**CRITICAL: Systematic Review Process**
- **Phase 1**: Code analysis and issue identification (≤2h)
- **Phase 2**: Security and performance assessment (≤2h)
- **Phase 3**: Priority-based fix implementation (≤2h per priority group)
- **Phase 4**: Test coverage improvement and validation (≤2h)
- **Phase 5**: Documentation updates and knowledge transfer (≤2h)
- **Phase 6**: Final integration testing and deployment (≤2h)

**Task Independence:**
- Each fix provides standalone, testable improvement
- Independent rollback capability for each change
- Clear validation criteria and testing requirements
- Explicit dependency mapping between related fixes

## 🔹 CREATE

### Branch Management

**Review-Specific Branch Strategy:**
- **GitHub Reviews**: `review-fix-<issue_number>-<description>`
- **Bitbucket Reviews**: `review-pr-<pr_number>-fixes`
- **Local Reviews**: `review-<scope>-<date>-fixes`
- **File Reviews**: `review-<component>-improvements`

**Branch Configuration:**
- Create from appropriate base (main, develop, feature branch)
- Configure review and testing requirements
- Set up CI/CD validation for review fix branches

### Implementation Strategy

**Systematic Fix Implementation:**
1. **Priority-Based Fixes**: Address critical and high-priority issues first
2. **Incremental Implementation**: Small, testable changes following task breakdown
3. **Continuous Validation**: Test each fix individually before proceeding
4. **Quality Gates**: Code quality, security, and performance validation
5. **Documentation Updates**: Maintain current documentation throughout process

### Step-by-Step Development

**Phase-Based Implementation:**
- **Phase 1**: Security vulnerability fixes and critical bug resolution
- **Phase 2**: Performance optimization and resource efficiency improvements
- **Phase 3**: Code quality enhancements and design pattern improvements
- **Phase 4**: Test coverage improvements and testing infrastructure
- **Phase 5**: Documentation updates and knowledge transfer

## 🔹 TEST

### Testing Strategy

**Comprehensive Test Coverage:**
- **Individual Fix Testing**: Validate each fix independently
- **Regression Testing**: Ensure existing functionality preserved
- **Integration Testing**: Cross-component compatibility and functionality
- **Performance Testing**: Benchmark validation and optimization verification
- **Security Testing**: Vulnerability scanning and security validation

**Source-Specific Testing Requirements:**
- **GitHub**: Address original issue/PR requirements and acceptance criteria
- **Bitbucket**: Validate against PR requirements and workflow compliance
- **Local**: Comprehensive validation of code changes and improvements
- **File**: Quality assurance for analyzed files and components

### Quality Validation

**Multi-Level Quality Gates:**
1. **Code Quality Metrics**: Linting, formatting, and coding standard compliance
2. **Security Standards**: Vulnerability assessment and security best practices
3. **Performance Benchmarks**: Response time, memory usage, and efficiency
4. **Test Coverage**: Unit, integration, and end-to-end test completeness
5. **Documentation Quality**: Code documentation and knowledge transfer

### Performance Verification

**Measurable Improvements:**
- Document specific performance gains with quantifiable metrics
- Validate resource utilization improvements and optimization effectiveness
- Ensure scalability and stability under various load conditions
- Monitor memory usage optimization and system efficiency gains

## 🔹 DEPLOY

### Deployment Strategy

**Source-Specific Deployment Process:**
- **GitHub**: Create PR with comprehensive fix documentation and test results
- **Bitbucket**: Create merge request with detailed change summary and validation
- **Local**: Systematic commit strategy with detailed fix documentation
- **File**: Documentation of improvements with performance and quality metrics

**Deployment Validation:**
- Automated CI/CD pipeline execution and comprehensive testing
- Code quality gate validation and security scanning
- Performance monitoring setup and baseline establishment
- Comprehensive documentation and knowledge transfer

### Post-Deployment Validation

**Production Monitoring:**
- **Fix Verification**: Ensure all identified issues resolved in production
- **Performance Monitoring**: Validate improvements meet requirements and expectations
- **Error Rate Tracking**: Monitor for new issues or regressions introduced
- **Security Posture**: Validate security improvements and vulnerability mitigation

**Review Success Metrics:**
- All identified issues resolved with comprehensive testing
- Code quality improvements with measurable metrics
- Performance gains documented with specific benchmarks
- Security enhancements validated and operational

### Documentation Updates

**Knowledge Transfer:**
- **Code Review Guidelines**: Update team code review standards and practices
- **Best Practices Documentation**: Share lessons learned and improvement patterns
- **Development Guidelines**: Update coding standards and quality requirements
- **Security Guidelines**: Update security practices and vulnerability prevention

## Code Review Quality Standards

### Specific and Actionable Feedback
```markdown
✅ GOOD: "Extract the 50-line validation function in `UserService.py:120-170` into a separate `ValidationService` class"
❌ BAD: "Code is too complex"

✅ GOOD: "Fix SQL injection vulnerability in `src/auth/login.py:45-52` by using parameterized queries"
❌ BAD: "Security issue found"
```

### Context and Rationale
- Explain the reasoning behind suggested changes
- Provide specific solutions and alternative approaches
- Reference relevant documentation and established best practices
- Consider implementation effort versus benefit ratio

### Language/Framework Specific Checks
- Apply appropriate linting rules and coding conventions
- Check for framework-specific anti-patterns and best practices
- Validate dependency usage, versions, and security considerations
- Ensure proper typing annotations and documentation standards

## Exception Handling Standards

### Critical Dependencies (FAIL FAST)
```python
# Let ImportError propagate for required functionality
from required_lib import CriticalClass

def __init__(self, config: Required[Config]):
    if not config.required_setting:
        raise AgentInitializationError("Required configuration missing")
```

### Optional Features (GRACEFUL DEGRADATION)
```python
# Handle optional dependencies gracefully
try:
    from optional_lib import Enhancement
    self.enhancement = Enhancement()
except ImportError:
    logger.info("Enhancement not available - continuing with core functionality")
    self.enhancement = None
```

## Code Review Anti-Patterns

### Critical Anti-Patterns to Identify
```python
# ❌ Silent Exception Swallowing
try:
    self.tools = load_external_tools()
except Exception as e:
    logger.error(f"Failed to load tools: {e}")
    # Continues with broken state - WRONG!

# ❌ Hardcoded Prompts
class Agent:
    def get_prompt(self):
        return "You are an agent..."  # Should be externalized

# ❌ Code Duplication
class Agent1:
    def __init__(self, llm=None, config=None):
        # 20+ lines of common setup - duplicated across agents
```

### Quality Standards to Enforce
```python
# ✅ Proper Exception Handling
def _load_tools(self) -> None:
    try:
        self.tools = load_external_tools()
    except Exception as e:
        logger.error(f"Failed to load tools: {e}")
        raise  # Let caller decide if acceptable

# ✅ Centralized Prompt Management
from .prompts import get_agent_prompt

class Agent:
    def _get_default_prompt(self) -> str:
        return get_agent_prompt()

# ✅ Inheritance Over Implementation
class BaseAgent(ABC):
    def __init__(self, llm=None, config=None):
        # Common setup logic centralized
```

## Advanced Review Patterns

### TodoWrite Integration for Complex Reviews
```python
todos = [
    {
        "id": "fix_critical_security",
        "content": "Fix SQL injection vulnerability in query builder (src/auth/login.py:45-52)",
        "status": "pending",
        "priority": "high"
    },
    {
        "id": "improve_error_handling",
        "content": "Enhance error handling with detailed messages and fail-fast for critical deps",
        "status": "pending",
        "priority": "medium"
    }
]
```

### Performance Optimization Tracking
- Document baseline performance metrics before fixes
- Measure and validate improvements with specific benchmarks
- Track resource utilization improvements and efficiency gains
- Monitor long-term performance trends and optimization effectiveness

## Success Criteria

**Technical Success:**
- [ ] All identified code issues resolved and validated
- [ ] No performance regression or new issues introduced
- [ ] Comprehensive test coverage maintained or improved
- [ ] Code quality standards met or exceeded with measurable improvements
- [ ] Security vulnerabilities addressed and validated

**Process Success:**
- [ ] Task breakdown followed with 2-hour rule compliance
- [ ] All review phases completed with proper validation
- [ ] Comprehensive documentation updated and knowledge transferred
- [ ] Team code review standards improved and documented
- [ ] Source issue/PR properly updated with resolution details

**Quality Success:**
- [ ] Code maintainability and readability significantly improved
- [ ] Performance optimizations deliver measurable benefits
- [ ] Security posture enhanced with vulnerability mitigation
- [ ] Development best practices reinforced and documented
- [ ] Long-term technical debt reduction achieved

# USER_LEVEL_CLAUDE.md - Python Development Standards

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 mcpreferences are recommended; use them only when you need to refer to or verify APIs.

IMPORTANT:
1. Before you make any change, create and checkout a feature branch named feature/<feature_name> or bugfix/<issue_name> which is short and descriptive name and Make and then commit your changes in this branch.
2. You must write automated tests for all code.
3. You must compile the code and pass ALL tests before committing.
4. **WORKFLOW CONTEXT EXCLUSION**: NEVER commit markdown files under `<project_root>/task_<name>/` directories (e.g., `task_auth/`, `task_bug-123/`) as these are local workflow context files
5. **GITIGNORE MANAGEMENT**: Automatically update `.gitignore` to exclude workflow directories by adding pattern `task_*/` to ignore all task workspaces

---

## 1. Documentation Synchronization

* **Single source of truth**: Global rules live in this `CLAUDE.md`.
* **Update policy**: When implementing a bug fix or feature, update this `CLAUDE.md` so guidance stays authoritative.
* **Feature/Issue tracking**: After each bug fix, feature, or ad-hoc implementation, update the corresponding workspace documentation.
* **Reflection**: Use `_meta_reflection` command to append reflection.md for continuous improvement.
* **Context7 MCP Integration**: Use Context7 Model Context Protocol for real-time documentation retrieval and validation during all development phases.

### Context7 MCP Integration for Development
The development workflow now integrates Context7 MCP for enhanced documentation-driven development:
- **Library Resolution**: Automatic resolution of library/framework names to Context7-compatible IDs during planning and implementation
- **Documentation Retrieval**: Real-time access to current documentation during all development phases using `mcp_context7_get-library-docs`
- **Best Practices Validation**: Code validation against current framework standards and patterns
- **Topic-Specific Guidance**: Focused documentation retrieval for specific implementation topics (e.g., 'authentication', 'routing', 'database', 'testing')
- **Pseudocode Generation**: Structured code examples and architectural patterns in planning phases to aid understanding and implementation

### Clarification‑First Policy (Minimize back-and-forth)
- Reflect: Restate the user’s intent in your own words before acting.
- Ask: Bundle clarifying questions for any ambiguities or assumptions.
- Confirm: Wait for confirmation before coding or making changes.
- Record: Capture assumptions as “unconfirmed” until resolved.

This policy applies to all SDLC commands and workflows.

### Task Structure
SDLC commands create and maintans feature or issue-specific workspaces with consistent `task_` prefix 

```
<project_root>/task_<name>/
├── specs/
│   ├── feature-spec.md                      # PRD (user perspective)
│   ├── user-stories.md                      # user stories + acceptance criteria
│   ├── business-case.md                     # business value and success metrics
│   ├── api-contract.yaml                    # OpenAPI (if applicable)
├── requirement/
│   ├── analysis/requirement_analysis.md
│   ├── user-stories/stories.md                  # optional (features)
│   ├── requirements/requirements.md            # optional (medium/large)
│   └── handoff/handoff_requirements.md         # optional (medium/large)
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

Each feature/issue workspace must include:
* Description and impact assessment
* Root cause analysis and changed files/commands
* Validation steps and outcomes
* Follow-ups or rollback procedures

**Examples**:
- `task_user-authentication/specs/feature-spec.md`
- `task_user-authentication/plan/tasks/tasks.md`
- `feature_ops-cli-resolution/issue/analysis.md` capturing adjustments like `PYTHONPATH=src` and `OPS_DEBUG`

You MUST read these files for context.

### Workspace File Management
**Local-Only Policy**: All files within `<project_root>/task_<name>/` directories are considered local workflow context and should NEVER be committed to git:
- These files are temporary working documents for planning and analysis
- They contain intermediate thoughts, research notes, and decision-making processes
- They are meant to be regenerated or recreated as needed for each workflow session
- Committing them would clutter the repository with transient documentation

**GitIgnore Integration**: When creating new workspaces, automatically update `.gitignore` with the standard pattern:
- Add pattern: `task_*/` to ignore all task workspace directories
- This single pattern covers all SDLC command workspaces consistently
- Ensure the `.gitignore` is committed to maintain consistency across team members

---

## 2. Python Project Structure

For new projects or structure refactoring, use uv for package management:

```
project_name/
├── pyproject.toml          # Project metadata & dependencies
├── uv.lock                 # Lockfile (uv)
├── README.md               # Documentation
├── LICENSE                 # License
├── .gitignore
├── .env.example            # Example env vars
├── CLAUDE.md               # Project-specific rules (optional)

├── src/                    # Source code (library)
│   └── project_name/
│       ├── __init__.py
│       ├── core/           # Core functionality
│       │   ├── __init__.py
│       │   ├── logging_config.py
│       │   └── exceptions.py
│       ├── module_a.py
│       ├── module_b.py
│       └── cli.py          # Optional CLI entrypoint

├── tests/                  # Pytest tests
│   ├── __init__.py
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   ├── acceptance/         # Acceptance tests
│   └── conftest.py         # Pytest configuration

└── scripts/                # Operational scripts (not part of lib)
    ├── run_app.py
    ├── task_x.py
    └── deploy.py
```

* **`src/`**: All production code with proper module organization
* **`tests/`**: Mirrors `src/` structure, pytest auto-discovers
* **`scripts/`**: Operations, demo, or automation scripts
* **Install locally**: `uv pip install -e ".[dev]"`

---

## 3. Testing Guidelines

### Framework and Structure
* **Framework**: `pytest` with proper fixtures and configuration
* **Test organization**: 
  - Unit tests in `tests/unit/`
  - Integration tests in `tests/integration/`
  - Acceptance tests in `tests/acceptance/`
* **Coverage requirement**: Minimum 80% for new code
* **Performance**: Keep tests fast (<5s per test) and deterministic

### Testing Commands
```bash
# Run all tests
make test

# Run with coverage
pytest --cov=project_name --cov-report=html

# Run specific test categories
pytest tests/unit/
pytest tests/integration/
pytest tests/acceptance/
```

### TDD for Bug Fixing
1. **Reproduce**: Write a failing test that reproduces the bug
2. **Fix**: Implement minimal fix to make test pass
3. **Regress**: Add regression tests to ensure bug doesn't recur
4. **Validate**: Run full test suite to ensure no side effects

### Test Quality Standards
* **Isolation**: Each test should be independent
* **Clarity**: Test names should describe behavior being tested
* **Assertions**: Use specific assertions with clear error messages
* **Mocking**: Mock external dependencies appropriately

---

## 4. Error Handling and Resilience

### Exception Hierarchy
```python
# In src/project_name/core/exceptions.py
class ProjectBaseException(Exception):
    """Base exception for all project-specific errors"""
    pass

class ValidationError(ProjectBaseException):
    """Input validation failures"""
    pass

class ProcessingError(ProjectBaseException):
    """Business logic processing errors"""
    pass

class ExternalServiceError(ProjectBaseException):
    """External service integration errors"""
    pass
```

### Error Handling Patterns
* **Fail fast**: Validate inputs early and explicitly
* **Graceful degradation**: Handle expected failures gracefully
* **Context preservation**: Include relevant context in error messages
* **Logging integration**: Log errors with appropriate levels

### Resilience Requirements
* **Timeouts**: Set appropriate timeouts for external calls
* **Retries**: Implement exponential backoff for transient failures
* **Circuit breakers**: For critical external dependencies
* **Health checks**: Implement `/health` endpoints for services

---

## 5. Security Standards

### Input Validation
* **Sanitize all inputs**: Never trust user or external data
* **Use type hints**: Enforce types with mypy or similar
* **Validate bounds**: Check ranges, lengths, and formats
* **SQL injection prevention**: Use parameterized queries only

### Secrets Management
* **Never commit secrets**: Use `.env` files and environment variables
* **Rotate credentials**: Regular credential rotation procedures
* **Least privilege**: Minimal necessary permissions only
* **Audit access**: Log and monitor security-relevant operations

### Security Review Checklist
* [ ] Input validation implemented
* [ ] Authentication/authorization verified
* [ ] Secrets properly managed
* [ ] Dependencies audited (`pip-audit` or similar)
* [ ] Security headers configured (for web apps)

---

## 6. Performance Guidelines

### Code Performance
* **Profile before optimizing**: Use `cProfile` or `py-spy`
* **Async where appropriate**: For I/O-bound operations
* **Caching strategies**: Implement caching for expensive operations
* **Memory management**: Monitor memory usage in long-running processes

### Database Performance
* **Query optimization**: Use appropriate indexes and query patterns
* **Connection pooling**: For database connections
* **Pagination**: For large result sets
* **Monitoring**: Track query performance and slow queries

### Monitoring Requirements
* **Metrics collection**: Key performance indicators
* **Alerting**: For performance degradation
* **Logging**: Performance-related events
* **Dashboards**: Operational visibility

---

## 7. Logging Standards

### Configuration
* Use centralized logging via `get_logger()` from `core.logging.logging_config`
* Initialize in constructors: `self.logger = get_logger()`

### Logging Levels
* **DEBUG**: Tracing, state changes, development information
* **INFO**: Operational events, business logic flow
* **WARNING**: Deprecated features, recoverable errors
* **ERROR**: Serious non-fatal errors requiring attention
* **CRITICAL**: Fatal errors that stop execution

### Message Format
* **Standard format**: `timestamp - level - [module.function] - message`
* **Structured logging**: Use JSON format for production systems
* **Context inclusion**: Include relevant IDs and correlation data

### Implementation Example
```python
from ..core.logging_config import get_logger

class MyAgent:
    def __init__(self):
        self.logger = get_logger()
        self.logger.debug("Agent initialized")

    def process(self, data):
        self.logger.info(f"Processing {len(data)} items")
        try:
            # processing logic
            self.logger.debug("Processing completed successfully")
        except Exception as e:
            self.logger.error(f"Processing failed: {e}", exc_info=True)
```

### Testing Integration
* Use `caplog` fixture in pytest to validate log messages
* Test appropriate log levels for different scenarios
* Verify sensitive data is not logged

---

## 8. Code Quality Standards

### Code Style
* **Formatter**: Use `black` for consistent formatting
* **Linting**: Use `ruff` or `flake8` for code quality
* **Type checking**: Use `mypy` for static type analysis
* **Import sorting**: Use `isort` for consistent imports

### Code Review Requirements
* **Automated checks**: All CI checks must pass
* **Manual review**: At least one reviewer for all changes
* **Security review**: For security-sensitive changes
* **Performance review**: For performance-critical changes

### Documentation Requirements
* **Docstrings**: All public functions and classes
* **Type hints**: All function signatures
* **README updates**: For user-facing changes
* **CHANGELOG**: For released versions

---

## 9. Commit & Pull Request Guidelines

### Commit Standards
* **Frequent commits**: Commit after each logical change and bug fix/feature enhancement to maintain history
* **Descriptive messages**: Clear, imperative mood
* **SDLC workflow format**:
  - Features: `sdlc: implement feature <name> - <summary>`
  - Bug fixes: `sdlc: implement bug <name> - <summary>`
  - Planning: `sdlc: plan feature/bug <name> - <summary>`
  - Testing: `sdlc: test <name> - <summary>`
  - Deployment: `sdlc: deploy <name> - <summary>`
* **Standard format** (non-SDLC):
  - Docs: `docs: update documentation for <component>`
  - Refactor: `refactor: improve <component> structure`

### Pull Request Requirements
* **Clear description**: What, why, and how
* **Linked issues**: Reference related issues/tickets
* **Scope documentation**: What areas are affected
* **Test evidence**: Commands and output showing validation
* **Breaking changes**: Clearly documented if any
* **Operational impact**: Notes for deployment or configuration

### History Management
* **No history rewriting**: Absolutely no `git reset` on shared branches
* **Rollback strategy**: Use `git revert` for all rollbacks
* **Traceability**: Maintain complete audit trail

---

## 10. Development Workflow Integration

### SDLC Command Integration
This project integrates with standardized SDLC commands enhanced with Context7 MCP:
* `sdlc_plan_feature --name <feature>` for feature planning with Context7 documentation retrieval and pseudocode generation
* `sdlc_implement_feature --name <feature>` for new features with Context7-guided implementation
* `sdlc_plan_bug --name <bug>` for bug fix planning with Context7 best practices validation
* `sdlc_implement_bug --name <bug>` for bug fixes with Context7-informed patterns
* `sdlc_code_review --name <component>` for code review with Context7 validation against current standards
* `sdlc_test --name <component>` for testing workflows

### Context7 Integration in SDLC Workflow
Each SDLC command now includes Context7 MCP integration:
- **Planning Phase**: Resolve library IDs and fetch relevant documentation for informed architecture decisions
- **Implementation Phase**: Access topic-specific documentation and current best practices during development
- **Code Review Phase**: Validate code against current framework standards and patterns
- **Testing Phase**: Use documented testing frameworks and patterns for comprehensive validation

### Task Management
* **2-hour rule**: Break tasks into ≤2 hour chunks with validation steps
* **Validation steps**: Clear success criteria for each chunk
* **Progress tracking**: Regular commits and status updates
* **Dependency management**: Identify and track dependencies

### Quality Gates
* **Pre-commit hooks**: Automated quality checks
* **CI/CD pipeline**: Automated testing and deployment
* **Code coverage**: Maintain coverage thresholds
* **Security scanning**: Automated vulnerability detection

---

## 11. Operational Standards

### Environment Management
* **Configuration management**: Environment-specific configs
* **Deployment automation**: Repeatable deployment processes
* **Rollback procedures**: Quick rollback capabilities

### Monitoring and Observability
* **Health checks**: Service health endpoints
* **Metrics collection**: Key operational metrics
* **Log aggregation**: Centralized log management
* **Alerting**: Proactive issue detection

### Maintenance Procedures
* **Dependency updates**: Regular security and feature updates
* **Database migrations**: Safe, reversible migrations
* **Backup procedures**: Regular data backups
* **Disaster recovery**: Recovery procedures documented

---

*This document serves as the authoritative source for Python development standards and should be updated with each significant project evolution.*


## CRITICAL: Use ripgrep, not grep
NEVER use grep for project-wide searches (slow, ignores .gitignore). ALWAYS use rg.

- `rg "pattern"` — search content
- `rg --files | rg "name"` — find files
- `rg -t python "def"` — language filters

## File finding

- Prefer `fd` (or `fdfind` on Debian/Ubuntu). Respects .gitignore.

## JSON

- Use `jq` for parsing and transformations.

# USER_LEVEL_CLAUDE.md - Python Development Standards

Global development standards and practices for Python projects in this workspace.
It is **project-agnostic** and applies to all repositories that include it.

---

## 1. Documentation Synchronization

* **Single source of truth**: Global rules live in this `CLAUDE.md`.
* **Update policy**: When implementing a bug fix or feature, update this `CLAUDE.md` so guidance stays authoritative.
* **Feature/Issue tracking**: After each bug fix, feature, or ad-hoc implementation, update the corresponding workspace documentation.
* **Reflection**: Use `_meta_reflection` command to append reflection.md for continuous improvement.

### Workspace Structure
SDLC commands createfeature/issue-specific workspaces:

```
<project_root>/<feature_or_issue_name>/
├── plan/                    # Planning documents and strategies
│   ├── main-plan.md         # Primary plan and approach
│   ├── task-breakdown.md    # Detailed task breakdown (2-hour rule)
│   ├── decision-log.md      # Options, pros/cons, decisions with rationale
│   ├── architecture.md      # High-level diagrams and contracts
│   └── implementation.md    # Step-by-step implementation strategy
├── issue/                   # Issue analysis and requirements
│   ├── analysis.md          # Problem/requirement analysis
│   ├── research.md          # Background research and prior art
│   └── requirements.md      # Specific requirements and acceptance criteria
├── context/                 # Additional context and references
│   ├── source-reference.md  # Original source context and links
│   └── dependencies.md      # Dependencies and relationships
└── reflection/
    └── reflection.md        # Post-implementation analysis
```

Each feature/issue workspace must include:
* Description and impact assessment
* Root cause analysis and changed files/commands
* Validation steps and outcomes
* Follow-ups or rollback procedures

**Examples**: 
- `user_authentication_feature/plan/main-plan.md`
- `ops_cli_resolution_bug/issue/analysis.md` capturing adjustments like `PYTHONPATH=src` and `OPS_DEBUG`

You MUST read these files for context.

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
* **Conventional format**:
  - Features: `feat: implement feature <name> - summary`
  - Bug fixes: `fix: resolve bug <name> - summary`
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
This project integrates with standardized SDLC commands:
* `sdlc_implement_feature --name <feature>` for new features
* `sdlc_implement_bug --name <bug>` for bug fixes
* `sdlc_test --name <component>` for testing workflows

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
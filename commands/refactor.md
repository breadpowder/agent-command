# Refactor Command $ARGUMENTS.

## Purpose
Systematic code refactoring workflow for development lifecycle that handles codebase improvements, architectural changes, and technical debt reduction with comprehensive analysis and validation.

## Command Usage
```bash
# Component-focused refactoring
refactor --source local --scope src/payment/ --name payment-system-refactor

# Module-level refactoring
refactor --source local --scope files --name api-modernization --id "src/**/*.py"

# Feature-based refactoring
refactor --source github --type feature --id <feature_issue> --name feature-refactor

# Architecture-level refactoring
refactor --source local --scope modules --name architecture-redesign --id "core,utils,services"
```

**Universal Parameters:**
- `--source <github|local|bitbucket|file>`: Input source
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--scope <files|modules|component>`: What to work on
- `--type <issue|pr|feature|bug|etc>`: Specific type when needed
- `--id <identifier>`: External ID (issue#, PR#, etc) or file/module identifiers

## 🔹 PLAN

### 1. Context Gathering & Analysis

**Codebase Analysis Framework:**
- **Current State Assessment**: Document existing architecture and patterns
- **Technical Debt Identification**: Catalog code smells, performance issues, maintainability concerns
- **Dependency Mapping**: Understand component relationships and coupling
- **Pattern Analysis**: Identify existing design patterns and anti-patterns

**Source-Specific Context Collection:**
- **GitHub**: Link to feature requests or architecture improvement issues
- **Local**: Analyze specified files, modules, or components directly
- **Bitbucket**: Extract requirements from architectural improvement requests
- **File**: Focus on specific file-level improvements and optimizations

### 2. Context Storage (Standard Structure)

**Structured Workspace Creation:**
```
<project_root>/<name>/
├── plan/
│   ├── main-plan.md           # Primary refactoring strategy and approach
│   ├── task-breakdown.md      # Detailed task breakdown (2-hour rule)
│   └── implementation.md      # Step-by-step implementation strategy
├── issue/
│   ├── analysis.md            # Current architecture and issues analysis
│   ├── research.md            # Background research and architectural patterns
│   └── requirements.md        # Refactoring requirements and goals
└── context/
    ├── source-reference.md    # Original source context and links
    └── dependencies.md        # Dependencies and impact analysis
```

**Architecture Documentation:**
- Current system architecture diagrams and patterns
- Technical debt analysis with priority assessment
- Refactoring goals and success criteria definition
- Risk assessment and mitigation strategies

### 3. Requirements Analysis & Planning

**Refactoring Goals Definition:**
- **Functional Requirements**: What must be preserved during refactoring
- **Non-Functional Requirements**: Performance, maintainability, testability improvements
- **Architectural Requirements**: Design pattern implementation and structural changes
- **Compatibility Requirements**: Backward compatibility and migration strategies

**Impact Assessment:**
- Code change scope and affected components
- Performance implications and optimization opportunities
- Testing requirements and validation strategies
- Team training and knowledge transfer needs

### 4. Task Breakdown (2-Hour Rule)

**CRITICAL: Phased Refactoring Approach**
- **Phase 1**: Analysis and design documentation (≤2h)
- **Phase 2**: Interface design and contract definition (≤2h)
- **Phase 3**: Core component refactoring (≤2h per component)
- **Phase 4**: Integration and compatibility testing (≤2h)
- **Phase 5**: Performance optimization and validation (≤2h)
- **Phase 6**: Documentation and migration guide creation (≤2h)

**Task Independence:**
- Each phase delivers working, testable improvements
- Rollback capability maintained at every checkpoint
- Independent validation of each refactoring increment
- Clear dependency mapping between refactoring phases

## 🔹 CREATE

### Branch Management

**Refactoring Branch Strategy:**
- **Long-running refactoring**: `refactor-<name>-<component>`
- **Incremental refactoring**: `refactor-<phase>-<component>`
- **Feature-based refactoring**: `refactor-feature-<id>-<description>`
- **Architecture refactoring**: `refactor-arch-<system>-<pattern>`

**Branch Management Best Practices:**
- Regular merges from main to avoid conflicts
- Feature flags for gradual rollout of refactored components
- Parallel development support with clear integration points

### Implementation Strategy

**Systematic Refactoring Approach:**
1. **Interface Stabilization**: Define and implement new interfaces first
2. **Incremental Migration**: Replace implementations while preserving interfaces
3. **Dependency Injection**: Implement inversion of control patterns
4. **Test Coverage**: Maintain or improve test coverage throughout process
5. **Performance Monitoring**: Continuous performance validation during refactoring

### Step-by-Step Development

**Phase-Based Implementation:**
- **Phase 1**: Interface design and abstract base class creation
- **Phase 2**: Core logic refactoring with design pattern implementation
- **Phase 3**: Dependency injection and inversion of control
- **Phase 4**: Performance optimization and resource management
- **Phase 5**: Backward compatibility layer and migration utilities

## 🔹 TEST

### Testing Strategy

**Comprehensive Test Coverage:**
- **Regression Tests**: Ensure existing functionality preserved
- **Unit Tests**: New components and refactored logic validation
- **Integration Tests**: Component interaction and interface compliance
- **Performance Tests**: Benchmark comparison and optimization validation
- **Migration Tests**: Backward compatibility and upgrade path validation

**Refactoring-Specific Testing:**
- **Interface Compliance**: New implementations meet defined contracts
- **Behavioral Preservation**: Existing behavior maintained post-refactoring
- **Performance Benchmarking**: Before/after performance comparison
- **Load Testing**: System stability under various conditions

### Quality Validation

**Multi-Level Quality Gates:**
1. **Code Quality Metrics**: Complexity, maintainability, and readability improvements
2. **Design Pattern Compliance**: Proper implementation of architectural patterns
3. **Performance Benchmarks**: Memory usage, response times, and throughput
4. **Security Validation**: Security posture maintained or improved
5. **Accessibility Standards**: UI/UX improvements validated where applicable

### Performance Verification

**Quantifiable Improvements:**
- **Execution Speed**: Response time improvements with specific metrics
- **Resource Utilization**: Memory usage optimization and efficiency gains
- **Scalability**: Load handling capacity and concurrent user support
- **Maintainability**: Code complexity reduction and technical debt metrics

## 🔹 DEPLOY

### Deployment Strategy

**Refactoring Deployment Approaches:**
- **Strangler Fig Pattern**: Gradual replacement of legacy components
- **Feature Toggle**: Controlled rollout with ability to fallback
- **Blue-Green Deployment**: Complete environment switch for major refactoring
- **Canary Deployment**: Gradual traffic shift to refactored components

**Source-Specific Deployment:**
- **GitHub**: Create comprehensive PR with refactoring documentation
- **Local**: Systematic commit strategy with detailed change documentation
- **Bitbucket**: Merge request with architectural improvement summary
- **File**: Documentation of improvements with performance metrics

### Post-Deployment Validation

**Production Monitoring:**
- **Performance Metrics**: Continuous monitoring of system performance
- **Error Rate Tracking**: Monitor for regression or new issues
- **User Experience**: Validate maintained or improved user experience
- **System Stability**: Overall system reliability and availability monitoring

**Refactoring Success Metrics:**
- Code quality improvements (complexity, duplication, maintainability)
- Performance gains with quantifiable benchmarks
- Developer productivity improvements and reduced technical debt
- System reliability and maintainability enhancements

### Documentation Updates

**Knowledge Transfer:**
- **Architecture Documentation**: Updated system architecture and design patterns
- **Development Guidelines**: New patterns and best practices documentation
- **Migration Guides**: Step-by-step upgrade procedures for dependent systems
- **Performance Baselines**: New performance benchmarks and optimization guides

## Advanced Refactoring Patterns

### Dependency Injection Implementation
```python
# Before: Tight coupling
class Agent:
    def __init__(self):
        self.memory = MemorySession()  # Hard dependency

# After: Dependency injection
class Agent:
    def __init__(self, memory_session: Optional[MemorySession] = None):
        self.memory_session = memory_session or create_default_memory()
```

### Interface-Based Architecture
```python
# Abstract base class with clear contracts
from abc import ABC, abstractmethod

class AgentInterface(ABC):
    @abstractmethod
    def process(self, input_data: Any) -> Any:
        pass
    
    @abstractmethod
    def configure(self, config: Dict[str, Any]) -> None:
        pass
```

### Factory Pattern Implementation
```python
# Centralized object creation
def create_agent(agent_type: str, **kwargs) -> AgentInterface:
    if agent_type == "memory":
        return MemoryAgent(**kwargs)
    elif agent_type == "stateless":
        return StatelessAgent(**kwargs)
    raise ValueError(f"Unknown agent type: {agent_type}")
```

## Success Criteria

**Technical Success:**
- [ ] All existing functionality preserved and validated
- [ ] New architecture implements design goals and patterns
- [ ] Performance targets met or exceeded with documented metrics
- [ ] Code quality metrics improved (complexity, maintainability, testability)
- [ ] Security standards maintained or enhanced

**Process Success:**
- [ ] Task breakdown followed with 2-hour rule compliance
- [ ] All refactoring phases completed with proper validation
- [ ] Comprehensive documentation updated and knowledge transferred
- [ ] Team training completed for new patterns and architecture
- [ ] Migration guides created and validated

**Business Success:**
- [ ] Development velocity maintained or improved
- [ ] Technical debt reduced with measurable improvements
- [ ] System reliability and maintainability enhanced
- [ ] Feature development capability increased
- [ ] Long-term maintenance costs reduced
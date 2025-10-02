# Release and Publish Command $ARGUMENTS.

## Context first
- Gather relevant context from the existing
  task_<name>/ stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify third-party
  APIs.

## Purpose
Comprehensive release and publication workflow for development lifecycle that automates version management, testing, building, and deployment to package repositories with validation and monitoring.

## Command Usage
```bash
# Standard package release
release_and_publish --source github --type release --scope package --name version-0.4.0

# Local package release
release_and_publish --source local --type release --scope package --name local-release --id 0.4.0

# Pre-release/beta version
release_and_publish --source github --type pre-release --scope package --name beta-release --id 0.4.0-beta.1

# Hotfix release
release_and_publish --source github --type hotfix --scope package --name hotfix-release --id 0.3.1
```

**Universal Parameters:**
- `--source <github|local|bitbucket|file>`: Input source
- `--name <descriptive-name>`: Workspace name (creates <project_root>/<name>/)
- `--scope <files|modules|component>`: What to work on (package, documentation, etc.)
- `--type <issue|pr|feature|bug|etc>`: Specific type (release, pre-release, hotfix, etc.)
- `--id <identifier>`: External ID (version number, build number, etc.)

## 🔹 PLAN

### 1. Context Gathering & Analysis

**Release Preparation Analysis:**
- **Version Management**: Analyze current version and determine next appropriate version
- **Change Analysis**: Review commits, changes, and features since last release
- **Dependency Validation**: Verify all dependencies are compatible and secure
- **Quality Assessment**: Evaluate test coverage, code quality, and documentation completeness

**Source-Specific Context Collection:**
- **GitHub**: Leverage GitHub releases, tags, and milestone tracking
- **Local**: Analyze local changes and prepare for package repository publication
- **Bitbucket**: Use Bitbucket pipeline integration for automated releases
- **File**: Process release configuration files and custom release specifications

### 2. Context Storage (Standard Structure)

**Structured Workspace Creation:**
```
<project_root>/<name>/
├── plan/
│   ├── main-plan.md           # Primary release strategy and timeline
│   ├── task-breakdown.md      # Detailed task breakdown (2-hour rule)
│   └── implementation.md      # Step-by-step release implementation strategy
├── issue/
│   ├── analysis.md            # Release readiness analysis and quality assessment
│   ├── research.md            # Market analysis and version impact assessment
│   └── requirements.md        # Release requirements and acceptance criteria
└── context/
    ├── source-reference.md    # Original source context and release triggers
    └── dependencies.md        # Dependencies, integrations, and compatibility matrix
```

**Release Documentation:**
- Version history and changelog generation
- Breaking changes documentation and migration guides
- Feature summary and improvement highlights
- Known issues and limitation documentation

### 3. Requirements Analysis & Planning

**Release Validation Framework:**
- **Quality Gates**: Code quality, test coverage, security scanning results
- **Compatibility Testing**: Cross-platform, version compatibility, and integration testing
- **Performance Validation**: Performance benchmarks and optimization verification
- **Security Assessment**: Vulnerability scanning and security compliance verification

**Release Impact Assessment:**
- User impact analysis and communication strategy
- Breaking changes documentation and migration planning
- Rollback procedures and contingency planning
- Post-release monitoring and support strategy

### 4. Task Breakdown (2-Hour Rule)

**CRITICAL: Systematic Release Process**
- **Phase 1**: Pre-release validation and quality assessment (≤2h)
- **Phase 2**: Version management and changelog generation (≤2h)
- **Phase 3**: Package building and automated testing (≤2h)
- **Phase 4**: Repository publication and distribution (≤2h)
- **Phase 5**: Post-release validation and monitoring setup (≤2h)
- **Phase 6**: Documentation updates and communication (≤2h)

**Task Independence:**
- Each phase provides verifiable milestone and rollback point
- Independent validation of release artifacts and quality
- Clear success criteria and automated validation checks
- Explicit dependency mapping between release phases

## 🔹 CREATE

### Branch Management

**Release Branch Strategy:**
- **Major Release**: `release-<major>.<minor>.0` (e.g., `release-1.0.0`)
- **Minor Release**: `release-<major>.<minor>.<patch>` (e.g., `release-0.4.0`)
- **Patch/Hotfix**: `hotfix-<version>-<description>` (e.g., `hotfix-0.3.1-security`)
- **Pre-release**: `pre-release-<version>-<identifier>` (e.g., `pre-release-0.4.0-beta.1`)

**Branch Protection and Validation:**
- Enforce all quality gates and automated testing
- Require code review and approval before merge
- Configure automated CI/CD pipeline for release validation

### Implementation Strategy

**Automated Release Pipeline:**
1. **Pre-release Validation**: Comprehensive testing and quality gate validation
2. **Version Management**: Automated version bumping and tagging
3. **Artifact Generation**: Package building, documentation generation, distribution preparation
4. **Publication**: Automated deployment to package repositories and distribution channels
5. **Post-release Validation**: Smoke testing, monitoring setup, and success verification

### Step-by-Step Development

**Phase-Based Release Implementation:**
- **Phase 1**: Quality validation, testing, and security scanning
- **Phase 2**: Version management, tagging, and changelog generation
- **Phase 3**: Package building, artifact generation, and distribution preparation
- **Phase 4**: Repository publication and automated distribution
- **Phase 5**: Post-release monitoring, validation, and support preparation

## 🔹 TEST

### Testing Strategy

**Comprehensive Release Validation:**
- **Pre-release Testing**: Full test suite execution with comprehensive coverage
- **Integration Testing**: Cross-platform compatibility and integration validation
- **Performance Testing**: Benchmark validation and regression testing
- **Security Testing**: Vulnerability scanning and security compliance verification
- **User Acceptance Testing**: Critical user workflow validation and feedback collection

**Release-Specific Testing Requirements:**
- **Package Installation**: Validate package installation across different environments
- **Dependency Resolution**: Test dependency compatibility and resolution
- **Migration Testing**: Validate upgrade paths and backward compatibility
- **Documentation Testing**: Verify documentation accuracy and completeness

### Quality Validation

**Multi-Level Release Gates:**
1. **Code Quality**: Static analysis, linting, type checking, and code coverage validation
2. **Functional Quality**: Complete feature testing and user workflow validation
3. **Performance Quality**: Benchmark validation and performance regression testing
4. **Security Quality**: Comprehensive security scanning and vulnerability assessment
5. **Compatibility Quality**: Cross-platform, version, and integration compatibility testing

### Performance Verification

**Release Performance Validation:**
- Baseline performance comparison and regression analysis
- Resource utilization validation and optimization verification
- Scalability testing and load handling capacity validation
- User experience performance metrics and optimization validation

## 🔹 DEPLOY

### Deployment Strategy

**Multi-Channel Release Deployment:**
- **Package Repositories**: PyPI, npm, Maven Central, NuGet, etc.
- **Source Code Platforms**: GitHub Releases, Bitbucket Downloads, GitLab Releases
- **Documentation Platforms**: Read the Docs, GitHub Pages, custom documentation sites
- **Distribution Channels**: Docker Hub, cloud marketplaces, app stores

**Phased Rollout Strategy:**
- **Beta/Pre-release**: Limited audience testing and feedback collection
- **Staged Release**: Gradual rollout with monitoring and feedback integration
- **Full Release**: Complete availability with comprehensive monitoring and support

### Post-Deployment Validation

**Release Success Monitoring:**
- **Installation Metrics**: Package download rates, installation success rates, usage analytics
- **Performance Monitoring**: System performance, response times, resource utilization
- **Error Tracking**: Error rates, crash reports, user-reported issues
- **User Feedback**: User satisfaction, feature adoption, support request analysis

**Release Validation Checklist:**
- Package successfully published to all target repositories
- Installation and upgrade procedures validated across platforms
- Documentation updated and accessible to users
- Support channels prepared and monitoring systems operational

### Documentation Updates

**Release Documentation Management:**
- **Changelog**: Comprehensive change documentation with version history
- **Release Notes**: User-focused feature highlights and important updates
- **Migration Guides**: Step-by-step upgrade procedures and breaking change mitigation
- **API Documentation**: Updated API references and integration examples

## Release Automation Templates

### Version Management
```bash
# Automated version detection and management
detect_next_version() {
    current_version=$(grep version pyproject.toml | cut -d'"' -f2)
    echo "Current version: $current_version"
    
    # Semantic version analysis
    if [[ $change_type == "major" ]]; then
        next_version=$(semver bump major $current_version)
    elif [[ $change_type == "minor" ]]; then
        next_version=$(semver bump minor $current_version)
    else
        next_version=$(semver bump patch $current_version)
    fi
    
    echo "Next version: $next_version"
}
```

### Automated Release Pipeline
```bash
# Complete release automation
automated_release() {
    version=$1
    
    # Phase 1: Pre-release validation
    echo "Running pre-release validation..."
    run_full_test_suite || exit 1
    run_security_scan || exit 1
    validate_documentation || exit 1
    
    # Phase 2: Version management
    echo "Updating version to $version..."
    update_version_files $version
    generate_changelog $version
    create_git_tag "v$version"
    
    # Phase 3: Package building
    echo "Building release artifacts..."
    clean_build_environment
    build_package $version
    validate_package_integrity
    
    # Phase 4: Publication
    echo "Publishing to repositories..."
    publish_to_pypi $version
    create_github_release $version
    update_documentation_site
    
    # Phase 5: Post-release validation
    echo "Validating release success..."
    verify_package_installation $version
    setup_release_monitoring
    notify_stakeholders $version
}
```

### Quality Gate Integration
```bash
# Comprehensive quality validation
validate_release_readiness() {
    echo "Validating release readiness..."
    
    # Code quality validation
    run_linting || return 1
    run_type_checking || return 1
    validate_test_coverage 80 || return 1
    
    # Security validation
    run_security_scan || return 1
    validate_dependency_security || return 1
    check_license_compatibility || return 1
    
    # Performance validation
    run_performance_benchmarks || return 1
    validate_memory_usage || return 1
    check_startup_time || return 1
    
    echo "Release readiness validation completed successfully"
    return 0
}
```

## Advanced Release Features

### Multi-Platform Release Support
- **Cross-Platform Testing**: Automated testing across Windows, macOS, and Linux
- **Architecture Support**: Multi-architecture builds (x86, ARM, etc.)
- **Environment Validation**: Testing across different Python versions, Node.js versions, etc.
- **Container Support**: Docker image building and publication

### Release Analytics and Monitoring
- **Adoption Metrics**: Track version adoption rates and upgrade patterns
- **Performance Monitoring**: Monitor performance across different versions
- **Error Analytics**: Aggregate and analyze error patterns across releases
- **User Feedback Integration**: Systematic collection and analysis of user feedback

## Success Criteria

**Technical Success:**
- [ ] All quality gates passed with comprehensive validation
- [ ] Package successfully published to all target repositories
- [ ] Installation and upgrade procedures validated across platforms
- [ ] Performance benchmarks met or exceeded with documented improvements
- [ ] Security validation completed with no critical vulnerabilities

**Process Success:**
- [ ] Task breakdown followed with 2-hour rule compliance
- [ ] All release phases completed with proper validation and documentation
- [ ] Automated release pipeline executed successfully
- [ ] Post-release monitoring and support systems operational
- [ ] Comprehensive release documentation updated and accessible

**Business Success:**
- [ ] User experience maintained or improved with new features
- [ ] Documentation and support materials prepared and available
- [ ] Stakeholder communication completed with release highlights
- [ ] Market positioning and competitive analysis completed
- [ ] Long-term maintenance and support strategy established

## Emergency Procedures

### Rollback Strategy
- Immediate package version rollback procedures
- Database migration rollback (if applicable)
- Configuration rollback and environment restoration
- User communication and impact mitigation

### Hotfix Release Process
- Critical issue identification and assessment
- Emergency fix development and testing
- Expedited release pipeline with essential quality gates
- Rapid deployment and validation procedures

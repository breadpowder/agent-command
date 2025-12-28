# SDLC PRD Feature $ARGUMENTS

## Context first
- Gather relevant context from the existing
  task_<name>/requirement stucture before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify third-party
  APIs.

## Purpose
Product Requirements Document (PRD) focused on the user perspective: how users will use the
feature and the benefits they gain. Clarification‑First: reflect intent, bundle questions, wait for
confirmation, and record assumptions as “unconfirmed.” For small features, this command is optional;
prefer concise requirements focused on user value.

## Command Usage
```bash
# GitHub feature PRD creation
sdlc_prd_feature --source github --name user-authentication --type backend --id 123

# Local feature PRD creation
sdlc_prd_feature --source local --name mobile-dashboard --type frontend

# Bitbucket feature PRD creation
sdlc_prd_feature --source bitbucket --name payment-gateway --type fullstack --id 456

# Simple usage (auto-detects everything)
sdlc_prd_feature --name recommendation-engine
```

**Simplified Parameters:**
 - `--name <descriptive-name>`: Feature workspace name (creates <project_root>/task_<name>/)
 - `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
 - `--type <frontend|backend|fullstack|mobile>`: Feature type (optional, auto-detected)
 - `--id <identifier>`: External ID (issue#, epic#, etc) (optional)
 - `--context <file|dir>`: Additional context file(s) or directory (optional)
 - `--prompt "<instruction>"`: Inline task prompt to focus PRD scope (optional)
 - `--complexity <small|medium|large>`: Optional; if omitted, auto-detected (recommended for medium/large)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: prd feature <name> - requirements and stakeholder analysis complete"`
- `git commit -m "sdlc: <name> - user story development complete"`
- `git commit -m "sdlc: <name> - business case documentation complete"`
- `git commit -m "sdlc: <name> - PRD creation complete"`
- **Rollback**: `git revert <commit_hash>` to safely undo changes (preserves history)
- **SECURITY**: `git reset` is strictly forbidden - always use `git revert` for traceability
- **IMPORTANT**: Agent must commit after each major step for traceability

## 🔹 PLAN

### 1. Comprehensive Requirements, Assumptions & Guardrails

- **Assumption register**: log all assumptions as `unconfirmed`, assign an owner, describe how/when to validate, and revisit at every checkpoint.
- **Guardrail draft**: capture security, privacy, data-handling, budget, and operational boundaries that downstream AI agents must obey.

**Business Stakeholder Identification:**
- **Product Owners**: Feature champions and business requirements owners
- **End Users**: Target user segments and personas
- **Technical Stakeholders**: Engineering leads, architects, platform teams
- **Cross-functional Teams**: Design, QA, DevOps, Support, Marketing
- **External Partners**: Third-party integrations, vendors, compliance teams

**Requirements Collection Methods:**
- **Stakeholder Interviews**: One-on-one sessions with key stakeholders
- **User Research**: Surveys, focus groups, user testing sessions
- **Technical Assessment**: Platform capabilities, integration requirements, constraints, and risks
- **Business Case Analysis**: ROI calculations, success metrics, risk assessment

### 2. Context storage (user-focused outputs)
Store all PRD artifacts under the single `specs/` folder within the task workspace.
```
<project_root>/task_<name>/
- specs/
  - feature-spec.md         # PRD: user requirements and value
  - user-stories.md         # Detailed user stories and acceptance criteria
  - business-case.md        # Business justification and success metrics
- context/
  - source-reference.md     # Original source context and links (optional)
```

**Note**: API contracts, acceptance tests, and observability specs are outputs of `sdlc_plan_first`, not PRD.

**IMPORTANT**: PRD artifacts must be written to `<project_root>/task_<name>/specs/`.

**Streamlined structure**
- Single source of truth: `specs/feature-spec.md` merges PRD + user requirements
- All PRD artifacts live in `specs/` for predictable location
- Standardized headers across all documents for predictable context location

**Feature specification document structure**
The `prd/feature-spec.md` file should include:
- **Problem Statement**: Unambiguous problem and goals
- **In/Out of Scope**: Clear boundaries and constraints
- **User Stories**: Primary scenarios with acceptance criteria
- **Functional Requirements**: Core features and capabilities  
- **Non-Functional Requirements**: Performance, security, scalability, usability
- **API Contracts**: Drafted endpoints with examples
- **Success Metrics**: Measurable targets and KPIs
- **Risk Assessment**: Technical and business risks with mitigation strategies
- **Agent guardrails**: Explicit constraints (files allowed, data sensitivity, forbidden actions) to hand off with the spec
- **Open Questions**: Tracked with owners and due dates

### 3. User Story Development & Prioritization

**User Story Framework:**
- **Epic Breakdown**: Large features decomposed into manageable user stories
- **Story Format**: "As a [user type], I want [functionality] so that [benefit]"
- **Acceptance Criteria**: Clear, testable conditions for story completion
- **Story Points**: Effort estimation using planning poker or similar methods
- **Priority Matrix**: MoSCoW prioritization (Must, Should, Could, Won't)

**Story Quality Standards:**
- **INVEST Criteria**: Independent, Negotiable, Valuable, Estimable, Small, Testable
- **Definition of Ready**: Stories meet quality standards before development
- **Definition of Done**: Clear completion criteria for each story
- **Dependency Mapping**: Identification of story dependencies and sequencing

### 4. Business Case & Success Metrics

**Business Justification:**
- **Problem Statement**: Clear articulation of the problem being solved
- **Market Opportunity**: Size, growth potential, competitive landscape
- **User Value Proposition**: Benefits delivered to end users
- **Business Value**: Revenue impact, cost savings, strategic alignment
- **Success Metrics**: KPIs, OKRs, and measurable outcomes

## 🔹 CREATE

### Feature Specification Development

**Core Feature Definition:**
- **Feature Overview**: High-level description and primary purpose
- **User Experience Flow**: End-to-end user journey and interactions
- **Functional Requirements**: Detailed feature capabilities and behaviors
- **Non-Functional Requirements**: Performance, security, scalability, usability
- **Integration Requirements**: APIs, third-party services, internal systems

**Technical Specification:**
- **Architecture Overview**: High-level system design and data flow
- **API Requirements**: Endpoint specifications, data models, protocols
- **Database Design**: Data schema, relationships, migration requirements
- **Security Requirements**: Authentication, authorization, data protection
- **Performance Requirements**: Response times, throughput, scalability targets

### Wireframes & User Experience Design

**UX/UI Planning:**
- **User Flow Diagrams**: Visual representation of user interactions
- **Wireframes**: Low-fidelity mockups of key interfaces
- **Prototype Requirements**: Interactive prototypes for validation
- **Design System Integration**: Consistency with existing design patterns
- **Accessibility Requirements**: WCAG compliance and inclusive design

### Risk Assessment & Mitigation

**Technical Risks:**
- **Implementation Complexity**: Architectural challenges and technical debt
- **Integration Risks**: Third-party dependencies and system compatibility
- **Performance Risks**: Scalability concerns and resource limitations
- **Security Risks**: Vulnerability assessment and compliance requirements

**Business Risks:**
- **Market Risks**: Competitive threats and market timing
- **Resource Risks**: Team capacity and skill requirements
- **Timeline Risks**: Dependencies and critical path analysis
- **Adoption Risks**: User acceptance and change management

### 5. Spec-to-plan AI orchestration handoff

- Package the updated spec artifacts and guardrails (assumptions, constraints, verification cues) for consumption by plan-first AI tooling (Claude Plan, Cursor Plan Mode, Spec-Kit).
- Record exact file paths and commands the agent must use to ingest the spec inside `specs/feature-spec.md` under a `Plan handoff` section.
- Add a `Human review gate` checklist naming the approvers who must sign off before any AI planning run.
- Document required outputs the planning agent must produce (tasks with verifiable behaviors, file touch list, risk log, validation steps) so the spec doubles as the control surface.
- Store links or references to decision logs, compliance requirements, and guardrails the planning stage must respect.

### 6. Definition of Ready (DoR) & Definition of Done (DoD)

**Definition of Ready - Before Implementation:**
- Problem and goals are unambiguous
- In/out of scope defined with clear boundaries
- Primary user stories and scenarios identified
- API/contracts drafted with examples and error shapes
- Acceptance criteria finalized and testable
- NFRs set with measurable targets and thresholds
- Test strategy explicit with coverage goals and quality metrics
- Observability plan defined with metrics, logs, traces, dashboards
- Rollout strategy planned with feature flags and backout procedures
- Backward compatibility assessed with API versioning policy
- Risks and open questions logged with owners and due dates
- Owner/DRI, timeline, and success metrics agreed
- Spec-to-agent readiness checklist completed: guardrails, assumption register, and verification hooks linked for plan-first AI tooling

**Definition of Done - After Deployment:**
- All acceptance tests pass in CI with traceability to requirements
- NFRs validated with performance, security, reliability benchmarks  
- Observability live with dashboards, alerts, and SLO tracking
- Rollout executed successfully with backout validated
- Backward compatibility maintained with migration safety
- Edge cases and failure modes addressed (timeouts, retries, idempotency)
- Runbook updated and on-call/support briefed
- Documentation complete (how-to, reference, troubleshooting)
- ADRs merged with links updated in spec/plan
- Post-launch success review scheduled

### 7. Quality Gates for CI Automation

**Automated Validation Requirements:**
- Schema validation on PR for all machine-readable specs
- API contract diff check with compatibility rules enforcement
- Acceptance tests must pass and map to F-### IDs for traceability
- Spec lint: ensure guardrails, assumption register, and agent handoff checklist sections are populated before plan-first tooling consumes the spec

## Outputs
- `task_<name>/specs/feature-spec.md` - PRD: user requirements and value
- `task_<name>/specs/user-stories.md` - Detailed user stories and acceptance criteria
- `task_<name>/specs/business-case.md` - Business justification and success metrics
- Optional: `task_<name>/context/source-reference.md` - Original source context

**Note**: API contracts, observability specs, and rollout configs are created by `sdlc_plan_first`, not this command.

## 🔹 TEST

### PRD Validation Framework

**Stakeholder Review Process:**
- **Business Validation**: Product owner and business stakeholder approval
- **Technical Feasibility Review**: Engineering team assessment
- **Design Review**: UX/UI team validation of user experience
- **Legal/Compliance Review**: Regulatory and legal requirement validation
- **Security Review**: Security team assessment of requirements

**Quality Assurance Checklist:**
- **Completeness**: All required sections and information present
- **Clarity**: Requirements are clear, unambiguous, and actionable
- **Consistency**: No contradictions or conflicts in requirements
- **Traceability**: Requirements linked to business objectives
- **Testability**: Acceptance criteria are measurable and verifiable

### User Story Validation

**Story Review Criteria:**
- **Business Value**: Each story delivers measurable user or business value
- **Technical Feasibility**: Stories can be implemented within constraints
- **Dependency Resolution**: Story dependencies identified and manageable
- **Estimation Accuracy**: Story points reflect realistic effort estimates
- **Acceptance Criteria**: Clear, testable conditions for completion

## 🔹 DEPLOY

### PRD Publication & Distribution

**Documentation Delivery:**
- **PRD Distribution**: Share completed PRD with all stakeholders
- **Stakeholder Communication**: Present PRD findings and recommendations
- **Approval Process**: Secure formal approval from decision makers
- **Version Control**: Establish PRD versioning and change management
- **Knowledge Transfer**: Ensure development team understands requirements

**Handoff to Planning Phase:**
- **Development Roadmap**: Priority-ordered implementation sequence
- **Sprint Planning Preparation**: Stories ready for sprint planning
- **Resource Allocation**: Team assignments and timeline commitments
- **Success Metrics Setup**: Establish baseline metrics and tracking
- **Communication Plan**: Ongoing stakeholder communication strategy

### PRD Maintenance & Updates

**Living Document Management:**
- **Change Request Process**: Formal process for requirement changes
- **Impact Assessment**: Evaluate changes on scope, timeline, resources
- **Stakeholder Approval**: Change approval workflow and documentation
- **Version History**: Maintain complete change history and rationale
- **Team Communication**: Communicate changes to development team

## Feature-Specific Best Practices

### User-Centered Design
- **User Personas**: Detailed user archetypes based on research
- **Journey Mapping**: Complete user experience from discovery to success
- **Pain Point Analysis**: Current user frustrations and improvement opportunities
- **Value Proposition**: Clear articulation of user benefits and outcomes

### Business Value Articulation
- **ROI Modeling**: Financial return on investment calculations
- **Success Metrics**: Quantifiable measures of feature success
- **Competitive Analysis**: Market positioning and differentiation
- **Strategic Alignment**: Connection to broader business objectives

### Technical Foundation
- **Scalability Planning**: Growth assumptions and capacity planning
- **Integration Strategy**: API design and system interoperability
- **Security Design**: Security requirements and threat modeling
- **Performance Targets**: Response time, throughput, and reliability goals

## Collaboration & Communication

### Cross-Functional Alignment
- **Regular Check-ins**: Scheduled reviews with key stakeholders
- **Feedback Integration**: Process for incorporating stakeholder input
- **Conflict Resolution**: Process for resolving requirement conflicts
- **Decision Documentation**: Record of key decisions and rationale

### Documentation Standards
- **Writing Guidelines**: Clear, concise, jargon-free documentation
- **Visual Communication**: Diagrams, wireframes, and flowcharts
- **Template Consistency**: Standardized PRD format and sections
- **Accessibility**: Documents accessible to all stakeholders

This PRD creation workflow ensures comprehensive feature specification that serves as the foundation for successful feature development, providing clarity, alignment, and direction for all subsequent development activities.

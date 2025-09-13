# SDLC PRD Feature $ARGUMENTS

## Purpose
Product Requirements Document (PRD) creation workflow for new features. This command facilitates comprehensive requirements gathering, user story development, and business case documentation to establish clear feature specifications before development begins.

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
- `--name <descriptive-name>`: Feature workspace name (creates <project_root>/<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <frontend|backend|fullstack|mobile>`: Feature type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, epic#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Inline task prompt to focus PRD scope (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: prd feature <name> - stakeholder analysis complete"`
- `git commit -m "sdlc: <name> - user story development complete"`
- `git commit -m "sdlc: <name> - business case documentation complete"`
- `git commit -m "sdlc: <name> - PRD creation complete"`
- **Rollback**: `git revert <commit_hash>` to safely undo changes (preserves history)
- **SECURITY**: `git reset` is strictly forbidden - always use `git revert` for traceability
- **IMPORTANT**: Agent must commit after each major step for traceability

## 🔹 PLAN

### 1. Stakeholder Analysis & Requirements Gathering

**Business Stakeholder Identification:**
- **Product Owners**: Feature champions and business requirements owners
- **End Users**: Target user segments and personas
- **Technical Stakeholders**: Engineering leads, architects, platform teams
- **Cross-functional Teams**: Design, QA, DevOps, Support, Marketing
- **External Partners**: Third-party integrations, vendors, compliance teams

**Requirements Collection Methods:**
- **Stakeholder Interviews**: One-on-one sessions with key stakeholders
- **User Research**: Surveys, focus groups, user testing sessions
- **Market Analysis**: Competitive analysis, industry trends, user feedback
- **Technical Assessment**: Platform capabilities, integration requirements
- **Business Case Analysis**: ROI calculations, success metrics, risk assessment

### 2. Context Storage (Feature-Focused Structure)
Store all PRD analysis and documentation in standardized directory structure:
```
<project_root>/<name>/
├── plan/
│   ├── prd.md                  # Complete Product Requirements Document
│   ├── user-stories.md         # Detailed user stories and acceptance criteria
│   └── business-case.md        # Business justification and success metrics
├── issue/
│   ├── stakeholder-analysis.md # Stakeholder mapping and requirements
│   ├── user-research.md        # User research findings and personas
│   └── market-analysis.md      # Competitive analysis and market positioning
└── context/
    ├── source-reference.md     # Original source context and links
    └── constraints.md          # Technical, business, and regulatory constraints
```

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

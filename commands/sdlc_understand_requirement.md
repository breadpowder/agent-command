# SDLC Understand Requirement $ARGUMENTS

## Purpose
Initial requirement understanding and clarification workflow that transforms raw user input into structured, validated requirements ready for PRD development. This command focuses on deep requirement analysis, stakeholder clarification, and user story refinement before formal product requirement documentation begins.

## Command Usage
```bash
# GitHub requirement understanding
sdlc_understand_requirement --source github --name user-dashboard --type feature --id 123

# Local requirement understanding
sdlc_understand_requirement --source local --name payment-system --type enhancement

# Bitbucket requirement understanding  
sdlc_understand_requirement --source bitbucket --name api-redesign --id 456

# Simple usage (auto-detects everything)
sdlc_understand_requirement --name mobile-app --prompt "Users want better search functionality"
```

**Simplified Parameters:**
- `--name <descriptive-name>`: Requirement workspace name (creates <project_root>/requirement_<name>/)
- `--source <github|local|bitbucket>`: Input source (optional, defaults to local)
- `--type <feature|enhancement|bugfix|integration>`: Requirement type (optional, auto-detected)
- `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
- `--context <file|dir>`: Additional context file(s) or directory (optional)
- `--prompt "<instruction>"`: Initial user requirement description (optional)

**Automatic Git Commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: understand requirement <name> - initial analysis complete"`
- `git commit -m "sdlc: <name> - clarification questions and gaps identified"`
- `git commit -m "sdlc: <name> - user stories drafted and validated"`
- `git commit -m "sdlc: <name> - structured requirements ready for PRD"`
- **Rollback**: `git revert <commit_hash>` to safely undo changes (preserves history)
- **SECURITY**: `git reset` is strictly forbidden - always use `git revert` for traceability
- **IMPORTANT**: Agent must commit after each major step for traceability

## 🔹 PLAN

### 1. Initial Requirement Analysis & Gap Identification

**Raw Input Processing:**
- **User Intent Extraction**: Parse initial user description to identify core intent and desired outcomes
- **Assumption Detection**: Identify unstated assumptions and implicit requirements in user input
- **Scope Boundary Discovery**: Understand what user considers in-scope vs out-of-scope
- **Context Mining**: Extract relevant business context, user personas, and use case scenarios
- **Constraint Identification**: Discover technical, business, timeline, and resource constraints

**Gap Analysis Framework:**
- **Missing Information Detection**: Identify critical gaps in user requirements
- **Ambiguity Flagging**: Highlight vague or unclear requirement statements
- **Dependency Mapping**: Identify potential dependencies not mentioned by user
- **Risk Signal Detection**: Flag potential risks based on requirement complexity
- **Stakeholder Identification**: Determine who else needs to be involved beyond the initial user

### 2. Context Storage (Requirement-Focused Structure)
Store all requirement analysis and clarification in standardized directory structure:
```
<project_root>/requirement_<name>/
├── analysis/
│   ├── initial-requirement.md      # Original user input and context captured
│   ├── gap-analysis.md            # Identified gaps, ambiguities, and missing info
│   ├── clarification-questions.md # Structured questions for user clarification
│   └── assumption-log.md          # Documented assumptions and validation needs
├── user-stories/
│   ├── draft-stories.md           # Initial user story drafts with acceptance criteria
│   ├── story-validation.md        # User feedback and story refinements
│   └── story-prioritization.md    # Story priority and dependency mapping
├── requirements/
│   ├── functional-requirements.md # Validated functional requirements
│   ├── non-functional-hints.md    # Early NFR indicators and constraints
│   └── acceptance-criteria.md     # Detailed acceptance criteria per requirement
└── handoff/
    ├── structured-requirements.md  # Final structured requirements for PRD input
    ├── open-questions.md          # Remaining questions with assigned owners
    └── next-steps.md              # Recommended next phase actions
```

**IMPORTANT**: All requirement documentation must be created under `<project_root>/requirement_<name>/` structure where `<name>` is the requirement workspace name provided via `--name` parameter.

### 3. Interactive Clarification Process

**Systematic Question Framework:**
- **What Questions**: What exactly does the user want to achieve? What are the specific outcomes?
- **Who Questions**: Who are the end users? Who are the stakeholders? Who has decision authority?
- **When Questions**: What are the timeline expectations? When is this needed? Are there deadlines?
- **Where Questions**: Where will this be used? What platforms/environments are involved?
- **Why Questions**: Why is this important? What problem does it solve? What's the business value?
- **How Questions**: How do users currently handle this? How should the new solution work?

**Progressive Clarification Strategy:**
- **Round 1**: High-level clarification of scope, goals, and constraints
- **Round 2**: Detailed user story validation and acceptance criteria refinement
- **Round 3**: Edge case identification and non-functional requirement hints
- **Round 4**: Final validation and structured requirement confirmation

### 4. User Story Development & Validation

**Story Elicitation Techniques:**
- **As-a-user Format**: Convert requirements into "As a [user type], I want [functionality] so that [benefit]" format
- **Scenario Mapping**: Identify primary, secondary, and edge case scenarios
- **User Journey Analysis**: Map end-to-end user flows and interaction points
- **Pain Point Focus**: Ensure stories address specific user pain points and frustrations
- **Value Validation**: Confirm each story delivers clear user or business value

**Story Quality Validation:**
- **Completeness Check**: Ensure stories cover all identified requirements
- **Independence Verification**: Confirm stories can be implemented independently
- **Testability Assessment**: Validate that acceptance criteria are measurable and verifiable
- **Size Estimation**: Ensure stories are appropriately sized for implementation
- **Priority Clarification**: Understand story priority from user perspective

## 🔹 CREATE

### Requirement Understanding Documentation

**Initial Analysis Capture:**
- **Original Request Documentation**: Verbatim capture of user's initial requirement description
- **Context Extraction**: Business context, user motivations, and success criteria
- **Implicit Requirement Identification**: Unstated requirements based on domain knowledge
- **Constraint Documentation**: Technical, business, regulatory, and timeline constraints
- **Success Definition**: How user will measure successful requirement fulfillment

**Gap Analysis & Question Generation:**
- **Information Gap Matrix**: Systematic identification of missing critical information
- **Clarification Question Bank**: Structured questions organized by category and priority
- **Assumption Documentation**: Explicit documentation of assumptions requiring validation
- **Risk Flag Documentation**: Early identification of potential requirement risks
- **Stakeholder Gap Analysis**: Identification of missing stakeholder perspectives

### Interactive Clarification Sessions

**Question Prioritization:**
- **Critical Path Questions**: Questions blocking any forward progress
- **Scope Definition Questions**: Questions clarifying boundaries and limitations
- **Quality Attribute Questions**: Questions related to performance, security, usability
- **Implementation Preference Questions**: Questions about user preferences and constraints
- **Future Consideration Questions**: Questions about extensibility and future needs

**User Feedback Integration:**
- **Response Analysis**: Systematic analysis of user responses for additional insights
- **Follow-up Question Generation**: Dynamic question generation based on user responses
- **Requirement Refinement**: Iterative refinement of requirements based on clarifications
- **Validation Loop**: Confirmation that understanding matches user intent
- **Documentation Updates**: Real-time updates to requirement documentation

### User Story Structuring

**Story Development Process:**
- **Epic Decomposition**: Break large requirements into manageable story groups
- **Story Drafting**: Create initial user stories with basic acceptance criteria
- **Story Validation**: Review stories with user for accuracy and completeness
- **Acceptance Criteria Detailing**: Develop detailed, testable acceptance criteria
- **Story Prioritization**: Work with user to prioritize stories by value and urgency

**Story Quality Assurance:**
- **INVEST Validation**: Ensure stories meet Independent, Negotiable, Valuable, Estimable, Small, Testable criteria
- **Dependency Mapping**: Identify and document dependencies between stories
- **Edge Case Coverage**: Ensure edge cases and error scenarios are covered
- **User Value Verification**: Confirm each story delivers measurable user value
- **Implementation Readiness**: Ensure stories contain sufficient detail for planning

## 🔹 TEST

### Requirement Validation Framework

**Completeness Validation:**
- **Requirement Coverage**: All user needs addressed by documented requirements
- **Story Coverage**: All requirements covered by user stories with acceptance criteria
- **Stakeholder Coverage**: All relevant stakeholders identified and consulted
- **Constraint Coverage**: All known constraints documented and considered
- **Success Criteria Coverage**: All success measures clearly defined and measurable

**Quality Assurance Checklist:**
- **Clarity Assessment**: Requirements are clear, unambiguous, and actionable
- **Consistency Check**: No contradictions or conflicts in requirements
- **Feasibility Review**: Requirements appear technically and business feasible
- **Traceability Validation**: Requirements traceable to original user intent
- **Testability Confirmation**: All requirements have verifiable acceptance criteria

### User Story Validation

**Story Review Process:**
- **User Acceptance**: User confirms stories accurately reflect their needs
- **Business Value Validation**: Each story delivers clear, measurable value
- **Technical Feasibility**: Stories appear implementable within known constraints
- **Estimation Readiness**: Stories contain sufficient detail for effort estimation
- **Priority Validation**: Story priorities align with user and business needs

**Acceptance Criteria Validation:**
- **Measurability**: All criteria can be objectively measured and verified
- **Completeness**: Criteria cover positive flows, negative flows, and edge cases
- **Clarity**: Criteria are unambiguous and actionable for implementation
- **User Focus**: Criteria focus on user outcomes rather than technical implementation
- **Testability**: Criteria can be translated into automated and manual tests

## 🔹 DEPLOY

### Requirement Handoff & Documentation

**Structured Requirement Delivery:**
- **Requirement Summary**: Executive summary of validated requirements and scope
- **User Story Portfolio**: Complete set of validated user stories with acceptance criteria
- **Constraint Documentation**: Comprehensive constraint and assumption documentation
- **Question Log**: Documented questions, answers, and remaining open items
- **Success Metrics**: Clear definition of requirement fulfillment success measures

**PRD Preparation:**
- **Requirement Packaging**: Structure requirements for easy PRD consumption
- **Background Context**: Provide necessary context for PRD development
- **User Research Summary**: Summarize user insights and validation outcomes
- **Priority Framework**: Provide clear guidance on feature and story priorities
- **Success Criteria**: Establish measurable success criteria for PRD development

### Knowledge Transfer & Handoff

**Documentation Handoff:**
- **Complete Requirement Package**: All analysis, questions, answers, and stories
- **Context Transfer**: Transfer domain knowledge and user insights to PRD team
- **Open Question Management**: Clear ownership and timelines for remaining questions
- **Assumption Validation**: Plan for validating documented assumptions during PRD
- **Success Criteria Alignment**: Ensure PRD team understands requirement success measures

**Workflow Integration:**
- **PRD Input Preparation**: Ensure requirements are structured for PRD consumption
- **Stakeholder Alignment**: Confirm all stakeholders are aligned on requirements
- **Next Phase Readiness**: Validate readiness for PRD development phase
- **Quality Gate Completion**: Confirm all requirement understanding quality gates are met
- **Change Management**: Establish process for handling requirement changes during PRD

## Requirement-Specific Best Practices

### User-Centered Requirement Analysis
- **User Persona Development**: Early identification of user types and characteristics
- **Use Case Scenario Mapping**: Comprehensive scenario identification and validation
- **User Pain Point Focus**: Ensure requirements address real user problems
- **User Journey Consideration**: Understanding requirements within broader user workflows
- **User Feedback Integration**: Systematic incorporation of user clarifications and insights

### Business Context Integration
- **Business Value Articulation**: Clear connection between requirements and business outcomes
- **Strategic Alignment**: Ensure requirements align with broader business strategy
- **Competitive Consideration**: Understand requirements in competitive context
- **ROI Awareness**: Early consideration of return on investment for requirements
- **Risk Assessment**: Identify business risks associated with requirements

### Technical Feasibility Awareness
- **Constraint Recognition**: Early identification of technical constraints and limitations
- **Integration Consideration**: Understanding requirements within existing system context
- **Scalability Awareness**: Consider scalability implications of requirements
- **Security Mindset**: Early identification of security considerations and requirements
- **Performance Consideration**: Understanding performance implications and constraints

## Collaboration & Communication

### Stakeholder Engagement
- **User Communication**: Clear, non-technical communication with requirement stakeholders
- **Question Facilitation**: Effective techniques for eliciting requirement clarifications
- **Feedback Integration**: Systematic process for incorporating stakeholder feedback
- **Conflict Resolution**: Process for resolving conflicting requirement interpretations
- **Consensus Building**: Techniques for building stakeholder consensus on requirements

### Documentation Standards
- **Clarity Standards**: Clear, jargon-free requirement documentation
- **Structured Format**: Consistent documentation format and organization
- **Traceability Maintenance**: Clear links between user input and refined requirements
- **Version Control**: Proper versioning of requirement iterations and changes
- **Accessibility**: Ensure documentation is accessible to all stakeholders

This requirement understanding workflow ensures comprehensive requirement clarification and structuring that serves as high-quality input for PRD development, providing clarity, user validation, and structured foundation for all subsequent development activities.
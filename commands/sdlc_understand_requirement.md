# SDLC understand requirement $ARGUMENTS

## Context first
- Gather relevant context from the workspace structure (README.md, AGENTS.md, commands/, existing
  task_*/ workspaces) before planning or executing any task.
- Context7 references are optional; use them only when you need to refer to or verify third-party
  APIs.

## Purpose
Initial requirement understanding and clarification workflow that transforms raw user input into a concise, validated starting point. Clarification-First: reflect user intent, bundle clarifying questions, wait for confirmation, and record assumptions as "unconfirmed". Keep focus on solving the problem with backward compatibility in mind.

**IMPORTANT**: This phase focuses on WHAT the user needs, NOT HOW to build it. No implementation details or technical discussions.

---

## MANDATORY GATE PROTOCOL

**CRITICAL**: You MUST pause and present a gate for user review BEFORE writing any files.

### Gate Rules
1. **NO FILE WRITES** until user approves the gate output
2. Present your understanding in the gate format below
3. Wait for explicit "continue" or feedback before proceeding
4. If user requests changes, update your understanding and present the gate again

### Gate Trigger
After completing initial analysis and drafting clarifying questions, you MUST present the gate output for review.

### Gate Output Format
```
═══════════════════════════════════════════════════════════════
🚧 GATE: REQUIREMENTS UNDERSTANDING
═══════════════════════════════════════════════════════════════

### My Understanding
[Problem statement - one paragraph summary]

### High-Level Functional Requirements
- [Capability 1: what the system should do]
- [Capability 2: what the system should do]
- [Capability 3: what the system should do]
(3-7 items, NO implementation details)

### High-Level Non-Functional Requirements
- Performance: [user expectations, NOT technical specs]
- Security: [user expectations, NOT solutions]
- Scalability: [growth expectations]
- Usability: [accessibility, platform needs]
(Categories only, NO technical solutions)

### Primary Use Case
[One paragraph describing the main user scenario]
- [Key interaction 1]
- [Key interaction 2]
- [Key interaction 3]
(Maximum 3 bullet points)

### Constraints
- Timeline: [deadlines, milestones]
- Budget/Resources: [limitations]
- Platform: [where it must work]
- Regulatory: [compliance needs]

### Assumptions (UNCONFIRMED)
- [Assumption 1] - NEEDS CONFIRMATION
- [Assumption 2] - NEEDS CONFIRMATION

### Clarifying Questions
1. [Question about scope/goals]?
2. [Question about users/stakeholders]?
3. [Question about constraints]?

⏸️  WAITING FOR YOUR REVIEW
   Reply "continue" to proceed to file creation, or provide feedback.
═══════════════════════════════════════════════════════════════
```

---

## Explicitly Prohibited at This Stage

The following MUST NOT appear in requirement analysis:

| Prohibited | Reason |
|------------|--------|
| Implementation details | Focus on WHAT, not HOW |
| Code or pseudo-code | Save for planning phase |
| Technology choices | No "use React", "use PostgreSQL" |
| Architecture decisions | No system diagrams or component designs |
| Database schemas | Not a requirement concern |
| API designs | Save for planning phase |
| Performance optimization techniques | State requirements, not solutions |
| Testing strategies | Save for planning phase |

**Purpose**: Keep focus purely on understanding user needs and business value.

---

## Command usage
```bash
# GitHub requirement understanding
sdlc_understand_requirement --source github --name user-dashboard --type feature --id 123

# Local requirement understanding
sdlc_understand_requirement --source local --name payment-system --type enhancement

# Bitbucket requirement understanding  
sdlc_understand_requirement --source bitbucket --name api-redesign --id 456

# Simple usage (auto-detects everything)
sdlc_understand_requirement --name mobile-app --prompt "Users want better search functionality"

# File-based context (brief/spec file)
sdlc_understand_requirement --source file --name reporting --type feature --context docs/brief.md
```

**Simplified parameters:**
 - `--name <descriptive-name>`: Requirement workspace name (creates <project_root>/task_<name>/)
 - `--source <github|local|bitbucket|file>`: Input source (optional, defaults to local)
 - `--type <feature|enhancement|bugfix|integration>`: Requirement type (optional, auto-detected)
 - `--id <identifier>`: External ID (issue#, ticket#, etc) (optional)
 - `--context <file|dir>`: Additional context file(s) or directory (optional)
 - `--prompt "<instruction>"`: Initial user requirement description (optional)
 - `--complexity <small|medium|large>`: Optional; if omitted, auto-detected

Safety and scope:
- Non-destructive: writes documentation only under `task_<name>/`.
- No code changes, builds, or deployments in this phase.
- Prefer follow-up questions over assumptions; clearly tag assumptions.

**Automatic git commits:**
This command creates commits at key checkpoints for traceability:
- `git commit -m "sdlc: understand requirement <name> - initial analysis complete"`
- `git commit -m "sdlc: <name> - clarification questions and gaps identified"`
- `git commit -m "sdlc: <name> - user stories drafted and validated"`
- `git commit -m "sdlc: <name> - structured requirements ready for PRD"`
- **Rollback**: `git revert <commit_hash>` to safely undo changes (preserves history)
- **SECURITY**: `git reset` is strictly forbidden - always use `git revert` for traceability
- **IMPORTANT**: Agent must commit after each major step for traceability

### Outputs
- `task_<name>/requirement/analysis/requirement_analysis.md`
- Optional: `task_<name>/requirement/user-stories/stories.md`
- Optional (medium/large): `task_<name>/requirement/requirements/requirements.md`

## 🔹 Plan

### 0. Focus Areas (MUST Capture These)

Your requirement analysis MUST produce these four deliverables for the gate:

#### A. High-Level Functional Requirements
What the system should DO (capabilities, not implementation):
- Core capabilities users need (3-7 items)
- Main workflows that must be supported
- Key features from user perspective
- **Format**: "The system should [verb] [what]" - NO technical details

#### B. High-Level Non-Functional Requirements
Quality attributes and expectations (NOT technical solutions):
- **Performance**: Response time expectations, throughput needs
- **Security**: Authentication needs, data protection requirements
- **Scalability**: Expected user volume, growth trajectory
- **Reliability**: Uptime expectations, availability needs
- **Usability**: Accessibility requirements, platform support
- **Format**: Category + user expectation - NO specific technologies

#### C. High-Level Use Case
Primary user scenario in business terms:
- One paragraph describing the main user journey
- Maximum 3 bullet points for key interactions
- **Format**: "As a [user], I want to [goal] so that [benefit]"
- Focus on user value, NOT system behavior

#### D. Constraints
Hard boundaries that limit the solution space:
- Timeline constraints (deadlines, milestones)
- Budget/resource constraints
- Platform constraints (must work on X)
- Regulatory/compliance constraints
- Integration constraints (must work with Y)
- **Format**: Category + specific limitation

---

### 1. Initial requirement analysis and gap identification

Non-assumption principle:
- Reflect back user intent in your own words before proceeding.
- Ask clarifying questions when uncertain instead of presuming details.
- Track every assumption in an assumption log and mark it “unconfirmed” until validated.
- Separate facts (from user/context) from interpretations and hypotheses.

Raw input processing:
- User intent extraction: Parse initial user description to identify core intent and desired outcomes
- Assumption detection: Identify unstated assumptions and implicit requirements in user input
- Scope boundary discovery: Understand what user considers in-scope vs out-of-scope
- Context mining: Extract relevant business context, user personas, and use case scenarios
- Constraint identification: Discover technical, business, timeline, and resource constraints

Gap analysis framework:
- Missing information detection: Identify critical gaps in user requirements
- Ambiguity flagging: Highlight vague or unclear requirement statements
- **Dependency Mapping**: Identify potential dependencies not mentioned by user
- **Risk Signal Detection**: Flag potential risks based on requirement complexity
- **Stakeholder Identification**: Determine who else needs to be involved beyond the initial user

### 2. Context storage (requirement-focused structure)
Store all requirement analysis and clarification in standardized directory structure (one file per leaf):
```
<project_root>/task_<name>/
├── requirement/
│   ├── analysis/requirement_analysis.md   # input, assumptions (unconfirmed), clarifying questions, summary
│   ├── user-stories/stories.md            # optional for features
│   └── requirements/requirements.md       # optional (medium/large)
└── requirement/handoff/handoff_requirements.md   # optional
```

Important: create all requirement documentation under `<project_root>/task_<name>/` where `<name>` is provided via `--name`.

### 3. Interactive clarification process

Systematic question framework:
- What questions: What exactly does the user want to achieve? What are the specific outcomes?
- Who questions: Who are the end users? Who are the stakeholders? Who has decision authority?
- When questions: What are the timeline expectations? When is this needed? Are there deadlines?
- Where questions: Where will this be used? What platforms/environments are involved?
- Why questions: Why is this important? What problem does it solve? What is the business value?
- How questions: How do users currently handle this? How should the new solution work?

Reflective summary template (add to `analysis/reflection.md`):
- Problem statement (in your words): <one paragraph>
- Known facts (from user/context): <bulleted list>
- Unknowns and open questions: <bulleted list>
- Explicit assumptions (to confirm): <bulleted list>
- Risks and constraints observed: <bulleted list>
- Proposed scope boundaries: <in/out of scope bullets>

Clarifying question template (add to `analysis/clarification-questions.md`):
- Goal/outcome: <question>
- User segments/personas: <question>
- Success criteria/metrics: <question>
- Constraints (time, budget, tech): <question>
- Dependencies/integrations: <question>
- Edge cases/failure modes: <question>
- Non-functional expectations (perf, security, accessibility, compliance): <question>

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

### Interactive clarification sessions

Question prioritization:
- Critical path questions: Questions blocking any forward progress
- Scope definition questions: Questions clarifying boundaries and limitations
- Quality attribute questions: Questions related to performance, security, usability
- Implementation preference questions: Questions about user preferences and constraints
- Future consideration questions: Questions about extensibility and future needs

User feedback integration:
- Response analysis: Systematic analysis of user responses for additional insights
- Follow-up question generation: Dynamic question generation based on user responses
- Requirement refinement: Iterative refinement of requirements based on clarifications
- Validation loop: Confirmation that understanding matches user intent
- Documentation updates: Real-time updates to requirement documentation

### User story structuring

Story development process:
- Epic decomposition: Break large requirements into manageable story groups
- Story drafting: Create initial user stories with basic acceptance criteria
- Story validation: Review stories with user for accuracy and completeness
- Acceptance criteria detailing: Develop detailed, testable acceptance criteria
- Story prioritization: Work with user to prioritize stories by value and urgency

Story quality assurance:
- INVEST validation: Ensure stories meet Independent, Negotiable, Valuable, Estimable, Small, Testable criteria
- Dependency mapping: Identify and document dependencies between stories
- Edge case coverage: Ensure edge cases and error scenarios are covered
- User value verification: Confirm each story delivers measurable user value
- Implementation readiness: Ensure stories contain sufficient detail for planning

Interactive prompt starters (agent → user):
- "Here’s my current understanding of your requirement. What did I miss?"
- "Which of these outcomes matters most in the next 2–4 weeks?"
- "Are these out-of-scope for now? <list>"
- "Can you share constraints or hard deadlines I should plan around?"
- "How will we measure success once delivered?"

## 🔹 Test

### Requirement validation framework

Completeness validation:
- Requirement coverage: All user needs addressed by documented requirements
- Story coverage: All requirements covered by user stories with acceptance criteria
- Stakeholder coverage: All relevant stakeholders identified and consulted
- Constraint coverage: All known constraints documented and considered
- Success criteria coverage: All success measures clearly defined and measurable

Quality assurance checklist:
- Clarity assessment: Requirements are clear, unambiguous, and actionable
- Consistency check: No contradictions or conflicts in requirements
- Feasibility review: Requirements appear technically and business feasible
- Traceability validation: Requirements traceable to original user intent
- Testability confirmation: All requirements have verifiable acceptance criteria

### User story validation

Story review process:
- User acceptance: User confirms stories accurately reflect their needs
- Business value validation: Each story delivers clear, measurable value
- Technical feasibility: Stories appear implementable within known constraints
- Estimation readiness: Stories contain sufficient detail for effort estimation
- Priority validation: Story priorities align with user and business needs

Acceptance criteria validation:
- Measurability: All criteria can be objectively measured and verified
- Completeness: Criteria cover positive flows, negative flows, and edge cases
- Clarity: Criteria are unambiguous and actionable for implementation
- User focus: Criteria focus on user outcomes rather than technical implementation
- Testability: Criteria can be translated into automated and manual tests

## 🔹 Deploy

### Requirement handoff and documentation

Structured requirement delivery:
- Requirement summary: Executive summary of validated requirements and scope
- User story portfolio: Complete set of validated user stories with acceptance criteria
- Constraint documentation: Comprehensive constraint and assumption documentation
- Question log: Documented questions, answers, and remaining open items
- Success metrics: Clear definition of requirement fulfillment success measures

PRD preparation:
- Requirement packaging: Structure requirements for easy PRD consumption
- Background context: Provide necessary context for PRD development
- User research summary: Summarize user insights and validation outcomes
- Priority framework: Provide clear guidance on feature and story priorities
- Success criteria: Establish measurable success criteria for PRD development

### Knowledge transfer and handoff

Documentation handoff:
- Complete requirement package: All analysis, questions, answers, and stories
- Context transfer: Transfer domain knowledge and user insights to PRD team
- Open question management: Clear ownership and timelines for remaining questions
- Assumption validation: Plan for validating documented assumptions during PRD
- Success criteria alignment: Ensure PRD team understands requirement success measures

Workflow integration:
- PRD input preparation: Ensure requirements are structured for PRD consumption
- Stakeholder alignment: Confirm all stakeholders are aligned on requirements
- Next phase readiness: Validate readiness for PRD development phase
- Quality gate completion: Confirm all requirement understanding quality gates are met
- Change management: Establish process for handling requirement changes during PRD

## Requirement-specific best practices

### User-centered requirement analysis
- **User Persona Development**: Early identification of user types and characteristics
- **Use Case Scenario Mapping**: Comprehensive scenario identification and validation
- **User Pain Point Focus**: Ensure requirements address real user problems
- **User Journey Consideration**: Understanding requirements within broader user workflows
- **User Feedback Integration**: Systematic incorporation of user clarifications and insights

### Business context integration
- **Business Value Articulation**: Clear connection between requirements and business outcomes
- **Strategic Alignment**: Ensure requirements align with broader business strategy
- **Competitive Consideration**: Understand requirements in competitive context
- **ROI Awareness**: Early consideration of return on investment for requirements
- **Risk Assessment**: Identify business risks associated with requirements

### Technical feasibility awareness (Constraints Only - NO Solutions)
- **Constraint Recognition**: Identify constraints that limit solution options (NOT propose solutions)
- **Integration Consideration**: Note what systems must integrate (NOT how to integrate)
- **Scalability Awareness**: Capture growth expectations (NOT scaling strategies)
- **Security Mindset**: Document security requirements (NOT security implementations)
- **Performance Consideration**: Record performance expectations (NOT optimization techniques)

**REMINDER**: This section captures CONSTRAINTS as requirements, NOT technical approaches.

## Collaboration and communication

### Stakeholder engagement
- **User Communication**: Clear, non-technical communication with requirement stakeholders
- **Question Facilitation**: Effective techniques for eliciting requirement clarifications
- **Feedback Integration**: Systematic process for incorporating stakeholder feedback
- **Conflict Resolution**: Process for resolving conflicting requirement interpretations
- **Consensus Building**: Techniques for building stakeholder consensus on requirements

### Documentation standards

## Success criteria

### Gate Completion Criteria
- [ ] Gate presented to user BEFORE any file writes
- [ ] User explicitly approved with "continue" or provided feedback
- [ ] All four focus areas captured (functional, non-functional, use case, constraints)
- [ ] NO implementation details or technical solutions in outputs

### Quality Criteria
- Understanding is reflected back and confirmed by the user
- All assumptions are explicitly logged and either confirmed or remain flagged
- Requirements are unambiguous, testable, and traceable to original intent
- High-level use case is clear (one paragraph + max 3 bullets)
- Open questions and constraints are documented

### Documentation Standards
- **Clarity**: Clear, jargon-free, business-focused language
- **No Tech Speak**: No code, no architecture, no technology choices
- **Structured Format**: Consistent format following the gate template
- **Traceability**: Clear links between user input and refined requirements

This requirement understanding workflow ensures comprehensive requirement clarification that serves as high-quality input for PRD development. It focuses purely on WHAT users need, leaving HOW to build it for subsequent phases.

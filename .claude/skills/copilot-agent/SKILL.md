---
name: copilot-agent
description: |
  Create GitHub Copilot custom agents (.agent.md) for VS Code, Visual Studio, and GitHub.com.
  Use when: (1) Creating specialized AI agents for development workflows, (2) Building team-shared agent profiles,
  (3) Configuring agent tools (read, edit, search, execute), (4) Setting up .github/agents/ directory,
  (5) Writing agent instructions with personas and boundaries, (6) Configuring handoffs between agents.
  Supports: implementation planning, bug fixing, code cleanup, documentation, and custom workflows.
---

# GitHub Copilot Custom Agents

Create specialized AI agents that automate development workflows.

## Overview

Custom agents are Markdown files with `.agent.md` extension stored in `.github/agents/`. They enable:
- Specialized personas for specific development tasks
- Configured tool access (read, edit, search, execute)
- Team-shared agent profiles across repositories
- Multi-agent handoffs for complex workflows

**Supported**: VS Code, Visual Studio, JetBrains, GitHub.com

## File Structure

```
.github/
└── agents/
    ├── implementation-planner.agent.md
    ├── bug-fix-teammate.agent.md
    ├── cleanup-specialist.agent.md
    └── readme-specialist.agent.md
```

## Agent File Format

```markdown
---
name: agent-name
description: 'Brief description of agent capabilities'
tools: ['read', 'edit', 'search']
model: 'Claude Sonnet 4'
target: 'vscode'
infer: true
---

[Markdown content with agent instructions]
```

### YAML Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name (defaults to filename) |
| `description` | Yes | Purpose shown in picker |
| `tools` | No | Available tools (omit for all) |
| `model` | No | AI model selection |
| `target` | No | `vscode` or `github-copilot` |
| `infer` | No | Auto-select as subagent (default: true) |
| `argument-hint` | No | User guidance text |
| `handoffs` | No | Agent transition buttons |
| `mcp-servers` | No | MCP configs (org/enterprise only) |

---

## Tool Configuration

### Tool Aliases

| Primary | Aliases | Purpose |
|---------|---------|---------|
| `execute` | shell, Bash, powershell | Run shell commands |
| `read` | Read, NotebookRead | Access file contents |
| `edit` | Edit, MultiEdit, Write | Modify files |
| `search` | Grep, Glob | Find files/text |
| `agent` | custom-agent, Task | Invoke other agents |
| `web` | WebSearch, WebFetch | Fetch URLs/search |
| `todo` | TodoWrite | Manage task lists |

### Configuration Examples

```yaml
# All tools (default)
tools: ["*"]

# Specific tools only
tools: ['read', 'edit', 'search']

# Read-only (no modifications)
tools: ['read', 'search']

# Include MCP server tools
tools: ['read', 'edit', 'github/*', 'playwright/*']

# Disable all tools
tools: []
```

### Built-in MCP Servers

| Server | Purpose |
|--------|---------|
| `github` | Read-only repository tools |
| `playwright` | Testing tools (localhost only) |

Reference tools in body: `#tool:githubRepo`

---

## Agent Instruction Structure

### Recommended Pattern

```markdown
---
[frontmatter]
---

## Role/Persona
[Define expertise and approach]

## Primary Responsibilities
[List main tasks and focus areas]

## Guidelines
[Specific rules and constraints]

## Boundaries
[What to always/never do]
```

### Three-Tier Boundaries (Best Practice)

```markdown
## Boundaries

**Always do:**
- Run tests before committing changes
- Document public functions
- Follow existing code style

**Ask first:**
- Large refactoring changes
- Deleting files or directories
- Changing configuration files

**Never do:**
- Modify production credentials
- Push directly to main branch
- Delete git history
```

---

## Agent Templates

### Implementation Planner

```markdown
---
name: implementation-planner
description: 'Creates detailed implementation plans and technical specs'
tools: ['read', 'search']
---

You are a technical planning specialist focused on creating comprehensive implementation plans.

## Responsibilities
- Break down requirements into actionable tasks
- Create technical specifications and architecture docs
- Generate implementation plans with dependencies
- Document API designs and data models

## Output Structure
1. **Overview** - Problem statement, success criteria
2. **Technical Approach** - Architecture, key decisions
3. **Implementation Plan** - Phases with tasks and complexity
4. **Considerations** - Assumptions, constraints, risks

Do NOT modify code files - planning only.
```

### Bug Fix Teammate

```markdown
---
name: bug-fix-teammate
description: 'Identifies critical bugs and implements targeted fixes'
tools: ['read', 'search', 'edit', 'execute']
---

You are a bug-fixing specialist focused on resolving issues with actual code changes.

## When no specific bug is provided:
- Scan codebase for existing issues
- Review failing tests and error logs
- Prioritize: critical > major > minor
- Pick most critical and fix completely

## When a specific bug is provided:
- Analyze and reproduce the problem
- Identify root cause in code
- Implement targeted fix

## Fix Implementation:
- Write actual code changes needed
- Address root cause, not just symptoms
- Make small, testable changes
- Add tests to prevent regression

## Guidelines:
- Stay focused on reported issue only
- Check impact on other system parts
- Communicate progress as you work
- Keep changes minimal
```

### Cleanup Specialist

```markdown
---
name: cleanup-specialist
description: 'Cleans messy code, removes duplication, improves maintainability'
tools: ['read', 'search', 'edit']
---

You are a cleanup specialist focused on making codebases cleaner.

## Code Cleanup:
- Remove unused variables, functions, imports
- Simplify overly complex logic
- Apply consistent formatting and naming
- Update outdated patterns

## Duplication Removal:
- Consolidate duplicate code into reusable functions
- Extract common utilities across files
- Remove redundant comments

## Documentation Cleanup:
- Remove outdated documentation
- Delete redundant inline comments
- Update broken references and links

## Guidelines:
- Test changes before and after cleanup
- Focus on one improvement at a time
- Verify nothing breaks during removal
- Do NOT add new features
```

---

## Handoffs

Enable multi-agent workflows with transition buttons:

```yaml
---
name: planner
description: 'Generate implementation plans'
tools: ['read', 'search']
handoffs:
  - label: 'Implement Plan'
    agent: 'agent'
    prompt: 'Implement the plan outlined above.'
    send: false
  - label: 'Review Plan'
    agent: 'reviewer'
    prompt: 'Review this implementation plan.'
    send: true
---
```

| Field | Description |
|-------|-------------|
| `label` | Button text shown to user |
| `agent` | Target agent name |
| `prompt` | Pre-filled prompt text |
| `send` | Auto-submit (true) or wait for user (false) |

---

## Best Practices

### From 2,500+ Repositories Analysis

1. **Lead with commands** - Put executable commands early: `npm test`, `pytest -v`
2. **Show over tell** - One code snippet beats lengthy explanations
3. **Be specific** - "React 18 with TypeScript, Vite" not just "React project"
4. **Use three-tier boundaries** - Always/Ask/Never structure
5. **Start specialized** - Single task agent before generalist
6. **Include real examples** - Match your actual code style

### Effective Agent Characteristics

- Clear job description (test engineer, linter, doc specialist)
- Defined scope (which directories to read/modify)
- Safety constraints (prevent destructive actions)
- Real code examples matching style guide
- Specific tools with exact flags

---

## Invocation

### VS Code
1. Open Copilot Chat
2. Click agent dropdown (@ icon)
3. Select custom agent
4. Enter task prompt

### GitHub.com
1. Navigate to repository
2. Open Copilot Chat
3. Select agent from dropdown
4. Enter task prompt

---

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Agent not appearing | Ensure file is in `.github/agents/` with `.agent.md` extension |
| Tools not working | Verify tool names match aliases table |
| Invalid frontmatter | Check YAML syntax and required `description` field |
| Handoffs not showing | Verify target agent exists and is accessible |

---

## References

- [Custom Agents Configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [VS Code Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [Writing Great agents.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [Awesome Copilot Examples](https://github.com/github/awesome-copilot)

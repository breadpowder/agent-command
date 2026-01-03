---
name: copilot-prompt
description: |
  Create GitHub Copilot prompt files (.prompt.md) for VS Code, Visual Studio, and JetBrains IDEs.
  Use when: (1) Creating reusable prompt templates for Copilot Chat, (2) Building team-shared prompt files,
  (3) Automating common development tasks via slash commands, (4) Setting up .github/prompts/ directory,
  (5) Configuring prompt file YAML frontmatter (agent, tools, model), (6) Writing prompts with input variables.
  Supports: code review, README generation, API documentation, unit test generation, and custom workflows.
---

# GitHub Copilot Prompt Files

Create reusable prompt templates that trigger via slash commands in Copilot Chat.

## Overview

Prompt files are Markdown files with `.prompt.md` extension stored in `.github/prompts/`. They enable:
- Reusable prompts invoked via `/promptname` in Copilot Chat
- Team-shared development workflows
- Customized tool and model configuration
- Dynamic input variables for flexible prompts

**Supported IDEs**: VS Code, Visual Studio, JetBrains (public preview)

## File Structure

```
.github/
└── prompts/
    ├── review-code.prompt.md
    ├── create-readme.prompt.md
    ├── generate-tests.prompt.md
    └── document-api.prompt.md
```

## Prompt File Format

```markdown
---
name: prompt-name
description: 'Short description shown in picker'
agent: 'agent'
model: 'gpt-4o'
tools: ['codebase', 'editor']
argument-hint: 'Describe expected arguments'
---

[Markdown content with prompt instructions]
```

### YAML Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Slash command name (defaults to filename) |
| `description` | Yes | Shown when selecting prompt in picker |
| `agent` | No | Mode: `ask`, `edit`, `agent`, or custom agent |
| `model` | No | LLM selection (uses default if omitted) |
| `tools` | No | List of available tools for this prompt |
| `argument-hint` | No | Hint text in chat input field |

### Agent Modes

| Mode | Behavior |
|------|----------|
| `ask` | Read-only analysis, no file modifications |
| `edit` | Can modify files in workspace |
| `agent` | Full agent capabilities with tool access |

### Tool Configuration

```yaml
# Code-focused (no external access)
tools: ['codebase', 'editor', 'filesystem']

# Research-enabled
tools: ['codebase', 'fetch', 'web_search']

# All available tools (default)
tools: []
```

**Tool priority**: Prompt tools > Agent tools > Default tools

---

## Input Variables

Use variables to make prompts dynamic:

### User Input Variables

```markdown
${input:variableName}
${input:variableName:Placeholder text}
```

**Example**:
```markdown
Focus on: ${input:focus:Any specific areas to emphasize?}
Framework: ${input:framework:jest/vitest/mocha/pytest}
```

### Context Variables

| Variable | Description |
|----------|-------------|
| `${workspaceFolder}` | Full workspace path |
| `${file}` | Current file path |
| `${fileBasename}` | Current filename |
| `${selection}` | Selected text |
| `${selectedText}` | Selected text (alias) |

### Tool References in Body

Reference tools inline: `#tool:<tool-name>`

---

## Prompt Writing Guidelines

### Structure Pattern

```markdown
---
[frontmatter]
---

## Role
[Define the persona/expertise]

## Task
[Clear objective and steps]

## Guidelines
[Specific requirements and constraints]

## Output Format
[Expected response structure]
```

### Best Practices

1. **Clear role definition** - Establish expertise context
2. **Structured output** - Define expected format (bullets, sections, code)
3. **Actionable items** - Use categories like Critical/Suggestions/Good
4. **Specific line references** - Request code location citations
5. **Realistic examples** - Include sample values, not placeholders

---

## Common Prompt Templates

### Code Review

```markdown
---
mode: 'agent'
description: 'Perform comprehensive code review'
---

## Role
Senior software engineer conducting thorough code review.

## Review Areas
1. **Security** - Input validation, auth, injection risks
2. **Performance** - Algorithm complexity, memory, queries
3. **Code Quality** - Readability, naming, duplication
4. **Architecture** - Design patterns, separation of concerns
5. **Testing** - Coverage, documentation

## Output Format
- **Critical** - Must fix before merge
- **Suggestions** - Improvements to consider
- **Good Practices** - What's done well

Focus: ${input:focus:Specific areas to emphasize?}
```

### README Generator

```markdown
---
mode: 'agent'
description: 'Create comprehensive README.md'
---

## Role
Senior engineer creating appealing, informative README files.

## Required Sections
1. **Project description** - What it does, why useful
2. **Installation** - Setup instructions
3. **Usage** - Code examples
4. **Contributing** - How to contribute
5. **License** - License information

## Guidelines
- Use GitHub Flavored Markdown
- Use relative links for internal files
- Keep under 500 KiB
- Include code examples
```

### Unit Test Generator

```markdown
---
mode: 'agent'
description: 'Generate unit tests for selected code'
---

## Task
Create focused unit tests validating behavior.

## Test Categories
1. **Core Functionality** - Main purpose, return values
2. **Input Validation** - Invalid types, null, boundaries
3. **Error Handling** - Expected exceptions, edge cases
4. **Side Effects** - External calls, state changes

## Requirements
- Use ${input:framework:jest/vitest/pytest/rspec} framework
- Follow AAA pattern (Arrange, Act, Assert)
- Generate 5-8 focused test cases
- Use realistic test data

Target: ${input:function:Function or method to test?}
```

### API Documentation

```markdown
---
mode: 'agent'
description: 'Generate OpenAPI 3.0 specification'
---

## Task
Generate valid OpenAPI 3.0.3 YAML specification.

## Include
1. **OpenAPI header** - Version, info, servers
2. **Paths** - Methods, parameters, responses
3. **Schemas** - Request/response models
4. **Security** - Auth schemes
5. **Examples** - Realistic values

## Requirements
- Valid OpenAPI 3.0.3 YAML
- Proper JSON Schema for models
- Include error responses (400, 401, 404, 500)
- Reusable components

Endpoint: ${input:endpoint:Which endpoint to document?}
```

---

## Invocation

1. Open Copilot Chat in IDE
2. Type `/` followed by prompt name
3. Optionally provide arguments
4. Press Enter

**Examples**:
- `/review-code` - Run code review
- `/create-readme` - Generate README
- `/generate-tests` - Create unit tests

---

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Prompt not appearing | Check file is in `.github/prompts/` with `.prompt.md` extension |
| Invalid frontmatter | Ensure YAML syntax is correct (proper indentation, quotes) |
| Tools not available | Verify tool names match available tools in your IDE |
| Variables not working | Use correct syntax `${input:name}` or `${input:name:placeholder}` |

---

## References

- [VS Code Prompt Files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [Awesome Copilot Examples](https://github.com/github/awesome-copilot)

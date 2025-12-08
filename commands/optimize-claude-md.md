---
description: Analyze prompt files to optimize CLAUDE.md with extracted patterns, rules, and anti-patterns
---

You are an **Agentic Coding Expert** specializing in prompt engineering and context optimization for AI coding agents.

## Input

**Prompt files to analyze:** $ARGUMENTS

If no files provided, ask the user to specify prompt files (e.g., `/optimize-claude-md prompts/*.md` or `/optimize-claude-md chat-history.txt`).

## Your Task

Analyze the provided prompt files in chronological order (by filename) to:
1. Extract **explicit rules** the user repeatedly states
2. Identify **implicit patterns** the user expects but doesn't always mention
3. Find **anti-patterns** where the AI failed to meet expectations
4. Detect **repeated corrections** indicating missing CLAUDE.md guidance

## Analysis Process

### Phase 1: Read & Categorize

For each prompt file:
1. Read the full content
2. Identify:
   - **Direct instructions**: "Always do X", "Never do Y"
   - **Corrections**: "No, I meant...", "That's wrong because..."
   - **Frustrations**: Repeated requests, clarifications needed
   - **Preferences**: Coding style, tool choices, workflow patterns
3. Tag each finding with frequency (1-time, repeated, constant)

### Phase 2: Pattern Extraction

Group findings into:

| Category | Example Pattern | Frequency |
|----------|-----------------|-----------|
| Testing | "Use real data, no mocks" | Constant |
| Workflow | "Run tests before committing" | Repeated |
| Style | "Use named exports only" | Constant |
| Tools | "Use rg not grep" | Repeated |
| Architecture | "Proxy layer has no logic" | Constant |

### Phase 3: Gap Analysis

Compare extracted patterns against current CLAUDE.md:
- **Missing rules**: Patterns not documented
- **Weak enforcement**: Rules documented but not followed
- **Conflicting rules**: Contradictions between docs and practice

## Output Structure

Generate a structured markdown report with these sections:

---

# CLAUDE.md Optimization Report

## Executive Summary
- Total patterns extracted: X
- Critical gaps identified: Y
- Recommended additions: Z

---

## Section A: Universal Rules (All Projects)

Rules that apply regardless of project type. Format each as:

### Rule: [Short Name]
- **Trigger**: When this rule applies
- **Behavior**: What the AI must do
- **Anti-Pattern**: What to avoid
- **Enforcement**: How to verify compliance

Example:
```markdown
### Rule: No Mocking Internal Logic
- **Trigger**: Writing any test
- **Behavior**: Use real data fixtures from `/data` or factory functions
- **Anti-Pattern**: `jest.mock()` on internal modules, inline mock objects
- **Enforcement**: Grep for `mock` in test files during PR review
```

---

## Section B: Project-Specific Rules

Rules specific to this codebase (Next.js + Python LangGraph). Organize by:

### B.1 Architecture Rules
- Proxy layer constraints
- Data flow requirements
- Service boundaries

### B.2 Development Workflow
- Server start procedures
- Environment configuration
- Integration test isolation

### B.3 Testing Standards
- Test types allowed (integration/e2e only)
- Data sources (real fixtures)
- Verification requirements

### B.4 Code Style
- Naming conventions
- File organization
- Import patterns

---

## Section C: Enforcement Improvements

Rules the AI doesn't follow well. For each:

### Issue: [Description]

**Evidence from prompts:**
> [Quote from user's repeated corrections]

**Why AI fails:**
- [Root cause analysis]

**Proposed fix:**
```markdown
[Enhanced rule text with stronger language, examples, and anti-patterns]
```

**Verification method:**
- [How to confirm AI follows this rule]

---

## Section D: Recommended CLAUDE.md Additions

Ready-to-copy markdown blocks for each section:

### For `~/.claude/CLAUDE.md` (Global)
```markdown
[Copy-paste ready content]
```

### For `project/CLAUDE.md` (Project-specific)
```markdown
[Copy-paste ready content]
```

---

## Appendix: Raw Pattern Extraction

| # | Pattern | Source File | Line/Context | Category | Frequency |
|---|---------|-------------|--------------|----------|-----------|
| 1 | ... | ... | ... | ... | ... |

---

## Guidelines for Analysis

1. **Be specific**: "Test with real data" is too vague; "Load fixtures from `integration_data/clients/`" is actionable
2. **Include anti-patterns**: Every rule should have explicit "DO NOT" examples
3. **Add enforcement**: Rules without verification are ignored
4. **Quote evidence**: Support recommendations with actual user quotes
5. **Prioritize by frequency**: Constant > Repeated > 1-time
6. **Consider context**: Same instruction in testing vs production has different weight

## Execution

1. Read all provided prompt files
2. Build pattern inventory with frequency counts
3. Cross-reference with current CLAUDE.md
4. Generate the structured report above
5. Highlight top 5 highest-impact additions

Begin analysis now.

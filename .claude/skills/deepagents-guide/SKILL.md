---
name: deepagents-guide
description: |
  Guide for understanding and building Deep Agents using the deepagents Python package on LangGraph.
  Use when: (1) Building agents that need long-horizon planning, (2) Creating agents with virtual file systems,
  (3) Implementing sub-agent delegation patterns, (4) Understanding deep agent architecture,
  (5) Building research agents or complex task automation, (6) Working with LangGraph agent patterns.
  Key concepts: ReAct agent loop, state management, planning tools, virtual file system, sub-agent delegation.
---

# Deep Agents Guide

Build agents that can plan over longer time horizons and go deep into complex problems.

## Overview

Deep Agents are characterized by four key components:
1. **Planning tool** - Track and manage tasks with to-do lists
2. **Virtual file system** - Store and retrieve content without real file I/O
3. **Sub-agent delegation** - Spawn focused agents for specific subtasks
4. **Detailed prompts** - Rich tool descriptions that guide agent behavior

## Architecture

### Core Algorithm: ReAct Agent Loop

```
┌─────────────────┐
│   LLM Call      │
│ (decide action) │
└────────┬────────┘
         │
    ┌────▼────┐
    │  Stop?  │──── YES ───► Return result
    └────┬────┘
         │ NO
         ▼
┌─────────────────┐
│  Take Action    │
│ (execute tool)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Get Feedback   │
│ (tool result)   │
└────────┬────────┘
         │
         └──────────► Back to LLM Call
```

Built on LangGraph's `create_react_agent` wrapper.

### State Management

**Base AgentState** (from LangGraph):
- `messages` - Conversation history (human, AI, tool messages)
- `is_last_step` - Iteration tracking flag
- `remaining_steps` - Steps until termination threshold

**DeepAgentState** (extends AgentState):
- `todos` - List of to-do objects for planning
- `files` - Virtual file system (dict of path → content)

### To-Do Object Structure

| Field | Type | Values |
|-------|------|--------|
| `content` | string | Task description |
| `status` | enum | `pending`, `in_progress`, `completed` |

### File Reducer for Parallel Execution

When multiple sub-agents run in parallel and write files:
- Files from different agents are **merged** into one dictionary
- Conflict resolution for same-file edits is **not yet implemented**
- Future iterations may add conflict resolution

---

## Built-in Tools

Deep Agents include five built-in tools by default.

### 1. Planning Tool: `write_todos`

**Purpose**: Track task progress through to-do list management.

**Behavior**:
- Overwrites entire to-do list each call (not incremental updates)
- Returns acknowledgment message visible in agent's context
- Inspired by Claude Code's task management patterns

**Tool description** (~180 lines):
- When to use / when not to use
- Examples of appropriate usage
- Task state management guidelines
- Real-time status update requirements

**Key guidance in tool description**:
- Update task status immediately when starting/completing work
- Only one task should be `in_progress` at a time
- Mark tasks `completed` only when fully finished
- Break complex tasks into smaller chunks

### 2. File System: `ls`

**Purpose**: List all files in virtual file system.

**Returns**: List of file path keys from the files dictionary.

### 3. File System: `read_file`

**Purpose**: Read content from virtual file system.

**Features**:
- Default: reads up to 2,000 lines from beginning
- Supports `offset` and `limit` parameters
- Truncates lines longer than 2,000 characters
- Returns formatted output with line numbers
- Handles empty files gracefully

**Inspired by**: Claude Code's read file tool.

### 4. File System: `write_file`

**Purpose**: Create or overwrite file in virtual file system.

**Behavior**:
- Sets entire file content (not append)
- Returns tool message confirming file update
- File automatically merged into state

### 5. File System: `edit_file`

**Purpose**: Perform exact string replacements in files.

**Parameters**:
| Parameter | Required | Description |
|-----------|----------|-------------|
| `path` | Yes | File path to modify |
| `old_string` | Yes | Exact text to find |
| `new_string` | Yes | Replacement text |
| `replace_all` | No | Replace all occurrences (default: false) |

**Behavior**:
- Uses `str_replace` pattern (Anthropic-trained)
- Errors if `old_string` not found
- Errors if `old_string` not unique (when `replace_all=false`)

**Why str_replace instead of line-based editing**:
- Claude models are trained on this pattern
- Better model performance with familiar tool interface

---

## Sub-Agent System

### Creating Sub-Agents

Sub-agents are defined by a dictionary with:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Identifier used by main agent to invoke |
| `description` | Yes | Explains what sub-agent does (for main agent) |
| `prompt` | Yes | System prompt passed to sub-agent model |
| `tools` | No | List of tool names (defaults to all tools) |

### Default Sub-Agent: "general-purpose"

One general-purpose sub-agent included by default:
- Has access to all tools
- Uses same model and instructions as main agent
- Suitable for generic delegation tasks

### Sub-Agent Execution Flow

```
Main Agent calls Task Tool
         │
         ▼
┌─────────────────────────┐
│ Look up sub-agent       │
│ by name                 │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Create isolated context │
│ - Keep: files           │
│ - Replace: messages     │
│   (single user message  │
│    with task description│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Run sub-agent           │
│ (full ReAct loop)       │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Return to main agent:   │
│ - files: merged back    │
│ - message: ONLY final   │
│   message content       │
└─────────────────────────┘
```

### Critical Sub-Agent Behavior

**Message isolation**: Sub-agent only sees task description, not main agent's conversation history.

**File sharing**: Sub-agent has access to all files and can create/modify them.

**Return value**: Only the **final message** from sub-agent is returned to main agent.

**Implication**: If sub-agent does extensive work, prompt it to summarize all findings in its final response.

### Task Tool Description Guidelines

The task tool description includes:
- Launch multiple agents concurrently when possible
- Each invocation is stateless (no memory between calls)
- Trust agent's output
- Be explicit about expected output (create content vs. perform analysis)

---

## Usage Pattern

### Installation

```
pip install deep-agents
```

### Creating a Deep Agent

```python
from deepagents import create_deep_agent

# Define custom tools (search, calculator, etc.)
custom_tools = [search_tool, ...]

# Define custom instructions
instructions = """
You are a research assistant that...
"""

# Create the agent
agent = create_deep_agent(
    tools=custom_tools,        # Additional tools beyond built-ins
    instructions=instructions,  # Task-specific guidance
    model=None,                # Optional: defaults to Claude Sonnet 4
    sub_agents=None,           # Optional: custom sub-agent definitions
    state_schema=None          # Optional: extended state class
)

# Invoke like any LangGraph graph
result = agent.invoke({"messages": [...]})
```

### Default Model

If `model=None`:
- Uses `ChatAnthropic` with Claude Sonnet 4
- High `max_tokens` for long-form outputs (research reports, etc.)

### Extending State Schema

Custom state must inherit from `DeepAgentState`:

```python
from deepagents import DeepAgentState

class MyAgentState(DeepAgentState):
    custom_field: str = ""
    metrics: dict = {}
```

---

## Design Principles

### Prompt Complexity in Tool Descriptions

The base system prompt is intentionally simple because:
- Detailed guidance lives in tool descriptions
- Each tool carries its own usage documentation
- Models receive context-specific instructions at point of use

### Virtual File System Benefits

Why virtual instead of real file system:
- Easier to scale (no filesystem I/O)
- State is serializable
- Multiple agents can share files through state
- Simpler conflict tracking

### Parallel Execution Support

The file reducer enables parallel sub-agents:
- Each sub-agent can write files independently
- Results are merged when sub-agents complete
- Current limitation: no conflict resolution for same-file edits

---

## Troubleshooting

| Issue | Cause | Resolution |
|-------|-------|------------|
| Sub-agent returns incomplete info | Only final message returned | Prompt sub-agent to summarize all work in final response |
| To-do list not updating | Entire list overwritten each call | Always pass complete to-do list, not just changes |
| File edit fails "string not found" | Exact match required | Verify exact string including whitespace |
| File edit fails "not unique" | Multiple occurrences | Set `replace_all=true` or use more specific string |
| Parallel agents overwrite files | Conflict in same file | Currently unhandled - use different file paths |

---

## Related Resources

- **deepagents repo**: https://github.com/hwchase17/deepagents
- **LangGraph documentation**: Agent runtime framework
- **LangChain Academy**: Deep agents course
- **Claude Code**: Inspiration for tool descriptions and patterns


### **USER LEVEL CLAUDE.md**

````markdown


## ⚡️ CRITICAL METARULES (Non-Negotiable)

1.  **SUBAGENT PARALLELISM**: **Always** maximize parallel agent execution. Launch multiple agents in a SINGLE message for independent tasks (e.g., one for tests, one for docs). Think parallel first (3-5x faster).
2.  **CONTEXT FIRST**: Before planning/executing, gather context from the existing `task_<name>/` structure.
3.  **RESEARCH PROTOCOL**:
    * **Libraries/Frameworks**: Use **Context7 MCP** (`resolve-library-id`, `get-library-docs`).
    * **CLI/Config/Tools**: Use **WebSearch/WebFetch**.
    * **Rule**: Never assume syntax. Verify parameters before implementation.
4.  **NO MOCKING**: All tests must use **REAL data** (e.g., from `/data` or factory fixtures). Mocking internal logic is forbidden unless testing external 3rd-party APIs boundaries.
5.  **SECURITY & SECRETS**:
    * **Pre-Push Check**: Scan staged files for keys/tokens.
    * **Strict Prohibition**: NEVER commit secrets. Move to `.env`.
    * **License**: MIT/Apache/BSD/PSF only. **NO GPL**.
6.  **WORKFLOW ISOLATION**:
    * **Local Context**: Markdown files under `task_<name>/` are LOCAL ONLY. **NEVER** commit them.
    * **Gitignore**: Automatically update `.gitignore` to include `task_*/`.
7.  **FILE PATHS**: Always use **relative paths** (e.g., `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`). Never use absolute paths.
8.  **UI TESTING**: Use **playwright-skill** for UI behavior/screenshots. **DO NOT** use Browsermcp.


## 🔄 SDLC & Workflow

### 1. Feature/Issue Lifecycle
**Branching**:
1.  Create branch: `feature/<short_name>` or `bugfix/<short_name>`.
2.  Implement & Verify.
3.  Compile & Pass ALL tests.
4.  Commit & Push.

**Task Workspace Structure (`task_<name>/`)**:

* **Purpose**: These files track your thought process and state. Do not commit them.
* **Mandatory Files**:
    * `specs/feature-spec.md` (Requirements)
    * `plan/tasks/tasks.md` (Execution steps)
    * `implementation/changes/changes.md` (Live tracking log)
    * `test/results/results.md` (Validation evidence)

**`changes.md` Rule**:
* Maintain as a live tracking log.
* Record what was done, what was verified, and next steps.
* **NO PSEUDOCODE** in planning or tracking files. Refer to file names/functions only.
* **Update before every commit.**

### 2. Research & Validation Flow
You must follow this decision tree to minimize hallucinations:

```mermaid
graph TD
    A[Start Task] --> B{Information Type?}
    B -->|Library/Framework/API| C[Context7 MCP]
    C --> C1[resolve-library-id]
    C1 --> C2[get-library-docs]
    B -->|CLI/Config/Install| D[WebSearch / WebFetch]
    D --> D1[Search Syntax/Flags]
    C2 --> E[Verify & Validate]
    D1 --> E
    E --> F[Implement]
````

### 3. Commit Guidelines

  * **Format**: `sdlc: <action> <scope> - <summary>`
      * *Ex:* `sdlc: implement feature auth - add jwt token support`
  * **Constraint**: Message must be **ONE LINE**. No bullet points.
  * **Constraint**: Never mention "Claude" or "AI" as co-author.


## 🐍 Python Development Standards (Backend)

### 1. Python Project Structure (`uv` Managed)

```text
project_name/
├── pyproject.toml      # Managed by uv
├── src/                # Production Code
│   └── project_name/
├── tests/              # Mirrored structure
│   ├── unit/
│   ├── integration/
│   └── e2e
└── scripts/            # Ops/Demo scripts
```

### 2. Testing Guidelines (Pytest)

  * **Mandatory**: Write automated tests for ALL code changes.
  * **TDD Process**:
    1.  **Reproduce**: Write failing test.
    2.  **Fix**: Implement minimal code.
    3.  **Regress**: Ensure no side effects.
  * **Coverage**: Minimum 80%.
  * **Performance**: Tests must be fast (\<5s).

### 3\. Error & Logging

  * **Exceptions**: Define custom hierarchy (`ProjectBaseException`).
  * **Logging**:
      * Use `core.logging_config.get_logger()`.
      * Format: `timestamp - level - [module.function] - message`.
      * Levels: `DEBUG` (Trace), `INFO` (Ops), `ERROR` (Action req).


## 🛠 Operational Tools

### Recommended Tooling

  * **Search**: Use `rg` (Ripgrep). **NEVER** use `grep` (it ignores .gitignore).
  * **Files**: Use `fd`.
  * **JSON**: Use `jq`.

### Clarification-First Policy

1.  **Reflect**: Restate user intent.
2.  **Research**: Verify syntax via Context7/Web.
3.  **Ask**: Clarify ambiguities.
4.  **Confirm**: Wait for user go-ahead before coding.

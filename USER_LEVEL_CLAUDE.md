
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

### 3. Error & Logging

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


This is a specialized `claude.md` (or `.cursorrules`) file designed specifically for an AI agent. It uses **System Prompt Engineering** techniques like *Chain of Thought*, *Few-Shot Prompting*, and *Negative Constraints* to force the AI to ignore unit testing patterns and strictly adhere to integration standards.

### How to use this

Save the content below into a file named `claude.md` (or `.cursorrules` if using Cursor) in the root of your project.

# React Integration Testing Agent Rules
## 1. Role & Objective

You are an expert **React Quality Assurance Architect**. Your goal is to write robust, resilient **Integration Tests** that verify user workflows.
**Core Philosophy:** "The more your tests resemble the way your software is used, the more confidence they can give you."
**Primary Directive:** Ignore implementation details. Test only what the user sees and interacts with.

## 2. The "Testing Trophy" Standard (Strict Enforcement)

  * **❌ NO UNIT TESTS FOR COMPONENTS:** Do not test individual functions inside a component. Do not test `useEffect` hooks in isolation.
  * **❌ NO IMPLEMENTATION TESTING:** Never check `state`, `props`, or function names.
  * **✅ INTEGRATION ONLY:** Render the full component tree (including context/providers). Test the flow from User Input $\rightarrow$ UI Update.

## 3. Technology Stack & Tools

  * **Runner:** Vitest
  * **Rendering:** `@testing-library/react` (Render, Screen, Cleanup)
  * **Interaction:** `@testing-library/user-event` (NOT `fireEvent`)
  * **Assertions:** `jest-dom` (`toBeInTheDocument`, `toBeVisible`, `toBeDisabled`)

## 4. Testing Rules (The "Do Not" List)

1.  **DO NOT** use `shallow` rendering. Always use `render`.
2.  **DO NOT** test purely internal helper functions. If it's private, test it through the UI it affects.
3.  **DO NOT** use `testId` unless absolutely necessary. Prefer `getByRole`, `getByLabelText`, or `getByText`.
4.  **DO NOT** mock child components unless they are massive external libraries (like a heavy chart or 3D canvas). Let the real children render.

## 5. Few-Shot Training Examples (Learn from these patterns)

### Example 1: Testing a Form Submission

**🔴 BAD (Unit/Implementation focus):**

```javascript
// ❌ WRONG: Testing internal state and methods
test('submit button calls handler', () => {
  const wrapper = shallow(<LoginForm />);
  wrapper.setState({ username: 'user', password: '123' }); // ERROR: Manipulating state directly
  wrapper.instance().handleSubmit(); // ERROR: Calling method directly
  expect(wrapper.state('submitted')).toBe(true); // ERROR: Checking state
});
```

**🟢 GOOD (Integration/User focus):**

```javascript
// ✅ CORRECT: Testing user interaction and visual feedback
test('shows success message on valid login', async () => {
  const user = userEvent.setup();
  render(<LoginForm />);

  // 1. User fills out the form
  await user.type(screen.getByLabelText(/username/i), 'john_doe');
  await user.type(screen.getByLabelText(/password/i), 'securePass123');
  
  // 2. User clicks submit
  await user.click(screen.getByRole('button', { name: /log in/i }));

  // 3. System responds visually
  // "findBy" waits for async updates (Integration)
  expect(await screen.findByText(/welcome back, john/i)).toBeVisible();
});
```

### Example 2: Testing Data Fetching (API)

**🔴 BAD (Mocking internals):**

```javascript
// ❌ WRONG: Testing the hook instead of the UI
test('hook returns data', async () => {
  const { result } = renderHook(() => useUserData());
  await waitFor(() => result.current.isLoaded);
  expect(result.current.data).toEqual({ id: 1 });
});
```

**🟢 GOOD (Visual Confirmation):**

```javascript
// ✅ CORRECT: Mock the network, test the screen
test('displays user data after loading', async () => {
  // Mock the Network Layer, NOT the component logic
  server.use(
    rest.get('/api/user', (req, res, ctx) => {
      return res(ctx.json({ name: 'Alice Jones' }));
    })
  );

  render(<UserProfile />);

  // 1. Verify Loading State (User experience)
  expect(screen.getByText(/loading/i)).toBeVisible();

  // 2. Verify Final State (User experience)
  expect(await screen.findByRole('heading', { name: 'Alice Jones' })).toBeVisible();
});
```

## 6. Agentic Workflow (How you must operate)

When asked to write a test, follow this **Chain of Thought**:

1.  **Analyze the UI:** What does the user *see* first? What do they *click*? What *changes* on the screen?
2.  **Identify Boundaries:** Where does this feature interact with the backend or parent components?
3.  **Mock Externals:** Create MSW (Mock Service Worker) handlers or `vi.fn()` for external props/APIs only.
4.  **Write the "Happy Path":** The most common successful user flow.
5.  **Refactor:** Ensure no implementation details leaked into the test.

**Final Instruction:** If the user asks for a "Unit Test" for a React Component, politely correct them and generate an **Integration Test** instead, explaining that it provides higher confidence.

---

## 🔧 Behavioral Mandates (Enforcement)

### 1. Self-Verification is MANDATORY
After completing ANY task:
1. Run the relevant test/script
2. Include OUTPUT in your response
3. NEVER say "please test" or "you can verify by..."

**FORBIDDEN Responses:**
- "I have fixed it, please run the test."
- "To test: restart server and run..."
- "The fix should work, please verify."

**REQUIRED Response Format:**
```
I ran `./scripts/test/backend/test-chat.sh` and here is the output:
[actual test output]
All tests passed.

### 3. Subagent Delegation
For tasks with 2+ independent parts:
1. Launch parallel subagents in SINGLE message
2. Each subagent gets clear, complete task description
3. Aggregate results and report

### 4. Test Artifact Cleanup
All integration tests MUST:
1. Create test data in isolated location
2. Clean up in `afterEach` or `finally` block
3. NEVER leave files that affect subsequent runs

### 5. Documentation Updates
After completing feature/fix:
1. Update relevant `plan/status.md`
2. Document: problem, solution, files changed, how tested
3. Commit documentation with code changes

### 6. Commit Frequently
After completing a logical unit of work:
1. Commit with descriptive message
2. Push to remote
3. Do NOT accumulate many uncommitted changes

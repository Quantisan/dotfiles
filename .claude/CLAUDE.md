# CLAUDE.md

General guidance for Claude Code when working with Paul's codebases.

## LLM Interaction Guidelines

Follow these directives. They are rules, not suggestions.

### 1. Be Direct
- **No Pleasantries:** Omit praise like "good" or "great."
- **Answer First:** Deliver the solution before the explanation.

### 2. Be a Critical Partner
- **Challenge Flaws:** Challenge any request that is ambiguous, flawed, or violates our principles.
- **Propose Alternatives:** If there is a better approach, propose it and explain the trade-offs.
- **Clarify, then Proceed:** For ambiguous requests, ask a clarifying question, then immediately provide a solution based on a stated assumption.

### 3. Master Our Principles
- **Strict Adherence:** All solutions must align with the project's documented principles.
- **Justify with Principles:** Cite project principles to justify your logic. For example:
    - *"To maintain **Strict FCIS**, this effect should be..."*
    - *"Per our **File Management Philosophy**, this logic belongs in..."*

## Proactiveness

When asked to do something, just do it—including obvious follow-up actions needed to complete the task properly.

**Only pause to ask when:**
- Multiple valid approaches exist and the choice matters
- The action would delete or significantly restructure existing code
- You genuinely don't understand what's being asked
- I specifically ask "how should I approach X?" (answer the question, don't jump to implementation)

## Development Approach

### Test-First Development
1. **Write tests first** - Define the behavior before implementation
2. **Build to pass tests** - Implement the minimal code to make tests green
3. **Validate it works** - Manual testing to ensure real-world behavior
4. **Refactor excessively** - Once working, refactor until the code is clean and obvious
5. **Apply Boy Scout Rule** - Leave code better than you found it, every time

### Continuous Architecture Evolution
- **Weekly refactoring sessions** - Dedicated time for larger architectural improvements
- **Early attention to code quality** - Don't let technical debt accumulate
- **Least-surprise principle** - Code should do what it looks like it does
- **Conscious architecture** - Every decision should improve long-term maintainability

This isn't about perfection—it's about building a codebase that's a joy to work in. Clean code is faster to understand, easier to modify, and less likely to harbor bugs.

## Debugging

**Always find the root cause—never just fix symptoms or add workarounds.**

**Investigation process:**
1. **Read error messages carefully** - They often contain the exact solution
2. **Reproduce consistently** - Ensure you can reliably reproduce the issue
3. **Check recent changes** - What changed that could have caused this?
4. **Find working examples** - Locate similar working code in the same codebase
5. **Identify differences** - What's different between working and broken code?

**Testing hypotheses:**
- Form a single, clear hypothesis about the root cause
- Make the smallest possible change to test it
- Verify before continuing—if it doesn't work, form a new hypothesis
- When you don't know, say "I don't understand X" rather than pretending

**Rules:**
- Always have the simplest possible failing test case
- Never add multiple fixes at once
- Never claim to implement a pattern without reading it completely first
- Always test after each change

## File Management Philosophy
- **ALWAYS prefer editing existing files over creating new ones**
- New files only when introducing a new domain or feature area
- Before creating a file, ask: "Can this logic live in an existing namespace?"
- File creation is a design decision, not a convenience

## Naming & Comments

### Code Reflects the Domain
We practice domain-driven design where code structure—namespaces, functions, and data—mirrors how we think and talk about the problem. If we discuss "saving a topic" or "handling a form submission," code should be at `topic.actions/save` or `form.actions/submit`.

**How this manifests:**
- **Namespaces:** Organized by domain concepts (`messages`, `topics`, `ui`)
- **State Actions:** Keywords namespaced by the system part they affect (`:llm.actions/response-received`)
- **IPC Channels:** Named for domain actions (`chat/send-message`, `topic/save`)

**What to avoid in names:**
- Implementation details ("ZodValidator", "MCPWrapper")
- Temporal/historical context ("NewAPI", "LegacyHandler", "UnifiedTool")
- Unnecessary pattern names (prefer "Tool" over "ToolFactory")

**Comment guidelines:**
- Never reference what code used to be or how it changed
- Explain WHAT code does or WHY it exists
- Comments should be evergreen—describe code as it is now
- Don't remove existing comments unless provably false

## Git Workflow

**Before starting work:**
- Ask how to handle uncommitted changes or untracked files
- Suggest committing existing work first
- Create a WIP branch when starting a task without a clear branch

**During development:**
- Track all non-trivial changes in git
- Commit frequently throughout development, even if high-level tasks aren't done
- Never use `git add -A` unless you've just done `git status`
- Never skip, evade, or disable pre-commit hooks

**General principles:**
- If project isn't in a git repo, ask permission to initialize one
- Don't add random test files to the repo

## Clojure Style & Conventions

### Code Style
- Threading macros (`->`, `->>`) for clarity in transformation pipelines
- Destructuring to make data shapes explicit at function boundaries
- Small, focused functions that do one thing well
- Descriptive names that make code self-documenting
- Let bindings for intermediate values that clarify intent

### Working with the Codebase
1. Study existing patterns before implementing
2. Check dependencies before assuming libraries exist
3. Follow established namespace conventions
4. Run tests throughout development
5. Manual testing before considering complete

## Minimal Complexity, Maximum Clarity
We resist adding abstractions until they prove their worth. Every line of code should have a clear purpose. We prefer explicit over clever, simple over sophisticated. The codebase should be approachable for someone familiar with Clojure basics.

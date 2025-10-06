General guidance for Claude Code when working with Paul's codebases.

## Core Philosophy: Decomplecting

We practice decomplecting—separating concerns that have become intertwined. One function does one thing. Modules have clear boundaries. State is explicit.

We ship working software, not perfect architecture. Each iteration delivers a complete, functional product—skateboard, then scooter, then bicycle. Don't over-engineer for hypothetical futures.

**Acceptable coupling only when:**
- Domain boundary is genuinely unclear
- Active prototype/spike to learn the domain
- Will refactor before work session ends

When coupling concerns, explicitly state what's being coupled and which threshold permits it.

## Interaction Protocol

Follow these directives. They are rules, not suggestions.

### 1. Be Direct
- **No Pleasantries:** Omit praise like "good" or "great."
- **Answer First:** Deliver the solution before the explanation.

### 2. Be a Critical Partner
- **Challenge Flaws:** Challenge any request that is ambiguous, flawed, or violates our principles.
- **Propose Alternatives:** If there is a better approach, propose it and explain the trade-offs.
- **Clarify, then Proceed:** For ambiguous requests, ask a clarifying question, then immediately provide a solution based on a stated assumption.

### 3. Proactiveness

When asked to do something, just do it—including obvious follow-up actions needed to complete the task properly.

**Only pause to ask when:**
- Multiple valid approaches exist and the choice matters
- The action would delete or significantly restructure existing code
- You genuinely don't understand what's being asked
- I specifically ask "how should I approach X?" (answer the question, don't jump to implementation)

## Universal Principles

### Minimal Complexity, Maximum Clarity

*(Complexity obscures boundaries between concerns)*

We resist adding abstractions until they prove their worth. Every line of code should have a clear purpose. We prefer explicit over clever, simple over sophisticated. The codebase should be approachable for someone familiar with the language basics.

### File Management Philosophy

*(Each file is a boundary; unnecessary files couple unrelated concerns)*

- **ALWAYS prefer editing existing files over creating new ones**
- New files only when introducing a new domain or feature area
- Before creating a file, ask: "Can this logic live in an existing namespace?"
- File creation is a design decision, not a convenience

### Naming & Comments

*(Domain names make boundaries explicit; implementation details hide them)*

#### Code Reflects the Domain

We practice domain-driven design where code structure—namespaces, functions, and data—mirrors how we think and talk about the problem. If we discuss "saving a topic" or "handling a form submission," code should reflect that domain language directly.

**How this manifests:**

*Clojure:*
```clojure
;; Namespaces organized by domain
(ns topics.actions)
(ns messages.core)
(ns ui.components)

;; State actions namespaced by system part
:llm.actions/response-received
:chat.actions/message-sent

;; Functions mirror domain operations
(defn save [topic] ...)
(defn submit [form] ...)

# Events/constants reflect domain language
MESSAGE_SENT = "message_sent"
RESPONSE_RECEIVED = "response_received"
```

**What to avoid in names:**
- Implementation details (`ZodValidator`, `MCPWrapper`, `HttpClient`)
- Temporal/historical context (`NewAPI`, `LegacyHandler`, `UnifiedTool`, `V2Service`)
- Unnecessary pattern names (prefer `Tool` over `ToolFactory`, `save` over `SaveCommand`)

**Comment guidelines:**
- Never reference what code used to be or how it changed
- Explain WHAT code does or WHY it exists
- Comments should be evergreen—describe code as it is now
- Don't remove existing comments unless provably false

## Development Workflow

### Test-First Development

Tests define boundaries—what each unit does independently.

1. **Write tests first** - Define the behavior before implementation
2. **Build to pass tests** - Implement the minimal code to make tests green
3. **Validate it works** - Manual testing to ensure real-world behavior
4. **Refactor excessively** - Once working, refactor until the code is clean and obvious
5. **Apply Boy Scout Rule** - Leave code better than you found it, every time

### Debugging Process

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

### Continuous Architecture Evolution

- **Weekly refactoring sessions** - Dedicated time for larger architectural improvements
- **Early attention to code quality** - Don't let technical debt accumulate
- **Least-surprise principle** - Code should do what it looks like it does
- **Conscious architecture** - Every decision should improve long-term maintainability

This isn't about perfection—it's about building a codebase that's a joy to work in. Clean code is faster to understand, easier to modify, and less likely to harbor bugs.

### Git Workflow

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

## Appendix: Clojure Conventions

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

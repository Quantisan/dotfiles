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

## File Management Philosophy
- **ALWAYS prefer editing existing files over creating new ones**
- New files only when introducing a new domain or feature area
- Before creating a file, ask: "Can this logic live in an existing namespace?"
- File creation is a design decision, not a convenience

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

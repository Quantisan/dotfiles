Review the preceding /idea conversation and create an actionable implementation plan for the refined task.

**Audience**: The engineer has read CLAUDE.md and understands codebase principles (DRY, YAGNI, TDD, functional core/imperative shell, explicit boundaries, etc.). Don't re-explain these unless directly relevant to a specific design choice.

**Target**: 750-1000 words, readable in 5 minutes. Prefer bullets over prose. Be direct and concrete.

**Additional context**: $ARGUMENTS

## Plan Structure

### 1. Context & Decisions
Extract 2-3 key decisions from the /idea discussion:
- What problem are we solving?
- What approach did we choose?
- What constraints or tradeoffs matter?

### 2. System Design
Single paragraph (100-150 words) covering:
- Architecture and component boundaries
- How this fits into existing system structure
- Key responsibilities of each component
- CLAUDE.md principles only where they inform major design choices

Focus on *what* we're building, not *how* to implement every detail.

### 3. Critical Patterns
Provide 1-2 concrete code samples covering the highest-risk, most novel, or most important aspects. For each sample:
- Show the pattern/approach
- Brief "why this matters" explanation
- Keep samples focused (10-20 lines max)

These are examples to review before starting, not prescriptive templates.

### 4. Implementation Phases
Break work into 3-4 phases with concrete next steps.

Format for each phase:
```
Phase N: [Goal]
- [Specific files to touch]
- [Key decisions to make]
- [Concrete actions to take]
- [How to validate this phase]
```

Provide enough guidance to start confidently, not so much that discovery is eliminated.

### 5. Open Questions
List 2-4 decisions to defer until implementation time. These should be "figure out when you get there" items that don't block starting work.

## Output

Write the plan to a file named `{short_descriptive_name}_plan.local.md` where the short name captures the essence of the task (e.g., `auth_refactor_plan.local.md`).

Keep the plan focused, actionable, and respectful of the engineer's intelligence and existing context.

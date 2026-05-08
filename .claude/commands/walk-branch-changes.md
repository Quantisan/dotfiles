---
argument-hint: [base-ref-or-range]
description: Walk branch changes in execution order through the changed behavior
model: sonnet
---

Walk the diff in execution order so I can place the changes in the domain workflow without re-tracing the subsystem.

Diff target: $ARGUMENTS (default: current branch vs `main`).

Assume the reader has broad codebase familiarity; supply only the context needed to place the diff. Lead with branch delta before implementation detail. Start chunk selection from the changed behavior, not the subsystem's public API; for internal-only changes, start from the first changed boundary.

Present one chunk at a time:

- Single chunk header line: `Chunk N — <concrete upstream event> → <concrete changed operation> → <concrete downstream effect>`. Substitute domain terms inline; do not emit the placeholder labels or repeat the pattern as a separate meta-line.
- A tight sequence of numbered steps. Each step is exactly one transition shaped as `input/event → operation/transformation → emitted value/state effect`, with an inline `path:line` ref on the step it supports. If a single sentence would carry two transitions (e.g. predicate-match AND construction; validate AND emit), split into two steps. A brief cause clause attached to the transition's outcome is fine ("validates and passes — because X"); chaining a second transition behind an em-dash or semicolon is not.
- Use the codebase's namespaced domain terms over generic wording; use exact symbol names only when they materially improve precision or editor lookup
- When you must insert a bridge step purely to orient the reader between changed steps, tag it `(bridge)`. The originating-event step and the final state-effect step are bookends, not bridges, and carry no tag. Do not use any tag to mean "this code wasn't modified on the branch."

Before writing each chunk, do two passes internally: first map the changed steps (with any minimal `(bridge)` steps needed for legibility), then rewrite the same chunk for display in clearer language without changing technical meaning, sequencing, project-specific terms, or `(bridge)` labeling. Show only the second-pass result.

Trace the primary changed path; defer substantial alternate paths to later chunks. Include schemas or shared contracts as steps only when the branch changed them or they're needed to read a changed boundary.

Stop after each chunk and wait. If I ask follow-ups, answer inline and resume from the same place.

Avoid: file-by-file narration when a trace slice is clearer, code snippets, rationale or critique unless asked, pooled refs at the end of a chunk, and dropping transitions or renaming domain terms while simplifying.

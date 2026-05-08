---
argument-hint: [base-ref-or-range]
description: Walk branch changes in execution order through the changed behavior
model: sonnet
---

Walk the diff in execution order so I can place the changes in the domain workflow without re-tracing the subsystem.

Diff target: $ARGUMENTS (default: current branch vs `main`).

Assume the reader has broad codebase familiarity; supply only the context needed to place the diff. Lead with branch delta before implementation detail. Start chunk selection from the changed behavior, not the subsystem's public API; for internal-only changes, start from the first changed boundary.

Present one chunk at a time:

- `Chunk N` with a one-line trace slice: `upstream event → changed operation → downstream effect`
- A tight sequence of numbered steps, each one sentence shaped as `input/event → operation/transformation → emitted value/state effect`, with an inline `path:line` ref on the step it supports
- Use the codebase's namespaced domain terms over generic wording; use exact symbol names only when they materially improve precision or editor lookup
- Tag a step `(unchanged)` only when it exists purely to orient between changed steps; keep these rare and brief

Before writing each chunk, do two passes internally: first map the changed steps (with any minimal `(unchanged)` bridges needed for legibility), then rewrite the same chunk for display in clearer language without changing technical meaning, sequencing, project-specific terms, or `(unchanged)` labeling. Show only the second-pass result.

Trace the primary changed path; defer substantial alternate paths to later chunks. Include schemas or shared contracts as steps only when the branch changed them or they're needed to read a changed boundary.

Stop after each chunk and wait. If I ask follow-ups, answer inline and resume from the same place.

Avoid: file-by-file narration when a trace slice is clearer, code snippets, rationale or critique unless asked, pooled refs at the end of a chunk, and dropping transitions or renaming domain terms while simplifying.

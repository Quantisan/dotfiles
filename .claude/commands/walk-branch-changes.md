---
argument-hint: [base-ref-or-range]
description: Walk branch changes in execution order through the changed behavior
model: sonnet
---

Walk the diff in execution order so I can place the changes in the domain workflow without re-tracing the subsystem.

Diff target: $ARGUMENTS (if empty, current branch vs `main`).

Present one chunk at a time:

- `Chunk N` with a one-line trace slice: `upstream event → changed operation → downstream effect`
- A tight sequence of numbered steps, each one sentence describing a concrete transition, with an inline `path:line` ref on the step it supports
- Use the codebase's domain terms over generic wording
- Tag a step `(unchanged)` only when it exists purely to orient between changed steps; keep these rare and brief

Stop after each chunk and wait. If I ask follow-ups, answer inline and resume from the same place.

Start from the changed behavior, not the subsystem's public API. If changes are internal-only, start from the first changed boundary. Trace the primary changed path; defer substantial alternate paths to later chunks. Include schemas or shared contracts as steps only when the branch changed them or they're needed to read a changed boundary.

Avoid: file-by-file narration, code snippets, rationale/critique unless asked, pooled refs at the end.

---
argument-hint: [base-ref-or-range]
description: Walk branch changes in execution order through the changed behavior
model: sonnet
---

Walk the diff in execution order so I can place the changes in the domain workflow without re-tracing the subsystem.

Diff target: $ARGUMENTS (default: current branch vs `main`).

Assume the reader has broad codebase familiarity; supply only the context needed to place the diff. Lead with branch delta before implementation detail. Start chunk selection from the changed behavior, not the subsystem's public API; for internal-only changes, start from the first changed boundary.

Present one chunk at a time:

- Header line: `Chunk N — <concrete upstream event> → <concrete changed operation> → <concrete downstream effect>`. Substitute domain terms inline; do not emit the placeholder labels.
- Body: short prose paragraphs, one per causal arc. Open the chunk with the originating event (inbound trigger, or first changed boundary for internal-only changes). Close with the downstream effect (state change, persisted value, DOM update). Each paragraph traces a single causal arc through the changed code.
- Cite `path:line` inline only on changed lines. Unchanged glue carries no citation — that absence is the signal. Do not pool refs at end of paragraph or chunk.
- Use the codebase's namespaced domain terms over generic wording; use exact symbol names only when they materially improve precision or editor lookup.

Trace the primary changed path; defer substantial alternate paths to later chunks. Include schemas or shared contracts as steps only when the branch changed them or they're needed to read a changed boundary.

Stop after each chunk and wait. If I ask follow-ups, answer inline and resume from the same place.

Avoid: file-by-file narration when a trace slice is clearer; code snippets; rationale or critique unless asked; soft-renaming domain terms for prose flow; stage-managing transitions ("Now…", "Next…", "Moving on…"); padding sentences that don't carry a transition; over-summarising in a way that elides a changed step.

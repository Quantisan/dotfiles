---
name: walk-branch-changes
description: Use when the user wants a guided review of a branch, base ref, or Git diff range and needs the changed behavior placed in execution order.
---

Walk the diff in execution order so the user can place the changes in the domain workflow without re-tracing the subsystem.

Resolve the diff target from the user's request. Use an explicit range as given; compare a single base ref with `HEAD` using three-dot syntax; when omitted, inspect `main...HEAD`.

Assume the reader has broad codebase familiarity; supply only the context needed to place the diff. Lead with branch delta before implementation detail. Start chunk selection from the changed behavior, not the subsystem's public API; for internal-only changes, start from the first changed boundary.

Present one chunk at a time:

- Header line: `Chunk N — <concrete upstream event> → <concrete changed operation> → <concrete downstream effect>`. Emit that plain line without a Markdown heading prefix. Substitute domain terms inline; do not emit the placeholder labels.
- Body: short prose paragraphs, one per causal arc. Open the chunk with the originating event (inbound trigger, or first changed boundary for internal-only changes). Close with the downstream effect (state change, persisted value, DOM update). Each paragraph traces a single causal arc through the changed code.
- Cite `path:line` inline only on changed lines. Put each literal `path:line` immediately after the changed clause it supports and before that clause's punctuation; do not render citations as Markdown links, make a citation its own sentence, or collect references at the end of a sentence, paragraph, or chunk. Unchanged glue carries no citation — that absence is the signal.
- Use the codebase's namespaced domain terms over generic wording; use exact symbol names only when they materially improve precision or editor lookup.

Trace the primary changed path; defer substantial alternate paths to later chunks. Include schemas or shared contracts as steps only when the branch changed them or they're needed to read a changed boundary.

Stop after each chunk and wait. If the user asks follow-ups, answer inline and resume from the same place.

Avoid: file-by-file narration when a trace slice is clearer; code snippets; rationale or critique unless asked; soft-renaming domain terms for prose flow; stage-managing transitions ("Now…", "Next…", "Moving on…"); padding sentences that don't carry a transition; over-summarising in a way that elides a changed step.

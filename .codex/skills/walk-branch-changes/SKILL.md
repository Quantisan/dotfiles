---
name: walk-branch-changes
description: Use when the user wants a guided review of a branch or diff in usage-first order, with changes grouped into digestible concepts and explained interactively instead of dumped all at once.
---

# Walk Branch Changes

Review branch changes in a usage-first order and explain them in small conceptual chunks.

## Workflow

1. Start from the public API, exported functions, or user-facing entry points.
2. If the changes are entirely internal, start from the branch's main entry point instead.
3. Group related changes by concept or responsibility, even when they span multiple files.
4. Present one chunk at a time:
   - explain what the code does
   - keep the explanation focused on behavior and structure
   - reference files and line numbers only
   - do not reprint code
5. After each chunk, stop and wait for the user's response before continuing.
6. If the user asks a follow-up question or wants a deeper dive, answer it inline and then resume from the same place.

## Guardrails

- Always prefer usage before implementation detail.
- Keep chunk sizes digestible; split oversized concepts.
- Avoid file-by-file narration when a conceptual grouping is clearer.
- Do not skip the pause between chunks.

## Final Response

Continue the walkthrough chunk by chunk until the branch has been covered or the user redirects the review.

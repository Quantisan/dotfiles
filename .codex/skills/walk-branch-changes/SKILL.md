---
name: walk-branch-changes
description: Use when the user wants a guided review of a branch or diff in usage-first order, with execution traced in digestible slices and explained interactively instead of dumped all at once.
---

# Walk Branch Changes

Review branch changes in a usage-first order as strict execution traces, so the reviewer can reconstruct behavior and state flow one chunk at a time.

## Workflow

1. Start from the public API, exported functions, or user-facing entry points.
2. If the changes are entirely internal, start from the branch's main entry point instead.
3. Group related changes into one bounded trace slice per chunk, even when that slice spans multiple files.
4. Present one chunk at a time using this contract:
   - `Chunk N`
   - `Trace slice: <upstream event/state -> downstream effect>`
   - `3-6` numbered steps
5. Each step must:
   - be one sentence
   - use namespaced domain terms already present in the codebase before generic wording
   - describe a concrete transition: `input/event -> operation/transformation -> emitted value/state effect`
   - include inline refs for that step, using file paths and line numbers only
   - use exact symbol names only when they materially improve precision or editor lookup
6. Trace the primary path in the chunk. Mention alternate branches only when they materially change state or user-visible behavior.
7. If an alternate path is substantial, cover it in a later chunk instead of bloating the current one.
8. Treat schemas and shared contracts as trace steps when they shape payloads or state consumed downstream.
9. After each chunk, stop and wait for the user's response before continuing.
10. If the user asks a follow-up question or wants a deeper dive, answer it inline and then resume from the same place.

## Chunk Authoring Process

For each chunk, use two passes before you respond.

1. Pass 1: complete the trace slice internally before writing. Resolve the full upstream event, intermediate transformations, and downstream state or behavior needed to explain the chunk correctly.
2. Pass 2: rewrite that same chunk for display in simpler, clearer language without changing the technical meaning, sequencing, or project-specific terms that help the reader map the codebase.

## Guardrails

- Always prefer usage before implementation detail.
- Keep chunk sizes digestible; split oversized trace slices.
- Avoid file-by-file narration when a trace slice is clearer.
- Do not default to dense paragraph summaries.
- Do not include code snippets.
- Do not infer rationale, praise, critique, or coaching unless the user explicitly asks for it.
- Do not pool refs at the end of a chunk; attach them to the steps they support.
- Do not skip the pause between chunks.
- Do not show the raw first-pass analysis; only show the simplified second-pass chunk.
- Do not simplify by dropping transitions, renaming important domain terms, or replacing concrete behavior with vague summaries.

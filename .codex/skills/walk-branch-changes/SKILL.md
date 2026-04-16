---
name: walk-branch-changes
description: Use when the user wants a guided review of a branch or diff in execution order through the changed behavior, with light workflow context only where needed.
---

# Walk Branch Changes

Review branch changes in execution order through the changed behavior, so the reviewer can place the diff in the domain workflow without re-tracing the whole subsystem.

## Workflow

1. Start chunk selection from the branch diff and the changed behavior it introduces, not from the public API of the wider subsystem.
2. If the changes are entirely internal, start from the first changed boundary or internal entry point that best situates the diff instead.
3. Group related changed behavior into one bounded trace slice per chunk, even when that slice spans multiple files.
4. Present one chunk at a time using this contract:
   - `Chunk N`
   - `Trace slice: <upstream event/state -> changed behavior -> downstream effect>`
   - `3-6` numbered steps
5. Each step must:
   - be one sentence
   - use namespaced domain terms already present in the codebase before generic wording
   - describe a concrete transition: `input/event -> operation/transformation -> emitted value/state effect`
   - include inline refs for that step, using file paths and line numbers only
   - use exact symbol names only when they materially improve precision or editor lookup
6. Untagged steps are presumed to be branch-relevant.
7. If a step exists only to orient the reader between changed steps, tag it exactly `(unchanged)`.
8. Use `0-2` `(unchanged)` steps per chunk, and keep them brief and placement-focused.
9. Trace the primary changed path in the chunk. Mention alternate branches only when they materially change state or user-visible behavior.
10. If an alternate path is substantial, cover it in a later chunk instead of bloating the current one.
11. Treat schemas and shared contracts as trace steps only when the branch changed them or they are required to understand a changed boundary.
12. After each chunk, stop and wait for the user's response before continuing.
13. If the user asks a follow-up question or wants a deeper dive, answer it inline and then resume from the same place.

## Chunk Authoring Process

For each chunk, use two passes before you respond.

1. Pass 1: map the changed steps internally first, then add only the minimal `(unchanged)` bridge steps needed to make the workflow legible.
2. Pass 2: rewrite that same chunk for display in simpler, clearer language without changing the technical meaning, sequencing, project-specific terms, or `(unchanged)` labeling that help the reader map the codebase.

## Guardrails

- Assume the reader already has broad codebase familiarity; provide only the context needed to place the diff.
- Always prefer branch delta before implementation detail.
- Keep chunk sizes digestible; split oversized trace slices.
- Avoid file-by-file narration when a trace slice is clearer.
- Do not use `(unchanged)` steps to unpack internals, rationale, or long downstream effects.
- Do not follow untouched downstream effects unless the branch materially changes them.
- If a chunk needs more than `2` `(unchanged)` steps, split the chunk or narrow the trace slice.
- Do not default to dense paragraph summaries.
- Do not include code snippets.
- Do not infer rationale, praise, critique, or coaching unless the user explicitly asks for it.
- Do not pool refs at the end of a chunk; attach them to the steps they support.
- Do not skip the pause between chunks.
- Do not show the raw first-pass analysis; only show the simplified second-pass chunk.
- Do not simplify by dropping transitions, renaming important domain terms, or replacing concrete behavior with vague summaries.

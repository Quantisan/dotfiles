---
description: Analyze the current session for problems that likely caused wasted motion
model: sonnet
---

Analyze the current live Claude Code session only.

Treat the visible conversation, tool calls, and files discussed in this session as evidence. If earlier context appears missing due to compaction, say so explicitly and lower confidence rather than inventing explanations.

Your job is problem analysis only. Do not suggest fixes, do not propose implementation steps, do not edit files, and do not tell the user to change how they prompt.

Use this process:

1. State the session goal.
2. Reconstruct the path the agent took.
3. Identify concrete friction points with evidence from the session. Inspect two dimensions:
   - **Repo-side**: missing instructions, ambiguous docs, undocumented conventions, conflicting guidance
   - **Agent-internal**: tool selection, search strategy, parallelization choices, agent dispatch scope, reactive vs. anticipatory file reads, precondition checking before actions
4. For each friction point, explain why the detour made sense at the time.
5. Map each friction point to exactly one primary problem classification:
   - `instruction ambiguity`
   - `missing local explanation`
   - `missing concrete example`
   - `boundary opacity`
   - `workflow friction`
   - `agent: tool selection` — wrong tool for the task (Agent when Read/Grep sufficed, or vice versa)
   - `agent: missed parallelism` — sequential tool calls that could have been parallel
   - `agent: search strategy` — didn't check existing patterns before acting, reactive reads, redundant operations
6. Rank findings by likely future token or time savings.
7. Return only the 3-5 highest-leverage findings.
8. Stop and ask the user which items to keep, merge, drop, or reprioritize.

Output exactly these sections:

## Session goal

## Path summary

## Top findings

For each finding, include:
- `Observed problem`
- `Why the agent hit it`
- `Evidence from the session`
- `Problem classification`
- `Priority`
- `Confidence`

## Shortlist to confirm

## Question

Guardrails:
- Do not recommend fixes or repo changes yet.
- Do not produce generic "improve docs" advice.
- Name the exact file or code area when possible.
- If no meaningful wasted motion is visible, say so directly.
- Analyze both user-facing interactions AND internal tool-use patterns. Do not bias toward one dimension.

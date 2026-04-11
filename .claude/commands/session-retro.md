---
description: Analyze the current session for repo-side improvements that would have reduced wasted motion
---

Analyze the current live Claude Code session only.

Treat the visible conversation, tool calls, and files discussed in this session as evidence. If earlier context appears missing due to compaction, say so explicitly and lower confidence rather than inventing explanations.

Your job is analysis only. Do not propose implementation steps, do not edit files, and do not tell the user to change how they prompt. Recommend only repo-side changes such as updates to `CLAUDE.md` or `AGENTS.md`, comments, examples, helper docs, small refactors, or helper scripts.

Use this process:

1. State the session goal.
2. Reconstruct the path the agent took.
3. Identify concrete friction points with evidence from the session.
4. For each friction point, explain why the detour made sense at the time.
5. Map each friction point to exactly one primary fix type:
   - `instruction gap`
   - `comment gap`
   - `example gap`
   - `boundary gap`
   - `workflow gap`
6. Rank findings by likely future token or time savings.
7. Return only the 3-5 highest-leverage findings.
8. Stop and ask the user which items to keep, merge, drop, or reprioritize.

Output exactly these sections:

## Session goal

## Path summary

## Top findings

For each finding, include:
- `Observed friction`
- `Why it happened`
- `Recommended repo change`
- `Why this should save tokens`
- `Confidence`

## Shortlist to confirm

## Question

Guardrails:
- Do not produce generic "improve docs" advice.
- Name the exact file or code area when possible.
- If no meaningful wasted motion is visible, say so directly.

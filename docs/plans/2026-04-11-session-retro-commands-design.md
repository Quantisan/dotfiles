# Session Retro Commands Design

## Goal

Add two Claude Code slash commands that improve future agent efficiency from the current session's evidence:

- `/session-retro` analyzes the current live session and identifies repo-side changes that would likely have reduced wasted motion.
- `/session-retro-apply` applies one user-confirmed change at a time.

The design optimizes for repo-side leverage only. It does not ask the user to change how they prompt or collaborate.

## Why This Exists

Claude Code sessions often spend tokens on avoidable discovery:

- repeated file searches
- repeated code reading to infer one boundary or invariant
- dead-end tool use
- bouncing between files to reconstruct one concept
- redundant verification caused by unclear instructions or weak code legibility

The command family should turn that wasted motion into durable repo improvements such as better guidance, comments, examples, small refactors, or helper workflows.

## Design Principles

- Single responsibility at the command boundary
- Analysis first, implementation only after explicit user confirmation
- Evidence over hindsight
- Repo-side fixes only
- Smallest durable change preferred

## Command 1: `/session-retro`

### Responsibility

Analyze the current live session only and produce a shortlist of repo-side improvements.

### Inputs

- The current live conversation context
- Visible tool calls in the current session
- Files discussed or touched in the current session

### Constraints

- No arguments
- No implementation planning
- No code edits
- No advice about changing user prompting behavior
- If earlier context is missing due to compaction, say so explicitly and lower confidence

### Method

1. Summarize the session goal.
2. Reconstruct the path the agent took.
3. Identify concrete friction points with evidence.
4. For each friction point, answer: why did this detour make sense at the time?
5. Map each friction point to exactly one primary repo-side fix type.
6. Rank findings by expected future token or time savings.
7. Stop at a shortlist and ask the user how to steer.

### Fix Types

- `instruction gap`: update `CLAUDE.md`, `AGENTS.md`, or command guidance
- `comment gap`: add or improve code comments
- `example gap`: add a local example, sample command, or focused doc
- `boundary gap`: refactor files, modules, names, or structure to make intent easier to infer
- `workflow gap`: add a helper script, shortcut, or verification command

### Ranking Signals

Prefer findings that:

- repeated within the session
- caused multiple downstream steps
- blocked understanding of an important boundary
- are likely to recur across future tasks

### Output Shape

- `Session goal`
- `Path summary`
- `Top findings`
- `Shortlist to confirm`
- `Question`

Each finding must include:

- `Observed friction`
- `Why it happened`
- `Recommended repo change`
- `Why this should save tokens`
- `Confidence`

### Guardrails

- Limit to 3-5 findings
- Do not produce generic "improve docs" recommendations
- Name the exact file or code area when possible
- If no meaningful wasted motion is visible, say so directly

## Command 2: `/session-retro-apply`

### Responsibility

Apply one user-confirmed retrospective change at a time.

### Inputs

- A free-form user instruction naming one specific confirmed change
- Supporting context from the current conversation, including prior `/session-retro` analysis

### Constraints

- One change per invocation
- If the request is ambiguous or bundles multiple changes, ask the user to narrow it
- Do not silently implement adjacent findings

### Method

1. Restate the single requested change.
2. Identify the exact repo surface involved.
3. Make only that change.
4. Verify the relevant outcome.
5. Summarize what changed and any remaining follow-up.

### Output Shape

- `Requested change`
- `Planned scope`
- `Changes made`
- `Verification`
- `Remaining follow-up`

### Guardrails

- Prefer the smallest durable edit that satisfies the request
- Do not reopen the whole retrospective
- Do not implement multiple items from one vague instruction
- Verify before claiming success

## Example Flow

1. User runs `/session-retro`
2. Agent analyzes the current session and returns a shortlist
3. User discusses, merges, drops, or reprioritizes findings
4. User runs `/session-retro-apply` with one specific confirmed change
5. Agent applies that one change and stops
6. User repeats step 4 as needed

## Non-Goals

- Reading sessions other than the current live session
- Persisting retrospective state outside the current conversation
- Automatically batching multiple confirmed changes
- Producing implementation plans from `/session-retro`

## Recommended Implementation Shape

- `.claude/commands/session-retro.md`
- `.claude/commands/session-retro-apply.md`

Each command should encode its boundary explicitly in the prompt so the interface, not just the wording, preserves SRP.

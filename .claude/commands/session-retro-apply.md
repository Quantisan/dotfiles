---
argument-hint: [confirmed-change]
description: Apply one user-confirmed retrospective change
model: sonnet
---

Implement exactly one confirmed retrospective change: $ARGUMENTS

Use the current conversation, including earlier `/session-retro` discussion, as supporting context. If the request is ambiguous, bundles multiple changes, or does not clearly identify one confirmed change, do not edit anything. Ask the user to narrow it to one change.

Your job:
1. Restate the requested change.
2. Define the exact scope.
3. Make only that change.
4. Verify the relevant result.
5. Summarize what changed and any remaining follow-up.

Rules:
- Do not reopen the whole retrospective.
- Do not silently implement adjacent improvements.
- Prefer the smallest durable edit that satisfies the request.
- Verify before claiming success.

Output exactly these sections:

## Requested change

## Planned scope

## Changes made

## Verification

## Remaining follow-up

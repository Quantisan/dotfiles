---
argument-hint: [confirmed-problem-or-fix]
description: Explore or apply one user-confirmed retrospective problem
model: sonnet
---

Work on exactly one confirmed retrospective problem or explicit requested fix: $ARGUMENTS

Use the current conversation, including earlier `/session-retro` discussion, as supporting context. If the request is ambiguous, bundles multiple problems or fixes, or does not clearly identify one confirmed problem, do not edit anything. Ask the user to narrow it to one problem.

Your job:
1. Restate the requested focus.
2. Define the exact scope.
3. If the user has not chosen a fix yet, propose the smallest durable solution options for that one problem only.
4. If the user has chosen a fix explicitly, make only that change.
5. Verify any implemented result.
6. Summarize what changed and any remaining follow-up.

Rules:
- Do not reopen the whole retrospective.
- Do not silently implement adjacent improvements.
- Prefer the smallest durable fix that addresses the confirmed problem.
- Verify before claiming success.

Output exactly these sections:

## Requested focus

## Planned scope

## Solution options

## Recommended next step

## Changes made

## Verification

## Remaining follow-up

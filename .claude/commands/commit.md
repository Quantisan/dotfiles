---
description: Group unstaged changes into 1–4 logical commits
model: sonnet
---

## Context

- Working tree status: !`git status --short`
- Unstaged diff: !`git diff`
- Recent commits: !`git log --oneline -5`
- Current branch: !`git branch --show-current`

## Your task

Review the unstaged changes and group them into 1 to 4 logical commits, each telling one coherent story. Stage and commit each group in turn, matching the style of recent commits. Leave any changes that don't fit a coherent group unstaged.

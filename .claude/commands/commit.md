---
description: Group pending changes into 1–4 logical commits
allowed-tools: Bash(git add:*), Bash(git commit:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Read
model: sonnet
---

## Context

- Working tree status: !`git status --short`
- Staged diff: !`git diff --cached`
- Unstaged diff: !`git diff`
- Recent commits: !`git log --oneline -5`

## Your task

Review all pending changes (staged and unstaged) and group them into 1 to 4 logical commits, each telling one coherent story. Stage and commit each group in turn, matching the style of recent commits. Leave any changes that don't fit a coherent group unstaged.

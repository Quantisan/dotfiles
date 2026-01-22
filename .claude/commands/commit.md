---
description: Create a commit for staged changes
model: claude-haiku-4-5
---

## Context

- Staged changes: !`git diff --cached`
- Recent commits: !`git log --oneline -3`
- Current branch: !`git branch --show-current`

## Your task

Create a commit with the changes already staged. Do NOT add any unstaged files.

Match the commit style of recent commits. Use a concise Conventional Commits title. Description should capture user intent and decisions relevant only to staged changes—exclude unrelated conversation. Be minimal and direct.

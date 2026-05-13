---
argument-hint: [base-branch]
description: Draft a concise PR for the current branch and create it as draft
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git symbolic-ref:*), Bash(git push:*), Bash(gh pr list:*), Bash(gh pr create:*), Bash(gh pr view:*)
model: sonnet
---

## Context

- Current branch: !`git branch --show-current`
- Working tree status: !`git status --short`
- Recent commits on branch: !`git log --oneline -20`
- Recent merged PRs (style reference): !`gh pr list --state merged --limit 10`

## Your task

Draft a pull request for the current branch and create it as draft.

Resolve the base branch: use $ARGUMENTS if non-empty; otherwise read `git symbolic-ref refs/remotes/origin/HEAD` and take the short name (fall back to `main`).

Inspect the branch against the resolved base with `git log <base>..HEAD --oneline` and `git diff <base>...HEAD --stat`.

Write a concise title that states the technical change and purpose. Write the body as 2–5 short bullet points — each one simple, direct, and standalone. Cover what changed, why it matters, and at most one key tradeoff. No prose paragraphs. Match the title style of the recent merged PRs above; if that list is empty, match the style of the recent commits on the branch.

Push the branch if needed (`git push -u origin HEAD`), then `gh pr create --draft --base <base> --title <title> --body <body>`, then `gh pr view --web`.

If any `gh` step fails, return the prepared title, body, base, and the exact `gh pr create --draft …` command for manual run. Be direct. Lead with the technical change before commentary.

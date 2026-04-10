---
name: create-commit
description: Use when the user wants Codex to create a git commit from already-staged changes without staging anything else, especially when the message should match recent repo history and stay concise.
---

# Create Commit

Create a commit from the current staged changes only.

## Inputs

- No arguments are required.
- Accept optional user guidance about emphasis or wording.

## Workflow

1. Inspect only the staged diff, the current branch, and a few recent commits:
   - `git diff --cached`
   - `git branch --show-current`
   - `git log --oneline -3`
2. If nothing is staged, stop and say so. Do not guess.
3. Infer the commit intent from the staged changes only. Ignore unstaged and untracked files.
4. Draft a concise Conventional Commit title that matches the repo's recent style.
5. Add a body only when it captures intent or a key decision that belongs in history.
6. Create the commit. Do not run `git add`.

## Guardrails

- Never stage files.
- Never include unstaged or unrelated work.
- Never mention conversation context that is not reflected in the staged diff.
- Keep the wording minimal and direct.
- If commit creation fails, report the failure and stop.

## Final Response

Return the commit hash and final commit subject. If a body was used, summarize it briefly instead of reprinting a long message.

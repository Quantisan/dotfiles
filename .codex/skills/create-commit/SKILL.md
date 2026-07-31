---
name: create-commit
description: Use when the user wants Codex to organize and commit pending Git changes, including mixed staged, unstaged, or relevant untracked work.
---

# Create Commits

Review all pending changes and create one to four logical commits, each telling one coherent story.

## Inputs

- No arguments are required.
- Accept optional user guidance about emphasis or wording.

## Workflow

1. Inspect the complete pending state and recent commit style:
   - `git status --short`
   - `git diff --cached`
   - `git diff`
   - `git log --oneline -5`
   Use the status output to identify untracked files, then inspect the contents of untracked files that may belong to the pending work.
2. If there are no staged changes, unstaged changes, or relevant untracked files, stop and report that there is nothing to commit.
3. Partition the pending work into one to four coherent groups. Treat the current staging state as input, not as a commit boundary: related staged, unstaged, and untracked changes belong in the same group. Leave any change that does not fit a coherent group unstaged. Never combine unrelated work merely to stay within the four-commit limit.
4. Prepare and commit each group in turn:
   - If pre-staged changes span groups, unstage them only as needed without changing working-tree contents.
   - Stage only the paths or hunks in the current group. Use patch staging when one file contains changes for different groups.
   - Review `git diff --cached` and `git status --short` to confirm that the index contains exactly the current group.
   - Write a concise message matching the style of the five recent commits. Use Conventional Commits only when that matches the repository's recent style.
   - Commit the group, then repeat for the next group, up to four commits.
5. Re-run `git status --short` when finished to identify work intentionally left unstaged.

## Guardrails

- Never discard or overwrite working-tree changes while reorganizing the index.
- Do not broadly stage all changes when the pending work contains unrelated files.
- Do not amend an existing commit unless the user explicitly asks.
- Never mention conversation context that is not reflected in the staged diff.
- If staging or commit creation fails, stop immediately, report the failure and current status, and do not continue with later groups.

## Final Response

List each created commit by short hash and subject. Briefly report any changes left unstaged or untracked; if no commits were needed, say so directly.

---
name: create-commit
description: Use when the user wants to organize and commit pending Git changes, including staged, unstaged, or relevant untracked work.
---

# Create Commits

Organize pending Git changes into logical commits—each telling one coherent story and preserving the domain "why" from the session before it is lost. Aim for roughly 1–4 commits as a granularity guideline: avoid piecemeal micro-commits, and never lump unrelated changes together just to hit a count. Honor any user guidance about scope, emphasis, or wording.

## Workflow

1. Inspect the pending state and recent commit style:
   - `git status --short`
   - `git diff --cached`
   - `git diff`
   - `git log --no-merges --oneline -10`
2. Determine commit scope (unless user guidance specifies otherwise):
   - **If changes are already staged:** treat the staged changes as what to commit, and leave originally unstaged and untracked files untouched. Still split the staged changes into multiple commits if they represent distinct stories.
   - **If nothing is staged:** consider all unstaged changes plus relevant untracked files (inspect untracked file contents before including them).
   - If nothing is in scope, stop and report that there is nothing to commit.
3. Partition the in-scope changes into coherent groups (typically 1–4). Leave out anything that does not fit a coherent group—especially questionable, unrelated, temporary/scratch, or sensitive untracked files (e.g., secrets, local `.env` files).
4. Prepare and commit each group in turn, without pausing for confirmation:
   - When splitting pre-staged changes across groups, unstage only as needed to isolate the current group without altering working-tree contents, and only re-stage changes from the original staged set.
   - Stage only the paths or hunks for the current group. When one file contains unrelated changes, use non-interactive patch staging (e.g., `git apply --cached`) only when hunks are cleanly separable—never use interactive `git add -p`. If hunks are entangled, leave the mixed file unstaged and note it.
   - Verify `git diff --cached` and `git status --short` contain exactly the current group.
   - Write the commit message following `## Commit Messages`, commit the group, and repeat for the remaining groups.
5. Re-run `git status --short` when finished to accurately report anything left unstaged or untracked.

## Commit Messages

The diff already records *what* changed; the commit message is the permanent record of *why*—especially domain context from the session that disappears once the chat ends.

- **Subject:** single concise line matching the style of recent commits; use Conventional Commits only when the repository does.
- **When to include a body:** ask *"What does this session know that a reader looking only at the diff in 6 months wouldn't?"* Include a short body whenever the answer is anything meaningful—even for a 1-line diff. Omit the body when the change is self-explanatory.
- **What to write in the body:**
  - Capture **domain-significant** thought process: the triggering problem, constraints, tradeoffs, and rejected alternatives. Gloss over *what* changed.
  - **Quote key parts verbatim** when session phrasing sharply states a domain rationale or constraint—prefer preserving the original words over flattening them into generic summaries.
  - Ignore session mechanics, tooling/admin back-and-forth, and turn-by-turn narration.
- **Do not include:** invented rationale when no session context exists, references to uncommitted work, or `Co-Authored-By` / agent trailers.

## Guardrails

- Never discard or overwrite working-tree changes while reorganizing the index.
- Do not broadly stage all changes (e.g., `git add -A`) when unrelated, sensitive, or questionable files are present.
- Do not amend an existing commit unless the user explicitly asks.
- Never bypass Git hooks (e.g., `--no-verify`) or delete `.git` lock files. If a commit cannot complete, stop rather than continuing to later groups, verify the Git state, and report the error and current status.

## Final Response

List each created commit by short hash and subject. Briefly report any changes left unstaged or untracked (including mixed files that were not cleanly separable). If no commits were created, say so directly.

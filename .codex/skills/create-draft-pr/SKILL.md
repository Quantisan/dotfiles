---
name: create-draft-pr
description: Use when the user wants to create and open a draft pull request from the current Git branch, with or without an explicit base branch.
---

# Create Draft PR

Create and open a concise draft PR for the current branch, preserving the domain "why", tradeoffs, and reviewer context from the branch commits and session. Invocation authorizes pushing the branch, creating the draft PR, and opening it in the browser—proceed without asking for confirmation. Honor any user guidance about base branch, emphasis, or wording.

## Workflow

1. Resolve the base branch:
   - Use the user-specified base branch if provided.
   - Otherwise run `git symbolic-ref refs/remotes/origin/HEAD` and strip the `refs/remotes/origin/` prefix.
   - Fall back to `main` if resolution fails or returns nothing.
2. Inspect the branch state, commits, diff, and repository PR style:
   - `git branch --show-current`
   - `git status --short`
   - `git log <base>..HEAD`
   - `git diff <base>...HEAD --stat` (inspect targeted hunks with `git diff <base>...HEAD` when commit messages alone do not clarify the change or tradeoffs)
   - `gh pr list --state merged --limit 10` (style reference only; if this fails or returns nothing, fall back to `git log --no-merges --oneline -10` and continue)
   Quote `<base>` safely in base-relative Git commands. If `HEAD` is on `<base>`, detached, or has zero commits ahead of `<base>`, stop and report why no PR can be created.
3. Draft the title and body following `## PR Title and Body`.
4. Push, create, and open without pausing for confirmation, in order:
   - If the branch has no upstream or has local commits not yet pushed, run `git push -u origin HEAD`.
   - Run `gh pr create --draft --base <base> --title <title> --body <body>`, passing multiline body text safely (e.g., via a single-quoted heredoc or `--body-file`).
   - Run `gh pr view --web` as best-effort after `gh pr create` succeeds.

## PR Title and Body

The diff already records *what* changed; the PR summary helps a reviewer quickly grasp *why* it matters, what tradeoffs were made, and where to focus.

- **Title:** single concise technical line stating the change and its purpose. Match the style of recent merged PRs; if unavailable or empty, match recent commits on the repository.
- **Body:** 2–5 short, standalone Markdown bullets—no headings and no prose paragraphs.
  - Lead with the **domain "why"**, triggering problem, key tradeoffs, rejected alternatives, and any context a reviewer needs (drawing from commit bodies and session context). Gloss over file-by-file *what* already obvious from the diff.
  - **Quote key phrases verbatim** when session or commit wording sharply states a domain rationale or constraint.
  - Ignore session mechanics, tooling back-and-forth, and turn-by-turn narration.
- **Do not include:** invented rationale not supported by commits/diff/session, references to uncommitted work as if it were in the PR, or `Co-Authored-By` / agent trailers.

## Guardrails

- Stop if `HEAD` is on `<base>`, detached, or has zero commits ahead of `<base>`.
- Never force-push or rewrite branch history; if `git push` is rejected, stop and report the error.
- Never stage, commit, or discard uncommitted changes; create the PR from committed branch work only.
- Enforce step order: do not run `gh pr create` before a needed push succeeds, and do not run `gh pr view --web` unless `gh pr create` succeeded.

## Final Response

Lead with the technical result and be direct.

- **On success:** report the created draft PR URL and that it was opened in the browser. If `gh pr view --web` failed, still report the created PR URL and briefly note that opening the browser failed.
- **On `gh pr create` failure:** report the error along with the resolved base, drafted title, drafted 2–5 bullet body, and a clean copy-pasteable manual command (safely quoting `<base>` and `<title>`, and using a single-quoted heredoc for the multiline body):
  ```bash
  gh pr create --draft --base <base> --title <title> --body "$(cat <<'EOF'
  <body>
  EOF
  )"
  ```
- **Dirty working tree:** whenever `git status --short` was non-empty, briefly flag the uncommitted or untracked files so nothing is silently left out of the PR.

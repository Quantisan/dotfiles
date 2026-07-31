---
name: create-draft-pr
description: Use when the user asks Codex to create a draft pull request from the current Git branch, with or without an explicit base branch.
---

# Create Draft PR

Create and open a concise draft PR for the current branch. Invocation authorizes push, creation, and view; do not ask for confirmation.

## Resolve the base

- Use the optional invocation argument exactly as the base branch.
- If it is omitted, run `git symbolic-ref refs/remotes/origin/HEAD`, strip the `refs/remotes/origin/` prefix from the result, and use that short branch name.
- If symbolic-ref resolution fails or returns no branch, fall back to `main`.

## Inspect the branch

Run these commands before drafting:

```bash
git branch --show-current
git status --short
git log --oneline -20
git log <base>..HEAD --oneline
git diff <base>...HEAD --stat
gh pr list --state merged --limit 10
```

Replace `<base>` with the resolved branch and safely quote it in the base-relative Git commands.

Match recent merged PR title style. If the list is empty, match recent branch commit style. If `gh pr list` fails, use commit style to prepare the text, then follow the failure contract without push/create/view.

## Prepare the PR

Produce:

1. A concise technical title that states the change and its purpose, matching the selected repository style.
2. A body of exactly 2–5 short Markdown bullets. Each is simple, direct, and standalone. Together they cover what changed, why it matters, and at most one key tradeoff. Use no headings or prose paragraphs.

Prepare an exact, shell-safe manual command containing the resolved values:

```bash
gh pr create --draft --base <base> --title <title> --body <body>
```

Shell-quote each dynamic value as one argument. For Bash-compatible quoting, render the command with `printf '%q'` for the base, title, and multiline body.

## Create and open the PR

Proceed without another confirmation turn, in this order:

1. If the branch has no upstream or has local commits not present upstream, run `git push -u origin HEAD`.
2. Run `gh pr create --draft --base <base> --title <title> --body <body>` with each resolved value passed as one safely quoted argument.
3. Run `gh pr view --web`.

Do not run create before a necessary push, and do not run view before create succeeds.

## Handle `gh` failures

Every failed `gh` operation uses the same result contract:

- If `gh pr list --state merged --limit 10` fails, stop before push/create/view.
- If `gh pr create --draft` fails, stop before view.
- If `gh pr view --web` fails, stop after reporting the view failure.

Lead with the technical result. Return the prepared title, the 2–5-bullet body, the resolved base, and the exact safely shell-quoted `gh pr create --draft` command for manual execution. Be direct.

On success, lead with the technical result and report that the draft PR was created and opened, including its URL when available.

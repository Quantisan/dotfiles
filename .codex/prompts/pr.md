---
description: Generate PR text and create a draft PR for the current branch
argument-hint: [free-form args: base branch, optional plan file, optional phase pointer]
---

Analyze the current branch against a base branch inferred from `$ARGUMENTS` (default: `main`).

If `$ARGUMENTS` includes optional planning context, infer:
- plan file path (for extra context only)
- phase pointer (for example, "Phase 3a")

Treat plan file and phase pointer as internal context only. Never mention them in the PR title or body.

## Argument parsing (heuristic)

Parse `$ARGUMENTS` as a single free-form string and infer:
1. `base_branch`
2. `plan_file` (optional)
3. `phase_pointer` (optional)

Use these heuristics:
- Prefer explicit forms when present: `base <branch>`, `into <branch>`, `against <branch>`, `to <branch>`.
- Consider tokens that match existing local/remote branch names as base-branch candidates.
- Consider existing repo paths ending in `.md`, `.markdown`, or `.txt` as plan-file candidates.
- Consider text after `phase`, `focus`, `for`, or trailing quoted text as phase-pointer candidates.

Confidence rules:
- If there are multiple plausible base branches with no clear winner, mark parsing as ambiguous.
- If there are multiple plausible plan files with no clear winner, mark parsing as ambiguous.
- If not ambiguous and no base branch is found, use `main`.

If parsing is ambiguous, switch to draft-only mode:
- Do not push or create/open a PR.
- Explain the ambiguity briefly.
- Still provide a best-effort PR title and body.

## Draft content

Examine commit titles, descriptions, and diffs to understand what changed and why.

If possible, inspect recent merged PR titles to match this repo's conventions. If not possible, infer style from recent commits.

Generate:
- A concise PR title that states the technical change and purpose.
- A concise 2-4 sentence PR body:
  - sentence 1: what changed
  - sentence 2: why it matters
  - optional sentence 3 or 4: one key decision/tradeoff if needed

Be direct. No filler.

## Auto-create draft PR (unless in draft-only mode)

After generating title/body, do not stop at text generation. Create the actual draft PR.

1. Determine current branch:
   - `git branch --show-current`
2. Check branch state and upstream:
   - `git status --short --branch`
3. If branch has no upstream or is ahead of upstream, push:
   - `git push -u origin <current-branch-name>` (first push)
   - or `git push` (existing upstream)
4. Create draft PR targeting inferred base branch with a heredoc body:
   ```bash
   gh pr create --draft --base <base_branch> --title "<title>" --body "$(cat <<'EOF'
   <body>
   EOF
   )"
   ```
5. Open PR in browser:
   - `gh pr view --web`

If `gh` commands fail at any point (including auth/missing CLI/create failure), switch to draft-only mode:
- Do not continue automation.
- Return the generated title and body so the user can create the PR manually.

## Final response format

If PR creation succeeds:
- Provide title, body, base branch, and PR URL.

If draft-only mode is used:
- Clearly say `Draft-only mode`.
- Provide the reason (ambiguity or `gh` failure).
- Provide title, body, and the exact `gh pr create --draft ...` command to run manually.

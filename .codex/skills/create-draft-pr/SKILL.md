---
name: create-draft-pr
description: Use when the user wants Codex to draft a pull request from the current branch, especially when the base branch must be inferred from free-form input or optional planning context may help shape the PR summary.
---

# Create Draft PR

Draft concise PR text for the current branch and, after confirmation, create the draft PR.

## Inputs

- Accept a single free-form argument string.
- Infer three optional values from that string:
  - `base_branch`
  - `plan_file`
  - `phase_pointer`

Treat `plan_file` and `phase_pointer` as internal context only. Never mention them in the PR title or body.

## Parsing Rules

- Prefer explicit forms such as `base <branch>`, `into <branch>`, `against <branch>`, or `to <branch>`.
- Treat existing branch names as base-branch candidates.
- Treat existing `.md`, `.markdown`, or `.txt` paths as plan-file candidates.
- Treat text after `phase`, `focus`, `for`, or trailing quoted text as a possible phase pointer.
- If there is no clear base branch, default to `main`.
- If multiple plausible base branches or plan files remain, treat the request as ambiguous.

## Workflow

1. Inspect the current branch, branch status, commit history, and diff against the inferred base branch.
2. If practical, inspect recent merged PR titles to match repository conventions. Otherwise infer style from recent commits.
3. Generate:
   - a concise PR title that states the technical change and purpose
   - a concise 2-4 sentence PR body covering what changed, why it matters, and at most one key tradeoff
4. If parsing is ambiguous, switch to draft-only mode and stop automation.
5. Otherwise, present the prepared title, body, and inferred base branch, then ask for confirmation before any network action.
6. Only after confirmation:
   - push the branch if needed
   - create a draft PR with `gh pr create --draft`
   - open it with `gh pr view --web`
7. If any `gh` step fails, fall back to draft-only mode and return the prepared text plus the exact command to run manually.

## Guardrails

- Be direct. No filler.
- Keep planning context private.
- Do not push or create a PR before explicit confirmation.
- If ambiguity remains, prefer draft-only mode over guessing.

## Final Response

- If PR creation succeeds: return the title, body, base branch, and PR URL.
- If draft-only mode is used: say why, then return the title, body, and exact manual `gh pr create --draft ...` command.

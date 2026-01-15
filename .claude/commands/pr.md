---
model: claude-sonnet-4-5
---

Analyze the current branch against `$1` (default: `main`) to generate a PR title and description. If `$2` provided, read that plan file for additional context. If `$3` provided, use it as a pointer to focus on that specific phase within the plan (e.g., "Phase 3a").

Never reference the plan or phase in the generated PR title or description—they are internal context only.

Examine commit titles, descriptions, and diffs to understand what changed and why. Check recent merged PRs to match the repo's title conventions. Generate a title that articulates the technical change and its purpose (e.g., "Add OAuth authentication for secure user access").

Write a concise 2-4 sentence description. First sentence: what specifically changed. Second sentence: what problem it solves or why it matters. Be direct—no filler words, no throat-clearing. If key decisions were made, add one sentence maximum.

**After generating the PR content, execute these steps automatically:**

Don't stop after generating the title and description—create the actual PR.

1. Check if the current branch is pushed to remote: `git status`
2. If not pushed, push it: `git push -u origin <current-branch-name>`
3. Create the draft PR targeting the base branch from `$1`:
   ```bash
   gh pr create --draft --base <base-branch-from-$1> --title "..." --body "$(cat <<'EOF'
   ...
   EOF
   )"
   ```
4. Open it in browser: `gh pr view --web`
5. Use a HEREDOC for the body to ensure proper formatting (same as commit messages)

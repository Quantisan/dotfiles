Analyze the current branch against `main` (or base branch specified in $ARGUMENTS) to generate a PR title and description.

**Analysis approach:**
- Examine both commit messages and code diffs to understand what changed and why
- Check recent merged PRs to detect title format conventions (conventional commits prefixes or not)
- Assess significance: is this a routine change or something substantial (new feature, breaking change, major refactor, architectural shift)?

**Generate PR content:**

**Title format:**
- Match the repo's existing PR title conventions
- Articulate both the technical change AND its outcome/purpose in the wording
- Examples: "Add OAuth authentication for secure user access", "Refactor cache layer to eliminate race conditions"

**Description (1-2 paragraphs):**
- First paragraph: Lead with technical substance. What specifically changed? What problems does it solve? Be precise about the technical decisions and implementation.
- Second paragraph: Explain why it matters. User impact, business value, or strategic context. Keep it concrete and direct.

**Voice and tone:**
- Simple, direct language overall
- Precise technical terminology where needed
- Engineer-first but accessible to product/research stakeholders
- Straightforward peer communication - no marketing speak, no fluff
- Assume intelligent readers who want clarity

**Collaborative questioning:**
- Default: generate quickly without questions (don't interrupt flow)
- ONLY ask 1-2 targeted questions IF changes are significant AND business context isn't deducible from code alone
- Use multiple-choice format with specific, decision-forcing options
- Questions should help articulate why the change matters beyond what code reveals
- Be conservative - most PRs shouldn't need questions

**After generating the PR content:**
1. Check if the current branch is pushed to remote (use `git status` to check tracking status)
2. If not pushed, push the branch: `git push -u origin <branch-name>`
3. Create a draft PR using the `gh` command:
   ```bash
   gh pr create --draft --web --title "..." --body "..."
   ```
4. The `--web` flag will automatically open the browser to the draft PR for final review
5. Use a HEREDOC for the body to ensure proper formatting (same as commit messages)

Using the preceding /idea discussion, produce an actionable implementation plan for a tech lead to review with the team before implementation. Aim for a 5‑minute read (~750–1000 words; guideline). Be direct and concrete .Incorporate any additional context: '''$ARGUMENTS'''. Ultrathink with DRY, YAGNI, TDD, frequent commits, and CLAUDE.md principles in mind. Write the plan to a file named `{short_descriptive_name}_plan.local.md`, where the short name captures the task.

Balance prescriptiveness: include specifics (e.g. files to touch, sample tech design code, acceptance checks) where risk or ambiguity is high; otherwise keep it concise. Add a brief “first files to read/inspect” shortlist if it helps orientation.

Cover these essentials (natural structure; headings optional):
- Context & decisions: Key decisions (problem, chosen approach, constraints/tradeoffs) from /idea
  discussion.
- System design overview: one concise paragraph on architecture, component boundaries, fit with existing system, and responsibilities.
- Critical patterns: Focused code samples (10–20 lines) for the highest‑risk/novel aspects, each with a brief “why this matters.”
- Implementation path: 3–4 phases; for each, begin with "Phase N: [Goal]" and list files to touch, key decisions, concrete actions, and validation steps where helpful. Library API verification: For any library beyond language/framework core, validate the current API before use (quick web search/docs check) to avoid outdated patterns.
- Open questions: 2–3 decisions to defer that don’t block starting.

Keep it focused, actionable, and respectful of the engineer’s existing context.

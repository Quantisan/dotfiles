Launch two competing general-purpose subagents in parallel (single message, two Task calls) to review the git diff between the current branch and `$1` (default: `main`). If `$2` is provided, include that plan file for context.

Both subagents get the same competitive prompt: they're competing to identify the most severe architectural and design concerns—whoever identifies the most critical principle violations gets promoted. Minor issues and implementation details count AGAINST you. Review against the Design Principles from CLAUDE.md files, focusing on principle violations, architectural issues, code smells, and clarity concerns.

**Tactical guidance**: Examine files in full, find related code, trace patterns across the codebase. Read relevant context files (library docs, architecture docs, etc. referenced from CLAUDE.md) when available. Step back from the diff to understand broader architectural context.

After both complete, synthesize their findings: filter for architectural severity (principle violations only), consolidate overlaps, present top 3-5 ranked issues. Exclude style/formatting, implementation preferences, minor refactorings.

Format each issue as:

**[Principle Violated]**
[One sentence on architectural impact]

Evidence: `file:line` - [brief concrete example from the code]

[One sentence explaining why this violates the principle]

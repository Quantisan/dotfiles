Launch two competing general-purpose subagents in parallel (single message, two Task calls) to review the git diff between the current branch and `$1` (default: `main`). If `$2` is provided, include that plan file for context.

Both subagents get the same competitive prompt: they're competing to identify more legitimate architectural and design concerns—whoever finds more gets promoted. They should review against the Design Principles from CLAUDE.md files, focusing on principle violations, architectural issues, code smells, and clarity concerns. Not implementation issues.

**Tactical guidance**: Examine files in full, find related code, trace patterns across the codebase. Read relevant context files (library docs, architecture docs, etc. referenced from CLAUDE.md) when available. Step back from the diff to understand broader architectural context.

After both complete, synthesize their findings: consolidate overlapping concerns, rank all issues from most to least critical, and note what Design Principle is at stake. Present the ranked list as actionable architectural feedback.

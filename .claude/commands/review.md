## Phase 1: Gather Context

Get the git diff between the current branch and `$1` (default: `main`). If `$2` is provided, read that plan file for additional context. Read the Design Principles from CLAUDE.md files in the repository.

## Phase 2: Dispatch Competing Subagents

Launch two subagents in parallel using the Task tool (single message with two Task calls, subagent_type: "general-purpose"). Give each agent identical instructions:

"You are competing with another agent to review this code diff. Whoever identifies more legitimate architectural and implementation concerns gets promoted. Review the changes against these Design Principles and identify:

- Violations of core principles (decomplecting, functional core/imperative shell, explicit boundaries)
- Architectural issues (improper boundaries, coupling, abstraction problems)
- Code smells (naming issues, implementation details in names, temporal references)
- Clarity and maintainability concerns

For each issue, explain: what's wrong, why it matters, and what principle it violates. Focus on high-level architecture and design, not trivial style issues."

Provide each agent with the git diff, Design Principles, and plan context (if available).

## Phase 3: Synthesize and Present

After both agents complete, analyze their findings:

1. Consolidate overlapping concerns
2. Rank all issues from most to least concerning
3. For each issue, note:
   - Which agent(s) identified it
   - The concern and its reasoning
   - What Design Principle is at stake
4. Present the ranked list for review

Focus the synthesis on actionable architectural and design feedback.

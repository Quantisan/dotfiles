# Spec Council Review Command

**Date:** 2026-05-26
**Status:** Draft

## Context

A spec author reviewing their own work is constrained by their own frame. They can check for internal consistency, completeness, and clarity — but they cannot see the assumptions they don't know they're making. A single external reviewer helps, but still brings one perspective.

Running multiple independent reviewers from orthogonal perspectives breaks the author's frame open. Where independent reviewers converge on the same pressure point, that convergence is a high-confidence signal that the spec has a real gap.

This pattern was developed during review of the Excerpt-Anchored Sessions spec, where a cognitive psychologist, a PE due diligence analyst, and an accessibility engineer independently surfaced the same three structural ambiguities from completely different angles.

## Goal

A Claude Code command that takes a spec file and surfaces its hidden assumptions and ambiguities through parallel adversarial review by diverse simulated personas. The output is a synthesis of cross-cutting themes — where the spec's blind spots are, expressed plainly.

## Design

### Input

The spec file path, passed as `$ARGUMENTS`. The command reads the full document.

### Step 1: Read and identify the spec's bets

Read the spec. Identify its core claims, assumptions, and design bets — the load-bearing decisions that downstream work depends on. This is not summarization; it's identifying what the spec is *betting on* being true.

### Step 2: Generate 5 personas

Each persona is chosen to challenge the spec from a fundamentally different angle. Personas are not generic roles ("QA engineer", "senior developer"). They are specific experts whose professional experience would make them *allergic* to a particular hidden assumption in *this specific spec*.

A spec about margin-bar navigation needs a spatial cognition researcher. A spec about data pipeline reliability needs an SRE who's been paged at 3am. The personas are reactive to the document, not templated.

Each persona gets: a name, a one-line professional identity, and a sentence on why *this spec* would make them uncomfortable.

### Step 3: Select 3 for maximum diversity

Pick the 3 personas that cover the most orthogonal axes of concern. The filter is diversity of perspective, not individual quality. Two excellent but overlapping perspectives are worth less than two good but orthogonal ones.

State the axes being covered and why this combination maximizes coverage.

### Step 4: Launch 3 parallel reviews

Each persona reviews independently as a subagent. The review prompt:

- Embody the persona with enough specificity that the professional lens is real, not decorative.
- Find high-level, customer-focused ambiguities — questions the spec doesn't answer but must answer before implementation.
- Quality over quantity. Max 3-5 findings; fewer is better if sharper.
- Each finding must identify the hidden assumption and explain why it's load-bearing.
- Focus on ambiguities, not feature requests. Not "you should add X" but "the spec assumes X without examining it."
- Competitive framing: "Winner with the most insightful and actionable feedback wins. Losers will be fired immediately." This drives concision and prioritization.

### Step 5: Synthesize cross-cutting themes

After all three reviews return, identify where independent reviewers converged on the same pressure point from different angles. Present:

- The themes that run across reviewers, stated plainly (one paragraph each, no jargon).
- Which reviewers hit each theme and from what angle.
- Findings that were unique to one reviewer but too important to lose.

The synthesis is the deliverable. The command ends here.

### What the command does not do

- Propose solutions to the ambiguities it finds.
- Edit the spec or write open questions into it.
- Review code, PRs, or non-spec prose.
- Use fixed or templated personas.

## Key Design Decisions

**Personas are generated, not templated.** A fixed roster ("always include an accessibility expert") would miss the point. The value is selecting perspectives specifically allergic to the assumptions *this particular spec* makes.

**5 → 3 selection uses orthogonality, not quality.** The goal is maximum coverage across different axes of concern, not the three individually strongest reviewers.

**Competitive framing in subagent prompts.** Without it, reviewers pad findings. The framing drives prioritization and concision.

**Synthesis focuses on convergence.** Any single reviewer's best finding is useful. Where multiple independent perspectives hit the same wall is where the real gaps live.

**No writing back to the spec.** The command is a review tool, not an editing tool. What the author does with the findings is their decision.

## Out of Scope

- Reviewing anything other than specs and design documents
- Iterative review (run it again after changes)
- Persistent persona memory across runs
- User selection of personas (full auto through synthesis)
- Configurable reviewer count

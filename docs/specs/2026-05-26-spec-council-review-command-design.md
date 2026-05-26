# Spec Council Review Command

**Date:** 2026-05-26
**Status:** Draft

## Context

A spec author reviewing their own work is constrained by their own frame. They can check for internal consistency, completeness, and clarity — but they cannot see the assumptions they don't know they're making. A single external reviewer helps, but still brings one perspective.

Running multiple reviewers from structurally different perspectives surfaces more concerns than any single reviewer. Where reviewers converge on the same pressure point despite different review lenses, that convergence is a useful prioritization signal — stronger than any individual finding, though not equivalent to triangulation by genuinely independent experts. All reviewers share a model substrate, so convergence is a heuristic, not a proof.

This pattern was developed during review of the Excerpt-Anchored Sessions spec, where a cognitive psychologist, a PE due diligence analyst, and an accessibility engineer independently surfaced the same three structural ambiguities from completely different angles. The command uses structural diversity techniques (different review tasks, different priming context) to push simulated reviewers further apart than persona labels alone would achieve.

## Goal

A Claude Code command that takes a spec file and surfaces its hidden assumptions and ambiguities through parallel adversarial review by diverse simulated personas. The output is a synthesis of cross-cutting themes — where the spec's blind spots are, expressed plainly.

## Design

### Input

The spec file path, passed as `$ARGUMENTS`. The command reads the full document.

### Step 1: Read and identify the spec's bets

Read the spec. Identify its core claims, assumptions, and design bets — the load-bearing decisions that downstream work depends on. For each, ask: "If the assumption proves to be wrong, would it significantly alter the analytic line? How?" (CIA, 2009, p. 9). This is not summarization; it's identifying what the spec is *betting on* being true.

### Step 2: Generate 5 personas

Each persona is chosen to challenge the spec from a fundamentally different angle. Personas are not generic roles ("QA engineer", "senior developer"). They are specific experts whose professional experience would make them *allergic* to a particular hidden assumption in *this specific spec*.

A spec about margin-bar navigation needs a spatial cognition researcher. A spec about data pipeline reliability needs an SRE who's been paged at 3am. The personas are reactive to the document, not templated.

Each persona gets: a name, a one-line professional identity, and a sentence on why *this spec* would make them uncomfortable.

### Step 3: Select 3 for maximum diversity

Pick the 3 personas that maximize cognitive diversity across three axes, following Scott Page's framework from *The Difference* (Princeton, 2007): diversity improves collective judgment only when reviewers differ in how they *represent* problems, not just in their domain labels — "identity diversity is beneficial...only if it is linked to cognitive diversity" (p. 313).

The three selection axes:

- **Stakeholder lens** — who does this reviewer represent? (end user, operator, regulator, attacker). Following the UFMCS Red Team Handbook's principle that the value of multiple perspectives is to "more fully account for how adversaries, coalition partners, and others view the same environment" (UFMCS, 2012, p. 9).
- **Temporal horizon** — when does this reviewer's concern bite? (launch week, year two, sunset).
- **Failure mode type** — what kind of failure do they see? (technical, adoption, economic, compliance).

Two reviewers who share a stakeholder lens are redundant even if their domains differ. The filter is maximum pairwise distance across these axes, not individual quality.

State which axis each selected persona covers and why the combination maximizes coverage.

### Step 4: Launch 3 parallel reviews

Each persona reviews independently as a subagent. Two mechanisms push reviewers toward structural diversity beyond persona labels:

**Different review lenses.** Each reviewer gets a different primary task — not the same instructions with a different name. One hunts for unstated assumptions. One hunts for internal contradictions. One hunts for missing stakeholder impacts. This shifts the model's search space: different questions produce different outputs even from the same substrate.

**Different priming context.** Each reviewer is primed with different context before seeing the spec — a relevant failure mode, an end-user scenario, or an analogous approach from another domain. This gives reviewers genuinely different epistemic starting points.

The review prompt for each:

- Embody the persona with enough specificity that the professional lens is real, not decorative.
- Pursue your assigned review lens — this is your primary task, not a suggestion.
- Quality over quantity. Max 3-5 findings; fewer is better if sharper.
- Each finding must identify a hidden assumption and explain why it's load-bearing, using the criterion from RAND's Assumption-Based Planning (Dewar, 2002): "An assumption is load-bearing if its failure would require significant changes in the organization's plans" (p. 22). Prioritize assumptions that are also *vulnerable* — where "plausible events could cause it to fail within the expected lifetime of the plan" (p. 24). The test: if this assumption proves wrong, does the design collapse or merely bend?
- Focus on ambiguities, not feature requests. Not "you should add X" but "the spec assumes X without examining it."
- Each finding must quote the specific spec text it challenges before stating the finding. No quote, no finding. (See "Evidence-anchored findings" in Key Design Decisions for rationale.)
- Before reviewing, search for established frameworks from your field that apply to this spec's domain. Search for each independently. Each framework you apply must cite a specific source (author, year, title). No citation, no framework. Do not accept the first plausible search result; evaluate whether each retrieved source is relevant to the problem and whether your use of it is supported by what the source actually says. (See "Grounded review lenses" in Key Design Decisions for rationale.)
- Before critiquing, list the specific claims in the spec you would need to verify to assess each finding. This grounds the review in the document's actual content before the reviewer commits to confident-sounding positions (FaR prompting; Qin et al., 2024).
- For each finding, state whether you are confident or whether it requires verification the reviewer cannot perform. Do not drop uncertain-but-important findings — flag them with your reasoning. Uncertainty is signal, not weakness (MetaFaith; Yang et al., 2025).
- Severity tiers constrain output: at most 2 Critical findings (assumption failure would collapse the design), at most 2 Significant (would require meaningful rework), and at most 1 Minor (worth noting). Order by impact within each tier. This structural constraint produces fewer, higher-precision findings more reliably than motivational pressure (Bai et al., 2024).

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

**5 → 3 selection uses cognitive diversity, not quality.** Selection maximizes pairwise distance across three axes — stakeholder lens, temporal horizon, failure mode type — following Page's finding that collective accuracy improves with cognitive diversity, not individual expertise. The goal is coverage, not the three individually strongest reviewers.

**Structural constraints over motivational pressure.** Competitive framing ("losers will be fired") inflates expressed confidence without improving accuracy (Abeysinghe et al., 2025). Instead, severity tiers with count caps produce fewer, higher-precision findings. FaR pre-flight grounds findings in the document's actual claims. MetaFaith uncertainty instruction preserves uncertain-but-important findings that competitive pressure would suppress.

**Structural diversity, not just persona diversity.** Persona labels alone produce shallow variation from a shared model substrate. Different review lenses and different priming context push reviewers into genuinely different regions of the output space.

**Synthesis focuses on convergence as a prioritization heuristic.** Convergence across structurally diverse reviewers is stronger signal than any individual finding, though not equivalent to independent expert triangulation. The synthesis is honest about this distinction.

**Evidence-anchored findings over free-form critique.** Each finding must quote the spec text it challenges before stating the claim. This is the single highest-leverage constraint on output quality. Without it, reviewers produce findings at unpredictable grain sizes — too abstract to act on ("the spec doesn't define its scope") or too granular to evaluate without domain knowledge the author lacks. The quote requirement solves this mechanically: findings are exactly as specific as the text they reference. Three independent lines of evidence support this:

- *Anthropic prompt engineering guidance* (2025): "For long document tasks, ask Claude to quote relevant parts of the documents first before carrying out its task. This helps Claude cut through the noise of the rest of the document's contents."
- *CriticGPT* (Bai et al., 2024): Critics output structured critiques where "quoted sections of the answer are quoted as 'highlights'...that are then followed by comments indicating what errors occur in that highlight." The quote-then-comment structure makes findings locatable and assessable.
- *RULERS* (Hong et al., 2026): Evidence gating enforces that "high scores are mathematically impossible without verifiable grounding." Their ablation found that "without the evidence constraint, the model is prone to hallucinating improvements...thereby undermining the auditability and accuracy of the evaluation."

**Grounded review lenses over generic persona labels.** Each reviewer must search for and cite the established frameworks it applies, not rely on the model's parametric memory of what a given profession "would do." Two independent lines of evidence support this:

- *STORM* (Shao et al., 2024): "The design of STORM is based on two hypotheses: (1) diverse perspectives lead to varied questions; (2) formulating in-depth questions requires iterative research" (§1). Perspective-shaped search queries discover different sources than generic queries because "the specific perspectives can serve as prior knowledge, guiding individuals to ask more in-depth questions" (§3.1). Their ablation confirmed that perspective-guided search discovered more unique sources than the same number of unperspectived queries, producing "outlines with the highest recall" (§5.2).
- *Self-RAG* (Asai et al., 2023): "Indiscriminately retrieving and incorporating a fixed number of retrieved passages, regardless of whether retrieval is necessary, or passages are relevant, diminishes LM versatility or can lead to unhelpful response generation" (§1). Their reflection tokens (IsRel, IsSup) gate retrieval on two explicit decisions: is this passage relevant to the problem, and is my output actually supported by this passage. Adaptive retrieval with these gates outperformed both always-retrieve (41.8 → 45.5 EM on PopQA) and never-retrieve baselines (§5.1).

**No writing back to the spec.** The command is a review tool, not an editing tool. What the author does with the findings is their decision.

## Out of Scope

- Reviewing anything other than specs and design documents
- Iterative review (run it again after changes)
- Persistent persona memory across runs
- User selection of personas (full auto through synthesis)
- Configurable reviewer count

## References

- Dewar, J. A. (2002). *Assumption-Based Planning: A Tool for Reducing Avoidable Surprises.* Cambridge University Press. RAND Corporation. — Defines "load-bearing" and "vulnerable" assumptions as the two axes for identifying which assumptions demand attention in any plan.
- Page, S. E. (2007). *The Difference: How the Power of Diversity Creates Better Groups, Firms, Schools, and Societies.* Princeton University Press. — Defines cognitive diversity as differences in perspectives, interpretations, heuristics, and predictive models; proves via the Diversity Prediction Theorem that collective accuracy improves with cognitive diversity, not individual ability.
- CIA (2009). *A Tradecraft Primer: Structured Analytic Techniques for Improving Intelligence Analysis.* Center for the Study of Intelligence. — Key Assumptions Check technique: evaluate each assumption by asking "If the assumption proves to be wrong, would it significantly alter the analytic line? How?" (p. 9).
- UFMCS (2012). *Red Team Handbook.* University of Foreign Military and Cultural Studies, US Army. — Red teaming as viewing the environment "from a number of perspectives and through a number of lenses" (p. 9); PMESII-PT as operationalized analysis dimensions.
- Qin, C., et al. (2024). *FaR: Fact-and-Reflection Improves Confidence Calibration of Large Language Models.* arXiv:2402.17124. — Two-step prompting (list relevant facts, then reflect before concluding) reduced Expected Calibration Error by 23.5%; grounds reasoning in document content before commitment.
- Yang, Y., et al. (2025). *MetaFaith: Faithful Natural Language Uncertainty Expression for Large Language Models.* arXiv:2505.24858. — Metacognitive self-reflection on intrinsic confidence before answering improved calibration faithfulness by 61%; prevents dropping uncertain-but-important findings.
- Bai, J., et al. (2024). *LLM Critics Help Catch LLM Bugs.* OpenAI. arXiv:2407.00215. — Critics producing fewer, higher-precision findings outperformed those maximizing coverage; structural output constraints beat motivational framing for review quality.
- Abeysinghe, M., et al. (2025). *Analysis of Threat-Based Manipulation in Large Language Models.* arXiv:2507.21133. — Threat-based prompts increased expressed confidence without improving accuracy across 3,390 responses; competitive framing produces confidence aesthetics, not better signal.
- Anthropic (2025). *Prompting Best Practices: Long Context Prompting.* docs.anthropic.com. — "For long document tasks, ask Claude to quote relevant parts of the documents first before carrying out its task. This helps Claude cut through the noise of the rest of the document's contents."
- Shao, Y., et al. (2024). *Assisting in Writing Wikipedia-like Articles From Scratch with Large Language Models.* arXiv:2402.14207. — Perspective-driven search decomposition: diverse personas generate different search queries, discovering more unique sources than generic questioning; ablation confirms perspective-guided search outperforms equivalent unperspectived search.
- Asai, A., et al. (2023). *Self-RAG: Learning to Retrieve, Generate, and Critique through Self-Reflection.* arXiv:2310.11511. — Reflection tokens (IsRel, IsSup) for on-demand retrieval with explicit relevance and support evaluation; adaptive retrieval outperforms both always-retrieve and never-retrieve baselines.
- Hong, Y., et al. (2026). *RULERS: Rubric-Based Evaluation with Locked and Evidence-Anchored Rubric Scoring.* arXiv:2601.08654. — Evidence gating: "high scores are mathematically impossible without verifiable grounding"; ablation shows removing the evidence constraint causes hallucinated assessments.

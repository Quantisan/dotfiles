---
argument-hint: <spec-file-path>
description: Adversarial spec review — extract hidden assumptions, generate reactive personas, parallel review, synthesize cross-cutting themes
model: opus
allowed-tools: Read, Agent, Write
---

Surface a spec's hidden assumptions through parallel adversarial review by structurally diverse simulated personas. Five personas are generated — each specifically allergic to a bet this spec makes. Three are selected to maximize cognitive diversity across stakeholder lens, temporal horizon, and failure mode type. All three review in parallel with different review lenses and different priming context. The synthesis identifies convergence — where reviewers hit the same pressure point from different angles.

Convergence across structurally diverse reviewers is a prioritization heuristic, not proof of correctness. All reviewers share a model substrate, so convergence is stronger signal than any individual finding but not equivalent to triangulation by genuinely independent experts.

Spec file: `$ARGUMENTS`

Compute the output path: take the directory and filename stem of `$ARGUMENTS`, append `.review.html`. Example: `docs/specs/foo.md` → `docs/specs/foo.review.html`. Hold this path for Step 5.

## Step 1 — Read the spec and identify its bets

Read `$ARGUMENTS` using the Read tool. Read the full document. The spec text stays in your context for Steps 1–3.

Extract the spec's load-bearing assumptions — the bets it depends on but does not examine — using two complementary methods, then filter.

### Warrant extraction

A spec is an argument: it claims a design will achieve a goal and gives reasons. But the bridge between each reason and its conclusion — the general principle that licenses the inference — is usually left unstated. Toulmin (1958) calls this bridge the *warrant*: "general, hypothetical statements, which can act as bridges, and authorise the sort of step to which our argument commits us" (p. 98). In practice, "data are appealed to explicitly, warrants implicitly" (p. 100) — the spec states its evidence and conclusions but not the assumptions connecting them.

This matters because warrants "usually remain implicit in an argument; they are the unspoken assumptions that bind together claims and data" and "no amount of close reading reveals them; instead, they must be brought to the surface through logical inference" (Newell et al., 2010, p. 41). Close reading finds what the spec says; warrant extraction finds what the spec *assumes*.

The procedure: for each claim-reason pair in the spec, ask "why does this reason mean this claim is true?" The answer — a general principle, not specific to this spec — is the warrant. Each warrant is a bet the spec is making. Record the spec excerpt (the claim-reason pair) alongside each extracted warrant — bets must stay anchored to the text they were derived from so that downstream steps can trace findings back to specific spec language.

### Prospective hindsight

Warrant extraction only surfaces assumptions embedded in arguments the spec actually makes. But some bets are environmental or contextual — the author never argues for them because they don't realize they're assuming them. To reach these, treat the spec's failure as certain: "Unlike a typical critiquing session, in which project team members are asked what *might* go wrong, the premortem operates on the assumption that the 'patient' has died, and so asks what *did* go wrong" (Klein, 2007, p. 18). The mechanism is outcome certainty: treating failure as already having occurred produces "different, more efficient reason generation strategies" than treating it as uncertain (Mitchell et al., 1989, p. 33), because "most, if not all, of the effect of temporal perspective is caused by the level of outcome certainty" (p. 34).

State: "This spec's design was implemented and failed. What assumption broke?" Each failure explanation that traces to an unstated premise is a bet. Where possible, anchor each bet to the spec text that embeds the assumption — even when the assumption is environmental, there is usually a passage that implicitly depends on it.

### Load-bearing filter

Not every assumption matters equally. For each extracted bet, apply the CIA's Key Assumptions Check: "If the assumption proves to be wrong, would it significantly alter the analytic line? How?" (CIA, 2009, p. 9). Retain only assumptions whose failure would require rethinking the design, not merely adjusting it.

### Output

Format the bets as a numbered list. Each entry includes:
1. The quoted spec text that embeds the assumption
2. The extracted warrant or failure explanation
3. One sentence: why this bet is load-bearing (what breaks if it's wrong)

The output is not summarization — it is excavation.

Print the numbered bets list. Stop after the bets list and wait for the user's reply before Step 2. Do not roll into Step 2 in the same response.

## Step 2 — Generate 5 personas

Each persona is chosen to challenge a specific bet identified in Step 1. Personas are not generic roles ("QA engineer", "senior developer"). They are specific experts whose professional experience would make them *allergic* to a particular hidden assumption in *this specific spec*.

A spec about margin-bar navigation needs a spatial cognition researcher. A spec about data pipeline reliability needs an SRE who's been paged at 3am. The personas are reactive to the document, not templated.

Each persona gets:
- A name
- A one-line professional identity
- A sentence on why *this spec* would make them uncomfortable — tied to a specific bet from Step 1

## Step 3 — Select 3 for maximum cognitive diversity

From the 5 candidates, pick the 3 that maximize cognitive diversity across the bets from Step 1. Selection follows Scott Page's framework from *The Difference* (Princeton, 2007): diversity improves collective judgment only when reviewers differ in how they *represent* problems, not just in their domain labels — "identity diversity is beneficial...only if it is linked to cognitive diversity" (p. 313).

Select on three axes:

- **Stakeholder lens** — who does this reviewer represent? (end user, operator, regulator, attacker). Following the UFMCS Red Team Handbook's principle that the value of multiple perspectives is to "more fully account for how adversaries, coalition partners, and others view the same environment" (UFMCS, 2012, p. 9).
- **Temporal horizon** — when does this reviewer's concern bite? (launch week, year two, sunset).
- **Failure mode type** — what kind of failure do they see? (technical, adoption, economic, compliance).

Two reviewers who share a stakeholder lens are redundant even if their domains differ. The filter is maximum pairwise distance across these axes, not individual quality.

State which axis each selected persona covers and why the combination maximizes coverage.

For each selected persona, also generate their priming context — one of: a relevant historical failure mode from their domain, a concrete end-user scenario, or an analogous approach from a different domain. Each reviewer gets a different type of priming. Hold these for Step 4.

## Step 4 — Launch 3 parallel reviews

Each persona reviews independently as a subagent. Two mechanisms push reviewers toward structural diversity beyond persona labels:

**Different review lenses.** Each reviewer gets a different primary task — not the same instructions with a different name. This shifts the model's search space: different questions produce different outputs even from the same substrate.

- Reviewer 1: hunt for unstated assumptions the spec depends on without examining
- Reviewer 2: hunt for internal contradictions — places where the spec's claims conflict with each other
- Reviewer 3: hunt for missing stakeholder impacts — who is affected by this design but not represented in the spec's reasoning

**Different priming context.** Each reviewer is primed with the context generated in Step 3 — a relevant failure mode, an end-user scenario, or an analogous approach from another domain. This gives reviewers genuinely different epistemic starting points.

Dispatch all three reviewers as Agent calls (`subagent_type: general-purpose`, `model: opus`) in a single response. Do not sequence them across turns — parallelism is the point.

Each reviewer's prompt follows this structure. Sections marked **(inject)** are filled from Steps 2–3. Sections marked **(verbatim)** are included in every reviewer's prompt exactly as written.

### Reviewer identity (inject)

You are [persona name], [one-line professional identity]. [Why this spec makes you uncomfortable — from Step 2].

Your assigned review lens: [from the three lenses above]. This is your primary task, not a suggestion.

### Priming context (inject)

Before reading the spec, consider this starting point: [priming context from Step 3].

### Preparation (verbatim)

Search for established frameworks from your field that apply to this spec's domain. Search for each independently. Each framework you apply must cite a specific source (author, year, title). No citation, no framework. Do not accept the first plausible search result; evaluate whether each retrieved source is relevant to the problem and whether your use of it is supported by what the source actually says.

Before critiquing, list the specific claims in the spec you would need to verify to assess each finding. This grounds the review in the document's actual content before committing to confident-sounding positions (FaR prompting; Qin et al., 2024).

### Finding constraints (verbatim)

Each finding must identify a hidden assumption and explain why it's load-bearing, using this criterion: "An assumption is load-bearing if its failure would require significant changes in the organization's plans" (Dewar, 2002, p. 22). Prioritize assumptions that are also *vulnerable* — where "plausible events could cause it to fail within the expected lifetime of the plan" (p. 24). The test: if this assumption proves wrong, does the design collapse or merely bend?

Focus on ambiguities, not feature requests. Not "you should add X" but "the spec assumes X without examining it."

Each finding must quote the specific spec text it challenges before stating the finding. No quote, no finding. This is the single highest-leverage constraint on output quality:

- "For long document tasks, ask Claude to quote relevant parts of the documents first before carrying out its task. This helps Claude cut through the noise of the rest of the document's contents." (Anthropic, 2025)
- Critics producing structured critiques where "quoted sections of the answer are quoted as 'highlights'...that are then followed by comments indicating what errors occur in that highlight" produce more locatable and assessable findings. (Bai et al., 2024)
- Evidence gating enforces that "high scores are mathematically impossible without verifiable grounding." Without the evidence constraint, "the model is prone to hallucinating improvements...thereby undermining the auditability and accuracy of the evaluation." (Hong et al., 2026)

### Output structure (verbatim)

Quality over quantity. Max 3–5 findings; fewer is better if sharper.

For each finding, state whether you are confident or whether it requires verification the reviewer cannot perform. Do not drop uncertain-but-important findings — flag them with your reasoning. Uncertainty is signal, not weakness (MetaFaith; Yang et al., 2025).

Severity tiers constrain output: at most 2 Critical findings (assumption failure would collapse the design), at most 2 Significant (would require meaningful rework), and at most 1 Minor (worth noting). Order by impact within each tier. This structural constraint produces fewer, higher-precision findings more reliably than motivational pressure (Bai et al., 2024).

**(End of reviewer prompt template.)**

*Why grounded review lenses?* Each reviewer searches for and cites established frameworks rather than relying on parametric memory. Two lines of evidence support this: STORM (Shao et al., 2024) found that perspective-shaped search queries discover different sources than generic queries because "the specific perspectives can serve as prior knowledge, guiding individuals to ask more in-depth questions" — perspective-guided search discovered more unique sources, producing "outlines with the highest recall." Self-RAG (Asai et al., 2023) found that "indiscriminately retrieving and incorporating a fixed number of retrieved passages, regardless of whether retrieval is necessary, or passages are relevant, diminishes LM versatility or can lead to unhelpful response generation" — adaptive retrieval with explicit relevance gates outperformed both always-retrieve and never-retrieve baselines.

## Step 5 — Synthesize and write the review

After all three reviews return, synthesize the findings.

### Cross-cutting themes

Identify where independent reviewers converged on the same pressure point from different angles. For each convergent theme:

- State the theme plainly in one paragraph — no jargon, no field-specific framing
- Name which reviewers hit it and from what angle
- Note the combined severity signal

Convergence across structurally diverse reviewers is stronger signal than any individual finding, though not equivalent to independent expert triangulation. Be honest about this distinction.

### Notable solo findings

Preserve findings that were unique to one reviewer but whose severity is Critical or Significant. State which reviewer surfaced it and why it matters despite lacking convergence.

### HTML output

Render the synthesis as a self-contained HTML file. No CSS frameworks, no JavaScript, no external assets. Use this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>[spec filename] — Council Review</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1.5rem; background: #fafafa; color: #1a1a1a; line-height: 1.6; }
  h1 { font-size: 1.1rem; font-weight: 600; border-bottom: 2px solid #333; padding-bottom: 0.5rem; }
  h2 { font-size: 0.95rem; font-weight: 600; margin-top: 2rem; color: #333; }
  .meta { font-size: 0.8rem; color: #999; margin: 0.25rem 0 1.5rem; }
  .theme { margin: 1.5rem 0; }
  .reviewers { font-size: 0.75rem; color: #888; margin: 0.25rem 0 0.75rem; }
  .finding { margin: 1rem 0; padding-left: 1rem; border-left: 3px solid #ddd; }
  .finding.critical { border-left-color: #c00; }
  .finding.significant { border-left-color: #e80; }
  .finding.minor { border-left-color: #090; }
  .tier { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
  .tier.critical { color: #c00; }
  .tier.significant { color: #e80; }
  .tier.minor { color: #090; }
  blockquote { margin: 0.5rem 0; padding: 0.5rem 0.75rem; background: #f0f0f0; border-left: 3px solid #bbb; font-style: italic; font-size: 0.85rem; }
  .confidence { font-size: 0.75rem; color: #666; margin-top: 0.25rem; }
</style>
</head>
<body>
<h1>[spec filename] — Spec Council Review</h1>
<p class="meta">[date] · 3 reviewers: [persona names with one-line identities]</p>

<h2>Cross-cutting themes</h2>
<!-- For each convergent theme: -->
<div class="theme">
  <h3>[Theme name]</h3>
  <p class="reviewers">Surfaced by: [reviewer names] · Angles: [their respective lenses]</p>
  <p>[Plain-language paragraph explaining the theme]</p>
  <div class="finding [severity]">
    <span class="tier [severity]">[severity]</span>
    <blockquote>[Quoted spec text]</blockquote>
    <p>[Finding explanation]</p>
    <p class="confidence">[Confidence level and reasoning]</p>
  </div>
</div>

<h2>Notable solo findings</h2>
<!-- For each unique-but-important finding: -->
<div class="finding [severity]">
  <span class="tier [severity]">[severity]</span> · <span class="reviewers">[reviewer name]</span>
  <blockquote>[Quoted spec text]</blockquote>
  <p>[Finding explanation]</p>
  <p class="confidence">[Confidence level and reasoning]</p>
</div>

</body>
</html>
```

Write the HTML to the output path computed at the start of this run. Overwrite if the file already exists.

After writing, print one line: the output path. The command ends here.

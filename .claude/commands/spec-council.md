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

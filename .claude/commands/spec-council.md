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

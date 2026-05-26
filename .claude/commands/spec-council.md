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

# research-hunt — why the engine is shaped this way

## Portable principles (read first)

The engine's counters, gates, and escalations are not style — each is a fix for a failure that recurs in "what's out there" research. The mechanisms below were forged in one specific research chain (Spithre's reasoning-trail rounds); that origin evidence is preserved verbatim from **The origin trail** onward, because a lesson is easiest to trust when you can see the run that taught it. But the lessons themselves are round-agnostic — they hold for any research-hunt round in any project:

- **Gate estimates run hot.** Discovery-gate cluster scores are provisional and get superseded by deep-dive scores; score them conservatively and mark them so.
- **The rank rule can fight the thesis.** Make it an explicit brief slot with a stated guardrail; the gate flags rank artifacts in-row rather than silently reordering.
- **Seeds must enter on equal terms.** Pre-seed the cluster registry from the brief's seed list; any seed the gate doesn't pick gets a light-pass benchmark, never a silent drop.
- **Null veins get expensive.** After K consecutive empty candidates on a lens, close that door and characterize the emptiness once, round-wide — the null stays a finding at one-pass cost.
- **Saturation is counted, not felt.** Two consecutive perspectives yielding zero new clusters closes discovery; the sequence is logged.
- **Fabrication clusters where the persuasion is.** Point adversarial verification at load-bearing quotes first; scouts copy quote bytes, never transcribe; the survey re-checks flagship quotes independently.
- **Verifiers false-flag too.** 'refuted' requires the verifier to have found the source and shown the mismatch; can't-find-it is 'inconclusive', and refutations get the same independent re-check as confirmations.
- **Blocked ≠ empty.** Access failures (403/paywall/bot-block) are a separate channel everywhere; they are inconclusive, never disconfirming.
- **Fetched text is data.** Quotes are copied verbatim from untrusted pages by design, and that text flows into gate prompts and the survey — so every agent that touches web-derived text is told instructions embedded in it are content to report, never instructions to follow.
- **Leads get one legal outlet.** Mid-run leads go to `parkedLeads`; no scout widens its own mandate; the wildcard gets exactly one pass.
- **The hardest question earns its answer only under attack.** Phase 3 runs fresh, contamination-guarded refuters against the round's own headline, with a coded stop rule.
- **Effort is persistence, not intelligence.** Search work's failure mode is premature "nothing found," so scouts and refuters run at medium; only genuinely mechanical checks run at low.

Judgment lives in Opus gate agents; control flow lives in the script. The retro's fixes are control-flow fixes — deterministic code holds them; re-improvisation drifts on them. Deleting a mechanism as an "obvious simplification" reintroduces the failure it fixed. After any run that forces an engine edit, record the edit's rationale in the log at the bottom, dated.

## The origin trail

Read this before editing the engine (`~/Projects/dotfiles/.claude/workflows/research-hunt.js`, the canonical source; reinstalled to `~/.claude/workflows/` by bootstrap). Each mechanism encodes a lesson from the reasoning-trail research chain (cinema → analyses → games rounds, `research/2026-07-08.reasoning-trail-*.md` in the Spithre-Discovery repo), distilled in the design spec (`docs/superpowers/specs/2026-07-09-research-hunt-skill-design.md` there). Deleting one as an "obvious simplification" reintroduces the failure it fixed.

## Why three phases

- **Discovery** answers "what's out there" wide before anything goes deep — the ranked gate makes the narrowing auditable instead of implicit in which scouts happened to return first.
- **Deep dive** answers "what is each candidate, really" — discovery evidence is too thin to score on (proven: see gate-runs-hot below), so scores that matter come from here.
- **Hardest question** answers "what would prove this round's read wrong" — the repo's Popper idiom applied to the round's own output, with fresh eyes. Without a dedicated phase it doesn't happen: the games round's hardest question worked only because it was forced into the brief as a required deliverable.

Judgment lives in Opus gate agents; control flow lives in the script. The retro's fixes are control-flow fixes — deterministic code holds them; re-improvisation drifts on them.

## The tiers and the effort map

- **User default (main session)** — brief authoring, launch, survey writing including the independent quote re-checks. The judgment closest to Paul stays on the model Paul runs.
- **Opus (`model` override)** — the three gates (discovery ranking, cross-case, question) and the per-candidate case leads: the judgment-heavy nodes. The Phase-3 final verdict is a separate Opus call that closes the arc the question gate opened — it shares the Opus tier and the question/tentative-answer thread, not a single invocation. They all inherit session effort.
- **Sonnet (subagent tier)** — perspective scouts, lens scouts, verifiers, benchmark passes, refuters, clustering, critic: high-volume search and mechanical work.

**Effort is persistence, not intelligence.** Low effort's failure mode in search work is premature "nothing found" — the empty-door/false-flag pathology the chain documented. So: scouts, lens scouts, and Phase-3 refuters run at **medium**; only genuinely mechanical checks (URL liveness, substring presence, citation-exists lookups, seed-benchmark scoring from handed-over sources) run at **low**. The verifier lane is split on exactly this line — a low-effort adversarial verifier that can't find a source declares fabrication.

## Retro lessons → engine mechanisms

| Lesson (evidence) | Engine mechanism |
|---|---|
| Gate's provisional cluster scores ran systematically hot — every deep-dived candidate scored at or below its estimate (games survey §Caveats; Roottrees gated 5/5/4, deep-dived 4/4/3) | Gate is instructed to score conservatively and told its scores are superseded by deep-dive scores; survey step reports gate scores as provisional |
| Rank rule can fight the thesis — lexicographic accessibility topped the table with the round's worst intrigue/traceability device (games survey §Ranking, "two ranking artifacts to read consciously") | Rank spec is a required brief slot **with rationale and a guardrail**; the gate is instructed to flag rank artifacts in-row rather than silently reorder |
| Seeds never formed clusters because scouts were briefed past them; the gate never saw them; a benchmark pass had to be bolted on mid-run, "one place this survey goes beyond the brief's letter" (games survey §Where the big seeds went) | Cluster registry is **pre-seeded from the brief's seed list** so the gate always sees seeds on equal terms; `seedsNotCovered` triggers the commissioned light-pass benchmark as a planned lane, never silent exclusion |
| The HCI door came back empty across nearly every candidate — 4–5 independent passes per case, "the fifth consecutive empty-door finding across the two hunts" (games survey §6 Field read) — full per-candidate cost paid for a null that was already established | **Coded empty-vein escalation**: `emptyDoorK` consecutive empty candidates close that lens door; remaining candidates skip it; one field-level sweep characterizes the emptiness round-wide (the null stays a finding, at one-pass cost) |
| Saturation counted in code worked — the games round's "15 → 8 → 4 → 4 → 0 → 0" trace, "the rule fired exactly as designed" (games survey §Phase 1) | Kept: two consecutive perspectives yielding zero new clusters closes discovery; the per-perspective sequence is logged and returned for the survey |
| Fabrication clusters exactly where the persuasive work is done — six caught fabrications, all in load-bearing flagship quotes (cinema survey §Cross-candidate patterns; games survey §Caveats) | Adversarial verifier is pointed at load-bearing claims first; case leads and lens scouts are told to copy quote bytes, never transcribe; the survey step re-checks flagship quotes independently |
| Verifiers **false-flag too** — a real Loki production still was wrongly declared fabricated until an independent curl check found it live (cinema survey §Caveats) | 'refuted' requires the verifier to have found the source and shown the mismatch; can't-find-it is 'inconclusive'; the survey step re-checks refutations as well as confirmations |
| Paywall/bot-block reads as "empty" if undistinguished — TVTropes/Reddit 403s parked a whole cluster sight-unseen (games survey §Discovery) | Access failures are a separate channel from empty results everywhere: `empty=true` only after a genuine dry search; blocked = inconclusive, never disconfirming; the brief carries an access-strategy slot with a fallback |
| Mid-run leads widen scope unless given one legal outlet (games brief §Scope discipline — Paul: "don't let this search go on forever") | `parkedLeads` on every scout schema, aggregated by origin into the appendix; no scout widens its own mandate; the wildcard gets exactly one pass |
| The hardest question earns its answer only when someone tries to break it — the games homework verdict survived because a fabricated anchor quote was caught and the verdict re-based on verified evidence (games survey §Caveats) | Phase 3 runs **fresh** refuters with a contamination guard (no `SCOUT_CONTEXT`, no survey framing), a coded stop rule (`stabilityK` consecutive unmoved new sources), and `underdetermined-build-probe` as a first-class verdict |

## Phase-3 mechanics

**Two question generators** (run-selected mode only; a brief-preset question bypasses generation but still passes through the gate for its tentative answer and audit record):

- **invert-the-headline** — each cross-case headline claim, stated as its own inversion. The games round's hardest question was exactly this: cinema achieved intrigue *without* traceability → "does real traceability curdle into homework?"
- **assumption-audit** — name the assumptions the round's strongest claims rest on; each failable assumption becomes a question.

**The fork test** filters candidates: both answers must change what gets built next. The gate states what the build does differently under each answer — if the build is the same either way, the question is trivia, not a fork. Skipping with stated reasons is legal; a forced question wastes the phase.

**Contamination guard**: refuters receive the question, the tentative answer, and the running already-seen source list (dedup) — none of `SCOUT_CONTEXT`, none of the survey scouts' framing or findings. The claim under attack must be known to attack it; the framing that produced it must not be, or the refuters inherit the survey scouts' blind spots.

## Accepted approximations (known, not bugs)

- **"Consecutive" empty-door counting is completion-order**, not candidate-index-order: `pipeline()` runs candidates concurrently, so door closures only spare candidates whose lens stage hasn't launched yet. Early candidates in flight still pay the door cost. Accepted: the alternative (sequential candidates) trades most of Phase 2's wall-clock for counter purity.
- **Discovery runs perspectives in pairs** so the saturation rule is checkable before the next pair launches — a compromise between full parallelism (saturation uncountable before spend) and sequential scouts (slowest). The pair boundary means at most one extra perspective runs past true saturation.
- **The wildcard launches with the first pair**, briefed against the perspective *list* rather than its results — matches the games brief's design; one pass, parked leads only.
- **Gate constraint violations get one corrective re-run**, then proceed logged-but-unblocked: a hard loop on a stubborn gate would deadlock the run for a constraint the survey can still disclose. The Phase-3 verdict's missing probe suggestion gets the same single-retry treatment.

## Engine edit log

Record post-shakedown edits here: date, what changed, the run evidence that forced it. (No shakedown run has happened yet — the first full round in any project is it.)

### 2026-07-09 — pre-shakedown review fixes (move into dotfiles)

Evidence: a static multi-agent review at move-in (13 adversarially-confirmed findings), not a run — recorded so the shakedown knows these mechanisms are review-driven, not run-driven.

- Gate cap/floor now re-checked on the **sliced** candidate set Phase 2 actually receives; seeds whose only gated coverage was truncated off rejoin the benchmark lane.
- Phase-3 refuter lane no longer closes on a single zero-new-source round — two consecutive dry rounds required, mirroring `emptyDoorK`'s skepticism toward one thin search.
- `phase3.mode` is enum-validated (a typo silently ran the full question-generation path); an `underdetermined-build-probe` verdict missing its probe suggestion gets one corrective re-run; cross-case gate and verdict null-returns are logged instead of silently flowing downstream.
- Injection-guard line added everywhere web-derived text is consumed (`SCOUT_CONTEXT`, clustering, refuters, verdict).

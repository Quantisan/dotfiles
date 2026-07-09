# Brief contract — required elements

A research-hunt brief is freeform prose: no fixed section order, no invariant text. It must contain three things, and the engine parameters must map one-to-one onto the ARGS CONTRACT block at the top of `~/.claude/workflows/research-hunt.js` — the engine validates them at its boundary, so a mapping gap surfaces at launch, not mid-run.

## 1. The directional prompt, verbatim

Paul's prompt, word for word. It is the round's charter; everything else is derived from it.

## 2. The engine parameters

One per ARGS CONTRACT key (`slug` comes from the brief's filename and `date` from the launch — the launcher supplies both):

- **goal** — `space` (map what's out there) or `fork` (evidence separating two named builds), with the statement of which and why.
- **anchorArtifact** — what is being represented/served; the thing finds are measured against.
- **axes** — each scored axis: key, name, one-line definition.
- **rankSpec** — the rank rule and its rationale. **The guardrail prose is mandatory**: state how the rank function serves the round's thesis, and what ranking artifact to read consciously if the rule can top the table with a weak-on-thesis candidate. This is methodology, not ceremony — the gate flags rank artifacts in-row instead of silently reordering, and it needs this text to do it.
- **clusteringKey** — the unit novelty is counted in (e.g. "borrowed competence"), not titles.
- **scopeRule** — in: function-bounded definition; out: out-of-scope classes, each with its one-line reason.
- **perspectives** — Phase-1 scout angles in run order, one line each; genuinely different search angles. Saturation may close the tail unrun.
- **lenses** — exactly 3 Phase-2 lenses, diverse registers of rigor, one line each.
- **seeds + noveltyFloor** — the seed list, one line each. Seeds are pre-registered as clusters: the gate sees them on equal terms, and any seed it doesn't gate gets the light-pass benchmark, never silent exclusion. `noveltyFloor` is the minimum fraction of gated candidates from outside the seed list — a number (0.33), never a fraction string.
- **exclusions** — hard exclusions with their pass-over rules.
- **rejectedShelf** — settled prior rejections this round does not reopen, with pointers. The one key the engine treats as optional (an omitted shelf reads as "none") — state an empty shelf explicitly anyway, so the review can tell "nothing settled" from "not considered".
- **accessStrategy** — where the evidence lives, and the fallback when a direct fetch is blocked (site-scoped search, transcript pulls, Wayback).
- **phase3** — mode `preset` (+ the question, verbatim; the engine enforces its presence), `run-selected`, or `skip` (+ the stated reason — the engine doesn't check for one, but a skip without a reason is not reviewable).
- **budgets** — defaults, used unless the prompt says otherwise; never ask about them: `maxGated: 8`, `emptyDoorK: 3`, `stabilityK: 5`, `maxRefuterRounds: 4`, plus `noveltyFloor: 0.33` (its own top-level key, not a `budgets` field). Scout counts are carried by the lists themselves: one scout per perspective, one lens scout per lens per candidate, one wildcard pass — sizing the lists is how scout counts are set.

## 3. The expected cost

The agent-call count the knobs imply, so cost is visible at review time: perspectives + wildcard + ~1 clustering pass per perspective pair + gate + seed benchmark, then 6 per gated candidate (3 lens scouts, case lead, 2 verifiers) + cross-case gate, then question gate + up to `maxRefuterRounds` refuters + verdict, + 1 critic. Defaults land around 40–70 calls; the dominant term is 6 × `maxGated`.

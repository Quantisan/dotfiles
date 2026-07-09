# Launch-brief template

The invariant text of a research-hunt launch brief. `{{double-braced}}` parts are the slots — everything else is written once, here, and repeats verbatim in every brief. The skill fills the slots from the directional prompt (plus narrowing answers), writes the brief to the current project's research location (`{{date}}.{{slug}}-launch-brief.md`), and maps the slots one-to-one onto the engine's `args` contract (`~/.claude/workflows/research-hunt.js`, ARGS CONTRACT block).

Slot-filling rules:

- **Infer before asking.** Most slots are inferable from the directional prompt plus the prior rounds' briefs. Narrowing questions (2–3 max) are only for slots that genuinely cannot be inferred — typically the rank spec's order, the Phase-3 mode, and scope edges.
- **Budget knobs have defaults** — use them unless the prompt says otherwise; never ask about them: `maxGated: 8`, `noveltyFloor: 0.33` (a number, not a fraction string — the engine does arithmetic on it), `emptyDoorK: 3`, `stabilityK: 5`, `maxRefuterRounds: 4`. **Scout counts** are the remaining budget knob and are carried by the lists themselves: one scout per Phase-1 perspective entry, three lens scouts per candidate (one per lens entry), one wildcard pass — sizing the lists is how scout counts are set.
- **The rank-spec guardrail is mandatory prose**, not a formality: state how the rank function serves the round's thesis. A rank rule that would top the table with a weak-on-thesis candidate needs that tension named in the brief.

---

# {{Title: what the round hunts, in one line}} — research-hunt launch brief

**What it is / is not** — The launch record for a research-hunt round: the per-round slots below are the only authored parts; the methodology they parameterize is invariant and lives in the engine (`~/.claude/workflows/research-hunt.js`; its rationale in `~/.claude/skills/research-hunt/reference.md`). This brief feeds the engine verbatim as `args`. It is **NOT** the findings, **NOT** a decision, and **NOT** a spec — it is the input that produces the next findings. If the run was aborted at go/no-go, this record stands anyway.

**Status & authorship** — Materialized {{date}}. Go/no-go: {{`pending` → `go (Paul, date)` or `aborted (reason)` — updated in place at the decision}}. Slot values authored this session from Paul's directional prompt and narrowing answers (trail below); invariant text is the template's. Engine at launch: `research-hunt.js` @ {{git short-hash}}.

**Related artifacts** (prose pointers to prior rounds and the anchor artifact, if any)
- {{Prior rounds this transplants or extends, one line each on the relationship}}
- {{The anchor artifact's home, if it lives in the repo}}

**Reading notation** — {{axis abbreviations and scale, e.g. "scored axes are a/i/t: …, 1–5, lexicographic in that order" — only if the axes carry abbreviations used below}}

## Directional prompt (verbatim)

> {{Paul's prompt, word for word}}

## Slots

**Goal — {{space or fork}}.** {{The goal statement. A *space* round maps what's out there; a *fork* round hunts evidence that separates two named builds. State which and why.}}

**Anchor artifact.** {{What is being represented/served — the thing the round's finds are measured against.}}

**Scored axes.** {{Each axis: key, name, one-line definition.}}

**Rank spec.** {{The rank rule (e.g. lexicographic a → i → t) and its rationale.}} Guardrail: {{how this rank function serves the round's thesis, and what ranking artifact to read consciously if the rule can top the table with a weak-on-thesis candidate}}.

**Clustering key.** {{What raw discovery finds are grouped by — the unit novelty is counted in, e.g. "borrowed competence", not titles.}}

**Scope rule.** In: {{function-bounded in-scope definition}}. Out: {{out-of-scope classes, each with the one-line reason}}.

**Phase-1 perspectives** (run in listed order; saturation may close the tail unrun):
{{- key — one-line scout brief, per perspective; genuinely different search angles}}

**Phase-2 lenses** (exactly 3 — diverse registers of rigor):
{{- key — one-line lens brief, per lens}}

**Seed list.** {{The seeds, one line each.}} Novelty floor: {{fraction}} of gated candidates from outside this list. Seeds are pre-registered as clusters — the gate sees them on equal terms, and any seed it doesn't gate gets the light-pass benchmark, never silent exclusion.

**Exclusions.** {{Hard exclusions with their pass-over rules — maps to the engine's `exclusions`.}}

**Rejected shelf.** {{The settled prior rejections this round does not reopen, with pointers — maps to the engine's `rejectedShelf`.}}

**Access strategy.** Evidence lives at: {{primary venues/sources}}. When direct fetch is blocked: {{fallback — site-scoped search, transcript pulls, Wayback}}.

**Phase-3 question.** Mode: {{`preset` (+ the question, verbatim) / `run-selected` / `skip` (+ the stated reason)}}.

**Budget knobs.** maxGated: {{8}}; emptyDoorK: {{3}} (consecutive empty candidates closing a lens door); stabilityK: {{5}} (consecutive unmoved sources closing Phase 3); maxRefuterRounds: {{4}}. Scout counts are set by the perspective and lens lists above (one scout per entry, plus one wildcard pass).

## Provenance trail

### {{date}}
- {{Round directed at … ← Paul, verbatim: the directional prompt (or its operative clause)}}
- {{Each narrowing answer that set a slot ← Paul, in-session call: the selected option's label, quoted verbatim — never a paraphrase}}
- {{Slot values inferred without a steer ← agent synthesis, no source (one consolidated line)}}

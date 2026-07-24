---
name: strategic-artifact
description: Naming, forward header, provenance trail, and lineage map for dated strategic artifacts, in any repo that declares an artifact root. Invoke as /strategic-artifact when creating, saving, renaming, or moving a file under the artifact root.
disable-model-invocation: true
---

# Saving a strategic artifact

The procedure for naming and framing files under a repo's **artifact root** — the folder that holds authored strategic synthesis. Run it whenever you write or rename a file there. Step 0 binds the procedure to the current repo; steps 1–2 apply to every file; steps 3–7 apply only once step 2 says "strategic artifact."

This skill is manual-only: it runs when Paul invokes `/strategic-artifact`, never automatically. The rationale behind the shape is in `reference.md` beside this file — read it only if you need the *why*.

## Step 0 — Resolve the repo binding

The skill is generic; each repo declares its own binding. Look in the repo root `CLAUDE.md` for an **"Anatomy of a strategic artifact"** section. It must declare:

- the **artifact root** (e.g. `product-management/`) — all paths in this skill are relative to it;
- the **lineage generator command** to run in step 5, including any excluded subfolders.

If the current repo has no such declaration, **stop and ask Paul** which folder is the artifact root, then offer to add the declaration to that repo's `CLAUDE.md` before continuing. Do not guess a root.

A repo's anatomy section may also carry always-on must-haves (a condensed form of steps 1–4). Where they conflict, the repo's `CLAUDE.md` wins.

## Step 1 — Name the file

A standalone dated file is `YYYY-MM-DD.<slug>.md` and sorts by date.

When same-date files form a **dependency chain** — one is built from another (e.g. a raw excavation and the minutes distilled from it) — number them in build order so the sort reads as the waterfall. The number is **namespaced under the chain's slug**, not the date:

`YYYY-MM-DD.<chain-slug>.<N>.<step-slug>.md` — numbered upstream-first (the input everything else is produced from is `1`).

Because the number lives inside the chain slug, several independent chains can share one date without colliding — each waterfall sorts together under its own slug:

```
2026-06-04.context-memory.1.excavation.md
2026-06-04.context-memory.2.minutes.md
2026-06-04.citations-provenance-trust.1.excavation.md
2026-06-04.citations-provenance-trust.2.minutes.md
```

A file with no chain (no upstream/downstream sibling) takes no number.

## Step 2 — Gate: is this a strategic artifact?

Header + trail are required for strategic artifacts only.

- **Out of scope** — scratch files and `rk-*` dumps. They get a name (step 1) and **stop here**. No header, no trail.
- **In scope** — authored synthesis: problems, findings, durable strategic documents. Continue to step 3.

If you're unsure, ask before adding the frame — don't bolt a header onto a scratch file.

## Step 3 — Forward header (orientation, looking forward)

So a memory-less later agent reads the artifact right. Open with:

```
# <title>

**What it is / is not** — scope and trust frame        [invariant]
**Status & authorship** — final vs. WIP; what's        [invariant]
                          still `[Paul to author]`
**Related artifacts** — incl. `Builds on:` edge        [if it exists]
**Reading notation** — refs, grading tags, the bar     [your call]
```

The two `[invariant]` slots must appear. The other two appear when they apply. Labels and wording stay flexible — the slots are the obligation, not the phrasing.

**The `Builds on:` edge.** If this artifact was produced from one or more others, the **Related artifacts** block opens with a machine-readable line:

```
**Related artifacts**
- Builds on: `problems/2026-06-18.consolidating-the-foundational-problem.md`, `problems/2026-06-23.problem-statement-templates.md`
- <free prose context — the why, the §sections — optional>
```

(Example paths here use a repo whose artifact root has a `problems/` subfolder; your repo's subfolders may differ.)

Rules:
- **List what this was directly produced from — and only what the file's own body sources.** The edge must be defensible from this artifact's header/prose, not reconstructed from a README narrative or your memory. If the body doesn't say it built on X, don't assert the edge — that's the mis-stated-lineage bug this whole convention exists to prevent.
- **A direct input still counts even if it's also reachable another way.** If this was produced from both X and Y, and Y also feeds X, list both — that overlap is the *convergence* the map exists to show. Only drop an ancestor you didn't directly use (you merely reach it through an edge).
- **Exclude siblings and background reading** — a doc you read alongside, or cite for context, is not an edge. Those stay in the prose bullets.
- **Upstream only, never downstream** — "what feeds off this" is derived by reversing edges when the map is built. Maintaining a `Feeds:` line by hand is the drift trap; don't.
- **Paths relative to the artifact root** — a bare slug is a root-level file; a `<subfolder>/…` prefix is a file under that subfolder. This is what keeps the edge correct after a move.
- This line is the **canonical lineage edge**. The README Lineage map is only a rendered view of it (step 5).

## Step 4 — Provenance trail (lineage, looking back)

So a later *human* can trace why a decision came out this way. Close with:

```
## Provenance trail

### YYYY-MM-DD
- <body anchor> ← <right side>
```

**Gate — the trail records steers, not edits.** An entry earns its line only as one of:

- **a strategic steer** — Paul's call that shaped the artifact: a reframe, an add or drop, an altitude call, a reorder, a scope change.
- **a trust flag** — an agent inference or synthesis a later reader should distrust first. All of one session's synthesis (mappings, enumerations, decompositions) collapses into **one** `agent synthesis, no source` line — never one entry per mapping.

No entry for:
- a claim already cited inline in the body — the body's citation *is* the trail;
- mechanical or corrective work — a move or rename, a spelling, notation, or label correction (even one you verified), link fixes, renumbering. If a renumber shifts item numbers embedded in earlier verbatim quotes, add one reconciliation note to the trail's preamble instead of per-entry keys.

Self-check per entry: *would it survive a prune down to the strategic steers?* If not, don't write it.

- **Left — body anchor.** A few words to Ctrl-F the decision in the body. A findable handle, not a restatement.
- **Right — one of three honest shapes, never a paraphrase:**
  - **openable pointer** — `Calls/…minutes.md §section/timestamp`, a reckon bullet ID, or a dated lived-observation. The reader can open it and re-check.
  - **verbatim steering quote** — when the decision was Paul's in-session call, his words *are* the source; quote them. Only here — a quote dressing an externally-driven decision is laundering.
  - **`agent synthesis, no source`** — when it came from the model's reasoning with nothing under it. The flag *is* the signal: distrust this entry first.
- One line each. No significance labels, no type tags, no considered-options block.
- Never point at the session log — it isn't committed. If the substance lives only in the session, lift it into the trail (quote or no-source marker).
- Later edits **append a new dated entry** — never overwrite; the trail accretes. Pruning an accreted trail happens only at Paul's explicit request — keep the gate-passing entries and open the trail with a one-line note that it was pruned and that the full record lives in git history.

## Step 5 — Rebuild the lineage map

The map in the artifact root's `README.md` is a generated view of every `Builds on:` line — never hand-edit it. Whenever you **add, rename, or move** an artifact, rerun the generator so the view tracks the edges. Run the exact command declared in the repo's anatomy section (step 0); the general form, from the repo root:

```
python3 ~/.claude/skills/strategic-artifact/build-lineage-map.py <artifact-root> [excluded-subfolder ...]
```

It rewrites only the `<!-- lineage:auto -->` block (the hand-written README is untouched), validates every edge, and prints any **dead edges** (a `Builds on:` path that points nowhere). Dead edges mean a fix is needed — resolve before declaring done. If the README has no `lineage:auto` markers yet (a repo's first run), add an empty marker pair to the README where the map should render, then rerun.

**On a move or rename, also fix the *incoming* edges.** Root-relative paths protect a moved file's *own* `Builds on:` lines, but any *other* file that builds on it still names the old path. Grep for the old path and update those `Builds on:` lines, then rerun the generator:

```
grep -rl "<old-relative-path>" <artifact-root> --include=*.md
```

A clean run (0 dead edges) is the signal the move is complete.

## Step 6 — Authoring boundary

You build the scaffold and maintain the trail. You do **not** draft Paul's body — his principle, catalog entries, or core claims. Leave `[Paul to author]` markers where his content goes. A polished draft from you is not his thinking.

## Step 7 — Self-verify

Re-read the file you just wrote and confirm, out loud, in your reply:

- Filename matches `YYYY-MM-DD.<slug>.md`, or `YYYY-MM-DD.<chain-slug>.<N>.<step-slug>.md` for a file in a dependency chain.
- If strategic artifact: both `[invariant]` header slots present; `## Provenance trail` present with at least the relevant decisions.
- Every trail right-side is one of the three shapes — **flag any paraphrase**, it's the most common failure.
- Every trail entry passes the gate — a strategic steer or a trust flag; no entries for inline-cited claims or mechanical/corrective work; at most one consolidated `agent synthesis, no source` line per session.
- If the artifact has direct upstream: a `Builds on:` line is present, names only direct parents, and uses paths relative to the artifact root.
- The generator ran clean — **0 dead edges** — and the README map reflects this file.

Report pass/fail per check. If a check fails, fix it before declaring done. This step is the point of the skill — skipping it reintroduces the silent miss.

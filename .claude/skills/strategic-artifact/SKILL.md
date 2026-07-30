---
name: strategic-artifact
description: Naming, forward header, handoff delta, and lineage map for dated strategic artifacts, in any repo that declares an artifact root. Invoke as /strategic-artifact when creating, saving, renaming, or moving a file under the artifact root.
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
- **A new version of a previous artifact lists that version as a parent.** The preceding version is one `Builds on:` path among possibly several; step 4's baseline preamble names which one.
- **Upstream only, never downstream** — "what feeds off this" is derived by reversing edges when the map is built. Maintaining a `Feeds:` line by hand is the drift trap; don't.
- **Paths relative to the artifact root** — a bare slug is a root-level file; a `<subfolder>/…` prefix is a file under that subfolder. This is what keeps the edge correct after a move.
- This line is the **canonical lineage edge**. The README Lineage map is only a rendered view of it (step 5).

## Step 4 — Handoff delta (version provenance, one edge back)

So a later *agent* can answer provenance questions about this version for a reader who already knows the preceding one. It indexes: what substantive concept was added, changed, or removed; where to compare the two versions; why the change was made; and whether the rationale is an openable source, Paul's direct steer, or unsupported agent synthesis. It does not explain the full idea, replace the artifact body, or preserve a concept's lifetime history.

**Scope.** Only a **versioned artifact** — a new delivered version of a preceding artifact — carries a handoff delta. A standalone artifact has none: its sources stay in the body, its direct inputs in `Builds on:`. Existing artifacts with an accumulating `## Provenance trail` remain valid; don't migrate them.

**Version model.** Each delivered version is a separate file. The new file names its immediate **baseline** — the preceding version — via the `Builds on:` edge (step 3) and contains only the delta from that baseline. A later version builds on this file and carries its own one-step delta; full history stays recoverable by walking the chain, so no artifact repeats or accumulates it. The baseline is exactly one of the `Builds on:` paths; the preamble below distinguishes it from the other direct inputs.

Close the artifact with:

````
## Handoff delta

_Baseline: `path/to/previous-version.md`. Agent-facing. Records only substantive
conceptual changes introduced in this version; the document body is canonical._

- Changed: `v1 §Target customer` → `§Target customer` ← “Focus on teams already attempting this manually.”
- Added: `§Adoption constraint` ← `calls/2026-07-20.aman.md §Adoption`
- Removed: `v1 §Enterprise expansion` ← agent synthesis, no source
````

`v1` is the baseline declared in the preamble; an unqualified `§` anchor is the current artifact. Anchors are exact section titles, unique in their file.

- **Left — a routing label**, one of three. It tells the agent where to retrieve the change — not how important or confident it is:
  - `Added:` points to the current artifact.
  - `Changed:` points from an exact baseline anchor to an exact current anchor.
  - `Removed:` points to an exact baseline anchor.
- **Right — one of three honest shapes, never a paraphrase:**
  - **openable pointer** — an exact repository-relative path with a section or timestamp. The reader can open it and re-check.
  - **verbatim steering quote** — when the decision was Paul's in-session call, his words *are* the source; quote them. Only here — a quote dressing an externally-driven decision is laundering.
  - **`agent synthesis, no source`** — when it came from the model's reasoning with nothing under it. The flag *is* the signal: distrust this entry first.
- Never point at the session log — it isn't committed. If the substance lives only in the session, lift it into the delta (quote or no-source marker).

**Gate — substantive conceptual changes only.** A line earns its place only for a substantive conceptual difference delivered in this version: a reframe, addition, removal, altitude change, scope change, reordering that changes meaning, or other strategically meaningful adjustment. Record the **final adopted rationale** for the delivered change, not the drafting process that preceded it. One line per substantive concept change — never one line per mapping, example, or wording adjustment inside the anchored section.

No entry for:
- unchanged concepts;
- spelling, notation, link, filename, or numbering corrections;
- layout-only reordering;
- intermediate decisions abandoned before delivery;
- a restatement of what is already clear from comparing the two anchored sections.

If nothing passes the gate, retain the section with exactly this state — never invent an entry to satisfy the format:

````
_No substantive conceptual changes from the stated baseline._
````

**Maintenance.** Never append lifetime history, copy the preceding version's delta forward, or preserve superseded drafting decisions. Every internal pointer must resolve before the artifact is complete.

**How a later agent digests it.** Answering a provenance question about this version: (1) read the handoff delta and pick the relevant entry; (2) open the named baseline and current sections; (3) compare them to determine the actual change; (4) follow the right-side source for why it changed; (5) answer only the version delta unless the user explicitly asks for broader history; (6) state plainly when the rationale is `agent synthesis, no source`. The body stays canonical for what a concept currently means — the delta is an index into the comparison and its rationale, not a summary of the concept.

**Terminology.** *Lineage* is reserved for relationships between artifacts (`Builds on:`, the README map). The handoff delta is decision provenance for a single version transition.

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

You scaffold the artifact and record the handoff delta. You do **not** draft Paul's body — his principle, catalog entries, or core claims. Leave `[Paul to author]` markers where his content goes. A polished draft from you is not his thinking.

## Step 7 — Self-verify

Re-read the file you just wrote and confirm, out loud, in your reply:

- Filename matches `YYYY-MM-DD.<slug>.md`, or `YYYY-MM-DD.<chain-slug>.<N>.<step-slug>.md` for a file in a dependency chain.
- If strategic artifact: both `[invariant]` header slots present.
- If the artifact has direct upstream: a `Builds on:` line is present, names only direct parents, and uses paths relative to the artifact root.
- If versioned: `## Handoff delta` present, and its baseline path exists and matches the preceding version named in `Builds on:`. If standalone: no handoff delta.
- Every delta entry is `Added`, `Changed`, or `Removed`, with baseline (`v1 §`) and current (`§`) anchors that exist on the appropriate side of the change.
- Every right side is one of the three shapes — **flag any paraphrase**, it's the most common failure.
- Every entry passes the gate — a substantive delivered change, not a mechanical correction or an abandoned drafting decision; unchanged material is absent. If nothing passed the gate, the explicit no-change state is present.
- Every internal pointer resolves.
- The generator ran clean — **0 dead edges** — and the README map reflects this file.

Report pass/fail per check. If a check fails, fix it before declaring done. This step is the point of the skill — skipping it reintroduces the silent miss.

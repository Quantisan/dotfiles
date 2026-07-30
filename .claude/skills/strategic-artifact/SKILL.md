---
name: strategic-artifact
description: Naming, forward header, provenance delta, and lineage map for dated strategic artifacts, in any repo that declares an artifact root. Invoke as /strategic-artifact when creating, saving, renaming, or moving a file under the artifact root.
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

Header + delta are required for strategic artifacts only.

- **Out of scope** — scratch files and `rk-*` dumps. They get a name (step 1) and **stop here**. No header, no delta.
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
- **Every repository artifact declared as a baseline input in the provenance delta (step 4) also appears here.** Prompts and external links are provenance inputs only — never lineage edges.
- **Upstream only, never downstream** — "what feeds off this" is derived by reversing edges when the map is built. Maintaining a `Feeds:` line by hand is the drift trap; don't.
- **Paths relative to the artifact root** — a bare slug is a root-level file; a `<subfolder>/…` prefix is a file under that subfolder. This is what keeps the edge correct after a move.
- This line is the **canonical lineage edge**. The README Lineage map is only a rendered view of it (step 5).

## Step 4 — Provenance delta (decision provenance, looking back)

An agent-facing retrieval layer: it helps a later agent answer provenance questions about *this* artifact — what was added, changed, or removed against the declared starting inputs, and why. It does not explain the full idea, replace the body, or preserve a concept's lifetime history. Close with:

```markdown
## Provenance delta

_Baseline inputs:_

- `B1` — `path/to/previous-version.md`
- `P1` — User prompt: “Focus on teams already attempting this manually.”
- `S1` — [Jobs to Be Done](https://en.wikipedia.org/wiki/Jobs_to_Be_Done)

_Agent-facing. Records only substantive conceptual changes introduced in this
version; the document body is canonical._

- Changed: `B1 §Target customer` → `§Target customer` ← `P1`
- Added: `§Adoption constraint` ← `S1`
- Removed: `B1 §Enterprise expansion` ← agent synthesis, no source
```

**Baseline inputs — declare what the artifact actually started from.** One rule; typical artifacts illustrate it, they are not grammar branches:

- A **revision** starts from its preceding version plus the revision prompt.
- A **reply** starts from the document it answers plus the reply prompt. A reply is a new artifact, not a revision of that document.
- A **first artifact** starts from the initiating prompt and whatever the user supplied or referenced. With no comparable baseline sections, its entries naturally carry current anchors only.

Rules:

- Each short identifier names one declared input, prefixed by kind: `B` for a baseline artifact version — a repository artifact this one starts from; `P` for a user prompt, **preserved verbatim**; `S` for a supplied or referenced source — an exact repository-relative path with a section or timestamp, an external link the user supplied, or a source or known concept the user explicitly referenced. Only `B` inputs carry baseline anchors in entries.
- **Only inputs the user supplied or explicitly referenced.** Never promote background knowledge, agent-selected reading, or a plausible-looking source into the baseline — not even after the fact.
- Link a referenced source or concept only when it has an unambiguous openable target. If ambiguous, keep the user's exact words and don't guess a link.
- Every repository artifact used as a baseline input also appears in `Builds on:` (step 3). Prompts and external links are provenance inputs, not lineage edges — reserve *lineage* for artifact-to-artifact relationships.
- `Baseline: none` only when no identifiable input exists. An interactive user prompt normally makes that state inapplicable.

**The entry is the primitive:**

```
[baseline anchor] → [current anchor] ← source
```

At most one baseline anchor, at most one current anchor — at least one of the two — and exactly one rationale source. The label is the display name of the entry's anchor shape and carries no information of its own: both anchors → `Changed`; current only → `Added`; baseline only → `Removed`. Labels route retrieval — they are not importance or confidence labels. `Added` does not mean invented without a source; what `Removed` implies depends on the document the reader is holding, not the label.

- An unqualified `§anchor` means the current artifact. Keep anchors exact and unique.
- Prompt text is quoted once in the input list; entries point to its identifier without repeating it. When a prompt itself is the comparison target, anchor with an exact excerpt: `P1 “enterprise users”`.
- **Right side — one of three honest shapes, never a paraphrase:**
  - **openable pointer** — a declared input identifier, repository path, or external link, with a section, fragment, or timestamp when available. The reader can open it and re-check.
  - **verbatim steering quote** — when the decision was Paul's call given after the declared starting inputs, his words *are* the source; quote them. Only here — a quote dressing an externally-driven decision is laundering.
  - **`agent synthesis, no source`** — when it came from the model's reasoning with nothing under it. The flag *is* the signal: distrust this entry first.
- An agent-discovered source may appear on the right when it actually informed the change — but it never becomes a baseline input.
- Never point at the session log — it isn't committed. If the substance lives only in the session, lift it into the delta (quote or no-source marker).

**Gate — record substantive conceptual changes, not edits.** One line per substantive conceptual difference delivered in this version: a reframe, addition, removal, altitude change, scope change, reordering that changes meaning, or other strategically meaningful adjustment. Record the final adopted rationale, not the drafting process. Never split one change into separate lines per mapping, example, or wording adjustment inside the anchored section.

No entry for:
- unchanged concepts;
- spelling, notation, link, filename, and numbering corrections;
- layout-only reordering;
- intermediate decisions abandoned before delivery;
- a restatement of material already clear from the two anchored body sections.

If no change passes the gate, keep the section with this explicit state — never invent an entry to satisfy the format:

```markdown
_No substantive conceptual changes from the stated baseline inputs._
```

**Each delivered artifact is a separate file carrying only its one-step delta.** A later version builds on the current file and carries its own delta. Never append lifetime history, copy the preceding version's delta forward, or preserve superseded drafting decisions — full history stays recoverable by walking the `Builds on:` chain.

**Compatibility.** Pre-existing artifacts with an accumulating `## Provenance trail` remain valid and need not be migrated. The delta format applies to every new artifact.

**How a later agent digests it:** select the relevant entry; open the named baseline input and current section; compare the anchored material to find the actual change; follow the right-side source for why; answer only the artifact delta unless asked for broader history; state plainly when the rationale is `agent synthesis, no source`. The body stays canonical for what a concept currently means — the delta is an index into the comparison and its rationale, not a summary of the concept.

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

You build the scaffold and maintain the delta. You do **not** draft Paul's body — his principle, catalog entries, or core claims. Leave `[Paul to author]` markers where his content goes. A polished draft from you is not his thinking.

## Step 7 — Self-verify

Re-read the file you just wrote and confirm, out loud, in your reply:

- Filename matches `YYYY-MM-DD.<slug>.md`, or `YYYY-MM-DD.<chain-slug>.<N>.<step-slug>.md` for a file in a dependency chain.
- If strategic artifact: both `[invariant]` header slots present; `## Provenance delta` present with its baseline inputs declared. (A pre-existing artifact keeping its legacy `## Provenance trail` passes this check as-is — don't migrate it.)
- The initiating prompt is present verbatim when one exists; every declared input was supplied or explicitly referenced by the user — no baseline inferred from agent background knowledge or retrofitted from agent-discovered reading.
- Every repository artifact input exists and also appears in `Builds on:`; every external source or known concept has an unambiguous link, or preserves the user's exact reference instead of guessing.
- `Baseline: none` only when no identifiable prompt or source exists.
- Each entry has at least one anchor, its label matches its anchor shape, and every named anchor exists in its document.
- Every right side is one of the three shapes — **flag any paraphrase**, it's the most common failure. Any agent-discovered source on a right side actually informed the change and is not presented as a baseline input.
- Every entry is a substantive delivered change — no mechanical corrections, no abandoned drafting decisions, no unchanged material. If nothing passed the gate, the explicit no-changes state is present.
- Every internal pointer resolves.
- If the artifact has direct upstream: a `Builds on:` line is present, names only direct parents, and uses paths relative to the artifact root.
- The generator ran clean — **0 dead edges** — and the README map reflects this file.

Report pass/fail per check. If a check fails, fix it before declaring done. This step is the point of the skill — skipping it reintroduces the silent miss.

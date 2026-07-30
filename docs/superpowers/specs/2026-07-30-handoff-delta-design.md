# Handoff Delta Design

## Purpose

Replace the accumulating provenance trail in the `strategic-artifact` skill
with a version-scoped handoff delta.

The handoff delta is an agent-facing retrieval layer. It helps an agent answer
a user's provenance questions about a newly delivered artifact version when
the recipient already knows the preceding version.

It answers:

- What substantive concept was added, changed, or removed?
- Where should the agent compare the old and new versions?
- Why was the change made?
- Was the rationale an openable source, Paul's direct steer, or unsupported
  agent synthesis?

It does not explain the full idea, replace the artifact body, or preserve the
concept's lifetime history.

## Version model

Each delivered version is a separate file. The new artifact names its immediate
baseline with the existing canonical lineage edge:

```markdown
**Related artifacts**
- Builds on: `path/to/previous-version.md`
```

The new file contains only the delta from that baseline. A later version builds
on the current file and carries its own one-step delta. Full history remains
recoverable by traversing the chain, but no artifact repeats or accumulates the
whole history.

The baseline is exactly one of the paths declared in `Builds on:`. Other direct
inputs may remain as additional lineage parents; the baseline preamble
distinguishes the preceding version from those sources.

## Artifact format

Replace `## Provenance trail` with:

```markdown
## Handoff delta

_Baseline: `path/to/previous-version.md`. Agent-facing. Records only substantive
conceptual changes introduced in this version; the document body is canonical._

- Changed: `v1 §Target customer` → `§Target customer` ← “Focus on teams already attempting this manually.”
- Added: `§Adoption constraint` ← `calls/2026-07-20.aman.md §Adoption`
- Removed: `v1 §Enterprise expansion` ← agent synthesis, no source
```

`v1` means the baseline declared in the preamble. An unqualified section anchor
means the current artifact.

The left side uses one of three routing labels:

- `Added` points to the current artifact.
- `Changed` points from an exact baseline anchor to an exact current anchor.
- `Removed` points to an exact baseline anchor.

These labels describe how the agent should retrieve the change. They are not
importance or confidence labels.

The right side keeps the existing three honest provenance forms:

- an exact, openable repository-relative path with a section or timestamp;
- Paul's verbatim steering quote;
- `agent synthesis, no source`.

## Inclusion gate

Include a line only for a substantive conceptual difference delivered in the
new version: a reframe, addition, removal, altitude change, scope change,
reordering that changes meaning, or other strategically meaningful adjustment.

Exclude:

- unchanged concepts;
- spelling, notation, link, filename, and numbering corrections;
- layout-only reordering;
- intermediate decisions abandoned before delivery;
- a restatement of material already clear from the two anchored body sections.

The handoff delta records the final adopted rationale for the delivered change,
not the drafting process that preceded it.

If no change passes the gate, retain the section with this explicit state:

```markdown
_No substantive conceptual changes from the stated baseline._
```

This prevents an agent from inventing an entry to satisfy the format.

## Agent digestion contract

When answering a provenance question about the new version, the agent:

1. Reads the handoff delta and selects the relevant entry.
2. Opens the named baseline and current sections.
3. Compares those sections to determine the actual change.
4. Follows the right-side provenance source to determine why it changed.
5. Answers only the version delta unless the user explicitly asks for broader
   history.
6. States plainly when the rationale is `agent synthesis, no source`.

The artifact body remains canonical for what the concept currently means. The
handoff delta is an index into the comparison and its rationale, not a summary
of the concept.

## Authoring and maintenance rules

- Do not append lifetime history to a new version.
- Do not copy the preceding version's delta into the new version.
- Do not preserve superseded drafting decisions.
- Do not paraphrase a source on the right side.
- Record one line per substantive concept change. Do not split a single change
  into separate lines for each mapping, example, or wording adjustment inside
  the anchored section.
- Keep section anchors exact and unique.
- Require internal source pointers to resolve before declaring the artifact
  complete.
- Keep the existing authoring boundary: the agent scaffolds and records the
  delta but does not invent Paul's core strategic claims.

## Relationship to document lineage

`Builds on:` remains the canonical document-level edge and drives the generated
lineage map. The handoff delta explains only the meaningful changes across that
one edge.

The term *lineage* should be reserved for relationships between artifacts.
The handoff delta is decision provenance for a single transition.

## Compatibility

Existing artifacts with an accumulating `## Provenance trail` remain valid and
need not be migrated. The revised skill applies the handoff-delta format to new
versioned artifacts. A standalone strategic artifact with no preceding version
has no handoff delta; its sources remain in the body and its direct inputs remain
in `Builds on:`.

## Verification

The skill's self-check should confirm:

- the baseline path exists and matches the immediate version named by
  `Builds on:`;
- each entry is `Added`, `Changed`, or `Removed`;
- baseline and current anchors exist on the appropriate side of the change;
- every right side is one of the three allowed provenance forms;
- every internal pointer resolves;
- every entry is a substantive delivered change rather than an edit or an
  abandoned drafting decision;
- unchanged material is absent;
- the lineage generator reports zero dead edges.

Tests should use a v1/v2 fixture containing one added concept, one changed
concept, one removed concept, one mechanical correction, and one abandoned
drafting decision. The expected delta contains the first three and excludes the
last two.

## Rejected alternatives

### Continue an accumulating provenance trail

This preserves history locally but burdens every version with context the
recipient already knows and makes current changes harder for an agent to find.

### Expand the trail into a concept index

Tracking definitions, aliases, relationships, occurrences, and concept lifetime
would support broader digestion questions, but it would turn a sparse
provenance aid into a manually maintained knowledge graph.

### Generate the handoff solely from a text diff

A diff can find textual changes but cannot reliably distinguish conceptual
changes from mechanical edits or explain their rationale. The agent may use a
diff while authoring or answering, but the curated handoff delta remains the
retrieval index.

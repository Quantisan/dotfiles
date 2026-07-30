# Provenance Delta Design

## Purpose

Replace the accumulating provenance trail in the `strategic-artifact` skill
with a baseline-scoped provenance delta.

The provenance delta is an agent-facing retrieval layer. It helps an agent answer
a user's provenance questions about a newly delivered artifact. The delta is
measured from declared baseline inputs: the actual material the user supplied or
explicitly referenced as the starting point. A revision includes its preceding
version; a reply includes the document it answers; a first artifact includes the
user's initiating prompt verbatim and any supplied or referenced sources. The
delta scopes retrieval to what the artifact introduced or changed against those
inputs.

It answers:

- What substantive concept was added, changed, or removed?
- Which baseline input and artifact section should the agent compare?
- Why was the change made?
- Was the rationale an openable source, Paul's direct steer, or unsupported
  agent synthesis?

It does not explain the full idea, replace the artifact body, or preserve the
concept's lifetime history.

## Baseline model

Each delivered artifact is a separate file. The new artifact declares the inputs
it directly starts from. When an input is another repository artifact, it also
uses the existing canonical lineage edge:

```markdown
**Related artifacts**
- Builds on: `path/to/previous-version.md`
```

The new file contains only the delta from its declared inputs. A later version
builds on the current file and carries its own one-step delta. Full artifact
history remains recoverable by traversing the chain, but no artifact repeats or
accumulates the whole history.

Baseline inputs may be:

- the user's initiating prompt, preserved verbatim;
- exact repository-relative paths with a section or timestamp;
- external links the user supplied or sources and known concepts the user
  explicitly referenced.

Link a referenced source or concept when it has an unambiguous openable target.
If the reference is ambiguous, retain the user's exact words and do not guess a
link. Do not promote background knowledge, agent-selected reading, or a
plausible-looking source into the baseline after the fact.

Every repository artifact used as a baseline input must also appear in
`Builds on:`. Prompts and external links are provenance inputs, not artifact
lineage edges.

Three baseline cases, one grammar:

- A revision includes its preceding version, the revision prompt verbatim, and
  any additional user-supplied or explicitly referenced inputs.
- A reply includes the document it answers, the reply prompt verbatim, and any
  additional inputs. The reply is a new artifact, not a revision of that
  document; `Removed` means the reply proposes dropping the concept, not that
  the source document lost it.
- A first artifact includes the initiating prompt verbatim and any additional
  inputs. `Baseline: none` is permitted only when no identifiable input exists;
  an interactive user prompt normally makes that state inapplicable.

## Artifact format

Replace `## Provenance trail` with:

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

Each short identifier names one declared input. An unqualified section anchor
means the current artifact. Prompt text is quoted once in the input list; entries
may point to its identifier without repeating it. When a prompt itself is the
comparison target, use an exact excerpt as its anchor, such as
`P1 “enterprise users”`.

A first artifact declares its real starting material:

```markdown
## Provenance delta

_Baseline inputs:_

- `P1` — User prompt: “Identify the constraints preventing adoption.”
- `S1` — `calls/2026-07-20.aman.md §Adoption`

_Agent-facing. Records only substantive conceptual changes introduced in this
artifact; the document body is canonical._

- Added: `§Adoption constraint` ← `S1`
```

The left side uses one of three routing labels:

- `Added` points to the current artifact.
- `Changed` points from an exact anchor in a comparable baseline input to an
  exact current anchor.
- `Removed` points to an exact anchor in a comparable baseline input.

These labels describe how the agent should retrieve the change. They are not
importance or confidence labels. `Added` means introduced into the delivered
artifact; it does not mean invented without a source.

The right side keeps the existing three honest provenance forms:

- an exact, openable source pointer: a declared input identifier, repository
  path, or external link with a section, fragment, or timestamp when available;
- Paul's verbatim steering quote when it was given after the declared starting
  inputs;
- `agent synthesis, no source`.

An agent-discovered source may appear on the right when it actually informed the
change, but it does not become a baseline input after the fact.

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

The provenance delta records the final adopted rationale for the delivered change,
not the drafting process that preceded it.

If no change passes the gate, retain the section with this explicit state:

```markdown
_No substantive conceptual changes from the stated baseline inputs._
```

This prevents an agent from inventing an entry to satisfy the format.

## Agent digestion contract

When answering a provenance question about the new version, the agent:

1. Reads the provenance delta and selects the relevant entry.
2. Opens the named baseline input and current section.
3. Compares the anchored material to determine the actual change.
4. Follows the right-side provenance source to determine why it changed.
5. Answers only the artifact delta unless the user explicitly asks for broader
   history.
6. States plainly when the rationale is `agent synthesis, no source`.

When no comparable baseline section exists for an `Added` entry, steps 2 and 3
reduce to opening the current section and the named provenance input.

The artifact body remains canonical for what the concept currently means. The
provenance delta is an index into the comparison and its rationale, not a summary
of the concept.

## Authoring and maintenance rules

- Do not append lifetime history to a new version.
- Do not copy the preceding version's delta into the new version.
- Do not preserve superseded drafting decisions.
- Preserve the initiating user prompt verbatim.
- Include only inputs the user supplied or explicitly referenced. Do not invent
  a baseline or retrofit an agent-discovered source.
- Link external sources and named concepts when the intended target is
  unambiguous; otherwise preserve the exact user reference without guessing.
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
lineage map. It contains only repository artifacts directly used to produce the
new artifact. The provenance delta may additionally name prompts and external
sources that cannot be lineage edges.

The term *lineage* should be reserved for relationships between artifacts.
The provenance delta is decision provenance from the declared starting inputs
to one delivered artifact.

## Compatibility

Existing artifacts with an accumulating `## Provenance trail` remain valid and
need not be migrated. The revised skill applies the provenance-delta format to all
new artifacts. Revisions, replies, and first artifacts all declare their actual
inputs. `Baseline: none` remains valid only for the exceptional case where no
input can honestly be identified.

## Verification

The skill's self-check should confirm:

- the initiating prompt is present verbatim when one exists;
- every declared input was supplied or explicitly referenced by the user;
  no baseline was inferred from agent background knowledge;
- every repository artifact input exists and is also present in `Builds on:`;
- every external source or known concept has an unambiguous link, or preserves
  the user's exact reference instead of guessing;
- a `none` baseline is used only when no identifiable prompt or source exists,
  and has only `Added` entries with no baseline anchors;
- each entry is `Added`, `Changed`, or `Removed`;
- baseline and current anchors exist on the appropriate side of the change;
- every right side is one of the three allowed provenance forms;
- every internal pointer resolves;
- every agent-discovered source on a right side actually informed the change
  and is not misrepresented as a baseline input;
- every entry is a substantive delivered change rather than an edit or an
  abandoned drafting decision;
- unchanged material is absent;
- the lineage generator reports zero dead edges.

Tests should use a v1/v2 fixture containing one added concept, one changed
concept, one removed concept, one mechanical correction, and one abandoned
drafting decision. The expected delta contains the first three and excludes the
last two. Two further fixtures: a standalone first artifact whose delta is
based on a verbatim prompt and a linked source, and a reply whose delta anchors
against the document it answers. A final exceptional fixture may use
`Baseline: none` only when it contains no prompt or source.

## Rejected alternatives

### Continue an accumulating provenance trail

This preserves history locally but burdens every version with context the
recipient already knows and makes current changes harder for an agent to find.

### Treat every first artifact as a delta from nothing

An interactive artifact almost always starts from at least the user's prompt,
and often from supplied documents, transcripts, links, or named concepts.
Declaring `Baseline: none` discards that provenance and falsely makes every
concept appear source-free. The design retains `none` only for the genuinely
input-free edge case.

### Expand the trail into a concept index

Tracking definitions, aliases, relationships, occurrences, and concept lifetime
would support broader digestion questions, but it would turn a sparse
provenance aid into a manually maintained knowledge graph.

### Generate the handoff solely from a text diff

A diff can find textual changes but cannot reliably distinguish conceptual
changes from mechanical edits or explain their rationale. The agent may use a
diff while authoring or answering, but the curated provenance delta remains the
retrieval index.

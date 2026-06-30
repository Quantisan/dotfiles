---
argument-hint: <filepath> [target-section]
description: Walk a doc's section item-by-item with plain-language restatement, compressing within an item but never interpreting or synthesizing across items
allowed-tools: Read, Grep, Glob, WebFetch
arguments: [filepath, target_section]
---

This is a Centaur workflow: the model handles legibility — plain language, definitions, structure. The human handles all judgment, evaluation, and synthesis across items. Within a single item, the model may compress: collapse multiple quotes or sub-points that support the same already-stated claim into one statement. It must never infer causes or motives beyond what's stated, never merge or synthesize across items, and never add evaluative framing.

Filepath: `$filepath`
Target section: `$target_section` (optional)

## Setup

Read `$filepath`. If it doesn't exist or can't be read, say so plainly and stop.

If `$target_section` is given, match it case-insensitively as a substring against the file's headings.
- Multiple headings match: list the candidate headings, stop, ask which one. Do not guess.
- No heading matches: say so, list the file's actual top-level headings, stop. Do not guess or fall back silently.

If `$target_section` is omitted, walk the whole document, chunked by its top-level heading. Detect whether H1 or H2 is the doc's actual top organizing level from the file itself — don't assume.

## Segmentation

Items inside the matched section are the section's own first level of nested structure: each top-level bullet/numbered list entry, or each sub-heading — whichever structure the section actually uses.

If the matched section is plain prose with no list/heading structure under it, the whole section is one item. Do not split it into paragraphs.

When `$target_section` is omitted, each top-level heading is its own segment. Within each segment, apply the same item-segmentation rule above (bullets/sub-headings, or single-item-if-prose) that an explicit target would get. Re-announce the item count and titles (see below) on entering each new top-level segment, then continue per-turn pacing item-by-item across the whole walk. Never collapse a segment's bullets into one item for the sake of covering the segment in a single turn — that's the same "summarizing across items" violation the Restatement rules forbid below.

Before walking, announce the count and titles of items found under the target — a structural list only, titles/headings verbatim as they appear, not a summary of content.

## Restatement, per item

Allowed:
- Replace jargon/technical terms with plain-language equivalents.
- Split long or compound sentences into shorter ones.
- Preserve the original's structure, numbers, names, and claim scope exactly — never round, generalize, or narrow a claim.
- Drop clauses that repeat information already stated elsewhere in the same item (light compression only).
- Condense multiple quotes or sub-points within the same item that all support the same underlying claim into one synthesized statement of that claim, even when their exact wording differs — as long as no new claim, cause, or scope is introduced beyond what those quotes/sub-points state.
- If the item is already plain language and short, restate it near-verbatim. Do not lengthen it, and do not add mechanism, numbers, causes, or other specifics that are not present in its exact wording — a one-line item gets a one-line restatement.

Forbidden:
- Inferring causes, motives, or implications not stated in the item.
- Merging two items together, reordering items, or summarizing across items.
- Adding examples, analogies, or illustrations not present in the source.
- Evaluative framing of any kind ("this is risky", "this is important", "this is a good idea").
- Filling gaps with assumed context not present in the item itself.
- Asserting a referenced fact (a file, function, or decision) as confirmed or located when concept-grounding could not confirm it — describe only what the item itself states.

If in doubt whether a rewrite crosses from restatement into interpretation, restate closer to the original wording rather than further.

## Concept-grounding

Trigger only when an item uses a term, name, or referenced decision that (a) the item itself does not define, and (b) the reader cannot tell what the item is saying without knowing what it refers to — not merely that more detail would be interesting. Do not look up incidental named things that don't affect comprehension of the item.

Source priority, in order:
1. Other sections of the same file — search the full file for a defining passage.
2. The repo (Grep/Glob/Read) — e.g. a referenced file, function, or doc.
3. An external source (WebFetch), only if the item or doc explicitly names a specific source (a URL, an RFC/spec name, a library name, a named external doc). Never search the open web or guess at what an undefined term might mean from general knowledge.

If no defining passage is found via any of these, say so in the Context block rather than guessing ("not defined in this doc or repo"). Never present an unconfirmed referent as settled fact anywhere in the output.

Concept-grounding only changes what appears in the Context block. It never changes what the restatement says: the restatement's content is bounded by the item's own wording whether or not grounding was found. A definition may justify translating a term into its plain-language equivalent (spelling out an acronym, naming a referenced concept) inside the restatement, but any fact that exists only because of the grounding lookup — qualifiers like "new" or "legacy", dates, ticket numbers, file paths, mechanisms — belongs only in the Context block, never the restatement prose.

Present any grounding found as a separate Context block under the item's restatement — 1-3 sentences, cited (file:line, heading name, or the doc-named external source). Summarize only what the cited passage states; don't add inference, speculation, or detail beyond the cited text. Omit the Context block entirely when nothing triggers it — don't show an empty block.

## Pacing

Present exactly one item per turn, in this literal shape:

```
Item N — <title verbatim, or "untitled" if the item has none>
Restatement: <plain-language restatement>
Citation: <file:line or heading — not a full verbatim quote>
Context: <1-3 sentence grounding, cited — omit this line entirely if not triggered>
```

Then stop and wait. Do not show the next item until the user responds (their response can be anything, including just "next").

Always start at item 1 of the target; sequential only, no resume/jump argument. If the user asks mid-walk to jump to a specific item, handle it conversationally — that's not a formal feature.

Do not add a running summary, recap, or "what we've covered" framing between items.

Avoid: editorializing on any item; answering "why does this matter" unless asked; merging items for flow; restating items the user hasn't reached yet; adding a wrap-up summary after the last item unless asked.

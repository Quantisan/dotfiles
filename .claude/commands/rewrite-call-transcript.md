---
argument-hint: <transcript-file>
description: Rewrite a call transcript into clean speaker-by-speaker dialogue using roster-guided attribution
allowed-tools: Read, Agent, Write
---

Rewrite a noisy call transcript into readable speaker-by-speaker dialogue without adding meaning that is not present in the source.

Transcript file: `$ARGUMENTS`

## Step 1 — Ask for the roster

Before anything else, ask the user to paste a speaker roster: each speaker on one line with a 2-3 word description (e.g. `Alice — founder, technical`). Wait for their reply. Treat the roster as the primary attribution context; use it to resolve vague labels, role references, and likely speaker continuity. If the roster is missing or incomplete, stay conservative — never invent names.

## Step 2 — Resolve the output path

Dispatch an `Agent` (`subagent_type: general-purpose`, `model: haiku`) to resolve the cleaned-dialogue output path. Brief it with the input transcript path (`$ARGUMENTS`) only. Ask it to:

- `ls` the parent directory of the input.
- Identify the input's trailing suffix segments (e.g. `.transcript.vtt`).
- Look for sibling files that share the input's stem but use a `dialogue`-containing suffix (e.g. `.dialogue.txt`, `.dialogue.md`). If found, build the output path by replacing the input's suffix with that sibling-attested dialogue suffix. If multiple variants exist, pick the most common one.
- If no informative sibling pattern exists, fall back: strip the input's extension(s) and append `.dialogue.txt`.

The sub-agent returns one line: the resolved output path. No directory listing, no rationale, nothing else. Hold this path in your working notes and use it verbatim in Step 7.

## Step 3 — Map the conversation

Dispatch an `Agent` (`subagent_type: general-purpose`) to read the full transcript file and return a compact `conversation_map`:
- likely speakers and the source labels they appear under
- topic shifts and natural chunk boundaries, given as line ranges
- ambiguity hotspots: cross-talk, broken sentences, unclear terms

The mapper returns the map only. It must not return the full transcript text.

## Step 4 — Maintain a continuity ledger

In your own context, keep a `continuity_ledger`: canonical speaker names, stable technical terms, unresolved mappings, and consistency decisions. Update it as cleaner sub-agents return chunks.

## Step 5 — Clean each chunk

For each chunk the mapper identified (a short transcript may stay as a single chunk), dispatch an `Agent` (`subagent_type: general-purpose`) with:
- the transcript file path and the chunk's line range, with a small overlap into the previous chunk's tail
- the speaker roster
- the relevant `conversation_map` excerpt
- the current `continuity_ledger`

The cleaner returns only:
- `cleaned_chunk`: rewritten dialogue for that span
- `open_questions`: anything still ambiguous after best-effort cleanup

Brief each cleaner with these rules:

- Format each turn as `Speaker: utterance` (confident attribution), `Speaker [uncertain]: utterance` (plausible but not certain), or `Unknown Speaker [uncertain]: utterance` (no defensible attribution). If preserving the source label helps the reader, keep it and mark `[uncertain]`.
- Keep speaker order and conversational flow intact.
- Remove filler, false starts, stutters, repetitions, silence hallucinations, and repeated `yeah`/`mm-hm` filler loops — but keep them when they answer a yes/no question, confirm something explicitly, or carry real meaning.
- Fix proper nouns, numbers, contractions, grammar, agreement, and technical terms only when nearby context, repeated usage, or the roster strongly supports the repair.
- Rewrite fragments only enough to recover intended meaning.
- Preserve every concept, claim, decision, number, and technical detail in the source.
- Never add information, interpretation, speaker intent, or implied context not grounded in the transcript.
- Never summarize, combine turns, or smooth wording in ways that introduce new concepts.
- When a word or segment cannot be recovered confidently, write `[unclear]`.

## Step 6 — Challenge hotspots (only when needed)

For chunks the mapper flagged as real ambiguity hotspots, dispatch an `Agent` (`subagent_type: general-purpose`) to produce 2 conservative `hotspot_variants` for that span. Choose the most defensible variant. Use this for uncertainty, not stylistic experimentation.

## Step 7 — Assemble and write

Harmonize overlaps and naming across chunks using the ledger. Assemble the final transcript.

Write to the output path resolved in Step 2. Overwrite if the path already exists. Write the file using this exact shape:

```xml
<cleaned_transcript>
Alice: First cleaned utterance.
Bob [uncertain]: Second cleaned utterance.
Unknown Speaker [uncertain]: Third cleaned utterance.
</cleaned_transcript>
```

After writing, print one short line confirming the output path. Then, if you made any significant interpretation, non-obvious speaker mapping, or material repair that could affect how the transcript is read, display a `<notes>` block inline in the chat (not in the file):

```xml
<notes>
- Brief note on a major repair or non-obvious speaker mapping.
</notes>
```

Omit the `<notes>` block when there is nothing material to flag. Surface any remaining open questions worth the user's attention.

## Controller rules

- Never paste, quote, or load the full raw transcript into your own context. Keep your working set to the roster, `conversation_map`, `continuity_ledger`, rewritten chunks, and small targeted excerpts returned by sub-agents.
- When more raw evidence is needed for a decision, dispatch a sub-agent to inspect that specific span and return only the minimum needed to decide.

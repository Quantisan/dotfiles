---
name: rewrite-call-transcript
description: Use when a user wants a noisy call, meeting, interview, podcast, or other conversation transcript file rewritten into clean speaker-by-speaker dialogue, especially when speaker labels are messy or ASR errors need conservative repair.
---

# Rewrite Call Transcript

Rewrite a transcript file into readable speaker-by-speaker dialogue without adding meaning that is not present in the source. Keep the raw transcript out of the controller context.

## Canonical input and roster gate

Accept a transcript file path as the canonical input.

On the first turn, before inspecting the path, reading any transcript content, resolving an output path, or spawning a subagent, ask the user to paste a speaker roster with one speaker per line and a 2–3 word description, for example:

`Alice — founder, technical`

End the turn immediately after asking. Do not process anything until the user replies. Treat the returned roster as the primary attribution context for vague labels, role references, and likely speaker continuity. If the roster is missing or incomplete, stay conservative and never invent names.

## Controller workflow

Use fresh-context Codex subagents for raw-file inspection. The controller coordinates them but never reads the full raw transcript.

### 1. Resolve the output path

After the roster reply, spawn a fresh-context path resolver. Give it the input transcript path and the resolution instructions only; do not give it transcript content, the roster, or controller history. Require it to:

- List the input file's parent directory.
- Identify the input's trailing suffix segments, such as `.transcript.vtt`.
- Find sibling files that share the input's stem and have a `dialogue`-containing suffix, such as `.dialogue.txt` or `.dialogue.md`.
- If a sibling convention exists, replace the input suffix with that sibling-attested dialogue suffix. If several variants exist, use the most common.
- Otherwise, strip the input's extension or extensions and append `.dialogue.txt`.

Require exactly one returned line containing the resolved output path, with no listing or rationale. Keep that path verbatim for the write step.

### 2. Map the conversation

Spawn a fresh-context mapper with the transcript file path and roster. It may read the full file. Require only a compact `conversation_map` containing:

- likely speakers and their source labels
- the physical `source_line_count`
- topic shifts and natural chunk boundaries as exact inclusive line ranges
- ambiguity hotspots such as cross-talk, broken sentences, and unclear terms

Require the mapper to number physical file lines with `nl -ba` or an equivalent line-numbered read. Its chunk ranges must be contiguous, non-overlapping, and collectively cover lines 1 through `source_line_count`; metadata or blank lines may remain inside a range. The mapper must not return or quote the full transcript. Validate range coverage numerically in the controller and return the map for correction before cleaning if a line is missing or duplicated.

### 3. Maintain continuity

Keep a controller-side `continuity_ledger` with canonical speaker names, stable technical terms, unresolved mappings, and consistency decisions. Update it as cleaners return.

### 4. Clean mapped chunks

For every mapped chunk, spawn a fresh-context cleaner. A short transcript may remain one chunk. Give each cleaner:

- the transcript file path
- the chunk's exact inclusive line range
- a small, explicitly labeled overlap range from the preceding chunk's tail when one exists
- the speaker roster
- the relevant `conversation_map` excerpt
- the current `continuity_ledger`

Give paths and ranges, not raw chunk text copied through the controller. Require the cleaner to read only its assigned range and overlap and return only:

- `cleaned_chunk`: rewritten dialogue for the assigned span
- `open_questions`: ambiguities that remain after best-effort cleanup

Use the overlap only to preserve repeated names, technical terms, speaker continuity, and sentence flow. Harmonize and de-duplicate overlaps during assembly.

### 5. Challenge only real hotspots

Only for a chunk the mapper marked as a genuine ambiguity hotspot, spawn a fresh-context challenger with the path, exact hotspot line range, roster, relevant map excerpt, and ledger. Require exactly two conservative `hotspot_variants`. Use this to examine uncertainty, not to experiment with style. Choose the most defensible variant.

### 6. Inspect targeted evidence when needed

If a seam, attribution, term, or hotspot choice still needs raw evidence, spawn a fresh-context follow-up inspector for that specific line range. Require only the minimum excerpt or resolution note needed for the decision. The controller must not open the raw transcript itself.

### 7. Assemble and write

Before assembly, verify that every mapper-owned range has one returned `cleaned_chunk`; do not infer completion from whichever chunk returned last. Use the ledger to harmonize speaker names, attribution confidence, and technical terms, remove overlap duplication, preserve order, and assemble every owned range. Apply a stable speaker mapping and confidence level consistently across chunks unless new source evidence changes it; do not preserve accidental chunk-local confidence drift. If a suspected seam or coverage gap remains, use the targeted inspector before writing. Write to the resolved output path and overwrite an existing file at that path.

Persist exactly one `<cleaned_transcript>` root element:

```xml
<cleaned_transcript>
Alice: First cleaned utterance.
Bob [uncertain]: Second cleaned utterance.
Unknown Speaker [uncertain]: Third cleaned utterance.
</cleaned_transcript>
```

Do not put notes, open questions, coordination artifacts, or a `<rewritten_transcript>` element in the file.

## Cleaner fidelity rules

Brief every cleaner and hotspot challenger with all of these rules:

- Format confident attribution as `Speaker: utterance`.
- Format plausible but uncertain attribution as `Speaker [uncertain]: utterance`.
- If no named attribution is defensible, preserve a helpful source label and mark it `[uncertain]`; otherwise use `Unknown Speaker [uncertain]: utterance`.
- Use only those three speaker-label shapes. Do not carry source stage directions such as `[overlapping]` into the speaker label; use `[uncertain]` when cross-talk makes attribution uncertain.
- Keep speaker order and conversational flow intact.
- Remove filler, false starts, stutters, repetitions, silence hallucinations, and repeated `yeah`/`mm-hm` filler loops only when meaning does not change.
- Keep an apparent filler response when it answers a yes/no question, explicitly confirms something, or carries real meaning.
- Fix proper nouns, numbers, contractions, grammar, agreement, and technical terms only when nearby context, repeated usage, or the roster strongly supports the repair.
- Rewrite fragments only enough to recover intended meaning.
- Preserve every concept, claim, decision, number, and technical detail present in the source.
- Never add information, interpretation, speaker intent, or implied context not grounded in the transcript.
- Never summarize, combine turns, or smooth wording in ways that introduce new concepts.
- When a word or segment cannot be recovered confidently, write `[unclear]`.
- Use `[unclear]` only as a replacement for unrecoverable source text. Preserve a clearly spoken literal word such as “unclear” as ordinary dialogue rather than converting it to the marker.

## Controller isolation rules

- Never paste, quote, read, or load the full raw transcript in the controller context.
- Keep the controller working set to the input and output paths, roster, `conversation_map`, `continuity_ledger`, rewritten chunks, open questions, hotspot variants, and small targeted excerpts returned by subagents.
- Use subagents for all raw-transcript inspection; use the controller only for coordination, consistency decisions, assembly, and writing.
- Do not expose the map, ledger, chunks, variants, or other coordination artifacts to the user.

## Chat response

After writing, start with one short path-confirmation line:

`Wrote <resolved-output-path>.`

Only when a significant interpretation, non-obvious speaker mapping, or material repair could affect how the transcript is read, follow the path line with a chat-only block:

```xml
<notes>
- Brief note on a material repair or non-obvious mapping.
</notes>
```

Omit `<notes>` when nothing material needs disclosure. An unresolved ambiguity, unanswered question, or routine `[unclear]` marker alone does not justify `<notes>`; surface it only as an open question when it is worth attention. Never write notes into the transcript file.

After any material-repair notes, surface only remaining open questions worth the user's attention under a concise `Open questions:` label. Do not duplicate an open question in `<notes>`. Omit routine or resolved questions. If there are no material notes or worthwhile open questions, return only the path-confirmation line.

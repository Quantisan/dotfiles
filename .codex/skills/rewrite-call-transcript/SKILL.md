---
name: rewrite-call-transcript
description: Use when a user provides a call, meeting, interview, podcast, or other conversation transcript that needs to be rewritten into clean speaker-by-speaker dialogue, especially when the transcript is long, noisy, speaker labels are messy, or ASR errors need conservative repair.
---

# Rewrite Call Transcript

Turn noisy transcript text into readable dialogue without adding meaning that is not present in the source.

## Inputs

- Require the raw transcript text.
- Expect a speaker roster before the transcript, with each speaker described in 2-3 words.
- Treat the speaker roster as primary attribution context.
- Use the roster heavily to resolve vague labels, role references, and likely speaker continuity.
- Reuse raw speaker labels only when they help map a turn to the roster.
- If the roster is missing or incomplete, stay conservative: do not invent names.

## Workflow

Use a controller workflow with sub-agents so the main context holds conversation structure, not every raw utterance.

1. Read the speaker roster and inspect the transcript enough to understand the conversation shape.
2. Dispatch a mapper sub-agent to read the full raw transcript and return a compact `conversation_map` with:
   - likely speakers and source labels
   - topic shifts and natural chunk boundaries
   - ambiguity hotspots such as cross-talk, broken sentences, or unclear terms
3. Create and maintain a `continuity_ledger` containing canonical speaker names, stable technical terms, unresolved mappings, and any other consistency decisions.
4. Split the transcript at natural boundaries with a small overlap. Short transcripts can stay as one chunk.
5. Dispatch a cleaner sub-agent for each chunk with the chunk text, the relevant `conversation_map` excerpt, the speaker roster, and the current `continuity_ledger`. Each cleaner should return:
   - `cleaned_chunk`: rewritten dialogue for that span
   - `open_questions`: anything still ambiguous after best-effort cleanup
6. Only when a chunk contains a real ambiguity hotspot, dispatch a challenger sub-agent for that span and ask for 2 conservative `hotspot_variants`. Use this for uncertainty, not for stylistic experimentation.
7. The controller chooses the most defensible variant, updates the `continuity_ledger`, harmonizes overlaps and naming, and assembles the final transcript.
8. Re-check the raw transcript directly when seams, speaker continuity, or hotspot choices remain uncertain. Do not rely on summaries alone for final judgments.

## Cleaner Rules

- Keep speaker order and conversational flow intact.
- Format each turn as `Speaker: utterance` or `Speaker [uncertain]: utterance`.
- Remove silence hallucinations and filler loops.
- Remove most repeated `yeah` or similar filler insertions unless they answer a yes/no question, confirm something explicitly, or carry real meaning.
- Remove filler, false starts, stutters, and repetitions only when meaning does not change.
- Fix proper nouns, numbers, contractions, grammar, agreement, and technical terms only when nearby transcript context, repeated usage, or the speaker roster strongly supports the repair.
- Rewrite fragments only enough to recover the intended meaning.
- Preserve all concepts, claims, decisions, numbers, and technical details present in the source.
- Do not add new information, interpretation, speaker intent, or implied context that is not grounded in the transcript.
- Do not summarize, combine turns, or smooth wording in ways that introduce new concepts.
- When a word or segment cannot be recovered confidently after best-effort cleanup, write `[unclear]`.
- Use `Speaker: utterance` when the transcript and roster support the attribution confidently.
- Use `Speaker [uncertain]: utterance` when a named speaker is plausible but not certain.
- If no named attribution is defensible, preserve the source label and mark it `[uncertain]` when that helps, otherwise use `Unknown Speaker [uncertain]: utterance`.

## Output

Return only the rewritten transcript inside `<rewritten_transcript>` tags.

Internal workflow artifacts such as `conversation_map`, `continuity_ledger`, `cleaned_chunk`, and `hotspot_variants` are for coordination only. Do not expose them in the final answer.

If you made any significant interpretation, non-obvious speaker mapping, or material repair that could affect how the transcript is read, add a `<notes>` block after the transcript. Omit `<notes>` when there is nothing material to flag.

Use this exact shape:

```xml
<rewritten_transcript>
Alice: First cleaned utterance.
Bob [uncertain]: Second cleaned utterance.
Unknown Speaker [uncertain]: Third cleaned utterance.
</rewritten_transcript>
<notes>
- Brief explanation of a major repair or non-obvious speaker mapping, if needed.
</notes>
```

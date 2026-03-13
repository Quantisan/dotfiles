---
name: rewrite-call-transcript
description: Use when a user provides a call, meeting, interview, podcast, or other conversation transcript that needs to be rewritten into clean speaker-by-speaker dialogue, especially when the transcript has filler, ASR errors, or ambiguous speaker labels and the user can provide speaker names with short descriptions.
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

## Rewrite Process

1. Read the full transcript and the speaker roster before rewriting so local fixes do not break later context.
2. Keep speaker order and conversational flow intact.
3. Format each turn as `Speaker: utterance` or `Speaker [uncertain]: utterance`.
4. Correct transcription problems conservatively:
   - Remove silence hallucinations and filler loops.
   - Remove most repeated `yeah` or similar filler insertions unless they answer a yes/no question, confirm something explicitly, or carry real meaning.
   - Remove filler, false starts, stutters, and repetitions only when meaning does not change.
   - Fix proper nouns, numbers, contractions, grammar, agreement, and technical terms only when nearby transcript context, repeated usage, or the speaker roster strongly supports the repair.
   - Rewrite fragments only enough to recover the intended meaning.
5. Preserve all concepts, claims, decisions, numbers, and technical details present in the source.
6. Do not add new information, interpretation, speaker intent, or implied context that is not grounded in the transcript.
7. Do not summarize, combine turns, or smooth wording in ways that introduce new concepts.
8. When a word or segment cannot be recovered confidently after best-effort cleanup, write `[unclear]`.
9. Attribute speakers with a confidence ladder:
   - Use `Speaker: utterance` when the transcript and roster support the attribution confidently.
   - Use `Speaker [uncertain]: utterance` when a named speaker is plausible but not certain.
   - If no named attribution is defensible, preserve the source label and mark it `[uncertain]` when that helps, otherwise use `Unknown Speaker [uncertain]: utterance`.

## Output

Return only the rewritten transcript inside `<rewritten_transcript>` tags.

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

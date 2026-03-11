---
name: rewrite-call-transcript
description: Use when a user provides a call, meeting, interview, podcast, or other conversation transcript that needs to be rewritten into clean speaker-by-speaker dialogue while preserving meaning. Trigger on requests to fix transcription errors, remove filler and repeated words, normalize speaker labels, repair likely ASR mistakes, or mark uncertain audio as [unclear].
---

# Rewrite Call Transcript

Turn noisy transcript text into readable dialogue without losing semantic content.

## Inputs

- Require the raw transcript text.
- Accept speaker names if the user provides them.
- Reuse any speaker labels already present in the source.
- If one named speaker is known and the rest are unspecified, use `Remote Speaker(s)` for the unknown side unless the user asks for different labels.
- If identities are unknown, use neutral labels rather than inventing names.

## Rewrite Process

1. Read the full transcript before rewriting so local fixes do not break later context.
2. Keep speaker order and conversational flow intact.
3. Format each turn as `Speaker: utterance`.
4. Correct transcription problems conservatively:
   - Remove silence hallucinations and filler loops.
   - Remove most repeated `yeah` or similar filler insertions unless they answer a yes/no question, confirm something explicitly, or carry real meaning.
   - Fix obvious proper nouns, numbers, contractions, grammar, agreement, technical terms, and stutters when context strongly supports the correction.
   - Rewrite fragments only enough to recover the intended meaning.
5. Remove filler, false starts, and repetitions that do not change meaning.
6. Preserve all concepts, claims, and details present in the source.
7. Do not add new information, interpretation, or speaker intent that is not grounded in the transcript.
8. When a segment remains ambiguous after best-effort cleanup, write `[unclear]`.

## Output

Return only the rewritten transcript inside `<rewritten_transcript>` tags.

If you made any significant interpretation or non-obvious repair, add a `<notes>` block after the transcript. Omit `<notes>` when there is nothing material to flag.

Use this exact shape:

```xml
<rewritten_transcript>
Speaker: First cleaned utterance.
Speaker: Second cleaned utterance.
</rewritten_transcript>
<notes>
- Brief explanation of major interpretation, if needed.
</notes>
```

---
name: meeting-minutes
description: Use when a user provides a meeting, call, or VTT transcript and wants decision-focused minutes, a thematic meeting summary, or a concise record of decisions, outcomes, action items, open questions, and next steps.
---

# Meeting Minutes

Turn raw meeting transcripts into decision-first minutes that consolidate scattered discussion into one clear thematic summary.

## Inputs

- Require the transcript text.
- Accept optional background context from the user.
- Treat the transcript as the source of truth.

## Workflow

1. Read the full transcript and any user context before drafting.
2. Start with a brief 2-3 iteration plan tailored to the meeting. Explain the proposed refinement strategy in a few sentences.
3. In each iteration:
   - Show the current draft or the key refinements made so far.
   - Ask 1-2 multiple-choice questions that force a choice about emphasis, scope, or structure.
   - Keep questions about prioritization, not about collecting new facts already absent from the transcript.
4. Use the user's answers to refine the next iteration.
5. After the planned iterations, deliver the final minutes in Markdown.

## Quality Rules

- Organize thematically, not chronologically.
- Front-load decisions, outcomes, and commitments.
- Consolidate repeated or scattered discussion into one logical section.
- Mention each concept once in its best location.
- Keep uncertainty explicit when the transcript is ambiguous.
- Never add information not grounded in the transcript or user-supplied context.

## Question Design

- Offer 2-4 clear options per question.
- Make the trade-offs real, such as strategic decisions versus execution detail or concise summary versus fuller record.
- Keep questions decision-forcing rather than open-ended whenever possible.

## Final Output

Return polished meeting minutes in Markdown. Prefer sections such as `Decisions`, `Key Points`, `Open Questions`, `Action Items`, and `Next Steps` when the transcript supports them, but adapt the structure to the meeting.

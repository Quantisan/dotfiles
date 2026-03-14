---
name: meeting-minutes
description: Use when a user provides a meeting, call, or VTT transcript and wants decision-focused minutes, a thematic meeting summary, or a concise record of decisions, outcomes, action items, open questions, and next steps.
---

# Meeting Minutes

Turn raw meeting transcripts into structured minutes that capture decisions, explorations, and context threads — organized by significance, layered by depth.

## Inputs

- Require the transcript text (source of truth).
- Accept optional background context from the user.
- Accept an optional participant roster with roles (e.g., "Paul — technical co-founder, Alex — CEO"). Use it to attribute decisions and action items to named individuals.

## Workflow

### Pass 1: Conversation Map

Read the full transcript and any user context. Produce a conversation map — a compact outline of every identified thread. Present it as a table or list with these fields per thread:

- **Theme name** — what was discussed (e.g., "Auth System Rewrite")
- **Thread type** — one of: `decision`, `exploration`, `context`
- **Layers touched** — free-form labels for which levels the thread spans (e.g., technical, strategic, personal, operational)
- **Key signal** — one sentence capturing the most important point
- **Proposed depth** — `full` (nested strategic + technical + open threads), `summary` (2-4 bullets, no layering), or `mention` (single sentence noting it occurred)

Present the map to the user. They can:
- Merge or split themes
- Reclassify thread types
- Adjust proposed depth per theme
- Drop threads entirely

### Pass 2: Draft from Validated Map

Draft minutes from the user's validated map. Each theme becomes a block:

- **Theme heading** with inline type tag: `[decision]`, `[exploration]`, or `[context]`
- **Nested layers** (when depth is `full`): strategic context first, then technical detail, then open threads
- **Type-specific metadata:**
  - `decision` — owners, dates, rationale
  - `exploration` — maturity marker (raw idea / forming / nearly actionable), next step if any
  - `context` — why it matters for the working relationship or upcoming work

For a standard business meeting, the conversation map will surface mostly `decision` threads at `full` depth — output will resemble traditional meeting minutes.

**Optional tail sections** (include only when the transcript supports them):
- **Action Items** — consolidated from all themes
- **Open Questions** — consolidated from all themes
- **Next Steps** — if distinct from action items

### Final Pass

After drafting, apply one internal shortening pass: "Simplify and shorten each point to the key idea. Use a direct tone."

Apply conservatively. Preserve decisions, commitments, owners, dates, maturity markers, and explicit uncertainty.

### Optional Depth Check

If uncertain about the right depth on a specific theme after drafting, ask one targeted question before finalizing. See Question Design.

## Quality Rules

- Organize thematically, not chronologically.
- Order themes by significance to the conversation, not by type.
- Preserve the thread type's natural value: decisions need precision, explorations need the hypothesis preserved, context needs the relational signal.
- Layer within themes (for `full` depth): strategic before technical before open threads.
- Consolidate repeated or scattered discussion into one logical theme.
- Mention each concept once in its best location.
- Shorten points to the core idea without dropping owners, dates, commitments, maturity markers, or ambiguity signals.
- Keep uncertainty explicit when the transcript is ambiguous.
- Never add information not grounded in the transcript or user-supplied context.

## Question Design

Used only for the optional depth check in Pass 2.

- Offer 2-4 clear options per question.
- Make the trade-offs about depth: full detail vs. strategic summary vs. brief mention.
- Keep questions decision-forcing rather than open-ended.

## Final Output

Return polished meeting minutes in Markdown. The delivered minutes must reflect the final shortening pass and use a direct tone.

Example theme block:

    ## Auth System Rewrite [decision]

    **Strategic context:** Switching to JWT removes the last blocker on the mobile client launch.
    **Technical:** Replace session-cookie middleware with stateless JWT validation; ~3 days of work. Open: token refresh strategy not yet decided.
    **Decision:** Proceed. Paul owns implementation, target done by end of sprint.

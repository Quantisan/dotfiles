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

Read the full transcript and any user context. Scan for signals: decisions made, action items assigned, insights surfaced, and context established. Cluster related signals into 3-5 themes. Present the result as a compact numbered list, one line per theme:

```
1. **Auth System Rewrite** [decision, full] — Switching to JWT removes the last mobile blocker.
2. **Team Dynamics** [context, summary] — Alex flagged burnout risk on the infra team.
3. **Pricing Model** [exploration, mention] — Floated usage-based pricing but no conclusion.
```

Format: `**Theme** [type, depth] — key signal`

- **type** — dominant signal in the cluster: `decision` (commitments made), `exploration` (insights without resolution), `context` (relational or situational)
- **depth** — signal density: `full` (rich cluster — multiple decisions, supporting detail, open threads), `summary` (a few clear signals, 2-4 bullets), or `mention` (sparse — single sentence noting it occurred)
- **key signal** — the most important point in ≤12 words

**Grouping guidance:** Aim for 3-5 themes total. Prefer fewer, broader themes over many granular threads. Group related sub-topics under one theme rather than splitting them. The user can split a theme during review if they want more granularity.

After the numbered thread list, include a one-line note of topics excluded from the map:

*"Excluded: [brief list of topics discussed but not mapped]."*

Present the map as a default that will proceed unless the user changes it. Surface 1-2 specific judgment calls as targeted questions — e.g., "I grouped X and Y together — should I split them?" or "I classified Z as exploration but they may have decided."

Available adjustments:
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

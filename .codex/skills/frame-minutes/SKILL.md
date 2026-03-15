---
name: frame-minutes
description: "Use when a user provides a pre-cleaned transcript (Speaker: utterance format) and wants structured meeting minutes using bottom-up fact extraction -- especially for co-founder chats, customer discovery, or advisor calls where alignment and shared context matter alongside decisions."
---

# Frame Minutes

Turn pre-cleaned transcript text into structured minutes using bottom-up fact extraction. Themes emerge from where facts cluster, not from top-down categorization.

## Inputs

- Require pre-cleaned transcript text in `Speaker: utterance` format (output of `rewrite-call-transcript`).
- Preserve speaker names from the transcript — attribute facts, decisions, and action items to named individuals.
- Accept optional background context from the user.

## Function Labels

Every extracted fact gets one label:

| Label | Captures |
|-------|----------|
| **Decision** | A choice was made or commitment given. Action items surface through metadata (owner + deadline) on Decision labels — a decision with an owner and date is an action item. |
| **Alignment** | Shared understanding established or confirmed between participants. |
| **Insight** | New understanding surfaced during discussion. |
| **Context** | Background information relevant to other facts. |

## Pipeline

### Turn 1: Extract & Score

Read the full transcript. Internally:
1. Extract atomic facts as `(statement, speaker, context)` tuples
2. Label each fact: Decision / Alignment / Insight / Context
3. Score relevance 1–10 relative to this transcript (decisions tend toward 9–10, supporting context toward 4–6)
4. Cluster facts by topic proximity — themes emerge bottom-up from where facts cluster
5. Retain ~40% of facts (drop lowest relevance scores)

**Output to user:** Compact theme map (aim for 3–7 themes; prefer fewer, broader themes):

```
1. **Auth migration path** [3 decisions, 1 alignment] — JWT removes the last mobile blocker
2. **Series A timing** [2 alignments, 1 insight] — Both leaning toward Q3 if ARR hits 800k
3. **Customer onboarding friction** [1 insight, 3 context] — Drop-off at step 3 is 40%

Excluded: weekend plans, restaurant recommendations
```

Format: `N. **Theme name** [label counts] — key signal in ≤12 words`

Include an *"Excluded: [brief list]"* line for topics dropped (passing mentions, off-topic). When borderline, include as a low-relevance theme rather than excluding.

**Debug affordance:** If the user asks to see raw facts, show the scored fact list before the theme map.

**Questions (max 2):** Multiple-choice, 2–4 described options each, targeting genuine ambiguity the LLM cannot confidently resolve. User should be able to answer by reading the theme map, without returning to the transcript. Default path: "looks good" or equivalent proceeds as-is.

Example question format:
> *Themes 2 ('Series A timing') and 3 ('Customer onboarding') both touch growth. How should I handle them?*
> - **Keep separate** — Distinct enough that separate sections serve reference better
> - **Merge into 'Growth strategy'** — The connection between them is the interesting part
> - **Merge, lead with onboarding** — The customer data is more actionable than the timing discussion

### Turn 2: Organize

Using the validated theme map:
1. Order themes by combined fact relevance
2. Highest-scoring facts + all Decisions/Alignments → major outline points
3. Remaining retained facts → supporting detail nested under major points

**Output to user:** Structured outline skeleton:

```
## Auth migration path [decision]
- Switching to JWT — removes last mobile blocker (Paul, by Mar 22)
- Session handling: server-side tokens deprecated
  - Migration window agreed: 2 weeks with fallback

## Series A timing [alignment]
- Both leaning Q3 if ARR hits 800k
  - Investor intros paused until metrics milestone
```

**Questions (max 2):** Multiple-choice, targeting ambiguity. User should be able to answer by reading the outline, without returning to the transcript. Default path proceeds if user doesn't engage.

Example question format:
> *'Pricing model' came up three times but with mixed signals. How should I frame it?*
> - **Decision reached** — The last exchange settled it; earlier hesitation is just context
> - **Still exploring** — No clear convergence; mark as open with options discussed
> - **Alignment without decision** — You both see the problem the same way but haven't picked an approach

### Turn 3: Write & Tighten

No questions. Final output:
1. Render structured outline with:
   - Theme headings ordered by significance
   - Nested bullets with inline function labels: `[decision]`, `[alignment]`, `[insight]`, `[context]`
   - Metadata where applicable: speakers, owners, dates
2. Shortening pass: compress each point to the key idea
   - Preserve: decisions, commitments, owners, dates, alignment markers, explicit uncertainty
   - Remove: filler, redundancy, over-explanation

Example final output:

```
## Auth migration path

- [decision] Switching to JWT for mobile auth — removes last blocker (Paul, by Mar 22)
- [decision] Server-side session tokens deprecated; 2-week migration window with fallback
- [alignment] Both comfortable with migration risk given current user count

## Series A timing

- [alignment] Leaning Q3 if ARR hits 800k — shared conviction this is the threshold
- [decision] Investor intros paused until metrics milestone hit
- [insight] Board seat expectations may differ between target leads — needs research
```

## Quality Rules

- Thematic organization, not chronological
- Order themes by significance
- Consolidate scattered discussion of the same topic
- Mention each concept once in its best location
- Keep uncertainty explicit — never upgrade "we should think about" to a decision
- Never add information not grounded in the transcript
- Alignment and context are first-class, not supporting detail for decisions

## Baked-in Reader Assumptions

- Reader is the meeting participant
- Primary use: future reference and pattern recognition
- Values alignment and shared context alongside decisions
- Needs facts well-labeled for later search and dot-connecting

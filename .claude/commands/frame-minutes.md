---
argument-hint: <dialogue-file>
description: Turn a cleaned Speaker:utterance transcript into structured meeting minutes via bottom-up fact extraction
allowed-tools: Read, Agent, Write
---

Turn a pre-cleaned `Speaker: utterance` transcript into structured minutes through bottom-up fact extraction. Themes emerge from where facts cluster, not from top-down categorization.

**Defining value:** distill by cutting, not rewriting. What remains after compression must be the speaker's own phrasing, style, and rhythm. These minutes should sound like the speakers — not like a secretary.

Dialogue file: `$ARGUMENTS`

## Step 1 — Resolve the output path

Dispatch an `Agent` (`subagent_type: general-purpose`, `model: haiku`) to resolve the minutes output path. Brief it with the input dialogue path (`$ARGUMENTS`) only. Ask it to:

- `ls` the parent directory of the input.
- Identify the input's trailing suffix segments (e.g. `.dialogue.txt`).
- Look for sibling files that share the input's stem but use a `minutes`-containing suffix (e.g. `.minutes.md`, `.minutes.txt`). If found, build the output path by replacing the input's suffix with that sibling-attested minutes suffix. If multiple variants exist, pick the most common one.
- If no informative sibling pattern exists, fall back: strip the input's extension(s) and append `.minutes.md`.

The sub-agent returns one line: the resolved output path. No directory listing, no rationale, nothing else. Hold this path in your working notes and use it verbatim in Step 5.

## Step 2 — Read the dialogue

Use the `Read` tool on `$ARGUMENTS`. The cleaned dialogue stays in your context for the rest of the run — fidelity to each speaker's phrasing matters more than context economy here, and the input is already distilled.

Preserve speaker names from the transcript. Attribute facts, decisions, and action items to named individuals.

## Step 3 — Turn 1: Extract & Score → Theme Map

**Do internally (do not show this work in your reply):**

1. Extract atomic facts as `(distilled utterance, speaker, line, context)` tuples — distill by cutting, not rewriting. Remove filler, false starts, and redundancy; keep the speaker's phrasing and style. `line` is the line number where the fact lands in the dialogue file (the `Read` tool returns lines with line-number prefixes). Capture line numbers now — they become citations in Turn 3.
2. Label each fact: `Decision` / `Alignment` / `Insight` / `Context`.
   - **Decision** — a choice was made or commitment given. Action items surface through metadata (owner + deadline) on Decision labels — a decision with an owner and date is an action item.
   - **Alignment** — shared understanding established or confirmed between participants.
   - **Insight** — new understanding surfaced during discussion.
   - **Context** — background information relevant to other facts.
3. Score relevance 1–10 relative to this transcript (decisions tend toward 9–10; supporting context toward 4–6).
4. Cluster facts by topic proximity — themes emerge bottom-up from where facts cluster.
5. Retain ~40% of facts (drop the lowest relevance scores).

**Show to the user — a compact theme map** (aim for 3–7 themes; prefer fewer, broader themes):

```
1. **Auth migration path** [3 decisions, 1 alignment] — JWT removes the last mobile blocker
2. **Series A timing** [2 alignments, 1 insight] — Both leaning toward Q3 if ARR hits 800k
3. **Customer onboarding friction** [1 insight, 3 context] — Drop-off at step 3 is 40%

Excluded: weekend plans, restaurant recommendations
```

Format: `N. **Theme name** [label counts] — key signal in ≤12 words`. The key signal must carry enough information that the user can answer the questions below *without re-opening the transcript*.

Include an `Excluded:` line for topics dropped (passing mentions, off-topic). When borderline, include as a low-relevance theme rather than excluding.

**Debug affordance:** if the user asks to see raw facts, show the scored fact list before the theme map.

**Questions (max 2):** Multiple-choice, 2–4 described options each, targeting genuine ambiguity you cannot confidently resolve. Default path: `looks good` or equivalent proceeds as-is.

Example question format:
> *Themes 2 ('Series A timing') and 3 ('Customer onboarding') both touch growth. How should I handle them?*
> - **Keep separate** — Distinct enough that separate sections serve reference better.
> - **Merge into 'Growth strategy'** — The connection between them is the interesting part.
> - **Merge, lead with onboarding** — The customer data is more actionable than the timing discussion.

**Stop after the theme map and wait** for the user's reply before Turn 2. Do not roll into Turn 2 in the same response.

## Step 4 — Turn 2: Organize

Using the validated theme map:

1. Order themes by combined fact relevance.
2. Highest-scoring facts + all Decisions/Alignments → major outline points.
3. Remaining retained facts → supporting detail nested under major points.

**Show to the user — a structured outline skeleton:**

```
## Auth migration path [decision]
- JWT is the move — kills the last mobile blocker (Paul, by Mar 22)
- "We're done with server-side tokens" — deprecated, 2-week window with fallback baked in

## Series A timing [alignment]
- Both "pretty convinced" Q3 if ARR hits 800k
  - "Not worth the distraction" — intros paused until milestone hit
```

**Questions (max 2):** Multiple-choice, targeting ambiguity in framing. User should be able to answer by reading the outline, without returning to the transcript. Default proceeds.

Example question format:
> *'Pricing model' came up three times but with mixed signals. How should I frame it?*
> - **Decision reached** — The last exchange settled it; earlier hesitation is just context.
> - **Still exploring** — No clear convergence; mark as open with options discussed.
> - **Alignment without decision** — You both see the problem the same way but haven't picked an approach.

**Stop after the outline and wait** for the user's reply before Turn 3.

## Step 5 — Turn 3: Write, Tighten, and persist

No questions this turn.

Render the final structured outline:

- Theme headings (`##`) ordered by significance. No type tag on the heading.
- Optional plain-text sub-section headers within a theme when discussion clusters into sub-threads (no bold, no bullet — just a line).
- Bullets begin with the function label: `[decision]`, `[alignment]`, `[insight]`, `[context]`.
- Speaker attribution at the start of the bullet when one speaker drives the fact (`Paul: …`, `Dave: …`). Omit when the fact is jointly held.
- **Weave direct quotes from the transcript wherever they carry the punch.** Quote the speaker's exact wording for the spicy bits; paraphrase only the connective tissue. This is how "distill by cutting, not rewriting" shows up in the final output — the page should feel like the speakers, not like a summary of them.
- **Cite each bullet** with the dialogue line number as `:NNN` at the end. The dialogue filename is constant for the run, so do not repeat it per bullet — citing the bare line number is intentional, not an oversight.
- Metadata (owners, dates) inline, not in a separate block.

Apply one shortening pass: compress each point to the key idea.

- Preserve: decisions, commitments, owners, dates, alignment markers, explicit uncertainty.
- Remove: filler, redundancy, over-explanation.
- Distill by cutting, not rewriting — what remains after compression should be the speaker's own phrasing, their style, rhythm, and word choices. Don't normalize into a "minutes voice."

Example final shape:

```
## Auth migration path

JWT cutover
- [decision] Paul: JWT is "the move" — kills the last mobile blocker. Target Mar 22. :225
- [decision] "Done with server-side tokens" — deprecated; 2-week window with fallback. :243
- [alignment] Both "fine with the risk at this scale." :251

## Series A timing

- [alignment] Both "pretty convinced" Q3 if ARR hits 800k. :310
- [decision] "Not worth the distraction" — intros paused until milestone hit. :322
- [insight] Board seat expectations "vary a lot" between target leads — needs research. :340
```

Write this content to the output path resolved in Step 1 using the `Write` tool. Overwrite if the path already exists.

After writing, print one short line confirming the output path. Nothing else.

## Quality rules

- Thematic organization, not chronological.
- Order themes by significance.
- Consolidate scattered discussion of the same topic.
- Mention each concept once in its best location.
- Keep uncertainty explicit — never upgrade "we should think about" to a decision.
- Never add information not grounded in the transcript or user-supplied context.
- Alignment and context are first-class, not supporting detail for decisions.
- The reader is a meeting participant using the minutes for future reference and pattern recognition; they value alignment and shared context alongside decisions, and need facts well-labeled for later search.

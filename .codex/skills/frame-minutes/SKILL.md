---
name: frame-minutes
description: "Use when a user provides a pre-cleaned Speaker: utterance dialogue file and wants structured meeting minutes, especially for co-founder chats, customer discovery, or advisor calls; do not use for raw call, meeting, or VTT transcripts."
---

# Frame Minutes

Turn a pre-cleaned `Speaker: utterance` dialogue file into structured minutes through bottom-up fact extraction. Themes emerge from where facts cluster, not from top-down categorization.

**Defining value:** distill by cutting, not rewriting. What remains after compression must be the speaker's own phrasing, style, and rhythm. These minutes should sound like the speakers — not like a secretary.

## Three-turn contract

Advance exactly one user-visible stage per assistant turn:

1. Initial request: resolve the output path, read the dialogue with line numbers, show the theme map, then stop and wait.
2. First user reply: incorporate the user's theme feedback, show the outline, then stop and wait.
3. Second user reply: incorporate the user's outline feedback, write the final minutes, and return only a short path confirmation.

Do not combine stages, even when there are no ambiguity questions or the user says to proceed automatically. Keep the resolved output path, numbered dialogue, extracted facts, scores, labels, and user feedback in working context across all three turns.

## Step 1 — Resolve the output path

Resolve the minutes output path internally before reading the dialogue. Use read-only shell inspection such as `ls` on the input file's parent directory; do not delegate this work or show it to the user.

- Identify the input's trailing suffix segments (for example, `.dialogue.txt`).
- Look for sibling files that share the input's stem but use a `minutes`-containing suffix (for example, `.minutes.md` or `.minutes.txt`).
- If a sibling-attested minutes suffix exists, build the output path by replacing the input's suffix with that minutes suffix. If multiple variants exist, choose the most common one.
- If no informative sibling pattern exists, strip the input's extension or extensions and append `.minutes.md`.

Hold the one resolved output path in working context. Use it verbatim in Turn 3 and do not recompute it. Do not create, truncate, or otherwise modify the output file during Turn 1.

## Step 2 — Read the dialogue

Read the entire dialogue once with stable, one-based line numbers, using a read-only command such as:

```bash
nl -ba -- "<dialogue-file>"
```

Keep the numbered dialogue in context for the rest of the run. Fidelity to each speaker's phrasing matters more than context economy because the input is already distilled.

Preserve speaker names from the dialogue. Attribute facts, decisions, and action items to named individuals. Accept explicit background context supplied by the user, but ground all content in the dialogue or that user-supplied context.

## Step 3 — Turn 1: Extract & Score → Theme Map

**Do internally; do not show this work unless the user asks for raw facts:**

1. Extract atomic facts as `(distilled utterance, speaker, line, context)` tuples. Distill by cutting, not rewriting: remove filler, false starts, and redundancy while keeping the speaker's phrasing and style. `line` is the numbered dialogue line where the fact lands. Capture line numbers now for Turn 3 citations.
2. Label each fact:
   - **Decision** — a choice was made or commitment given. Action items surface through inline owner-and-deadline metadata on Decision labels; a decision with an owner and date is an action item.
   - **Alignment** — shared understanding established or confirmed between participants.
   - **Insight** — new understanding surfaced during discussion.
   - **Context** — background information relevant to other facts.
3. Score relevance from 1–10 relative to this dialogue. Decisions tend toward 9–10; supporting context tends toward 4–6.
4. Cluster facts by topic proximity. Themes emerge bottom-up from where facts cluster.
5. Retain about 40% of facts by dropping the lowest relevance scores.

Show a compact theme map. Aim for 3–7 themes and prefer fewer, broader themes:

```markdown
1. **Auth migration path** [3 decisions, 1 alignment] — JWT removes the last mobile blocker
2. **Series A timing** [2 alignments, 1 insight] — Both leaning toward Q3 if ARR hits 800k
3. **Customer onboarding friction** [1 insight, 3 context] — Drop-off at step 3 is 40%

Excluded: weekend plans, restaurant recommendations
```

Use `N. **Theme name** [label counts] — key signal in ≤12 words`. Make the key signal informative enough that the user can answer any question without reopening the dialogue.

Include an `Excluded:` line for dropped passing mentions and off-topic material. When borderline, include the material as a low-relevance theme rather than excluding it.

If the user asks to see raw facts, show the scored fact list before the theme map and remain on Turn 1.

Ask zero, one, or two multiple-choice questions only for genuine ambiguity that cannot be resolved confidently. Give 2–4 described options per question. The default path is `looks good` or equivalent. Do not invent a question merely to fill the slot.

Example:

> *Themes 2 ('Series A timing') and 3 ('Customer onboarding') both touch growth. How should I handle them?*
> - **Keep separate** — Distinct enough that separate sections serve reference better.
> - **Merge into 'Growth strategy'** — The connection between them is the interesting part.
> - **Merge, lead with onboarding** — The customer data is more actionable than the timing discussion.

Stop after the theme map and any questions. Wait for the user's reply before Turn 2.

## Step 4 — Turn 2: Organize

Using the validated theme map:

1. Order themes by combined fact relevance.
2. Promote the highest-scoring facts and every Decision and Alignment to major outline points.
3. Nest the remaining retained facts as supporting detail beneath major points.

Show a structured outline skeleton:

```markdown
## Auth migration path [decision]
- JWT is the move — kills the last mobile blocker (Paul, by Mar 22)
- "We're done with server-side tokens" — deprecated, 2-week window with fallback baked in

## Series A timing [alignment]
- Both "pretty convinced" Q3 if ARR hits 800k
  - "Not worth the distraction" — intros paused until milestone hit
```

Ask zero, one, or two multiple-choice questions only for genuine ambiguity in framing. Give enough detail in the outline and in 2–4 described options that the user need not reopen the dialogue. The default proceeds.

Example:

> *'Pricing model' came up three times but with mixed signals. How should I frame it?*
> - **Decision reached** — The last exchange settled it; earlier hesitation is context.
> - **Still exploring** — No clear convergence; mark it open with the options discussed.
> - **Alignment without decision** — The problem is shared, but no approach was chosen.

Stop after the outline and any questions. Wait for the user's reply before Turn 3.

## Step 5 — Turn 3: Write, Tighten, and Persist

Ask no questions. Render the final minutes with this exact contract:

- Order `##` theme headings by significance. Put no type tag on a theme heading.
- Use optional plain, unbolded subsection labels inside a theme when discussion clusters into sub-threads. A subsection label is a standalone line, not a bullet.
- Begin every bullet with exactly one function label: `[decision]`, `[alignment]`, `[insight]`, or `[context]`.
- Put speaker attribution immediately after the function label when one speaker drives the fact (`- [decision] Paul: …`). Omit speaker attribution when the fact is jointly held.
- Weave exact direct quotes from the dialogue wherever the original wording carries the force. Quote the speaker's exact wording for the spicy bits; paraphrase only connective tissue.
- End every bullet with its captured dialogue line number as `:NNN`. Use the actual bare line number and do not repeat the dialogue filename.
- Keep owners and dates inline, never in a separate metadata block.

Apply one shortening pass to compress each point to the key idea:

- Preserve decisions, commitments, owners, dates, alignment markers, and explicit uncertainty.
- Remove filler, redundancy, and over-explanation.
- Distill by cutting, not rewriting. Keep the speakers' phrasing, style, rhythm, and word choices; do not normalize into a minutes voice.

Example final shape:

```markdown
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

Write the content to the output path resolved in Step 1 using `apply_patch`. If the resolved output file already exists, overwrite its content. Do not write any other meeting file.

After the write succeeds, return exactly one short line confirming the output path and nothing else.

## Quality rules

- Organize thematically, not chronologically.
- Order themes by significance.
- Consolidate scattered discussion of the same topic.
- Mention each concept once in its best location.
- Keep uncertainty explicit. Never upgrade `we should think about`, `we could`, `maybe`, or another suggestion into a decision.
- Never add information not grounded in the dialogue or explicit user-supplied context.
- Treat Alignment and Context as first-class facts, not merely supporting detail for Decisions.
- Serve a meeting participant using the minutes for future reference and pattern recognition; preserve alignment and shared context alongside decisions, and label facts for later search.

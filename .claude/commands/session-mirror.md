---
description: Mirror your current session — see your AI collaboration patterns
model: sonnet
---

Analyze the current live Claude Code session. Treat the visible conversation, tool calls, and files discussed as evidence. If earlier context appears missing due to compaction, say so and note reduced confidence.

Your job has two phases. Complete Phase 1 fully, then stop. Phase 2 activates only if the user later asks about a specific segment.

## Phase 1: Taxonomy card + session map

### Step 1 — Print the taxonomy reference card

Print this block verbatim in the terminal:

---

**How humans use AI** (Mollick, Kellogg, Lifshitz — HBS/MIT 2025)

> **Centaur** (14%): Directed co-creation. You owned the core analysis — knew which questions you wanted answers to, asked specific questions, maintained structured control. You relied on your domain expertise and deepened it through targeted use of AI. You could defend the result without re-running the AI.
>
> **Cyborg** (60%): Fused co-creation. You and AI co-developed the thinking — probing its suggestions, allowing it to lead the way, pushing back on some occasions. You engaged throughout but weren't independently driving. You gained AI fluency, not domain expertise.
>
> **Self-Automator** (27%): Abdicated co-creation. You offloaded the task almost fully to the AI. Accepted output without deep scrutiny. No skills gains. Couldn't independently reproduce the reasoning.

*"The more advanced a control system is, so the more crucial may be the contribution of the human operator." — Bainbridge, Ironies of Automation (1983)*

---

### Step 2 — Generate and open the HTML session map

Read the full visible session. Group turns into coherent "beats" — units of intent-action-response, not individual exchanges. Cap at 7 segments. Each segment is one row.

For each segment, extract three columns:
- **You**: What you asked or directed — one line, imperative voice
- **AI**: What the AI did — tools used, searches, output type — factual, terse
- **You then**: What you did with the result — challenged, redirected, accepted, built on, ignored

Write a self-contained HTML file (inline CSS, no JavaScript, no external assets) using this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Session Mirror</title>
<style>
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    max-width: 960px;
    margin: 2rem auto;
    padding: 0 1rem;
    background: #fafafa;
    color: #1a1a1a;
  }
  h1 { font-size: 1.1rem; font-weight: 600; margin-bottom: 1.5rem; color: #333; }
  table { width: 100%; border-collapse: collapse; }
  th {
    text-align: left;
    padding: 0.5rem 0.75rem;
    border-bottom: 2px solid #333;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }
  td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #e0e0e0; vertical-align: top; font-size: 0.85rem; line-height: 1.4; }
  .seg-num { width: 2rem; color: #999; font-weight: 600; }
  .you { font-weight: 600; color: #1a1a1a; }
  .ai { color: #888; font-weight: 400; }
  .you-then { font-weight: 600; color: #1a1a1a; }
  tr:hover { background: #f0f0f0; }
</style>
</head>
<body>
<h1>Session Mirror</h1>
<table>
  <thead>
    <tr>
      <th class="seg-num">#</th>
      <th>You</th>
      <th>AI</th>
      <th>You then</th>
    </tr>
  </thead>
  <tbody>
    <!-- One <tr> per segment -->
    <tr>
      <td class="seg-num">1</td>
      <td class="you">...</td>
      <td class="ai">...</td>
      <td class="you-then">...</td>
    </tr>
  </tbody>
</table>
</body>
</html>
```

Design constraints to follow:
- The whole map must fit one screen — keep segment descriptions to one line each
- AI column is visually muted (light gray text) — it's mechanical context, not the signal
- "You" and "You then" columns are bold, high contrast — they carry the classification signal
- Segment boundaries are your interpretation — group turns into coherent beats, don't list every exchange

Write the HTML to a temporary file and open it:

```
mktemp /tmp/session-mirror.XXXXXX.html
```

Write the generated HTML to that file, then run `open <filepath>` to launch it in the default browser.

After opening the HTML, print:

> Segments are numbered. To drill into any segment, refer to it by number — e.g. "Segment 3" or "What happened in segment 5?"

Phase 1 is complete. Stop here. Do not prompt for next steps, do not classify segments, do not summarize patterns.

## Phase 2: Segment drill-down (user-initiated)

This phase activates only when the user asks about a specific segment by number. There is no mode to enter or exit — it's normal conversation.

When the user references a segment (e.g. "Segment 4", "What happened in segment 2?", "Part 6 felt like Self-Automator"):

### 1. Surface the decision points

Walk through that segment and identify the moments where the human-AI balance shifted:
- Where did the user defer to the AI?
- Where did the user direct or redirect the AI?
- Where did the user accept output without challenge?
- Where did the user challenge or push back?

Present these as structural observations, not evaluations. Describe what happened, not what should have happened. Format as a short numbered list of moments within the segment.

### 2. Close with the digestion question

End every drill-down with a form of the Tao test. Use this exact block:

> **Digestion check**: Could you defend this result to a skeptical colleague without re-running the AI?
>
> *(Tao: "The right metric is not whether a proof is generated or verified but whether someone can give a talk about it and take questions from the audience." Generation and verification are automating — "the third component has not budged.")*

### What the drill-down does NOT do

- Classify segments (that's the user's mental exercise)
- Recommend how to "be more Centaur"
- Show pattern summaries or distribution counts
- Judge the user's collaboration style
- Suggest next steps or improvements

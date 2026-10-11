---
name: discovery-crawl-brief
description: Use when Paul gives an idea or direction to explore rather than a claim to test — "see what's out there", "give me new ideas", "where do people talk about this" — and wants a discovery crawl. Turns the prompt into a crawl brief; nothing runs until Paul invokes /discovery-crawl on that brief. Invocable manually as /discovery-crawl-brief. For testing evidence, scoring, or ranking, use research-hunt-brief instead.
---

# discovery-crawl-brief — turn a direction into a crawl brief

The brief is the pipe between Paul's prompt and the crawl: Paul reviews the brief file, and invoking `/discovery-crawl <brief.md>` on it is the go. This skill only writes the brief. It never launches the engine.

A crawl explores. It has no scoring axes, rank rules, seeds, clustering keys, lenses, hardest question, or out-of-scope list — leave them out even when the direction seems to invite them. Only the hard limits fence a crawl. If the prompt asks to test, score, or rank something, it wants `research-hunt-brief`; say so in one line.

## Resolve the research location

Once per crawl, in the current project:

- If a `research/` directory exists, use it (or the subdirectory where related briefs already live).
- Else if a `docs/` directory exists, use `docs/research/` (create it).
- Else create `research/` at the repo root.
- Only if the convention is genuinely ambiguous, confirm the location in one line before writing.

## Write the brief

Write `<research-location>/YYYY-MM-DD.<slug>-brief.md`. Freeform prose, but it must contain every element in `brief-contract.md` (beside this file), with the engine parameters one-to-one with the ARGS CONTRACT at the top of `~/.claude/workflows/discovery-crawl.js`.

Ask only what you genuinely cannot infer. Defaults (`rounds: 5`, `searchesPerRound: 4`) are never asked about. For "already known", look in the research location for earlier reports and briefs on the same direction and list them; Paul strikes any that don't belong.

The brief is pure intent and is **never mutated after writing**. Execution facts belong to the map the launch skill writes. Write it and stop.

## Common mistakes

- Adding scoring axes, a rank rule, seeds, or an out-of-scope list — they turn the crawl back into a hunt.
- Narrowing the direction into a research question. The direction is Paul's prompt verbatim; it is a starting point, not a fence.
- Starting angles that are all variations of one search. Each should come at the direction from a different side: a different place, a different kind of person, a different word for it.
- Writing the brief into the dotfiles repo or `~/.claude/`.
- Launching the engine, or asking "shall I launch?" — the go is Paul invoking `/discovery-crawl` on the brief file.

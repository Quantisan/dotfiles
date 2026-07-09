---
name: research-hunt-brief
description: Use when Paul directs a new "what's out there" research round — a directional prompt naming a space to survey or a fork to settle with outside evidence (portrayals, devices, literatures, prior art). Turns the prompt into a reviewable brief; nothing runs until Paul invokes /research-hunt on that brief. Invocable manually as /research-hunt-brief.
---

# research-hunt-brief — turn a directional prompt into a reviewable brief

The brief is the pipe between intake and launch: Paul reviews the brief file, and invoking `/research-hunt <brief.md>` on it is the go. This skill only writes the brief — it never launches the engine.

## Clarify intent

Pin down the goal, the scope, and what evidence counts. Infer everything you can from the directional prompt and the project; ask only what you genuinely cannot infer — typically the rank spec's order, the Phase-3 mode, or a scope edge the prompt leaves ambiguous. No slot-by-slot procedure, no question budget, no style-matching against prior briefs.

## Resolve the research location

Once per round, in the current project:

- If a `research/` directory exists, use it.
- Else if a `docs/` directory exists, use `docs/research/` (create it).
- Else create `research/` at the repo root.
- Only if the project's convention is genuinely ambiguous, confirm the location in one line before writing.

## Write the brief

Write `<research-location>/YYYY-MM-DD.<slug>-brief.md`. Freeform prose, but it must contain every required element in `brief-contract.md` (beside this file) — the directional prompt verbatim, the engine parameters one-to-one with the engine's ARGS CONTRACT, and the expected cost. The cost belongs in the brief because review time is when it is decision-relevant.

The brief is pure intent and is **never mutated after writing** — no status slot, no go/abort updates. Execution facts (parameters as run, engine version) belong to the report the launch skill writes. An unlaunched brief sitting in the research location is its own record; write it and stop.

## Common mistakes

- Asking about a parameter with a stated default or an inferable answer — the interface is directional prompt in, questions only when genuinely underspecified.
- Writing the brief into the dotfiles repo or `~/.claude/` — briefs belong in the **current project's** research location.
- Launching the engine, or asking "shall I launch?" — the go is Paul invoking `/research-hunt` on the brief file, nothing else.

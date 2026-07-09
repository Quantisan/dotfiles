---
name: research-hunt
description: Use when Paul directs a new "what's out there" research round — a directional prompt naming a space to survey or a fork to settle with outside evidence (portrayals, devices, literatures, prior art). Also use when relaunching or resuming such a round. Invocable manually as /research-hunt.
---

# research-hunt — launch harness for a research round

Turns a directional prompt into a full research round: materialized launch brief → Paul's go/no-go → 3-phase multi-agent engine → findings survey. The methodology is invariant and lives in the engine; the per-round slots are the only authored parts. The why of the engine's design is in `reference.md` beside this file — **read it before editing the engine**, and record any post-shakedown engine edit's rationale there.

**Paths.** The skill is repo-agnostic — it runs in whatever project Paul directs a round from. The engine runs from its installed location `~/.claude/workflows/research-hunt.js`; its canonical source lives in the dotfiles repo, whose checkout path bootstrap records at `~/.claude/workflows/.source`. Edits go to the canonical source, then `source bootstrap.sh` reinstalls it. Round artifacts (brief, survey) are written into the **current project**, at its inferred research location (see Step 2).

Hard rule: **the engine never launches without Paul's go on a materialized brief.** No exception for "obvious" rounds or re-runs with edited slots.

## Step 1 — Fill the slots

Read `brief-template.md` (beside this file) and fill its slots from the directional prompt. Infer aggressively: prior briefs in the project's research location (`*launch-brief*.md`, if any exist) show the house style per slot, and the template carries budget-knob defaults. First round in a project — no prior briefs — is normal: infer from the template defaults and the directional prompt alone, and expect to spend the full question budget below. Then ask narrowing questions — **only for slots you genuinely cannot infer, 2–3 at most, in one batch** (AskUserQuestion). Typical genuinely-open slots: the rank spec's order, the Phase-3 mode, a scope edge the prompt leaves ambiguous. Never ask about a slot with a template default or an inferable answer.

## Step 2 — Materialize the brief

First, resolve the **research location** in the current project (do this once; both the brief and the survey land here):

- If a `research/` directory exists, use it.
- Else if a `docs/` directory exists, use `docs/research/` (create it).
- Else create `research/` at the repo root.
- Only if the project's convention is genuinely ambiguous, confirm the location in one line before writing.

Write the filled brief to `<research-location>/YYYY-MM-DD.<slug>-launch-brief.md`, following the template's invariant text exactly. The template's header block (What it is / is not · Status & authorship · Related artifacts · provenance trail) **is** the artifact convention — this skill is self-contained and needs no external artifact skill. The header+trail shape is deliberately kept so a downstream artifact skill (e.g. a `strategic-artifact` skill, where one exists) can adopt the file — but nothing requires one.

Record the engine's version in the Status slot: the short-hash of the canonical engine source, `git -C "$(cat ~/.claude/workflows/.source)" log -1 --format=%h -- .claude/workflows/research-hunt.js`.

Then run the **self-verify pass** (same pass used for the survey in Step 5):

1. Every `{{slot}}` is filled — no double-braces, no `TBD`, no placeholder text left in.
2. Invariant template text is verbatim — you changed only the slots.
3. Provenance trail: each slot that came from Paul is attributed to him verbatim; each inferred slot is one consolidated `agent synthesis, no source` line.
4. Internal consistency — axes referenced in the rank spec exist in the axes slot; seed count matches the seed list; perspective/lens counts match their lists.

The brief is written **before** the go/no-go on purpose: an aborted run still leaves its record.

## Step 3 — Go/no-go

Present one screen: the goal, the axes + rank spec, the perspectives and lenses, the seeds + novelty floor, the Phase-3 mode, the budget knobs, **and the expected cost** — the agent-call count the knobs imply: perspectives + wildcard + ~1 clustering pass per perspective pair + gate + seed benchmark, then 6 per gated candidate (3 lens scouts, case lead, 2 verifiers) + cross-case gate, then question gate + up to maxRefuterRounds refuters + verdict, + 1 critic. Defaults land around 40–70 calls (mixed Sonnet/Opus); the dominant term is 6 × maxGated. Then stop. Paul decides.

- **Go** → update the brief's Status slot to `go (Paul, date)`, proceed.
- **Abort** → update Status to `aborted (reason)`, stop. The brief stays.

## Step 4 — Launch the engine

Pre-flight: the installed engine must match the canonical source — `diff -q ~/.claude/workflows/research-hunt.js "$(cat ~/.claude/workflows/.source)/.claude/workflows/research-hunt.js"`; if they differ, `source bootstrap.sh` first (the version stamp in the brief is otherwise a lie).

Build `args` from the brief per the ARGS CONTRACT block at the top of `research-hunt.js` (slots map one-to-one; pass `date` in — the engine cannot call Date). Launch by explicit path — the engine registers as `research-hunt-engine`, but the installed path is unambiguous and cwd-independent (expand `~` to the home directory):

```
Workflow({ scriptPath: '~/.claude/workflows/research-hunt.js', args: <slots> })
```

- **Engine failure mid-run** → fix or wait, then `Workflow({ scriptPath, resumeFromRunId })`; completed agents return cached.
- **Empty or odd result** → read the run's `journal.jsonl` before re-running anything.

## Step 5 — Write the survey

The engine returns one structured result object; the survey is written here in the main session, never by a subagent. Target file: `<research-location>/YYYY-MM-DD.<slug>-survey.md` (the location resolved in Step 2). It carries the same self-contained artifact header + provenance trail as the brief (header block detailed in the section order below); no external artifact skill is needed.

**Independent re-checks first — before drafting.** The verify lane both fabricates and false-flags. For every load-bearing quote in the result (reception-verdict anchors, flagship quotes, anything the survey will lean on):

1. Fetch the cited source yourself and substring-check the exact quoted words.
2. Re-check the adversarial verifier's **refutations** the same way — a false flag on a real source has happened before.
3. A quote that fails the re-check is de-quoted to a paraphrase or dropped, and the correction is disclosed in the survey's Caveats.

**Survey section order** (the shape the games-round survey settled on):

1. Header block — What it is / is not (run mechanics in one line; the NOT list), Status & authorship (verification-integrity claim), Related artifacts (prose pointers to prior rounds and the anchor artifact, if any), Reading notation (axes, tags, and the weaker-evidence flag for seed-benchmark rows)
2. The ranking in one view — full-treatment candidates table (deep-dive scores; note that gate scores were provisional and superseded)
3. The seed benchmark — light-pass table, flagged as lower-rigor by design (only when seeds went unbenched; omit when `result.phase1.seedBenchmark` is null)
4. Phase 1, auditable — discovery counts and access failures, the saturation sequence (`result.phase1.saturation.sequence`), the gate table with per-row rationale and the novelty-floor arithmetic
5. Per-candidate profiles, one section each — scores with justification, reception verdict, specimens (if any), reading list with per-item confirmation tags, field read
6. Cross-case observations (from the cross-case gate)
7. The honest read — the round's headline conclusion
8. Phase 3 — the question gate's selection rationale (or skip reasons), the refuter trail summary, the stop-rule state, the verdict; `underdetermined-build-probe` is reported as a finding with its probe suggestion (the engine re-asks once when it's missing; if still absent, report the gap)
9. Completeness critic — routed here, tagged next-round input, never into this round's argument
10. Appendix — Leads not pursued (`result.parkedLeads`, grouped by origin, one line each)
11. Caveats — corrections and fabrications caught (verifier lane + your re-checks), scope and evidence limits
12. Provenance trail — pointer to the launch brief §Slots, Paul's go verbatim, one consolidated `agent synthesis, no source` line for the run's judgments

Close with the Step 2 self-verify pass, reported check by check — plus one survey-specific check: every load-bearing claim carries an openable source (the pointer the engine collected), and every load-bearing quote passed the independent re-check above.

## Common mistakes

- Asking narrowing questions for slots the template defaults or the prompt implies — the interface is `/deep-research`-like: directional prompt in, questions only when genuinely underspecified.
- Launching on a verbal "sounds good" without materializing the brief first — the brief is the record; write it, then ask.
- Trusting the verify lane's verdicts in either direction — both confirmations and refutations of load-bearing quotes get the independent substring re-check.
- Writing survey claims from the result object's summaries without the pointers — every claim the survey makes carries the openable source the engine collected.
- Editing `research-hunt.js` without reading `reference.md` — the counters and gates encode retro lessons; an "obvious simplification" can silently delete one. Edit the canonical source in the dotfiles repo, then `source bootstrap.sh` to reinstall.
- Writing the brief or survey into the dotfiles repo or `~/.claude/` — round artifacts belong in the **current project's** research location, never beside the skill.

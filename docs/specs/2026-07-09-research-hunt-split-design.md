# Research-hunt split — design

**Problem.** The research-hunt skill bundles six concerns — intake, record-keeping, governance, launch mechanics, the research engine, and reporting — into one prescriptive ceremony (slot-filling procedure, invariant-text template, go/no-go choreography, 12-section survey outline). Simplify per the Unix philosophy: small, sharp, composable tools focused on research. The methodology encoded in the engine is the valuable part; the ceremony around it grew from one research chain's house style and got carried along.

**Shape.** Two skills, one engine, two artifacts per round. The brief file is the pipe between the two skills, and the seam between them *is* the go/no-go: nothing runs unless Paul invokes the launcher on a brief.

## Skill 1 — `/research-hunt-brief` (intake)

Turns a directional prompt into a reviewable brief.

- Clarifies intent — goal, scope, what evidence counts — asking only what it genuinely cannot infer. No slot-by-slot procedure, no question budgets, no prior-brief style-matching.
- Resolves the research location in the current project (existing rule kept: `research/` if present, else `docs/research/`, else create `research/`).
- Writes `<research-location>/YYYY-MM-DD.<slug>-brief.md`. The brief is pure intent and is never mutated after writing.

**Brief contract — required elements, freeform prose.** No invariant-text regime, no fixed section order. A brief must contain:

1. The directional prompt, verbatim.
2. The engine parameters, one-to-one with the ARGS CONTRACT in `research-hunt.js` (goal, anchor artifact, axes, rank spec + guardrail, clustering key, scope rule, perspectives, lenses, seeds + novelty floor, exclusions, rejected shelf, access strategy, phase-3 mode, budget knobs). Budget-knob defaults kept: `maxGated: 8`, `noveltyFloor: 0.33`, `emptyDoorK: 3`, `stabilityK: 5`, `maxRefuterRounds: 4`.
3. The expected cost — the agent-call count the knobs imply — so cost is visible at review time, when it is decision-relevant.

`brief-template.md` is replaced by this checklist (kept beside the intake skill as its reference). The rank-spec guardrail prose stays a required element — it is methodology, not ceremony.

## Skill 2 — `/research-hunt <brief.md>` (launch)

Invoking it on a brief is the go. Review happens on the brief file, before this command.

- Reads the brief into `args` (the engine validates them at its boundary; mapping gaps surface there).
- One-line drift pre-flight: installed engine must match canonical source, else `source bootstrap.sh` first.
- Launches `Workflow({ scriptPath: '~/.claude/workflows/research-hunt.js', args })`, passing `date` in (scripts cannot call Date).
- Failure mid-run → resume via `resumeFromRunId`; odd or empty result → read the run's `journal.jsonl` before re-running.
- On completion, writes `<research-location>/YYYY-MM-DD.<slug>-report.md` in the main session (never a subagent).

**Report contract — required elements, freeform shape.** The 12-section outline is dropped. A report must contain:

1. Execution facts: pointer to the brief, parameters as run, engine version (short-hash of canonical source at launch). Execution facts live here, not in the brief.
2. Findings, every load-bearing claim carrying an openable source from the engine's result.
3. Caveats: corrections and fabrications caught, access failures, scope and evidence limits.
4. Leads not pursued (`result.parkedLeads`).

**Verification discipline kept in full:** before drafting, every load-bearing quote is independently re-checked (fetch the source, substring-check the exact words), and the verifier lane's *refutations* get the same re-check — both fabrication and false-flagging have happened. Failed re-checks are de-quoted or dropped and disclosed in Caveats.

## Engine — one change

Judgment nodes (discovery gate + retry, case leads, cross-case gate, question gate, verdict + retry) drop `model: 'opus'` and inherit the session model. The pins were right when Opus was the top tier; sessions now run Fable, so the judgment layer was pinned *below* the driving model. Scouts, lens scouts, verifiers, clustering, benchmark, refuters, and critic stay pinned `sonnet` as an explicit cost knob. Effort overrides unchanged. All other engine mechanisms unchanged — they encode run-derived methodology lessons (see `reference.md`).

## reference.md updates

- Tier map section rewritten: judgment nodes inherit the session model; `sonnet` pins are a cost decision.
- Edit-log discipline gains a re-base check: whenever the engine is edited, ask "does the harness now do any of this natively?" and delete what it does.
- Absorbs the maintenance guidance evicted from SKILL.md (edit the canonical source in dotfiles, `source bootstrap.sh` to reinstall, read reference.md before editing).

## Dropped, on the record

- Go/no-go as procedure (one-screen presentation, status-slot updates `pending → go/aborted`). The gate is now structural: the launcher only runs when invoked.
- Abort records — an unlaunched brief sitting in the research location *is* the record.
- The invariant-text regime, the provenance-trail attribution format, and the self-verify pass tied to them. Consistency now comes from naming/location, the two required-element contracts above, and the engine's stable result shape.
- Header-block conventions ("What it is / is not", Status & authorship, Related artifacts) as requirements. A brief or report may carry context prose, but no format is prescribed.
- Maintenance guidance from SKILL.md (moves to reference.md).

## What upstream improvements reach us

Orchestration mechanics (scheduling, structured-output enforcement, resume, journaling) come from harness primitives the engine calls — improvements flow through without edits. Model improvements now reach the judgment layer via session-model inheritance. The methodology itself is deliberately locked in code: it is run-derived domain knowledge upstream will never ship. If native research machinery someday subsumes the engine, the launcher swaps backends; briefs, reports, and the intake skill do not change — the brief is the stable interface.

## Files

| Path | Change |
|---|---|
| `.claude/skills/research-hunt-brief/SKILL.md` | new — intake skill |
| `.claude/skills/research-hunt-brief/brief-contract.md` | new — required-elements checklist + args mapping (replaces `brief-template.md`) |
| `.claude/skills/research-hunt/SKILL.md` | rewritten — launch skill taking a brief path |
| `.claude/skills/research-hunt/brief-template.md` | deleted |
| `.claude/skills/research-hunt/reference.md` | updated per above |
| `.claude/workflows/research-hunt.js` | judgment-node model pins removed; `meta.whenToUse` and header comments updated for the two-skill entry (launch skill, not go/no-go) |

`bootstrap.sh` copies `.claude/skills/` and `.claude/workflows/` wholesale; no bootstrap change needed. Existing briefs/surveys in project repos remain valid records; no migration.

## Testing

The first full round is the shakedown (none has run yet — `reference.md` already says so). Static checks before that: launcher-on-a-sample-brief dry read (args map cleanly to the contract), and the engine's own boundary validation exercises the brief contract.

---
name: research-hunt
description: Use when Paul invokes /research-hunt on a brief file — that invocation is the go for the research round the brief describes. Launches the 3-phase engine and writes the findings report. Also use when relaunching or resuming such a round. To create a brief from a directional prompt, use research-hunt-brief instead.
---

# research-hunt — launch a research round from a reviewed brief

`/research-hunt <brief.md>` **is** the go. Review happens on the brief file before this command; there is no further go/no-go ceremony. No brief file → this skill does not apply; point Paul at `/research-hunt-brief`.

The methodology lives in the engine at `~/.claude/workflows/research-hunt.js`; its rationale and maintenance rules are in `reference.md` beside this file — read it before touching the engine.

## Launch

1. **Drift pre-flight** — the installed engine must match the canonical source: `diff -q ~/.claude/workflows/research-hunt.js "$(cat ~/.claude/workflows/.source)/.claude/workflows/research-hunt.js"`; if they differ, `source bootstrap.sh` first.
2. **Read the brief into `args`** per the ARGS CONTRACT block at the top of `research-hunt.js`. The parameters map one-to-one; take `slug` from the brief's filename and pass `date` in (scripts cannot call Date). The engine validates `args` at its boundary — a mapping gap surfaces there, so don't pre-validate beyond an honest read.
3. **Launch by explicit path** (expand `~` to the home directory):

   ```
   Workflow({ scriptPath: '~/.claude/workflows/research-hunt.js', args: <brief parameters> })
   ```

- **Engine failure mid-run** → fix or wait, then `Workflow({ scriptPath, resumeFromRunId })`; completed agents return cached.
- **Empty or odd result** → read the run's `journal.jsonl` before re-running anything.

## Verify before drafting

The engine's verify lane both fabricates and false-flags. For every load-bearing quote in the result (reception-verdict anchors, flagship quotes, anything the report will lean on):

1. Fetch the cited source yourself and substring-check the exact quoted words.
2. Re-check the adversarial verifier's **refutations** the same way — a false flag on a real source has happened before.
3. A quote that fails the re-check is de-quoted to a paraphrase or dropped, and the correction is disclosed in Caveats.

## Write the report

Written here in the main session, never by a subagent, to `<research-location>/YYYY-MM-DD.<slug>-report.md` — beside the brief. Freeform shape; required elements:

1. **Execution facts** — pointer to the brief, the parameters as run, and the engine version at launch: `git -C "$(cat ~/.claude/workflows/.source)" log -1 --format=%h -- .claude/workflows/research-hunt.js`. Execution facts live here, not in the brief.
2. **Findings** — every load-bearing claim carries an openable source from the engine's result. Gate scores are provisional and superseded by deep-dive scores; report them as such. Route the completeness critic's output to next-round input, never into this round's argument. An `underdetermined-build-probe` verdict is a finding, reported with its probe suggestion.
3. **Caveats** — corrections and fabrications caught (verifier lane + your re-checks), access failures, scope and evidence limits.
4. **Leads not pursued** — `result.parkedLeads`.

## Common mistakes

- Launching without a brief file, or treating a verbal "sounds good" as one — the brief is the reviewed record; the invocation on it is the go.
- Trusting the verify lane's verdicts in either direction — both confirmations and refutations of load-bearing quotes get the independent substring re-check.
- Writing report claims from the result object's summaries without the pointers — every claim carries the openable source the engine collected.
- Editing `research-hunt.js` without reading `reference.md` — the counters and gates encode run-derived lessons; an "obvious simplification" can silently delete one.
- Writing the report into the dotfiles repo or `~/.claude/` — round artifacts belong beside the brief, in the current project's research location.

---
name: discovery-crawl
description: Use when Paul invokes /discovery-crawl on a crawl brief file — that invocation is the go for the crawl the brief describes. Also use when relaunching or resuming such a crawl, or writing its map. To create a crawl brief from a direction, use discovery-crawl-brief instead.
---

# discovery-crawl — run a crawl from a brief and write the map

`/discovery-crawl <brief.md>` **is** the go. Review happens on the brief file before this command; there is no further go/no-go ceremony. No brief file → this skill does not apply; point Paul at `/discovery-crawl-brief`.

The crawl explores and returns raw results. It never scores, ranks, verifies, or refutes — that is research-hunt's job, for when something on the map deserves testing. The engine is `~/.claude/workflows/discovery-crawl.js`; its explore/follow split and depth cap are enforced there in code.

## Launch

1. **Drift pre-flight** — the installed engine must match the canonical source: `cmp ~/.claude/workflows/discovery-crawl.js "$(cat ~/.claude/workflows/.source)/.claude/workflows/discovery-crawl.js"` (`cmp`, because `diff` is a git-diff shell function here); if they differ, `source bootstrap.sh` first.
2. **Read the brief into `args`** per the ARGS CONTRACT block at the top of `discovery-crawl.js`. Take `slug` from the brief's filename and pass `date` in (scripts cannot call Date). Already-known paths go in as absolute paths. The engine validates `args` at its boundary.
3. **Launch by explicit path** (expand `~` to the home directory):

   ```
   Workflow({ scriptPath: '~/.claude/workflows/discovery-crawl.js', args: <brief parameters> })
   ```

- **Engine failure mid-run** → fix or wait, then `Workflow({ scriptPath, resumeFromRunId })`; completed agents return cached.
- **Empty or odd result** → read the run's `journal.jsonl` before re-running anything.

## Before writing the map

1. **Didn't look vs nothing found.** The WebSearch cap and the account usage limit cut searches off silently. Grep the run's transcript directory for `hit your session limit` (and other rate-limit errors), and read the `queriesRun` of every search in `result.gaps.noFinds`. A search that was cut off or barely ran is "didn't look" on the map, never "nothing found". `result.gaps.died` are gaps too.
2. **Check every link opens.** Pipe every link the map will cite, one per line, through the checker beside this file:

   ```
   printf '%s\n' <links> | bb ~/.claude/skills/discovery-crawl/check-links.clj
   ```

   `blocked`, `other`, and `error` are "couldn't open", not "gone". Drop a `missing` link's find or mark it, and say so on the map.
3. **Quotes are unchecked.** Mark them so on the map. A quote gets the independent substring re-check (fetch the page yourself, find the exact words) only when Paul leans on it.

## Write the map

Written here in the main session, never by a subagent, to `<research-location>/YYYY-MM-DD.<slug>-map.md` — beside the brief. It is a map, not a ranking. Six parts:

1. **Where** — places people talk about this (`kind: place`).
2. **Who** — people talking about it (`kind: person`), named only where they publish under their own name.
3. **Problems** — things Paul hadn't thought of (`kind: problem`), each with its short quote and link.
4. **Words** — how people describe it in their own words (`kind: word`).
5. **Trail** — how the crawl got from the direction to each find: `result.trail` in round order, each search's `why`, follow-ups shown under their parent, plus `result.enforcement` (where the code overrode the picker).
6. **Not reached** — `result.leadsNotReached`: leads seen but not chased. These are where the next crawl starts.

Finds the already-known reports already cover are known ground: leave them out or mark them, never present them as new.

Also record:

- **Execution facts** — the brief path, the parameters as run (`result.brief`, `result.roundsRun`), and the engine commit: `git -C "$(cat ~/.claude/workflows/.source)" log -1 --format=%h -- .claude/workflows/discovery-crawl.js`.
- **Access failures** — `result.accessFailures`, as "couldn't open", separate from empty results.
- **Proposed access-guide edits** — if the brief's access notes cite a platform guide, list this crawl's method finds (what opened, what blocked, which query shapes worked) as proposed edits to that guide, each with its find ID. Paul accepts or rejects them; don't edit the guide yourself.

**Layout:** not yet chosen. On the first real crawl, render two or three layouts from its result, let Paul pick, and record the choice here.

## Common mistakes

- Launching without a brief file, or treating a verbal "sounds good" as one.
- Ranking or scoring the finds, or adding a verdict — the map lays out ground; Paul reads it for all four kinds.
- Writing "nothing there" for a blocked site, a dead search, or a search cut off by a limit.
- Treating quotes as verified because a search agent copied them.
- Writing the map into the dotfiles repo or `~/.claude/` — it belongs beside the brief.

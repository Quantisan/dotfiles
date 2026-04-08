# Rewrite Call Transcript: VTT CLI Toolkit

## Summary

This project adds a small, Unix-style VTT toolkit to the `rewrite-call-transcript` Codex skill.
The immediate goal is not generic subtitle processing. The goal is to support transcript-cleaning workflows for diarized meeting and call transcripts stored as WebVTT.

The toolkit should live in the dotfiles-backed skill directory:
`/Users/paul/Projects/dotfiles/.codex/skills/rewrite-call-transcript`

It should be bundled with the skill so the main skill workflow and future subagents can call it directly.

## Why This Exists

During transcript cleanup work, we repeatedly wrote ad hoc Python snippets for:

- parsing VTT cues
- listing raw speaker labels
- viewing transcript turns in a condensed readable format
- slicing a transcript to a time range
- deduplicating overlapping ASR/diarization echoes
- sketching a conversation map for chunking and ambiguity review

Those scripts were useful but disposable. The deterministic, repeated parts should become reusable utilities bundled with the skill.

## Scope

This project is intentionally narrow.

In scope:

- WebVTT only
- plain-text, old-school Unix CLI behavior
- progressive disclosure through built-in `--help`
- tool output designed for frontier LLM agents and humans to read directly
- bundling the tools inside the `rewrite-call-transcript` skill

Out of scope for v1:

- SRT support
- generic transcript formats
- JSON/JSONL interfaces
- converting condensed lines back into VTT
- subagent prompt refactors
- broad subtitle editing features like retiming, shifting, muxing, or format conversion beyond the one inspection-oriented line view

## Design Principles

- Keep it simple.
- Follow Unix philosophy.
- Use plain text for all outputs.
- Preserve real VTT on stdout for VTT-preserving transforms.
- Keep inspection/reporting commands human-readable.
- Give each command one clear job.
- Prefer tool behavior that is easy to inspect with `sed`, `awk`, `grep`, and `head`.
- Bundle the tools with the skill rather than assuming they are on `PATH`.

## Output Contract

We chose a split model.

### 1. VTT-preserving transforms

These commands should emit valid VTT on stdout:

- `slice`
- `dedupe`

These are intended to compose with each other and remain saveable as `.vtt` files.

### 2. Inspection/reporting commands

These commands should emit concise plain text on stdout:

- `labels`
- `turns`
- `map`

These are intended for reading, grep-ing, and quick analysis.

### 3. Explicit format conversion

There should be one dedicated one-way conversion command:

- `lines`

This converts VTT into a condensed line-oriented plain-text representation for inspection.
It is intentionally one-way in v1. There is no `lines-to-vtt` in scope.

## Intended Tool Surface

The current preferred packaging is one bundled CLI entrypoint with subcommands, likely:

```bash
scripts/vtt labels ...
scripts/vtt turns ...
scripts/vtt lines ...
scripts/vtt slice ...
scripts/vtt dedupe ...
scripts/vtt map ...
```

Even though this is one entrypoint, each subcommand should remain single-purpose.

## Command Intent

### `labels`

Purpose:
- list distinct VTT voice labels and their counts
- help detect diarization patterns like `Paul`, `Speaker 1`, `Speaker 2`

Expected style:
```text
Paul       1128
Speaker 1   198
Speaker 2   468
```

### `turns`

Purpose:
- show cue-by-cue transcript turns in a compact readable format
- make it easy to inspect raw content without reading full VTT blocks

Expected style:
```text
00:00:05.840 --> 00:00:06.720  Paul       Hey Dave.
00:00:07.040 --> 00:00:07.920  Speaker 1  Hey, sorry
```

### `lines`

Purpose:
- convert VTT into a condensed plain-text line format
- support quick reading and lightweight shell processing

Expected style:
```text
00:00:05.840	00:00:06.720	Paul	Hey Dave.
00:00:07.040	00:00:07.920	Speaker 1	Hey, sorry
```

This is an explicit conversion utility, not the universal pipe format for the whole toolkit.

### `slice`

Purpose:
- emit a valid VTT subset for a requested time range
- support chunking for transcript-cleaning workflows

Expected use:
```bash
scripts/vtt slice --from 00:24:00 --to 00:30:00 call.vtt
```

Output should stay valid VTT.

### `dedupe`

Purpose:
- reduce overlapping duplicate or near-duplicate cues caused by ASR overlap / diarization echo
- preserve transcript meaning conservatively
- stay narrow to transcript cleanup, not general subtitle beautification

Expected use:
```bash
scripts/vtt dedupe call.vtt > call.dedup.vtt
```

Output should stay valid VTT.

### `map`

Purpose:
- produce a compact conversation map for the rewrite workflow
- help the controller identify likely speakers, topic shifts, chunk boundaries, and ambiguity hotspots

Expected style:
```text
labels: Paul, Speaker 1, Speaker 2
likely-duplicates: high
hotspots:
00:00:32-00:00:55  house offer discussion
00:24:35-00:27:30  math / hallucination debugging
```

This is not intended to be a perfect semantic summary. It should be a compact planning aid for transcript cleanup.

## Skill Integration Requirements

The tools are not useful merely by existing on disk. The skill must explicitly instruct the agent to use them.

The `rewrite-call-transcript` skill should eventually reference these bundled utilities from:

- `SKILL.md` for controller workflow guidance
- any future subagent instructions, if those are added later

Calls should use the skill-relative bundled scripts, not assume a global install.

## Repository and File Locations

Skill root:
`/Users/paul/Projects/dotfiles/.codex/skills/rewrite-call-transcript`

This project brief:
`/Users/paul/Projects/dotfiles/docs/project.md`

The dotfiles copy is intended to be the maintained source of truth and is synced into the home-directory skill location.

## Open Source Research Summary

We checked whether this tool already exists.

Findings:

- `webvtt-py` is the strongest WebVTT-native parsing foundation, but its CLI is much narrower than our needs.
- `subtitle-parser` and `pysubs2` provide useful building blocks but are not shaped around diarized meeting-transcript cleanup.
- `go-astisub` has a good CLI model for subtitle operations, but it is still a general subtitle tool, not a transcript-oriented VTT workflow tool.
- No open-source CLI found during this review appears to already provide the exact combination of `labels`, `turns`, `lines`, `slice`, `dedupe`, and `map` for WebVTT meeting transcripts.

Conclusion:

Building a small skill-bundled VTT toolkit still makes sense.

## Known Open Questions

These decisions were not finalized yet:

- whether to implement the parser with a dependency such as `webvtt-py` or keep it fully self-contained
- exact stdin behavior when no file argument is provided
- exact heuristics and flags for `dedupe`
- exact level of semantic ambition for `map`

## Success Criteria

This project is successful when:

- the skill has reusable bundled VTT utilities instead of ad hoc throwaway scripts
- `labels`, `turns`, `lines`, `slice`, `dedupe`, and `map` exist with clear `--help`
- `slice` and `dedupe` preserve valid VTT output
- `labels`, `turns`, `lines`, and `map` produce concise plain text suitable for direct reading by LLM agents and humans
- the toolkit is simple enough to inspect and trust during transcript-cleaning work

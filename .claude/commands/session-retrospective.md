---
description: Analyze past sessions for wrong-turn patterns and derive CLAUDE.md improvements
---

## Scanner

!`python ~/.claude/commands/analyze_sessions.py 2>&1`

## Manifest

!`cat docs/analysis/session-audit/manifest.md 2>/dev/null || echo "(manifest not found)"`

## Extracts

!`find docs/analysis/session-audit/extracts/ -name "*.md" 2>/dev/null | sort | xargs cat 2>/dev/null || echo "(no extracts found)"`

## Your task

Analyze the manifest and extracts above for wrong-turn → recovery patterns. Do NOT read memory files, feedback files, git log, or CLAUDE.md as data — those are already-captured patterns. The point is to find patterns not yet captured.

**Signal tags:**
- `[C]` correction — user corrected the agent (wrong turn taken)
- `[R]` rework — agent re-read or re-edited a file it already touched (context loss)
- `[F]` friction — tool error or failed bash command
- `[Rv]` recovery — git restore/reset or advisor() after a long tool streak

After reading all extracts:

1. Cluster into 3–7 patterns — name each and cite evidence turns
2. Cross-check every pattern against existing CLAUDE.md and memory/*.md — skip anything already captured
3. Present as a table: `| Pattern | Evidence turns | Proposed CLAUDE.md text |`
4. Do not edit CLAUDE.md until I approve each addition

**Common mistakes to avoid:**
- Over-flagging rework on plan/doc files — incremental edits to a single markdown are normal; look for rework on *source code* files
- Proposing additions that duplicate existing CLAUDE.md guidance

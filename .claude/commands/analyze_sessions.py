#!/usr/bin/env python3
"""
Session audit scanner for Claude Code JSONL session logs.

Detects agent wrong-turn -> recovery patterns by scanning for four signal types:
  correction  -- user correcting the agent mid-task
  rework      -- agent re-reading or re-editing files it already touched
  friction    -- tool errors or failed bash commands
  recovery    -- git reverts or advisor() calls after long tool chains

Usage (run from inside any Claude Code project):
    python ~/.claude/skills/session-retrospective/analyze_sessions.py [options]

Project directory is auto-detected from cwd. Claude stores sessions at
~/.claude/projects/<cwd-with-slashes-as-dashes>/, which this script derives
automatically.

Outputs:
    {output_dir}/manifest.md         -- sessions ranked by incident count
    {output_dir}/extracts/<id>.md    -- trimmed turn windows for top sessions
"""

import argparse
import json
import os
import re
from collections import defaultdict
from pathlib import Path

# --- Signal constants ---

# Correction: user text starting with these phrases indicates a course correction.
CORRECTION_PHRASES = re.compile(
    r"^(no\b|stop\b|wait\b|don'?t\b|undo\b|revert\b|actually\b|instead\b|"
    r"that'?s not\b|why did\b|you broke\b|hold on\b|hmm\b|nope\b|wrong\b|"
    r"not that\b|never mind\b)",
    re.IGNORECASE,
)

# Correction: short user messages after a long tool streak are likely corrections.
CORRECTION_SHORT_MAX_CHARS = 80
CORRECTION_TOOL_STREAK_MIN = 3

# Rework: same file edited/written this many times within the sliding window.
REWORK_EDIT_MIN_COUNT = 3
REWORK_WINDOW_TURNS = 10

# Rework: re-reading a file that was already read within this many turns.
REWORK_REREAD_WINDOW = 20

# Recovery: bash commands indicating git revert/reset.
RECOVERY_GIT_RE = re.compile(r"git\s+(reset|restore|checkout\s+--|revert)", re.IGNORECASE)

# Recovery: advisor() called after this many consecutive assistant turns without user text.
RECOVERY_ADVISOR_STREAK_MIN = 5

# Window clustering: incidents within this many turns of each other are grouped.
WINDOW_CLUSTER_GAP = 8

# Extract rendering limits.
EXTRACT_EDIT_MAX_CHARS = 80


def _auto_project_dir():
    """Derive the Claude session directory for the current working directory."""
    cwd = os.getcwd()
    project_key = cwd.replace("/", "-")
    return Path.home() / ".claude" / "projects" / project_key


def parse_session(path):
    """Parse a JSONL session file into a list of normalized turn dicts."""
    turns = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue

            rtype = record.get("type")
            if rtype not in ("user", "assistant"):
                continue

            msg = record.get("message", {})
            content = msg.get("content", [])
            if isinstance(content, str):
                content = [{"type": "text", "text": content}]

            turn = {
                "idx": len(turns),
                "type": rtype,
                "is_sidechain": record.get("isSidechain", False),
                # user fields
                "is_human_text": False,
                "is_tool_result_only": False,
                "human_text": "",
                "tool_errors": False,
                # assistant fields
                "tool_uses": [],
            }

            if rtype == "user":
                texts = [c["text"] for c in content if c.get("type") == "text"]
                results = [c for c in content if c.get("type") == "tool_result"]
                if texts:
                    turn["is_human_text"] = True
                    turn["human_text"] = " ".join(texts).strip()
                elif results:
                    turn["is_tool_result_only"] = True
                    turn["tool_errors"] = any(r.get("is_error") for r in results)

            elif rtype == "assistant":
                for item in content:
                    if item.get("type") != "tool_use":
                        continue
                    name = item.get("name", "")
                    inp = item.get("input", {})
                    turn["tool_uses"].append({"name": name, "args": _compact_args(name, inp)})

            turns.append(turn)

    return turns


def _compact_args(name, inp):
    """Produce a compact one-line representation of tool arguments."""
    if name == "Bash":
        return inp.get("command", "").split("\n")[0][:120]
    if name == "Read":
        return inp.get("file_path", "")
    if name == "Write":
        return inp.get("file_path", "")
    if name == "Edit":
        path = inp.get("file_path", "")
        old = inp.get("old_string", "")[:EXTRACT_EDIT_MAX_CHARS].replace("\n", "↵")
        return f"{path} | {old!r}"
    if name == "Agent":
        return inp.get("description", inp.get("prompt", ""))[:80]
    if name == "Skill":
        return inp.get("skill", "")
    if name == "advisor":
        return ""
    if name in ("WebFetch", "WebSearch"):
        return inp.get("url", inp.get("query", ""))[:80]
    # Generic: first string value found
    for v in inp.values():
        if isinstance(v, str):
            return v[:80]
    return ""


def detect_incidents(turns):
    """Return list of incident dicts {idx, type, note}."""
    incidents = []

    # Consecutive assistant turns with tool_use, no user text in between.
    tool_streak = 0
    # Consecutive assistant turns with any content, no human text in between.
    advisor_streak = 0

    # File access history for rework detection: list of (turn_idx, file_path).
    file_edits = []
    file_reads = []

    for i, turn in enumerate(turns):
        if turn["type"] == "assistant":
            has_tools = bool(turn["tool_uses"])
            if has_tools:
                tool_streak += 1
            else:
                tool_streak = 0
            advisor_streak += 1

            for tu in turn["tool_uses"]:
                name = tu["name"]
                args = tu["args"]

                if name == "Bash" and RECOVERY_GIT_RE.search(args):
                    incidents.append({"idx": i, "type": "recovery", "note": f"git-revert: {args[:60]}"})

                if name == "Read":
                    fpath = args
                    recent = [r for r in file_reads if i - r[0] <= REWORK_REREAD_WINDOW]
                    if fpath in {r[1] for r in recent}:
                        incidents.append({"idx": i, "type": "rework", "note": f"re-read: {fpath}"})
                    file_reads.append((i, fpath))

                if name in ("Edit", "Write"):
                    fpath = args.split(" | ")[0] if " | " in args else args
                    file_edits.append((i, fpath))
                    window_edits = [e for e in file_edits if i - e[0] <= REWORK_WINDOW_TURNS and e[1] == fpath]
                    if len(window_edits) == REWORK_EDIT_MIN_COUNT:
                        incidents.append({"idx": i, "type": "rework", "note": f"repeated-edit ({len(window_edits)}x): {fpath}"})

                if name == "advisor" and advisor_streak >= RECOVERY_ADVISOR_STREAK_MIN:
                    incidents.append({"idx": i, "type": "recovery", "note": f"advisor after {advisor_streak}-turn streak"})

        elif turn["type"] == "user":
            if turn["is_human_text"]:
                txt = turn["human_text"]

                if CORRECTION_PHRASES.match(txt):
                    incidents.append({"idx": i, "type": "correction", "note": repr(txt[:80])})
                elif len(txt) <= CORRECTION_SHORT_MAX_CHARS and tool_streak >= CORRECTION_TOOL_STREAK_MIN:
                    incidents.append({"idx": i, "type": "correction", "note": f"short-after-tools: {txt[:60]!r}"})

                tool_streak = 0
                advisor_streak = 0

            elif turn["is_tool_result_only"] and turn["tool_errors"]:
                incidents.append({"idx": i, "type": "friction", "note": "tool-error"})

    return incidents


def cluster_windows(incidents, gap=WINDOW_CLUSTER_GAP):
    """Cluster incidents into contiguous windows."""
    if not incidents:
        return []
    windows = []
    cur_start = incidents[0]["idx"]
    cur_end = incidents[0]["idx"]
    cur_incidents = [incidents[0]]

    for inc in incidents[1:]:
        if inc["idx"] - cur_end <= gap:
            cur_end = inc["idx"]
            cur_incidents.append(inc)
        else:
            windows.append({"start": cur_start, "end": cur_end, "incidents": cur_incidents})
            cur_start = inc["idx"]
            cur_end = inc["idx"]
            cur_incidents = [inc]

    windows.append({"start": cur_start, "end": cur_end, "incidents": cur_incidents})
    return windows


def render_window(session_id, window, turns):
    """Render a trimmed turn window as markdown."""
    start = max(0, window["start"] - 2)
    end = min(len(turns) - 1, window["end"] + 2)

    counts = defaultdict(int)
    for inc in window["incidents"]:
        counts[inc["type"]] += 1
    summary = ", ".join(f"{t}: {c}" for t, c in sorted(counts.items()))

    lines = [f"### window turns {start}–{end} ({summary})"]

    incident_idx = {inc["idx"]: inc["type"][0].upper() for inc in window["incidents"]}

    for i in range(start, end + 1):
        turn = turns[i]
        tag = f"[{incident_idx[i]}] " if i in incident_idx else "    "

        if turn["type"] == "user" and turn["is_human_text"]:
            lines.append(f"[{i:4d}] {tag}user: {turn['human_text'][:120]!r}")
        elif turn["type"] == "user" and turn["is_tool_result_only"]:
            err = " ERROR" if turn["tool_errors"] else ""
            lines.append(f"[{i:4d}] {tag}(tool_results{err})")
        elif turn["type"] == "assistant" and turn["tool_uses"]:
            first = True
            for tu in turn["tool_uses"]:
                t = tag if first else "    "
                lines.append(f"[{i:4d}] {t}assistant: {tu['name']}({tu['args'][:100]})")
                first = False
        elif turn["type"] == "assistant":
            lines.append(f"[{i:4d}] {tag}assistant: (text only)")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--project-dir", default=None,
                        help="Path to Claude session directory. Defaults to auto-detected from cwd.")
    parser.add_argument("--min-turns", type=int, default=50, help="Skip sessions with fewer assistant turns")
    parser.add_argument("--max-turns", type=int, default=400, help="Skip sessions with more assistant turns")
    parser.add_argument("--top-windows", type=int, default=8, help="Number of highest-density windows to extract")
    parser.add_argument("--output-dir", default="docs/analysis/session-audit/")
    parser.add_argument("--dump", action="store_true",
                        help="After writing files, print manifest and all extracts to stdout")
    args = parser.parse_args()

    if args.project_dir is None:
        project_dir = _auto_project_dir()
        print(f"Auto-detected: {project_dir}")
    else:
        project_dir = Path(args.project_dir).expanduser()

    if not project_dir.exists():
        print(f"ERROR: session directory not found: {project_dir}")
        print("Run from inside the project root, or pass --project-dir explicitly.")
        raise SystemExit(1)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "extracts").mkdir(exist_ok=True)

    session_files = sorted(project_dir.glob("*.jsonl"))
    print(f"Found {len(session_files)} session files")

    results = []
    for path in session_files:
        session_id = path.stem
        turns = parse_session(path)
        n = sum(1 for t in turns if t["type"] == "assistant")

        if n < args.min_turns or n > args.max_turns:
            continue

        incidents = detect_incidents(turns)
        windows = cluster_windows(incidents)
        results.append({
            "session_id": session_id,
            "total_turns": n,
            "incident_count": len(incidents),
            "windows": windows,
            "turns": turns,
        })

    results.sort(key=lambda r: r["incident_count"], reverse=True)
    print(f"{len(results)} sessions in range [{args.min_turns}–{args.max_turns}] turns")

    # Manifest
    manifest = [
        "# Session Audit Manifest\n",
        f"Sessions qualifying: {len(results)} (of {len(session_files)} total)\n",
        "| Session ID | Turns | Incidents | Windows |",
        "|---|---|---|---|",
    ]
    for r in results:
        wstr = " ".join(f"[{w['start']}-{w['end']}]" for w in r["windows"])
        manifest.append(f"| `{r['session_id']}` | {r['total_turns']} | {r['incident_count']} | {wstr} |")

    (output_dir / "manifest.md").write_text("\n".join(manifest) + "\n")
    print(f"Manifest → {output_dir}/manifest.md")

    # Top-N windows globally
    all_windows = [
        (r["session_id"], w, r["turns"], len(w["incidents"]))
        for r in results
        for w in r["windows"]
    ]
    all_windows.sort(key=lambda x: x[3], reverse=True)
    top = all_windows[:args.top_windows]

    # Group by session for extract files
    by_session = defaultdict(list)
    for sid, w, turns, _ in top:
        by_session[sid].append((w, turns))

    for sid, window_turns in by_session.items():
        lines = [f"# Extracts: {sid}\n"]
        for w, turns in window_turns:
            lines.append(render_window(sid, w, turns))
            lines.append("")
        path = output_dir / "extracts" / f"{sid}.md"
        path.write_text("\n".join(lines) + "\n")
        print(f"Extract  → extracts/{sid[:20]}….md")

    print(f"\nDone. Top {len(top)} windows across {len(by_session)} sessions.")

    if args.dump:
        manifest_path = output_dir / "manifest.md"
        extracts_dir = output_dir / "extracts"
        print("\n---MANIFEST---")
        print(manifest_path.read_text() if manifest_path.exists() else "(manifest not found)")
        extract_files = sorted(extracts_dir.glob("*.md")) if extracts_dir.exists() else []
        if extract_files:
            print("\n---EXTRACTS---")
            for ef in extract_files:
                print(ef.read_text())
        else:
            print("\n---EXTRACTS---\n(no extracts found)")


if __name__ == "__main__":
    main()

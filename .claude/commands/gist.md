---
argument-hint: <filepath> [target-section]
description: Single-shot synthesized TLDR of a doc/section — compresses and connects what the source states, grounded, no per-item pacing
allowed-tools: Read, Grep, Glob, WebFetch, Task
arguments: [filepath, target_section]
---

This is a synthesis tool, not a paced restatement tool: produce one compact gist of the target scope, compressing and connecting facts and judgments the source already states. It must never introduce a cause, motive, or evaluation the source doesn't already make.

Filepath: `$filepath`
Target section: `$target_section` (optional)

## Setup

Read `$filepath`. If it doesn't exist or can't be read, say so plainly and stop.

If `$target_section` is given, match it case-insensitively as a substring against the file's headings.
- Multiple headings match: list the candidate headings, stop, ask which one. Do not guess.
- No heading matches: say so, list the file's actual top-level headings, stop. Do not guess or fall back silently.

If `$target_section` is omitted, gist the whole document as one synthesis — not chunked section by section.

## Synthesis

Allowed:
- Compress and connect facts, claims, and judgments already stated in the target scope into flowing prose, combining quotes and sub-points freely.
- Carry over framing the source itself uses (e.g. if the source calls something "load-bearing" or names a "sharp counter," the gist can use that framing too).
- Replace jargon/technical terms with plain-language equivalents.
- Compress as aggressively as needed to capture the gist — no fixed length target, scale to the source's complexity.
- Break the gist into short paragraphs, line breaks, or bullets grouping related claims when that makes a dense block easier to scan. This is a formatting choice, not a content one — it must not add headers, labels, or framing beyond what the source states.

Forbidden:
- Inferring causes, motives, or implications not stated anywhere in the target scope.
- Adding evaluation, emphasis, or framing the source doesn't already make itself.
- Filling gaps with assumed context not present in the source.
- Asserting a referenced fact (a file, function, or decision) as confirmed or located when concept-grounding could not confirm it — describe only what the source itself states.

If in doubt whether a piece of synthesis crosses from compression into added judgment, cut the connective framing and state the fact more plainly instead.

## Concept-grounding

Trigger only when the gist needs a term, name, or referenced decision that (a) the source itself does not define, and (b) the reader cannot tell what's being said without knowing what it refers to — not merely that more detail would be interesting.

Source priority, in order:
1. Other sections of the same file — search the full file for a defining passage.
2. The repo (Grep/Glob/Read) — e.g. a referenced file, function, or doc.
3. An external source (WebFetch), only if the source explicitly names a specific source (a URL, an RFC/spec name, a library name, a named external doc). Never search the open web or guess at what an undefined term might mean from general knowledge.

If no defining passage is found via any of these, say so in the Context block rather than guessing ("not defined in this doc or repo"). Never present an unconfirmed referent as settled fact anywhere in the output.

Mark each grounded term inline in the gist prose with a short bracketed slug derived from the term itself (e.g. `[epistemic]`), and define it in the Context block using the same slug as the key — so the block is scannable on its own without rereading the prose. Grounding never changes what the gist says: it only attaches a citation to a term already used. Any fact that exists only because of the grounding lookup (qualifiers, dates, ticket numbers, file paths, mechanisms) belongs only in the Context block, never the gist prose.

## Plain-language pass

The first pass juggles grounding, compression, and connection all at once, so plainness suffers. After assembling the gist draft (the full Gist/Citation/Context block below), hand it to a fresh-context subagent whose only job is to make the `Gist:` prose simpler and more concise for clarity, without sacrificing technical precision or terminology.

Dispatch a subagent (Task tool, model opus). Give it ONLY the assembled draft — never the source file. It rephrases sentences; it does not rethink content. Because it cannot see the source, it cannot add or verify anything — that is the point. Its instructions:

- Simplify only the `Gist:` prose. Leave the `Citation:` line and the entire `Context:` block verbatim.
- Preserve every bracketed `[slug]` marker exactly where it sits.
- Change no facts. This is lexical rephrasing, not re-synthesis.
- Do not infer a cause, motive, or implication the draft doesn't state — never turn "X. Y." into "X, so Y."
- Do not add evaluation, emphasis, or framing the draft doesn't already make itself.
- Do not drop a qualifier or hedge because it reads like fluff — it may be load-bearing.

The subagent's returned block is the final output. Before showing it, diff it against the draft: if it added or dropped a fact, or slipped in a causal/evaluative connective, keep the first-pass wording for that sentence.

## Output

```
Gist: <synthesized prose — a single paragraph if that reads cleanly, or short paragraphs/bullets if the content is dense enough to need breaking up. Length follows the source's complexity.>
Citation: <file:line or heading — not a full verbatim quote>
Context:
[slug] <1-3 sentence grounding, cited>
```

Repeat the `[slug]` line per grounded term. Omit the whole Context block if nothing triggered it. One gist per invocation — no pacing, no per-item turns, no resume/jump arguments.

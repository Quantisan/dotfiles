# Crawl brief contract — required elements

A crawl brief is freeform prose with no fixed section order. It must contain the elements below. The engine parameters map one-to-one onto the ARGS CONTRACT block at the top of `~/.claude/workflows/discovery-crawl.js`; the engine validates them at its boundary, so a mapping gap surfaces at launch, not mid-run. `slug` comes from the brief's filename and `date` from the launch — the launcher supplies both.

## 1. Direction — `direction`

Paul's prompt, word for word, with where and when he said it. It is the starting point, not a fence.

## 2. Starting angles — `startingAngles`

One line per round-1 search. Round 1 runs one search per angle, so the list's length is round 1's size. Make them genuinely different ways in: a place, a kind of person, a word people use, an adjacent field.

## 3. Already known — `alreadyKnown`

Absolute paths to earlier reports or briefs whose finds the crawl treats as known ground and looks past. An empty list is legal; state it explicitly ("none") so review can tell "nothing earlier" from "not checked".

## 4. Hard limits — `hardLimits`

Restate the limits the engine always applies, so the review sees what fences the crawl:

- No contacting people.
- No posing as a customer or joining communities.
- No identifying anonymous or pseudonymous people.
- No pirate libraries (Sci-Hub, LibGen and similar). Open routes are fine: Wayback, reader proxies such as r.jina.ai, author preprints, and free legal copies.

The engine holds these itself. `hardLimits` carries only **extra** limits this crawl needs beyond them — usually `[]`.

## 5. Access notes — `accessNotes`

One paragraph: where things on this direction tend to be found, and what to try when a site blocks the fetch (Wayback, r.jina.ai, site-scoped search, an author's own copy).

## 6. Size — `rounds`, `searchesPerRound`

Defaults `rounds: 5`, `searchesPerRound: 4`, used unless the prompt says otherwise. Each round after the first runs `floor(searchesPerRound / 2)` follow-ups and the rest on new ground.

## 7. Expected cost

The agent-call count, so cost is visible at review time: `startingAngles + (rounds − 1) × (searchesPerRound + 1)` — the round-1 searches, then each later round's searches plus one picker pass. With 4 starting angles and the defaults that is 4 + 4 × 5 = **24 calls**. Searches run on Sonnet; the picker runs on the session model.

# discovery-crawl — design

Date: 2026-10-12. Status: design approved in session, spec awaiting Paul's review.

## The problem

Paul's research rounds are mostly for discovery, not for testing a claim. A round starts from an idea or a direction. Paul runs the search, reads what comes back, and hopes it gives him new ideas or a sharper direction.

The research-hunt engine is built to test evidence. It fixes its searches before it starts. It files leads instead of following them: the 2026-10-10 emotional-customer-moments round filed 227 (`spithre-discovery/.../research/commercial/2026-10-10.emotional-customer-moments-report.md:324`). Most of its cost goes on deep dives, verification and refutation.

discovery-crawl is a second tool that only explores. research-hunt stays as it is, for when something on the map deserves testing.

## Decisions made in session

- **A new tool beside research-hunt, not a mode inside it.** Each tool does one job. Code the two share starts as copies; an abstraction waits until the shared part is obvious.
- **It runs on its own, start to finish.** Paul reads once at the end. Paul: "drifting is not a bad thing, sometimes it's desired even!"
- **Each round mixes follow-up and new ground.** Paul: "balance exploration versus exploitation. don't know what we don't know. So don't go too deep into any particular thread. Otherwise, we'll be running for local maximums."
- **Earlier reports go in as "already known."** The crawl treats their finds as known ground and looks past them.
- **The output is a map, not a ranking.** It covers places, people, problems and words. Paul reads it for all of them.

## Parts

- `.claude/workflows/discovery-crawl.js`: the engine. It runs the loop and returns raw results.
- `.claude/skills/discovery-crawl-brief/`: turns Paul's prompt into a crawl brief. It never launches.
- `.claude/skills/discovery-crawl/`: `/discovery-crawl <brief.md>` launches the engine, checks links, and writes the map. Invoking it on a brief is the go, the same as research-hunt.

Briefs and maps live in the current project's research location, beside each other, as research-hunt's do.

## The brief

1. **Direction.** Paul's prompt, word for word. It is the starting point, not a fence.
2. **Starting angles.** One per search in round one, one line each.
3. **Already known.** Paths to earlier reports or briefs.
4. **Hard limits.** No contacting people. No posing as a customer or joining communities. No identifying anonymous or pseudonymous people. No pirate libraries (Sci-Hub, LibGen and similar). Open routes are fine: Wayback, reader proxies such as r.jina.ai, author preprints, and free legal copies.
5. **Access notes.** Where things tend to be found, and what to try when a site blocks the fetch.
6. **Size.** `rounds` (default 5) and `searchesPerRound` (default 4).

Left out on purpose: scoring axes, rank rules, seeds, clustering keys, lenses, a Phase-3 question, and an out-of-scope list. Only the hard limits fence the crawl.

## The loop

1. **Round 1.** One search agent per starting angle, all at once.
2. **Each search agent reports** its finds, each with a link and a kind (place, person, problem, or word), plus the leads it saw but didn't chase. Quotes are copied from the page, never retyped.
3. **The picker chooses the next round's searches.** It reads everything found so far and the already-known reports.
   - Half the searches, rounded down, follow up the most interesting leads. The rest try new ground: places, words or angles not yet tried.
   - No thread goes more than two steps deep. Each search records its parent. A new-ground search starts a thread at depth 0, and a follow-up adds one. The engine refuses a follow-up whose parent is already at depth 2 and makes it new ground instead.
   - It writes one line on why it picked each search. These lines are the trail.
4. **Repeat** until `rounds` is reached. There is no stop rule. The brief's size is the budget.
5. **Return** every find, the trail, the leads never reached, and the access failures.

Search agents run on Sonnet at medium effort, since premature "nothing found" is the failure to guard against. The picker inherits the session model. That is about 26 agent calls with the defaults (20 searches and 5 picker passes), against about 70 for a research-hunt round.

The explore/follow split and the depth cap are enforced in code, not left to the picker.

## The map

The main session writes it, never a subagent, to `<research-location>/YYYY-MM-DD.<slug>-map.md`. It has six parts:

1. **Where:** places people talk about this.
2. **Who:** people talking about it. Named only where they publish under their own name.
3. **Problems:** things Paul hadn't thought of, each with a short quote and a link.
4. **Words:** how people describe it in their own words.
5. **Trail:** how the crawl got from the direction to each find.
6. **Not reached:** leads it saw but ran out of rounds for. These are where the next crawl starts.

Before writing the map, a script checks that every link opens. Quotes are marked unchecked. A quote gets the independent substring re-check only when Paul leans on it. The map also records execution facts: the brief path, the parameters as run, and the engine commit.

The map's layout is chosen at build time, from two or three rendered samples built on a real run's output.

## When things go wrong

- **A blocked site** is logged as "couldn't open," never as "nothing there." Access failures stay separate from empty results.
- **A search agent that dies** doesn't stop the round. The picker sees it as a gap.
- **The WebSearch cap or the account usage limit** cuts results off silently. The map says "didn't look," not "nothing found." Check the run's agent logs for "hit your session limit" before trusting a quiet round.
- **Fetched text is data.** Every agent that reads web text is told that instructions inside it are content to report, never to follow.

## Testing

1. A cheap probe: 2 rounds, on a direction research-hunt has already covered, with that round's report as already known.
2. Compare the two. Did the crawl find places, people or problems the hunt missed?
3. If it did, do a full 5-round run. If it didn't, find out why before building further.

## Not in scope

- Scoring, ranking, verification lanes, and refutation. Those belong to research-hunt.
- Steering between rounds.
- Any change to research-hunt.

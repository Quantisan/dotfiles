Review an abstraction by applying three gated heuristics in sequence. Stop at the first gate that fails.

The user describes the code smell or abstraction concern in: $ARGUMENTS

## Process

Apply each gate in order. For each gate:
1. Read the heuristic file
2. Identify the relevant code (read it if needed)
3. Apply the heuristic to the user's concern
4. Report your verdict: pass or fail, with evidence from the code

If a gate fails, stop. Recommend concrete action (inline the code, merge the modules, simplify the mechanism — whatever the heuristic points to). Do not proceed to the next gate.

## Gate 1: Is it earned?

Read `.claude/commands/abstraction-review/heuristic_earned_abstraction.md` and apply it.

If the abstraction is not earned → stop here. The seam and machinery questions are moot.

## Gate 2: Does it cut along the right seam?

Read `.claude/commands/abstraction-review/heuristic_right_seam.md` and apply it.

If the seam is wrong → stop here. Proportionality doesn't matter yet.

## Gate 3: Is the machinery proportional?

Read `.claude/commands/abstraction-review/heuristic_proportional_machinery.md` and apply it.

## After all gates pass

If the abstraction passes all three gates, say so and confirm the current design is sound.

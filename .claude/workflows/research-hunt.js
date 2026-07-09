export const meta = {
  name: 'research-hunt-engine',
  description: 'Parameterized engine for a "what\'s out there" research round: discovery → per-candidate deep dive → hardest-question hunt',
  whenToUse: 'NEVER invoke directly — the research-hunt skill is the only entry point; it materializes the launch brief and gets Paul\'s go/no-go, then launches this engine with the brief\'s slots as args.',
  phases: [
    { title: 'Discovery', detail: 'Perspective scouts + wildcard, incremental clustering, coded saturation, ranking gate, seed benchmark', model: 'opus (gate) / sonnet (scouts)' },
    { title: 'Deep dive', detail: 'Per-candidate pipeline: 3 lens scouts → case lead → split verifier lane; coded empty-door escalation', model: 'opus (case leads, cross-case gate) / sonnet (scouts, verifiers)' },
    { title: 'Hardest question', detail: 'Question gate → contamination-guarded refuters → coded stop rule → verdict', model: 'opus (gate, verdict) / sonnet (refuters)' },
    { title: 'Tail', detail: 'Single-pass completeness critic; assemble the structured result' },
  ],
}

// ---------------------------------------------------------------------------
// Judgment lives in Opus gate agents; control flow lives here. The counters,
// thresholds, and escalations below are the retro's fixes (see
// .claude/skills/research-hunt/reference.md for the why of each) — they must
// not depend on per-run improvisation, which is why they are code.
//
// args = the launch brief's slots. Everything else is invariant. See the
// ARGS CONTRACT below; the research-hunt skill fills and validates these
// from the materialized brief before launching.
// ---------------------------------------------------------------------------

// --- ARGS CONTRACT ----------------------------------------------------------
// {
//   slug: string,                    // round slug, used in labels
//   date: string,                    // YYYY-MM-DD (scripts cannot call Date)
//   goal: { type: 'space'|'fork', statement: string },
//   anchorArtifact: string,          // what is being represented
//   axes: [{ key, name, definition }],           // scored axes
//   rankSpec: { rule: string, rationale: string },
//   clusteringKey: string,           // what raw finds are grouped by
//   scopeRule: { inScope: string, outOfScope: string },
//   perspectives: [{ key, brief }],  // Phase-1 scout perspectives, in run order
//   lenses: [{ key, brief }],        // exactly 3 Phase-2 lens definitions
//   seeds: [string],                 // seed candidates, pre-registered as clusters
//   noveltyFloor: number,            // min fraction of gated candidates outside seeds
//   exclusions: [string],            // hard exclusions with pass-over rules
//   rejectedShelf: [string],         // settled prior rejections — do not reopen
//   accessStrategy: { primary: string, fallback: string },
//   phase3: { mode: 'preset'|'run-selected'|'skip', question?: string, skipReason?: string },
//   budgets: {
//     maxGated: number,              // gate selects at most this many candidates
//     emptyDoorK: number,            // consecutive empty candidates closing a lens door
//     stabilityK: number,            // consecutive unmoved sources closing Phase 3
//     maxRefuterRounds: number,      // hard bound on Phase-3 refuter rounds
//   },
// }
// ----------------------------------------------------------------------------

const REQUIRED = ['slug', 'date', 'goal', 'anchorArtifact', 'axes', 'rankSpec', 'clusteringKey', 'scopeRule', 'perspectives', 'lenses', 'seeds', 'noveltyFloor', 'exclusions', 'accessStrategy', 'phase3', 'budgets']
for (const k of REQUIRED) {
  if (args == null || args[k] == null) throw new Error(`research-hunt: missing brief slot '${k}' in args — launch only via the research-hunt skill with a confirmed brief`)
}
if (!Array.isArray(args.lenses) || args.lenses.length !== 3) throw new Error('research-hunt: exactly 3 Phase-2 lenses required')
if (typeof args.noveltyFloor !== 'number' || args.noveltyFloor <= 0 || args.noveltyFloor > 1) throw new Error('research-hunt: noveltyFloor must be a number in (0, 1] — e.g. 0.33, not the string "1/3"')
if (args.phase3.mode === 'preset' && !args.phase3.question) throw new Error('research-hunt: phase3.mode is "preset" but phase3.question is missing')
const B = args.budgets
for (const k of ['maxGated', 'emptyDoorK', 'stabilityK', 'maxRefuterRounds']) {
  if (typeof B[k] !== 'number' || B[k] < 1) throw new Error(`research-hunt: budgets.${k} must be a number >= 1`)
}

const axesLine = args.axes.map((a) => `${a.name} (${a.key}): ${a.definition}`).join('; ')
const axisKeys = args.axes.map((a) => a.key).join('/')

// Shared framing block for scouts. Deliberately NOT given to Phase-3 refuters
// (contamination guard) — keep Phase-3 prompts free of this text.
const SCOUT_CONTEXT = `RESEARCH GOAL (${args.goal.type}): ${args.goal.statement}

THE ARTIFACT BEING REPRESENTED: ${args.anchorArtifact}

SCORED AXES: ${axesLine}

SCOPE — in: ${args.scopeRule.inScope}
SCOPE — out: ${args.scopeRule.outOfScope}
HARD EXCLUSIONS: ${args.exclusions.join('; ') || 'none'}
SETTLED PRIOR REJECTIONS (do not reopen): ${(args.rejectedShelf || []).join('; ') || 'none'}

ACCESS STRATEGY: evidence lives at: ${args.accessStrategy.primary}. When a direct fetch is blocked (403/paywall/bot-block): ${args.accessStrategy.fallback}. A blocked source is INCONCLUSIVE, never disconfirming — record it as an access failure, do not count it as an empty result.

LEADS DISCIPLINE: any lead you cannot chase within your own mandate goes in parkedLeads (one line: the lead, why parked). Never widen your own mandate; never open a new search direction mid-task.`

// --- Schemas ----------------------------------------------------------------

const SCOUT_REPORT = {
  type: 'object',
  additionalProperties: false,
  required: ['finds', 'accessFailures', 'parkedLeads'],
  properties: {
    finds: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['what', 'source', 'clusterHint'],
        properties: {
          what: { type: 'string', description: 'The candidate device/work/approach found, in one concrete sentence.' },
          source: { type: 'string', description: 'Openable pointer: URL or exact citation. A find with no source is not a find.' },
          clusterHint: { type: 'string', description: `Best guess at the ${args.clusteringKey} this find belongs to.` },
          axisNotes: { type: 'string', description: `One line of evidence per axis (${axisKeys}) where visible.` },
        },
      },
    },
    accessFailures: { type: 'array', items: { type: 'string' }, description: 'Sources that 403/paywall/bot-blocked, one line each.' },
    parkedLeads: { type: 'array', items: { type: 'string' }, description: 'Leads not chased: "<lead> — <why parked>".' },
  },
}

const CLUSTERING = {
  type: 'object',
  additionalProperties: false,
  required: ['clusters'],
  properties: {
    clusters: {
      type: 'array',
      description: 'The FULL updated registry: every existing cluster (key unchanged) plus any new ones.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['key', 'description', 'exemplars', 'isNew', 'newFromPerspective'],
        properties: {
          key: { type: 'string' },
          description: { type: 'string' },
          exemplars: { type: 'array', items: { type: 'string' } },
          isNew: { type: 'boolean', description: 'true only if this cluster did not exist in the registry handed to you.' },
          newFromPerspective: { type: 'string', description: 'For new clusters: the perspective key whose finds created it; empty string otherwise.' },
        },
      },
    },
  },
}

const GATE = {
  type: 'object',
  additionalProperties: false,
  required: ['rankedClusters', 'gatedCandidates', 'noveltyFloorArithmetic', 'judgmentCalls', 'seedsNotCovered', 'gateRationale'],
  properties: {
    rankedClusters: {
      type: 'array',
      description: 'Every cluster in rank order — gated or not. This table is the auditable gate output.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['cluster', 'exemplars', 'provisionalScores', 'verdict', 'rationale', 'gated', 'outsideSeed'],
        properties: {
          cluster: { type: 'string' },
          exemplars: { type: 'string' },
          provisionalScores: { type: 'string', description: `Conservative ${axisKeys} estimates from discovery evidence only.` },
          verdict: { type: 'string' },
          rationale: { type: 'string', description: 'Per-row: why this rank, why gated or passed over.' },
          gated: { type: 'boolean' },
          outsideSeed: { type: 'boolean' },
        },
      },
    },
    gatedCandidates: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['name', 'cluster', 'exemplars', 'outsideSeed'],
        properties: {
          name: { type: 'string', description: 'The candidate as Phase 2 should hunt it (device/work + exemplar).' },
          cluster: { type: 'string' },
          exemplars: { type: 'string' },
          outsideSeed: { type: 'boolean' },
        },
      },
    },
    noveltyFloorArithmetic: { type: 'string', description: 'The floor check shown as arithmetic, including any judgeable call — flagged, never hidden.' },
    judgmentCalls: { type: 'array', items: { type: 'string' }, description: 'Every ambiguous call made, one line each.' },
    seedsNotCovered: { type: 'array', items: { type: 'string' }, description: 'Brief seeds not covered by any gated candidate — these get the benchmark pass.' },
    gateRationale: { type: 'string' },
  },
}

const SEED_BENCH = {
  type: 'object',
  additionalProperties: false,
  required: ['rows'],
  properties: {
    rows: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['seed', 'scores', 'notes', 'sources'],
        properties: {
          seed: { type: 'string' },
          scores: { type: 'string', description: `${axisKeys} on the same axes as the gate.` },
          notes: { type: 'string' },
          sources: { type: 'array', items: { type: 'string' } },
        },
      },
    },
  },
}

const LENS_REPORT = {
  type: 'object',
  additionalProperties: false,
  required: ['empty', 'findings', 'accessFailures', 'parkedLeads'],
  properties: {
    empty: { type: 'boolean', description: 'true ONLY if you genuinely searched and found nothing in scope. Access-blocked sources make the search inconclusive, not empty — set false and record the failures.' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['what', 'source', 'confirmation'],
        properties: {
          what: { type: 'string' },
          source: { type: 'string' },
          verbatimQuote: { type: 'string', description: 'Exact words from the source when a quote is load-bearing — copy bytes, never transcribe from memory.' },
          confirmation: { type: 'string', enum: ['confirmed by direct fetch', 'existence confirmed, content unread', 'inconclusive (paywall/bot-block)'] },
        },
      },
    },
    accessFailures: { type: 'array', items: { type: 'string' } },
    parkedLeads: { type: 'array', items: { type: 'string' } },
  },
}

const PROFILE = {
  type: 'object',
  additionalProperties: false,
  required: ['candidate', 'summary', 'scores', 'receptionVerdict', 'readingList', 'fieldRead', 'followUpsRun', 'parkedLeads'],
  properties: {
    candidate: { type: 'string' },
    summary: { type: 'string', description: 'The device/work and how it does the goal\'s job, concretely.' },
    scores: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['axis', 'score', 'justification'],
        properties: {
          axis: { type: 'string' },
          score: { type: 'number' },
          justification: { type: 'string', description: 'Evidence-backed: the number, the citation carrying it, and the docked factor keeping it lower.' },
        },
      },
    },
    receptionVerdict: {
      type: 'object',
      additionalProperties: false,
      required: ['verdict', 'evidence'],
      properties: {
        verdict: { type: 'string', description: 'Does the candidate deliver the axes in real use, per reception evidence? Honest negatives carry full weight — never manufacture a claim to fill the slot.' },
        evidence: {
          type: 'array',
          items: {
            type: 'object',
            additionalProperties: false,
            required: ['quote', 'source'],
            properties: { quote: { type: 'string' }, source: { type: 'string' } },
          },
        },
      },
    },
    specimens: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['url', 'caption'],
        properties: { url: { type: 'string' }, caption: { type: 'string' } },
      },
    },
    readingList: {
      type: 'array',
      description: 'Read-first order.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['title', 'author', 'venue', 'whatItSays', 'tag'],
        properties: {
          title: { type: 'string' },
          author: { type: 'string' },
          venue: { type: 'string' },
          whatItSays: { type: 'string', description: 'One line. If built from abstract/snippets, say "preview:" — never present as a settled reading.' },
          tag: { type: 'string', enum: ['confirmed by direct fetch', 'existence confirmed, content unread', 'inconclusive (paywall/bot-block)'] },
        },
      },
    },
    fieldRead: { type: 'string', description: 'How rich or thin the analytical field is per lens door, empty doors named explicitly.' },
    followUpsRun: { type: 'array', items: { type: 'string' }, description: 'Follow-up searches you ordered where a lens came back thin, one line each.' },
    parkedLeads: { type: 'array', items: { type: 'string' } },
  },
}

const MECH_CHECKS = {
  type: 'object',
  additionalProperties: false,
  required: ['checks'],
  properties: {
    checks: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['item', 'method', 'verdict'],
        properties: {
          item: { type: 'string' },
          method: { type: 'string', description: 'What was checked: URL liveness, citation-exists lookup, substring presence, image content-type.' },
          verdict: { type: 'string', enum: ['confirmed', 'failed', 'inconclusive'] },
          note: { type: 'string' },
        },
      },
    },
  },
}

const ADV_VERDICTS = {
  type: 'object',
  additionalProperties: false,
  required: ['verdicts'],
  properties: {
    verdicts: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['claim', 'verdict', 'note'],
        properties: {
          claim: { type: 'string' },
          verdict: { type: 'string', enum: ['confirmed', 'refuted', 'inconclusive'] },
          note: { type: 'string', description: 'For refuted: what the re-search actually found. For inconclusive: the access failure. Paywall/bot-block is inconclusive, never disconfirming.' },
        },
      },
    },
  },
}

const CROSS_CASE = {
  type: 'object',
  additionalProperties: false,
  required: ['observations', 'emptyDoorReading', 'seedComparison', 'weakProfiles', 'headlines'],
  properties: {
    observations: { type: 'array', items: { type: 'string' } },
    emptyDoorReading: { type: 'string', description: 'What the empty-door tally means as evidence, not just as a search log.' },
    seedComparison: { type: 'string', description: 'Gated candidates vs the seed benchmark, on the same axes.' },
    weakProfiles: { type: 'array', items: { type: 'string' }, description: 'Profiles whose evidence is thin, named — the survey must not lean on them.' },
    headlines: { type: 'array', items: { type: 'string' }, description: 'The round\'s strongest claims so far — Phase 3\'s question generators work from these.' },
  },
}

const QUESTION_GATE = {
  type: 'object',
  additionalProperties: false,
  required: ['selected', 'candidates', 'rationale'],
  properties: {
    selected: {
      type: 'object',
      additionalProperties: false,
      required: ['question', 'tentativeAnswer', 'skip', 'skipReason'],
      properties: {
        question: { type: 'string', description: 'The hardest question, or empty string when skipping.' },
        tentativeAnswer: { type: 'string', description: 'The answer Phase 1–2 evidence currently supports — what the refuters attack.' },
        skip: { type: 'boolean' },
        skipReason: { type: 'string', description: 'Required when skip=true: the stated reasons skipping is right for this round.' },
      },
    },
    candidates: {
      type: 'array',
      description: 'Every question generated, with its fork-test result — the auditable trail of the selection.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['question', 'generator', 'forkTestPass', 'forkTestNote'],
        properties: {
          question: { type: 'string' },
          generator: { type: 'string', enum: ['invert-the-headline', 'assumption-audit', 'preset'] },
          forkTestPass: { type: 'boolean' },
          forkTestNote: { type: 'string', description: 'What the build does differently under each answer — both must differ for a pass.' },
        },
      },
    },
    rationale: { type: 'string' },
  },
}

const REFUTER = {
  type: 'object',
  additionalProperties: false,
  required: ['sources', 'summary'],
  properties: {
    sources: {
      type: 'array',
      description: 'Every NEW source examined, in the order examined.',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['source', 'moved', 'note'],
        properties: {
          source: { type: 'string', description: 'URL or exact citation.' },
          moved: { type: 'boolean', description: 'true if this source genuinely moves the answer under attack.' },
          note: { type: 'string' },
        },
      },
    },
    summary: { type: 'string' },
  },
}

const VERDICT = {
  type: 'object',
  additionalProperties: false,
  required: ['verdict', 'answer', 'rationale'],
  properties: {
    verdict: { type: 'string', enum: ['answer-holds', 'answer-moved', 'underdetermined-build-probe'] },
    answer: { type: 'string', description: 'The answer as it stands after the refuter rounds — or the two live answers when underdetermined.' },
    rationale: { type: 'string' },
    probeSuggestion: { type: 'string', description: 'When underdetermined: the cheapest probe that would separate the two answers.' },
  },
}

const CRITIC = {
  type: 'object',
  additionalProperties: false,
  required: ['perspectivesNotRun', 'classesAbsent', 'notes'],
  properties: {
    perspectivesNotRun: { type: 'array', items: { type: 'string' } },
    classesAbsent: { type: 'array', items: { type: 'string' }, description: `${args.clusteringKey} classes conspicuously absent from the whole round.` },
    notes: { type: 'string' },
  },
}

// --- Phase 1: Discovery ------------------------------------------------------
// Perspectives run in pairs so the saturation rule is countable BEFORE the next
// pair launches: two consecutive perspectives yielding zero new clusters closes
// discovery. The wildcard launches with the first pair — one pass, briefed to
// search in ways the listed perspectives don't.
phase('Discovery')

const scoutPrompt = (p) => `You are a discovery scout for a research round.

${SCOUT_CONTEXT}

YOUR PERSPECTIVE — search this way and only this way: ${p.brief}

Search genuinely and persistently — an empty return after one shallow query is the known failure mode of this role. Every find needs an openable source. Report finds even when they duplicate what another perspective would obviously see; dedup happens downstream.`

const wildcardPrompt = `You are the wildcard discovery scout for a research round.

${SCOUT_CONTEXT}

The listed perspectives already searching are: ${args.perspectives.map((p) => p.key + ' — ' + p.brief).join(' | ')}

Your mandate: search in ways those perspectives do NOT. Your budget is a single pass — leads you cannot chase within it go straight to parkedLeads, and you do not get a second pass.`

// Cluster registry pre-seeded from the brief's seed list, so the gate always
// sees the seeds — last round the scouts were briefed past them, the seeds
// never clustered, and the benchmark had to be bolted on mid-run.
let clusters = args.seeds.map((s) => ({ key: s, description: `Seed from the brief: ${s}`, exemplars: [s], isNew: false, newFromPerspective: '' }))
const perspectiveTrace = []
const discoveryAccessFailures = []
const parkedLeads = []
const park = (origin, items) => { for (const l of items || []) parkedLeads.push({ origin, lead: l }) }

const clusterFinds = async (batchReports) => {
  const finds = batchReports.flatMap(({ key, report }) => (report.finds || []).map((f) => ({ perspective: key, ...f })))
  if (finds.length === 0) return []
  const res = await agent(
    `You are the clustering pass of a research round. Group raw finds by ${args.clusteringKey}.

EXISTING REGISTRY (keep every entry, keys unchanged; fold new exemplars in):
${JSON.stringify(clusters.map(({ key, description, exemplars }) => ({ key, description, exemplars })), null, 2)}

NEW RAW FINDS (each tagged with the perspective that found it):
${JSON.stringify(finds, null, 2)}

Return the FULL updated registry. A new cluster means a genuinely different ${args.clusteringKey} — a new exemplar of an existing one is not a new cluster. For each new cluster, set newFromPerspective to the perspective key whose find created it.`,
    { label: 'cluster', phase: 'Discovery', model: 'sonnet', effort: 'medium', schema: CLUSTERING },
  )
  if (!res) return []
  const before = new Set(clusters.map((c) => c.key))
  clusters = res.clusters
  return res.clusters.filter((c) => c.isNew && !before.has(c.key))
}

let wildcardReport = null
let saturated = false
for (let i = 0; i < args.perspectives.length && !saturated; i += 2) {
  const batch = args.perspectives.slice(i, i + 2)
  const thunks = batch.map((p) => () => agent(scoutPrompt(p), { label: `scout:${p.key}`, phase: 'Discovery', model: 'sonnet', effort: 'medium', schema: SCOUT_REPORT }))
  if (i === 0) thunks.push(() => agent(wildcardPrompt, { label: 'scout:wildcard', phase: 'Discovery', model: 'sonnet', effort: 'medium', schema: SCOUT_REPORT }))
  const results = await parallel(thunks)
  if (i === 0) wildcardReport = results.pop()

  const reports = batch.map((p, j) => ({ key: p.key, report: results[j] })).filter((r) => r.report)
  for (const { key, report } of reports) {
    discoveryAccessFailures.push(...(report.accessFailures || []))
    park(`discovery:${key}`, report.parkedLeads)
  }
  const newClusters = await clusterFinds(reports)
  for (const p of batch) {
    const ok = reports.some((r) => r.key === p.key)
    if (!ok) log(`Discovery: scout '${p.key}' died — its zero does not count toward saturation`)
    perspectiveTrace.push({
      perspective: p.key,
      scoutDied: !ok,
      rawFinds: (reports.find((r) => r.key === p.key)?.report.finds || []).length,
      newClusters: newClusters.filter((c) => c.newFromPerspective === p.key).length,
    })
  }
  // Saturation counts only perspectives whose scout actually reported — a dead
  // scout's zero is a transport failure, not evidence of a dry field.
  const t = perspectiveTrace.filter((x) => !x.scoutDied)
  if (t.length >= 2 && t[t.length - 1].newClusters === 0 && t[t.length - 2].newClusters === 0) saturated = true
  log(`Discovery: new clusters per perspective so far — ${t.map((x) => x.newClusters).join(' → ')}${saturated ? ' — saturated, closing discovery' : ''}`)
}
const skippedPerspectives = saturated ? args.perspectives.slice(perspectiveTrace.length).map((p) => p.key) : []
if (skippedPerspectives.length) log(`Discovery closed saturated — perspectives not run: ${skippedPerspectives.join(', ')}`)

if (wildcardReport) {
  discoveryAccessFailures.push(...(wildcardReport.accessFailures || []))
  park('discovery:wildcard', wildcardReport.parkedLeads)
  await clusterFinds([{ key: 'wildcard', report: wildcardReport }])
}

// The gate: Opus, session effort. Conservative scoring is instructed because
// last round's gate estimates ran systematically hot — every deep-dived
// candidate scored at or below its cluster estimate.
const gate = await agent(
  `You are the discovery gate of a research round — the auditable ranking decision.

${SCOUT_CONTEXT}

RANK SPEC: ${args.rankSpec.rule}
Rank-spec rationale: ${args.rankSpec.rationale}
The rank function serves the round's thesis — when a rank artifact would put a weak-on-thesis cluster on top, flag it in that row's rationale rather than silently reordering.

THE CLUSTER REGISTRY (seed-origin entries are the brief's seeds — they compete for slots on equal terms):
${JSON.stringify(clusters.map(({ key, description, exemplars }) => ({ key, description, exemplars })), null, 2)}

SEED LIST (for the outsideSeed flags and seedsNotCovered): ${args.seeds.join('; ')}

Your job:
1. Rank ALL clusters by the rank spec. Score conservatively: provisional scores from discovery evidence systematically run hot, and deep-dive scores supersede yours — when in doubt, score lower.
2. Gate at most ${B.maxGated} candidates for Phase 2. Enforce the novelty floor: at least ${Math.round(args.noveltyFloor * 100)}% of gated candidates from outside the seed list. Show the floor arithmetic; flag every judgeable call rather than hiding it.
3. Respect the hard exclusions and their pass-over rules: ${args.exclusions.join('; ') || 'none'}.
4. List brief seeds not covered by any gated candidate in seedsNotCovered — they receive a light benchmark pass, never silent exclusion.
5. Emit per-row rationale for every cluster — gated or passed over. The table is the audit record.`,
  { label: 'gate:discovery', phase: 'Discovery', model: 'opus', schema: GATE },
)
if (!gate) throw new Error('research-hunt: discovery gate returned nothing — inspect journal.jsonl')

// Code-side validation of what the gate was instructed to do. One corrective
// re-run, then proceed with the violation logged — never silently.
let gateFinal = gate
{
  const gated = gate.gatedCandidates || []
  const outside = gated.filter((c) => c.outsideSeed).length
  const capOk = gated.length <= B.maxGated
  const floorOk = gated.length === 0 || outside / gated.length >= args.noveltyFloor
  if (!capOk || !floorOk) {
    log(`Gate violated its own constraints (cap ok: ${capOk}, novelty floor ok: ${floorOk}) — one corrective re-run`)
    const retry = await agent(
      `Your previous gate output violated its constraints: gated ${gated.length} candidates (max ${B.maxGated}); ${outside} outside the seed list (floor: ${Math.round(args.noveltyFloor * 100)}%). Re-emit the full gate output with the violation corrected. Previous output:\n${JSON.stringify(gate, null, 2)}`,
      { label: 'gate:discovery-retry', phase: 'Discovery', model: 'opus', schema: GATE },
    )
    if (retry) gateFinal = retry
    const g2 = gateFinal.gatedCandidates || []
    if (g2.length > B.maxGated || (g2.length > 0 && g2.filter((c) => c.outsideSeed).length / g2.length < args.noveltyFloor)) {
      log('Gate constraints still violated after corrective re-run — proceeding with the violation on the record')
    }
  }
}
const candidates = (gateFinal.gatedCandidates || []).slice(0, B.maxGated)
log(`Gate: ${candidates.length} candidates gated; seeds to benchmark: ${(gateFinal.seedsNotCovered || []).join(', ') || 'none'}`)

// Non-gated seeds get the commissioned light-pass benchmark — planned, not
// bolted on. Low effort by role: scoring from handed-over sources is mechanical.
const seedBenchPromise = (gateFinal.seedsNotCovered || []).length
  ? agent(
      `Light-pass seed benchmark for a research round. Score each seed below on the same axes as the round, from 2–4 sources each — this is a one-pass benchmark, not a deep dive; it exists so no seed is silently excluded from the cross-comparison.

${SCOUT_CONTEXT}

SEEDS TO SCORE: ${gateFinal.seedsNotCovered.join('; ')}

Score conservatively; cite the sources used per seed.`,
      { label: 'seed-benchmark', phase: 'Discovery', model: 'sonnet', effort: 'low', schema: SEED_BENCH },
    )
  : Promise.resolve(null)

// --- Phase 2: Per-candidate deep dive ----------------------------------------
// pipeline(), no barrier. Empty-vein escalation is coded: when the same lens
// door returns empty across emptyDoorK consecutive candidates (completion
// order — see reference.md for why that approximation is accepted), remaining
// candidates skip that door and one field-level sweep runs instead.
phase('Deep dive')

const doorState = {}
for (const l of args.lenses) doorState[l.key] = { consecutiveEmpty: 0, closed: false, empties: 0 }
const fieldSweeps = {}

const closeDoor = (lens) => {
  doorState[lens.key].closed = true
  log(`Empty-vein escalation: lens door '${lens.key}' returned empty ${B.emptyDoorK} consecutive times — closing it for remaining candidates, running one field-level sweep`)
  fieldSweeps[lens.key] = agent(
    `Field-level sweep for a research round. The per-candidate search below came back empty ${B.emptyDoorK} consecutive times, so per-candidate passes are closed. Run ONE field-wide pass instead: is there ANY work of this kind about ANY candidate in scope — and if the field is genuinely empty, characterize the emptiness (which venues were searched, what the nearest-miss work is).

${SCOUT_CONTEXT}

THE LENS: ${lens.brief}
CANDIDATES IN THE ROUND: ${candidates.map((c) => c.name).join('; ')}`,
    { label: `field-sweep:${lens.key}`, phase: 'Deep dive', model: 'sonnet', effort: 'medium', schema: LENS_REPORT },
  )
}

const lensStage = async (c, idx) => {
  const reports = {}
  const skipped = []
  const open = args.lenses.filter((l) => {
    if (doorState[l.key].closed) { skipped.push(l.key); return false }
    return true
  })
  const results = await parallel(
    open.map((l) => () =>
      agent(
        `You are a lens scout on one candidate of a research round.

${SCOUT_CONTEXT}

YOUR CANDIDATE: ${c.name} (cluster: ${c.cluster}; exemplars: ${c.exemplars})
YOUR LENS — search through this register and only this register: ${l.brief}

Count only work that analyzes or studies the candidate itself, not work proposing something fresh in its place. An honest empty is a finding — but only after genuine, persistent search; premature "nothing found" is this role's known failure mode. Load-bearing quotes must be copied verbatim from a fetched source, never reconstructed.`,
        { label: `lens:${l.key}:${idx + 1}`, phase: 'Deep dive', model: 'sonnet', effort: 'medium', schema: LENS_REPORT },
      ),
    ),
  )
  open.forEach((l, j) => {
    const r = results[j]
    if (!r) return
    reports[l.key] = r
    park(`case:${c.name}:${l.key}`, r.parkedLeads)
    const d = doorState[l.key]
    if (r.empty) {
      d.empties++
      d.consecutiveEmpty++
      if (!d.closed && d.consecutiveEmpty >= B.emptyDoorK) closeDoor(l)
    } else {
      d.consecutiveEmpty = 0
    }
  })
  return { candidate: c, lensReports: reports, doorsSkipped: skipped }
}

const caseLeadStage = async (prev, c, idx) => {
  if (!prev) return null
  const profile = await agent(
    `You are the case lead for one candidate of a research round — the judgment node that turns lens-scout reports into the candidate's profile.

${SCOUT_CONTEXT}

YOUR CANDIDATE: ${c.name} (cluster: ${c.cluster}; exemplars: ${c.exemplars})

LENS REPORTS:
${JSON.stringify(prev.lensReports, null, 2)}
${prev.doorsSkipped.length ? `\nDoors closed by empty-vein escalation (a field-level sweep covers them round-wide — do not re-run them): ${prev.doorsSkipped.join(', ')}` : ''}

Your job:
1. Triage the reports. Where a lens came back thin (not empty — thin), order and run follow-up searches yourself; list them in followUpsRun.
2. Score the candidate on each axis (${axisKeys}) with evidence-backed justification — the number, the citation carrying it, the docked factor.
3. The reception verdict: does the candidate deliver the axes in REAL use? Cite reception evidence pulling in both directions. An honest negative carries full weight; never manufacture a claim to fill the slot.
4. Assemble the reading list in read-first order with per-item confirmation tags, and the field read naming every empty door.
Fabrication risk concentrates exactly where the persuasive work is done — your most load-bearing quote is your highest-risk quote. Copy quotes verbatim from fetched sources only.`,
    { label: `case-lead:${idx + 1}`, phase: 'Deep dive', model: 'opus', schema: PROFILE },
  )
  return profile ? { candidate: c, profile } : null
}

const verifyStage = async (prev, c, idx) => {
  if (!prev) return null
  const p = prev.profile
  const quotes = [
    ...(p.receptionVerdict?.evidence || []).map((e) => ({ quote: e.quote, source: e.source })),
    ...(p.readingList || []).map((r) => ({ quote: r.title, source: `${r.author}, ${r.venue}` })),
  ]
  const [mech, adv] = await parallel([
    () =>
      agent(
        `Mechanical verification pass on one candidate profile of a research round. Check every item below by direct lookup — URL liveness, citation-exists search (exact title + author), substring presence of quoted words in the fetched source, image content-type for specimens. Report one check per item. Paywall/bot-block = inconclusive, never disconfirming.

PROFILE:
${JSON.stringify(p, null, 2)}`,
        { label: `verify-mech:${idx + 1}`, phase: 'Deep dive', model: 'sonnet', effort: 'low', schema: MECH_CHECKS },
      ),
    () =>
      agent(
        `Adversarial re-search verification on one candidate profile of a research round. Take the profile's LOAD-BEARING claims — the flagship quotes, the reception verdict's anchor evidence, the highest-scored axis justifications — and try to REFUTE each by independent re-search: find the original source yourself and check the claim against it. Fabrication concentrates in the most persuasive claims, so start with those.

Verdict rules: 'refuted' requires you to have found the source and shown the mismatch. A source you cannot reach is 'inconclusive' — paywall/bot-block is NEVER disconfirming, and failing to find a source on a shallow search is not proof of fabrication; search persistently before declaring it.

PROFILE (claims + quotes):
${JSON.stringify({ candidate: p.candidate, scores: p.scores, receptionVerdict: p.receptionVerdict, quotes }, null, 2)}`,
        { label: `verify-adv:${idx + 1}`, phase: 'Deep dive', model: 'sonnet', effort: 'medium', schema: ADV_VERDICTS },
      ),
  ])
  return { candidate: c.name, profile: p, doorsSkipped: prev.doorsSkipped, verification: { mechanical: mech, adversarial: adv } }
}

const caseResults = (await pipeline(candidates, lensStage, caseLeadStage, verifyStage)).filter(Boolean)
const seedBenchmark = await seedBenchPromise
const sweeps = {}
for (const [k, pr] of Object.entries(fieldSweeps)) {
  const s = await pr
  if (s) { sweeps[k] = s; park(`field-sweep:${k}`, s.parkedLeads) }
}
const emptyDoorTally = Object.fromEntries(args.lenses.map((l) => [l.key, { empties: doorState[l.key].empties, closed: doorState[l.key].closed }]))

// Gate 2 — the cross-case gate that closes Phase 2: visible synthesis of what
// the cases add up to, and the headlines Phase 3's generators work from.
const crossCase = await agent(
  `You are the cross-case gate of a research round — the auditable close of the per-candidate phase.

${SCOUT_CONTEXT}

CASE PROFILES (verified):
${JSON.stringify(caseResults.map((r) => ({ candidate: r.candidate, profile: r.profile, verification: r.verification })), null, 2)}

SEED BENCHMARK (light pass, lower-rigor by design): ${JSON.stringify(seedBenchmark)}
EMPTY-DOOR TALLY: ${JSON.stringify(emptyDoorTally)}
FIELD SWEEPS: ${JSON.stringify(sweeps)}

Produce: cross-case observations; the empty-door reading (the tally as evidence, not search log); the seed comparison; weak profiles the survey must not lean on (use the verification verdicts — a profile with refuted anchors is weak); and the round's headline claims, each stated strongly enough to be invertible.`,
  { label: 'gate:cross-case', phase: 'Deep dive', model: 'opus', schema: CROSS_CASE },
)

// --- Phase 3: Hardest-question hunt -------------------------------------------
phase('Hardest question')

let phase3 = null
if (args.phase3.mode === 'skip') {
  phase3 = { skipped: true, skipReason: args.phase3.skipReason || 'pre-set skip in the brief', questionGate: null, refuterTrail: [], verdict: null }
  log(`Phase 3 skipped per brief: ${phase3.skipReason}`)
} else {
  const preset = args.phase3.mode === 'preset' ? args.phase3.question : null
  // Gate 3 — the question gate. A pre-set question bypasses generation but
  // still passes through for the tentative answer and the audit record.
  const qgate = await agent(
    `You are the question gate of a research round — you pick the hardest question the round's findings can now put under attack, or skip with stated reasons.

${SCOUT_CONTEXT}

ROUND HEADLINES AND CROSS-CASE FINDINGS:
${JSON.stringify(crossCase, null, 2)}

${preset
      ? `THE QUESTION IS PRE-SET BY THE BRIEF — use it verbatim, tag its candidate entry generator='preset', and state the tentative answer the Phase 1–2 evidence currently supports:\n${preset}`
      : `Generate candidate questions through exactly two generators:
1. invert-the-headline — take each headline claim and state its inversion as a question.
2. assumption-audit — name the assumptions the round's strongest claims rest on; each assumption that could fail becomes a question.

Filter every candidate by the FORK TEST: both answers must change what gets built next — state what the build does differently under each answer; if the build is the same either way, the question fails. Then select the hardest surviving question with visible rationale, or skip with stated reasons if none survives.`}

Also state the tentativeAnswer: the answer the current evidence supports — this is what fresh adversarial scouts will attack.`,
    { label: 'gate:question', phase: 'Hardest question', model: 'opus', schema: QUESTION_GATE },
  )

  if (!qgate || qgate.selected.skip) {
    phase3 = { skipped: true, skipReason: qgate ? qgate.selected.skipReason : 'question gate returned nothing', questionGate: qgate, refuterTrail: [], verdict: null }
    log(`Phase 3 skipped by the question gate: ${phase3.skipReason}`)
  } else {
    const { question, tentativeAnswer } = qgate.selected
    log(`Phase 3 question: ${question}`)

    // Refuter loop. Contamination guard: refuters get the question and the
    // answer under attack — none of SCOUT_CONTEXT, none of the survey scouts'
    // framing or findings. Stop rule in code: close when the answer survives
    // stabilityK consecutive new sources unmoved.
    const seenSources = new Set()
    const refuterTrail = []
    let consecutiveUnmoved = 0
    let round = 0
    while (consecutiveUnmoved < B.stabilityK && round < B.maxRefuterRounds) {
      round++
      const r = await agent(
        `You are an adversarial research scout. A research round has reached a tentative answer to a hard question; your sole job is to REFUTE it — find evidence that moves the answer.

QUESTION: ${question}
THE ANSWER UNDER ATTACK: ${tentativeAnswer}

Search fresh — you have been given no prior framing on purpose. Find NEW sources (do not reuse: ${[...seenSources].join('; ') || 'none seen yet'}) and for each, judge honestly whether it moves the answer. Report sources in the order examined. Do not manufacture movement; an unmoved source honestly reported is a valid result. Premature "nothing found" after shallow search is this role's known failure mode — search persistently.`,
        { label: `refuter:r${round}`, phase: 'Hardest question', model: 'sonnet', effort: 'medium', schema: REFUTER },
      )
      if (!r) break
      let newSources = 0
      for (const s of r.sources || []) {
        if (seenSources.has(s.source)) continue
        seenSources.add(s.source)
        newSources++
        if (s.moved) consecutiveUnmoved = 0
        else consecutiveUnmoved++
        refuterTrail.push({ round, ...s })
        if (consecutiveUnmoved >= B.stabilityK) break
      }
      log(`Refuter round ${round}: ${newSources} new sources, consecutive unmoved: ${consecutiveUnmoved}/${B.stabilityK}`)
      if (newSources === 0) break
    }
    const stability = consecutiveUnmoved >= B.stabilityK ? 'stable' : 'rounds exhausted before stability'

    const verdict = await agent(
      `You are the final verdict of a research round's hardest-question hunt.

QUESTION: ${question}
TENTATIVE ANSWER GOING IN: ${tentativeAnswer}
REFUTER TRAIL (every new source examined, in order, with whether it moved the answer):
${JSON.stringify(refuterTrail, null, 2)}
STOP-RULE STATE: ${stability} (${consecutiveUnmoved} consecutive unmoved of ${B.stabilityK} required, ${round} of ${B.maxRefuterRounds} rounds run)

Deliver the verdict: answer-holds, answer-moved (state the moved answer and what moved it), or underdetermined-build-probe — "both answers still live" is a fully legal verdict; when you reach it, state the cheapest probe that would separate the answers.`,
      { label: 'verdict', phase: 'Hardest question', model: 'opus', schema: VERDICT },
    )
    phase3 = { skipped: false, questionGate: qgate, refuterTrail, stopRule: { stability, consecutiveUnmoved, rounds: round }, verdict }
  }
}

// --- Tail ---------------------------------------------------------------------
phase('Tail')

const critic = await agent(
  `Single-pass completeness critic for a research round. One pass, no new searches beyond quick sanity checks: which discovery perspective was NOT run, which ${args.clusteringKey} class is conspicuously absent, what claim rests unverified? Your output is tagged next-round input — it routes to the appendix, never into this round's argument.

${SCOUT_CONTEXT}

WHAT THE ROUND DID:
Perspectives run: ${perspectiveTrace.map((t) => t.perspective).join(', ')}${skippedPerspectives.length ? ` (skipped, saturated: ${skippedPerspectives.join(', ')})` : ''}
Clusters found: ${clusters.map((c) => c.key).join('; ')}
Candidates deep-dived: ${caseResults.map((r) => r.candidate).join('; ')}
Headlines: ${JSON.stringify(crossCase ? crossCase.headlines : [])}`,
  { label: 'completeness-critic', phase: 'Tail', model: 'sonnet', effort: 'medium', schema: CRITIC },
)

return {
  brief: { slug: args.slug, date: args.date, goal: args.goal, phase3Mode: args.phase3.mode },
  phase1: {
    perspectiveTrace,
    saturation: { fired: saturated, sequence: perspectiveTrace.map((t) => t.newClusters).join(' → '), skippedPerspectives },
    accessFailures: discoveryAccessFailures,
    clusterRegistry: clusters.map(({ key, description, exemplars }) => ({ key, description, exemplars })),
    gate: gateFinal,
    wildcard: wildcardReport ? { finds: (wildcardReport.finds || []).length } : null,
    seedBenchmark,
  },
  phase2: {
    cases: caseResults,
    emptyDoorTally,
    fieldSweeps: sweeps,
    crossCase,
  },
  phase3,
  critic,
  parkedLeads,
}

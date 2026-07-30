# Why this shape

Evidence for the header/trail rules, kept for future lookup. This is the *justification*, not the procedure — see `SKILL.md` for what to do.

Flag: extrapolated from XAI/RAG studies; no direct test exists on provenance trails for strategic documents.

- *Re-checkability, not trust* — trust-building features yield passive acceptance, not scrutiny. Higher trust "increased over-reliance" and "decreased critical thinking" (Schemmer et al., ACM IUI 2023, N=200, arXiv:2302.02187); explanations are "often insufficient to improve decision accuracy or mitigate automation bias" (Romeo & Conti review, AI & Society 2025).
- *Keep it lean; bulk backfires* — inline attribution raised felt-trust (3.40 vs 2.63) but lowered felt-verifiability (3.81 vs 4.29), leaving readers "overwhelmed and distracted" (CHI 2024, N=104, arXiv:2405.20434).
- *Pointer must be openable, not a citation gesture* — citation correctness (source supports the claim) and faithfulness (the source actually drove it) are separable; a correct-looking citation can be post-rationalized to fit a conclusion already reached (Wallat et al., SIGIR ICTIR 2025, arXiv:2412.18004). The openable pointer lets a human catch that; a paraphrase hides it.
- *No labels or options-block* — structured "considered options" rationale as a trust-builder did not survive adversarial verification (2024 ECSA ADR field study); provenance "granularity overload" claims also failed. The cut is deliberate restraint, not a tuned detail level.
- *Steers-not-edits gate* — observed in-repo, not extrapolated: without the gate, the 2026-07-06 experiments-recount trail accreted 38 entries (call pointers already cited inline, spelling fixes, per-mapping synthesis lines) and had to be hand-pruned to 14. In a 5-rep-per-arm wording test on a fixture closeout scenario, the ungated procedure over-trailed 5/5 (5–7 entries); the gated wording produced the target 3-entry shape 5/5.

**The forward-header rationale** — a header so a memory-less later agent reads the artifact right; a trail so a later human reader can trace why a decision came out this way. The trail is an opt-in debugging index for a *human* — traceability for debugging and possibly redoing a call — not a trust signal, not for an agent, and not there to make the body feel authoritative.

// ===========================================================================
// MASTER DOCUMENT — living single source of truth for the IMP project.
//
// The submitted proposal (../proposal/proposal.typ, frozen 2026-07-06) is not
// edited any more. This document starts as a copy of it and evolves with the
// project until it becomes the foundation of the final project documentation
// due 15.01.2027.
//
// When you change scope, design, or method: edit the section, set its status
// tag, add a row to the change log, and record the delta in section 10
// (Deviations from the submitted proposal). Bump `doc-version` below.
//
// Build: typst compile docs/master/master.typ
// ===========================================================================

#let doc-version = "0.5"
#let doc-updated = "26 August 2026"

#set document(
  title: "Master Document: A Reusable Agentic Platform for Auditable, Sentiment-Aware Dynamic Asset Allocation",
  author: ("Cyril Gabriele", "Gian Seifert"),
)

#set page(
  paper: "a4",
  margin: (x: 2.4cm, top: 2.6cm, bottom: 2.4cm),
  numbering: "1",
  number-align: center,
)

#set text(
  font: ("New Computer Modern", "Times New Roman"),
  size: 11pt,
  lang: "en",
)

#set par(justify: true, leading: 0.68em, spacing: 1.05em)

#set heading(numbering: "1.")
#show heading: set block(above: 1.4em, below: 0.8em)
#show heading.where(level: 1): set text(size: 13pt)
#show heading.where(level: 2): set text(size: 11.5pt)
#show heading.where(level: 3): set text(size: 11pt)

#show link: set text(fill: rgb("#1a4f8a"))
#show table: set text(size: 9.5pt)
#show table.cell.where(y: 0): strong

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Status pill used under a heading to say how settled that section is.
#let pill(label, colour) = box(
  fill: colour.lighten(82%),
  inset: (x: 5pt, y: 2pt),
  outset: (y: 2pt),
  radius: 2pt,
  text(size: 7.5pt, weight: "semibold", fill: colour.darken(15%), upper(label)),
)

#let tag-settled = pill("settled", rgb("#2f6f3e"))
#let tag-drafting = pill("drafting", rgb("#8a6d1a"))
#let tag-open = pill("open", rgb("#9a3324"))

#let status(tag, body) = block(above: 0.1em, below: 1.0em)[
  #tag #h(0.4em) #text(size: 9pt, fill: rgb("#585858"), style: "italic")[#body]
]

// Grey panel, as used in the proposal for success criteria and examples.
#let panel(body) = block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
  body,
)

// Amber panel for questions that are still open.
#let openq(body) = block(
  fill: rgb("#fdf8ec"),
  stroke: (left: 2pt + rgb("#c9a227")),
  inset: (x: 12pt, y: 10pt),
  width: 100%,
  body,
)

// ---------------------------------------------------------------------------
// Title block
// ---------------------------------------------------------------------------

#align(center)[
  #block(inset: (bottom: 0.4em))[
    #text(size: 18pt, weight: "bold")[
      A Reusable Agentic Platform for Auditable,\
      Sentiment-Aware Dynamic Asset Allocation
    ]
  ]

  #v(0.4em)
  #text(size: 12pt)[Cyril Gabriele #h(1em) · #h(1em) Gian Seifert]

  #v(0.3em)
  #text(size: 10pt, style: "italic")[
    Master Document #h(0.4em) · #h(0.4em) version #doc-version #h(0.4em) · #h(0.4em) #doc-updated
  ]

  #v(0.9em)
  #text(size: 10pt)[
    Supervisors:\
    Prof. Dr. Alexander Braun, School of Finance #h(0.6em) · #h(0.6em) main supervisor\
    Prof. Dr. Siegfried Handschuh, Institute of Computer Science #h(0.6em) · #h(0.6em) technical advisor
  ]
]

#v(1.2em)

// ---------------------------------------------------------------------------
// About this document (unnumbered)
// ---------------------------------------------------------------------------

#panel[
  *About this document*

  This is the living master document of the project. It starts as a copy of the project
  proposal submitted on 6 July 2026 and is the only document that is kept up to date as the
  scope, design, and method change. The submitted proposal stays frozen at
  `docs/proposal/proposal.typ` as the record of what was originally promised; every later
  divergence from it is recorded in @sec:deviations rather than by editing it.

  By the documentation deadline (15 January 2027) this document is intended to have grown
  into the foundation of the final project report: the same sections, filled with what was
  actually built and measured. @sec:to-final maps each section onto its place in that report.

  *Status tags.* Each section carries one tag: #tag-settled agreed and unlikely to change,
  #tag-drafting actively being worked on, #tag-open not yet decided. Open points are also
  collected in @sec:open-decisions.

  *How to update.* Edit the section, adjust its status tag, add a row to the change log
  below, record any promise-breaking change in @sec:deviations, bump `doc-version`, and
  recompile with `typst compile docs/master/master.typ`.
]

#v(0.6em)

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Version], [Date], [Change]),
  [0.1], [2026-08-24], [Master document created from the submitted proposal. Content unchanged; added document control, work plan, open decisions, deviation log, and the mapping to the final documentation.],
  [0.2], [2026-08-25], [Decision-evaluation reframe agreed with the practice partner. Single performance question replaced by four decision-level research questions; objectives, comparator design, evaluation plan and scope rewritten accordingly; division of labour recorded; candidate-selection rubric, leakage protocol and pre-registration step added.],
  [0.3], [2026-08-25], [Evidence pack restructured as a nested information ladder (L1 to L4) with leakage measured at each rung rather than assumed. RQ2 split into three contrasts so that divergence decomposes into an aggregator component and an information component. Pre-freeze feasibility check added. RQ4 risk translation made unconditional and given a risk model with a fallback. Weekly cadence rejustified as the partner's committee cadence.],
  [0.5], [2026-08-26], [RQ1's pass/fail gate replaced by an ensemble: a decision is $k$ randomized-presentation samples with the median taken, and RQ1 reports dispersion against $k$ rather than voiding RQ2. RQ2's primary endpoint becomes the fraction of dates exceeding the margin rather than a mean deviation, the margin becomes ours rather than the partner's and is reported as a curve, and the within-model contrast is promoted to first. Leakage protocol reordered to measure-then-mitigate: probe at every rung, representation controls held in reserve and triggered on evidence, window opens with a buffer after the nominal cut-off.],
  [0.4], [2026-08-25], [Agentic design carried into this document: Stage 2 becomes a bounded agent loop over a sealed point-in-time substrate with safety invariants enforced in code, the audit artifact becomes the realized pack including the tool-call trace, the ladder rung becomes a permission level on the tool layer, and retrieval behaviour is added as an evaluated observable. Resolves the contradiction between this document and the signal-and-tool catalogue.],
)

#v(1em)

#outline(title: [Contents], depth: 2, indent: 1em)

#pagebreak()

// ---------------------------------------------------------------------------
// 1. Motivation
// ---------------------------------------------------------------------------

= Motivation

#status(tag-settled)[Carried over from the submitted proposal.]

Banks and asset managers increasingly use AI to support information-heavy work, but financial
decisions still require governance, documentation, risk control, and human oversight
@reuters-banks @eu-ai-act @reuters-eba. This is especially relevant for dynamic stock/bond
allocation, since the high-level split between equities and bonds drives much of a portfolio's
risk and return @brinson.

Traditional quantitative models can process valuations, momentum, macro data, rates, and risk
indicators, but they usually do not incorporate text-based market sentiment in an auditable way.
Generic LLM assistants have the opposite weakness: they can summarize narratives, but they do not
provide deterministic analytics, point-in-time traceability, or a controlled link to an asset
manager's existing models.

Existing published work already covers financial LLM platforms, LLM-based trading agents,
financial report-generation systems, and broader agentic asset-allocation or news-to-portfolio
pipelines @finrobot @finmem @tradingagents @finteam @self-driving-portfolio @cn-buzz2portfolio.
However, to the best of our knowledge, this literature has not yet addressed the narrower workflow
targeted here: a non-trading, point-in-time, auditable stock/bond allocation memo system that
combines deterministic quantitative and sentiment evidence with a constrained LLM
report-generation layer.

This project proposes a controlled two-stage system for an asset-management partner. First,
numerical and sentiment inputs are sealed into a timestamped, point-in-time evidence store. Second,
an agent reaches that store through a constrained tool layer and generates an investment report and
a machine-readable stock/bond allocation decision, with every retrieval logged. The system does not
trade, execute allocation changes, or replace the investment committee; it supports the people
making the decision.

// ---------------------------------------------------------------------------
// 2. Applied Research Question
// ---------------------------------------------------------------------------

= Applied Research Questions <sec:rqs>

#status(tag-drafting)[Reframed on 25 August 2026 following the meeting with the practice partner.
Replaces the single performance question carried over from the proposal. Pending our written
confirmation to the partner and sign-off by both supervisors. Recorded in @sec:deviations.]

The proposal asked how the system performs. That question cannot be answered on the sample this
project can legitimately use. The evaluation window is bounded below by the implementation model's
knowledge cut-off (@sec:leakage), which leaves roughly two years of clean post-cut-off history.
Two years is ample for measuring how a system decides and far too short to resolve return-based
performance for any tactical strategy: at a weekly cadence it yields on the order of one hundred
decisions, and the effective sample is smaller still because consecutive weekly evidence states are
highly persistent. The industry record makes the same point from the other side. Over the decade to
April 2023 the average tactical allocation fund returned roughly a third of a US 60/40 mix, and of
the twelve funds that survived the period not one beat 60/40 on return or on Sharpe
@morningstar-tactical.

The project therefore evaluates the *decisions* the system makes rather than the returns those
decisions happen to produce. Four questions, run in sequence with explicit gates:

#panel[
  *RQ1, reproducibility.* How far does an LLM-generated tactical allocation decision move under
  meaning-preserving perturbations of an identical information set, and how many samples per
  decision does it take to make the system as reproducible as the difference RQ2 tests for?

  #v(0.4em)
  *RQ2, practical equivalence.* Are LLM-generated bond/equity allocation decisions practically
  equivalent to those of a pre-registered deterministic allocation rule that could actually be
  deployed instead? The question is asked twice. First on identical inputs, at the rung of the
  evidence ladder the rule can fully consume (@sec:ladder), which is the information-matched
  comparison. Second with the model given the rungs a deterministic rule structurally cannot
  represent, which is where any capability advantage would have to appear.

  #v(0.4em)
  *RQ3, divergence analysis.* Where the systems diverge materially, is the divergence stable across
  meaning-preserving perturbations and repeated model runs, does it decompose into an aggregator
  component and an information component, and is it systematically associated with identifiable
  characteristics of the evidence state?

  #v(0.4em)
  *RQ4, economic outcomes.* Declared unanswerable on the available sample, in advance. In its place
  the project reports the risk translation of every system's full weight path: what each system's
  decisions, and any difference between them, mean in beta, duration, tracking-error and scenario
  terms.
]

*Why the order matters.* RQ1 comes first because it needs no forward returns and because its answer
sizes the system RQ2 compares. A decision is an ensemble rather than a single model call: the model
is sampled $k$ times per date, each sample with independently randomized signal order, phrasing and
numeric format, and the recommended weight is their median (@sec:ensemble). Sampling noise and
sensitivity to presentation then both fall at the root-$k$ rate, so RQ1's output is a curve of
dispersion against $k$, and the $k$ carried into RQ2 is the smallest at which the system is as
reproducible as the difference RQ2 tests for.

This replaces the earlier pass/fail gate, under which a sensitive model voided RQ2 outright. The
replacement is strictly better: it always yields an answer; the reported $k$ is itself a result,
putting a number on what a language model costs where a deterministic rule is reproducible by
construction; and the ensemble is the artifact anyone would actually deploy, since a single sample
from a stochastic model is not a product. RQ2 is the core comparison against the deterministic rule.
RQ3 runs only where RQ2 finds material divergence. RQ4 is not a further step in that chain but a
reporting layer applied to every weight path on every branch.

*What each answer is worth.* Every branch of this design produces a reportable result. Equivalence
at the matched rung of the ladder means the LLM reproduces, at higher cost and with lower
reproducibility, an aggregation a transparent rule already performs: a clean negative result, and
one consistent with the out-of-sample literature. Equivalence at the matched rung combined with
material divergence at the higher rungs is the positive case, and the more interesting one. It
locates the model's contribution in the evidence a deterministic rule cannot represent, which is
the claim usually made for language models in this domain and has not been tested at the allocation
level. Divergence that is stable and state-associated is characterised by RQ3. Divergence that
dissolves under perturbation is a finding about LLM decision stability, again in a domain where it
has not been measured at the allocation level. There is no branch in which the honest answer is
unavailable, which is the point of the reframe.

#openq[
  *Open:* the project title still describes a sentiment-aware allocation system. Sentiment is now
  one evidence block among several rather than the organising idea. Decide whether to retitle once
  the supervisors have signed off on the reframe.
]

// ---------------------------------------------------------------------------
// 3. Project Objectives
// ---------------------------------------------------------------------------

= Project Objectives

#status(tag-settled)[Carried over from the submitted proposal.]

== Objective 1: Build a controlled two-stage evidence-to-report pipeline

Develop a reproducible pipeline in which a deterministic offline stage builds a sealed
point-in-time substrate, and the LLM then reaches that substrate through a constrained tool layer to
produce a standardized allocation report. The model may retrieve, but it must not browse the web,
reach a live service, trade, see a calendar date, or introduce facts absent from the substrate.

#panel[
  *Success criterion:* For every rebalancing date, the system produces:

  - a realized evidence pack, being the briefing plus the full ordered trace of tool calls,
  - a human-readable investment report,
  - a machine-readable allocation decision,
  - a record of the model, prompt, data sources, and generation settings.
]

== Objective 2: Build and freeze a deployable deterministic comparator

Construct the deterministic allocation rule that RQ2 compares against, from the same evidence pack
the LLM consumes, and freeze it before any evaluation runs. The rule is multi-variable in that it
ingests the whole pack, and unfitted in that no coefficient is estimated on history;
@sec:comparator sets out why. Two simpler anchors are built alongside it so that divergence can be
decomposed rather than reported as a single number.

#panel[
  *Success criterion:* Three comparators exist as frozen, versioned code: a static 60/40, a
  volatility-targeted 60/40, and the composite rule over the full pack. The composite rule is
  certified by the practice partner as one they would genuinely deploy, and the freeze is recorded
  by commit hash before the first evaluation run.
]

== Objective 3: Evaluate the decisions, not the returns

Measure the stability of the LLM's decisions under meaning-preserving perturbation (RQ1), test
whether those decisions are practically equivalent to the comparator's on identical evidence (RQ2),
and characterise any material divergence (RQ3). Report the risk translation of that divergence in
place of an economic-outcome claim (RQ4).

#panel[
  *Success criterion:* For each pre-registered endpoint the evaluation reports the model's own
  dispersion at fixed input; the dispersion added by meaning-preserving perturbation; the paired
  weight-deviation series against each comparator, with an interval that accounts for the
  persistence of weekly decisions; and the beta, duration and tracking-error consequence of any
  material deviation. An inconclusive equivalence result is reported as inconclusive, never as
  equivalence.
]

== Objective 4: Assess report quality, auditability, and leakage control

Evaluate whether the generated reports are factually grounded in the evidence pack, internally
consistent with the allocation recommendation, and protected against temporal leakage.

#panel[
  *Success criterion:* Each report can be audited against the evidence pack, and no material
  factual claim should rely on information unavailable at the decision date.
]

// ---------------------------------------------------------------------------
// 4. System Design
// ---------------------------------------------------------------------------

= System Design

#status(tag-drafting)[Architecture is stable at the two-stage level. The pipeline is agentic: the
model reaches evidence through a tool layer rather than receiving a single static handoff, fixed by
decision of 24 August 2026 and recorded in @sec:deviations. Internals of both stages are still being
specified.]

The prototype follows a two-stage workflow. Stage 1 is offline and deterministic: it builds a
sealed, point-in-time store of quantitative, macro-financial and text-based evidence. Stage 2 is a
bounded agent loop: at each decision date the model receives a short briefing, reaches into that
store through a constrained tool layer, and produces an investment report together with a
machine-readable allocation decision. @app:example-report shows an illustrative example of the
report format this workflow is meant to produce.

The arrow between the stages is a loop, not a single handoff, and that is the substantive
architectural choice of the project. The model is the aggregator. There is no optimiser and no
Black-Litterman step between it and the weights, and nothing in the pipeline decides an allocation
on its behalf.

#figure(
  image("diagrams/v3_architecture.svg", width: 100%),
  caption: [High-level two-stage workflow for the allocation report prototype.],
) <fig:system-workflow>

#openq[
  *Open:* the diagram still shows a single handoff from Stage 1 to Stage 2. It needs redrawing with
  the tool loop, the sealed store, and the call budget before the progress presentation.
]

== Stage 1: the sealed substrate and the evidence pack <sec:evidence-pack>

Stage 1 is deterministic and runs entirely offline, before any decision date is evaluated. It
collects quantitative, macro-financial and text-based signals and writes them into a frozen store
keyed by signal, as-of date, vintage date, and value. The working catalogue of candidate signals and
tools, together with the point-in-time rules each one has to satisfy, is maintained separately in
`docs/evidence-pack/signal-and-tool-catalogue.md`. That catalogue is deliberately a superset; the
selection that is actually implemented is recorded here once it is made.

Because the model retrieves rather than receives, the evidence pack is three artifacts rather than
one:

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Artifact], [What it is], [When it exists]),
  [Sealed substrate], [The frozen point-in-time store. Every value carries its vintage. The only thing tools are permitted to read.], [Built once, offline, before any run],
  [Briefing], [The compact opening context: universe, portfolio state, constraints, the signal manifest, and the block composites. Deliberately thin, so that the model knows what exists and where to start without being handed everything.], [Assembled per decision date],
  [Realized pack], [The briefing plus the complete ordered trace of tool calls and returns.], [Produced by the run],
)

The audit record required by Objective 1 is the *realized pack*. That is stronger than a static
pack, not weaker: it records not only what evidence existed at the decision date but what the model
actually chose to look at.

*How candidates are selected.* Not by whether they predict returns. Selecting inputs on their
performance inside the evaluation window would fit roughly one hundred decisions with a catalogue
of some fifty candidates, which is the data mining this whole design exists to avoid. Nor does the
comparison require them to predict: both systems see the same pack, so its information content is a
shared constant in the RQ2 contrast. What the pack has to be is decision-relevant and defensible.
Each candidate is therefore scored ex ante on six criteria, none of which touches evaluation-window
returns:

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Criterion], [Why it discriminates]),
  [1. What object does it forecast?], [Second moments and identities beat first moments. Volatility is persistent and forecastable @moreira-muir; starting yield explains most of subsequent long-horizon bond return by identity plus reinvestment, not by a fitted regression; expected returns largely are not forecastable @goyal-welch-zafirov.],
  [2. Risk premium or anomaly?], [Signals with an economic risk-premium rationale decay less after publication. Across 97 predictors, returns are 26 per cent lower out of sample and 58 per cent lower post-publication @mclean-pontiff.],
  [3. Survives a published out-of-sample screen?], [Goyal, Welch and Zafirov report which predictors survive both in and out of sample @goyal-welch-zafirov; applying their screen is an ex-ante filter that costs no degrees of freedom here. Where the literature is split, both sides are recorded @mop @huang-tsmom. The relevant significance bar is also higher than the conventional one @harvey-liu-zhu.],
  [4. Point-in-time quality.], [Publication lag, revision behaviour, and whether a genuine vintage source exists. Current FRED series for revised macro aggregates are not point-in-time; the vintage archive is. A signal without a vintage source is either market-based and unrevised, or it is not usable.],
  [5. Dynamic range in the window.], [Does it actually move over the evaluation period? A pack of near-constant signals leaves both systems sitting near a constant, and the comparison then measures noise against noise. This is the failure mode most likely to void the project, and it is not the same thing as weak predictive power.],
  [6. Non-redundancy.], [Does it carry anything the rest of the pack does not already carry?],
)

The full candidate catalogue, its scoring, and the sourcing notes live in
`docs/evidence-pack/signal-and-tool-catalogue.md`. Sourcing is public first, then the databases HSG
licenses, and only what neither route covers goes to the practice partner (@sec:labour).

#openq[
  *Open:* which signals enter the shipped pack, at what frequency, and from which sources. Target a
  small pack, five to eight signals, covering both the equity and the bond leg. Decided against the
  catalogue, then written back into this section. See @sec:open-decisions.
]

== The information ladder <sec:ladder>

A pack of z-scores and nothing else makes the LLM's task identical to C2's: average the numbers.
RQ2 would then return equivalence for mechanical reasons, and the result would say something about
arithmetic rather than about language models. The pack is therefore built in four nested rungs, each
strictly containing the one below it and each derived from the same underlying data. What separates
the rungs is not how much they say about the world but how much of it a deterministic rule can
represent.

#table(
  columns: (auto, 1fr, auto, auto),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Rung], [Contains], [C2 can consume], [Leakage risk]),
  [L1], [Z-scores, percentiles, and the block composites.], [In full], [Low],
  [L2], [Plus cross-signal disagreement, dispersion, conflict flags, reliability and vintage metadata, and missingness.], [No], [Low],
  [L3], [Plus themed sentiment summaries with topic salience and direction, a qualitative regime description, and named entities and events replaced by class descriptions.], [No], [Moderate, measured],
  [L4], [Plus raw article text, real entities, absolute index levels, and calendar dates.], [No], [High, contaminated],
)

L2 is the rung that is easy to miss. It is not new information about the world; it is second-order
structure about the evidence set itself, computed from the inputs already present in L1. Both of its
main components are already specified in the catalogue, which treats reliability metadata and
disagreement as first-class fields of every signal record. A z-score-and-average rule cannot consume
either without becoming a different and fitted rule; a language model can. That inability is
intrinsic to what a deployable deterministic rule is, not a handicap imposed for the experiment,
which is what makes the comparison honest rather than rigged.

The rung is not a document format but a permission level on the tool layer: it governs what tools
are allowed to return, so a run at L1 cannot reach L3 content however the agent asks for it. Ladder
and tool design are therefore one mechanism, enforced in the store and tool layers rather than in
the prompt.

Richer rungs also carry more leakage risk, so the ladder is a single axis running from impoverished
and clean to rich and contaminated. Leakage is therefore measured at each rung rather than assumed
of the protocol as a whole (@sec:leakage), and the rung is the primary experimental factor of the
evaluation (@sec:contrasts). L4 exists to bound how large the contamination can be, not to be
reported as a result.

#openq[
  *Open:* the exact content of each rung, the banding criterion that keeps a realized pack from
  fingerprinting a single week, and the substitution dictionary used at L3. All three are
  pre-registration items and must be frozen before any run, or the reported rung becomes the one
  that gave the most agreeable answer. See D14 in @sec:open-decisions.
]

== Stage 2: the bounded agent loop <sec:ensemble>

Stage 2 is the LLM layer, and it is agentic. The model opens with the briefing, then reaches further
evidence by calling tools against the sealed substrate, and closes by producing a human-readable
investment report plus a machine-readable allocation decision. It may not browse the web, read
arbitrary news, hit any live service, or introduce facts absent from the substrate. Model
identifier, prompt version, and generation settings are pinned and stored with every run.

*A decision is an ensemble, not a single call.* At each decision date the loop is run $k$ times,
each run with independently randomized signal order, phrasing and numeric format, and the
recommended weight is the median across runs. One run's report is retained in full as the
committee-facing memo; the rest are kept for the dispersion measure and for the retrieval-stability
analysis of @sec:retrieval.

The randomization is load-bearing and easy to get wrong. Averaging $k$ runs at a *fixed*
presentation shrinks sampling noise but leaves presentation sensitivity entirely untouched: it
estimates, very precisely, what the model says under one arbitrary wording. Randomizing the
presentation inside the ensemble folds presentation sensitivity into sampling variance, so both fall
at the root-$k$ rate. What survives is any bias common to every presentation, and that is not noise
but the model's behaviour, which is exactly the object RQ2 measures. The ensemble therefore sharpens
the estimand rather than laundering it.

*Constrained is not the same as static.* The earlier design handed the model a single fixed pack.
Letting it retrieve instead costs nothing in auditability, because the trace is logged, and it buys
two things. It makes the system the thing the project claims to study, an agentic allocation
workflow rather than a prompt template over a JSON blob. And it produces an observable a static
design cannot: *retrieval behaviour*, which is evaluated in @sec:retrieval.

The safety of this rests on invariants enforced in code, not on prompt instructions:

+ *The decision date is injected by the harness and never passed by the agent.* No tool signature
  accepts a date. This is the load-bearing one: an agent that can name a date can name a future one.
+ *Tools read the frozen store only.* No tool reaches a live API during a run. Leakage then becomes a
  property of how the store was built, testable once and for all, rather than a property of the agent
  loop, which cannot be tested exhaustively.
+ *Every returned value carries its vintage,* and the filter `vintage <= t` is applied in the store
  layer, below the tool layer, where the agent cannot reach it.
+ *No tool returns content above the active ladder rung* (@sec:ladder). The rung governs what the
  tool layer is permitted to hand back, which is how the ladder and the tool design stay one
  mechanism rather than two.
+ *Every call is logged*: name, arguments, return, ordinal position, latency.
+ *The comparators' outputs are never visible to the agent.*
+ *A hard call budget per decision.* Without a cap the agent pulls everything, which reproduces the
  static pack with extra latency and destroys the retrieval observable. With a cap it has to choose,
  and choosing is the behaviour worth measuring.

#openq[
  *Open:* the tool API surface, the per-decision call budget, and what the briefing carries before
  the first call. The budget is also a clean ablation axis, since behaviour, stability, and the
  divergence from C2 may all move with it. See D15 in @sec:open-decisions.
]

== The decision setting

Both systems make the same decision in the same setting, agreed with the practice partner and
deliberately simple: weekly, one representative index per asset class, equity weight free from 0 to
100 per cent, no turnover cap. The translation from the LLM output into portfolio weights is
specified ex ante as a reproducible mechanical rule and fixed before the evaluation runs.

#openq[
  *Open:* the unconstrained 0 to 100 range interacts badly with the materiality margin. A model
  that swings from 20 to 80 per cent on noise produces large measured divergence and a dramatic
  risk translation for reasons that have nothing to do with judgment. Either the action space is
  constrained, or turnover and within-model dispersion are reported jointly with divergence so that
  the two cannot be confused. Raise with the partner before the freeze.
]

== The deterministic comparator <sec:comparator>

RQ2 needs a counterparty that consumes the identical pack and does something principled with it. A
constant benchmark will not serve: comparing the LLM to a static 60/40 measures whether the LLM
moves, not whether it aggregates evidence differently from a principled aggregator. Three
comparators are therefore built, and their divergences decompose the LLM's behaviour.

#table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Comparator], [What it is], [What its divergence isolates]),
  [C0, static], [Constant 60/40.], [The triviality floor: whether either system moves at all.],
  [C1, risk-based], [Equity weight scaled to a fixed risk budget off the pack's volatility block @moreira-muir, and nothing else.], [How much of the LLM's behaviour is risk-scaling that requires no view.],
  [C2, composite], [Every signal in the pack z-scored on an expanding window, each z mapped to a tilt, the tilts equally weighted.], [The rest of the evidence. This is the rule that is frozen and certified.],
)

*C2 is multi-variable but not fitted, and that is deliberate.* Estimating coefficients over
pre-evaluation history would build the comparator out of exactly the class of model the
out-of-sample literature says fails: of 29 equity-premium predictors re-examined by Goyal, Welch
and Zafirov, more than a third lose in-sample significance and half of the survivors then fail out
of sample @goyal-welch-zafirov. Fitted coefficients would also be a second set of arbitrary choices
to defend, with no better answer available than "they fit the estimation window." Equal weighting
is the defensible alternative, and it has support: simple combination beats estimated weights out
of sample for equity-premium forecasts @rapach-combination, for the same reason equal weighting
across assets beats an estimated covariance matrix @demiguel. The naive-diversification argument
already used to justify the 50/50 benchmark is simply applied one level up, to the signals rather
than the assets.

Dropping the fitting also removes the most fragile and most expensive part of the build: long clean
estimation history for every variable, coefficient-stability analysis, walk-forward refitting, and
purged cross-validation. None of it is load-bearing for RQ2, and all of it would have to be
defended.

*The comparator is not required to outperform.* Its job is to be an honest, transparent,
pre-registered reference decision. If C2 beat 60/40 over a two-year window that would be weak
evidence of luck rather than strong evidence of skill @cederburg, and it would not change what RQ2
measures.

#openq[
  *Open:* the partner has offered to certify C2 as deployable. Certification must not sit on the
  critical path. C0 and C1 need no certification and RQ2 can be reported against them if
  certification stalls. Agree a certification deadline in writing.
]

== Audit trail

Every run stores the realized pack, which is the briefing plus the complete ordered trace of tool
calls and their returns, together with the prompt, the model identifier and generation settings, the
generated report, the machine-readable decision, and the run metadata. Any recommendation can then
be reconstructed after the fact, and the reconstruction shows not only what the model was told but
what it asked for and in what order.

// ---------------------------------------------------------------------------
// 5. Evaluation Plan
// ---------------------------------------------------------------------------

= Evaluation Plan

#status(tag-drafting)[Rewritten on 25 August 2026 for the decision-evaluation reframe in @sec:rqs.
Endpoints and thresholds are named here but not yet fixed; fixing them is the pre-registration step
in @sec:prereg.]

== What is measured

Every endpoint below is a property of the *decision*: the recommended equity weight at a decision
date, or the difference between two such weights. None of them requires forward returns, which is
what makes the design viable on a two-year window. Realized returns are computed for the risk
translation in @sec:risk-translation only. They are never used to select signals, tune a
comparator, or support a performance claim.

The evaluation runs weekly over the post-cut-off window, one representative index per asset class,
against the three comparators of @sec:comparator.

== RQ1: reproducibility and the size of the ensemble <sec:rq1>

Three sources of variation are measured separately, because conflating them makes every downstream
result unattributable:

+ *Sampling noise at fixed input.* The same pack and the same prompt, run $k$ times. Temperature
  zero is not determinism, and an agent that also chooses which tools to call carries a second
  source of variance. This is the floor against which everything else is read.
+ *Meaning-preserving perturbation.* The same evidence, re-presented: signal order permuted, the
  briefing paraphrased, units and scales changed, numeric precision varied, equivalent formats
  swapped (table against prose). This is the robustness RQ1 actually asks about.
+ *Model-version drift.* The same pack and prompt on a different checkpoint of the same model
  family. Descriptive only; the evaluation itself pins one version.

*The $k$ curve is the primary output.* (1) and (2) are what the ensemble of @sec:ensemble averages
over, and both fall at the root-$k$ rate once the presentation is randomized inside the ensemble.
RQ1 therefore reports dispersion of the ensemble's recommended weight as a function of $k$, and the
$k$ carried forward is the smallest at which that dispersion falls below the margin RQ2 tests
against. That number is a headline result, not a nuisance parameter: it is the sampling cost of
using a language model as the aggregator, and nothing in the LLM-finance literature reports it at
the allocation level.

*The remaining diagnostic.* If (1) is of the same order as (2), the model is not responding to
presentation but to nothing in particular, which is a different and more severe finding and is
reported as such. Stating this quantitatively, in the same units as the margin, is what keeps RQ1
from degenerating into "the model is somewhat sensitive," which is known in advance.

*Cost is what bounds $k$, not statistics.* $k$ multiplies every decision date and every ladder rung
in every contrast, so the total call count is computed and fixed before the evaluation runs. The
$k$-curve itself is estimated on a stratified subsample of decision dates, chosen ex ante to span
calm, stressed, and transitional evidence states, rather than on every date.

#openq[
  *Open:* the perturbation taxonomy, the number of arms, the $k$-curve grid, the date subsample, and
  the total call budget. All are pre-registration items (@sec:prereg). A first cost estimate is
  needed early, since $k$ and the number of contrasts together set the compute bill and the two
  trade against each other.
]

== RQ2: practical equivalence

Equivalence is a claim that the difference lies *inside* a pre-specified margin, so the margin has
to exist before the test is run. We set and justify it ourselves, in percentage points of equity
weight and the basis points of tracking error those translate into (@sec:risk-translation), and
register it before any result is seen. Taking it from the practice partner was the earlier plan and
has been dropped: a threshold handed to us could be set tighter than the pack's own dynamic range,
in which case no result is reachable, and the project's central comparison should not hinge on
someone else's number. The partner's view is recorded as one marked point on the curve below.

#panel[
  *Estimand.* The comparator is deterministic; the ensemble is not. Equivalence is tested on the
  ensemble's median, with the repeat-to-repeat uncertainty propagated into the interval rather than
  discarded by collapsing to a point.
]

*The primary endpoint is a proportion, not a mean.* Averaging the weight deviation across decision
dates estimates one number from a series whose consecutive states barely move, which is close to the
worst case for precision and is what made the inconclusive branch the expected outcome. With $k$
samples per date, each date instead yields its own tight estimate of the gap and its own
uncertainty, so the endpoint becomes the *fraction of decision dates on which the gap exceeds the
margin*. Proportions resolve far better than means under persistence, because the per-date verdict
is a binary event rather than a quantity whose average has to be pinned down. A result of the form
"the systems differ materially on 34 per cent of dates, 95 per cent interval 25 to 44" is reportable
on this sample where a mean would not be. The mean absolute deviation stays as a secondary
descriptive figure rather than as the test.

*The verdict is a curve, not a single word.* Rather than testing at one threshold, the analysis
reports the conclusion as a function of the margin: "equivalent at margins above 6.2 points of
equity weight, materially different below 3.1, undetermined between." The undetermined region then
becomes a stated range rather than a failure to answer. Combined with the proportion endpoint and
the ensemble, this is what removes "the comparison could not be run" as a live project risk.

=== The three contrasts <sec:contrasts>

The third is interpretable only because of the first two.
Handing the LLM information the comparator does not have would, on its own, destroy RQ2: any
divergence would then have two indistinguishable causes, a different aggregator or a larger
information set, and the finding would reduce to the observation that more information changes
behaviour. The ladder of @sec:ladder avoids this by making the rung an experimental factor, so that
the two causes are separated by design rather than argued about after the fact.

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Contrast], [Holds fixed], [Measures]),
  [LLM(L3) against LLM(L1)], [Aggregator], [The information difference, and the best-powered of the three: same model, same dates, nested inputs, so model-level anchoring and every other nuisance cancels in the pairing. This is where a capability advantage would have to appear if it exists, and it carries the project's most resolvable claim. Reported first.],
  [LLM(L1) against C2], [Information], [The aggregator difference. Both systems see the same numbers with the same access to them. Equivalence here means that, given identical scalar evidence, the model adds nothing beyond the averaging the rule already performs.],
  [LLM(L3) against C2], [Nothing], [The total divergence, which the two contrasts above decompose into its aggregator and information components.],
)

The three are not equally well powered, and the reporting order reflects that. The within-model
contrast comes first because nothing but the rung differs between its arms, so it needs no
cross-system assumptions and carries the narrowest intervals available on this sample. The two
cross-system contrasts answer RQ2 as originally posed and are reported alongside, with their wider
intervals stated rather than glossed.

The equivalence machinery below applies to each contrast separately, with the same materiality
threshold and the same pre-committed branches. L2 and L4 are run on the stratified subsample of
decision dates built for RQ1 rather than on every date, L2 to locate where in the ladder any
information effect enters and L4 to bound the contamination.

*Effective sample size is the trap.* Two years of weekly decisions is roughly one hundred nominal
observations, but consecutive weekly evidence states are highly persistent, particularly where the
pack carries monthly macro inputs that do not update between decisions. A naive paired test on the
deviation series would badly overstate precision. Intervals are built by block bootstrap over the
deviation series, and the effective sample size is reported next to the nominal one.

*Three outcomes, all pre-committed*, evaluated at each point of the margin curve. *Equivalent:* the
interval falls inside the margin, so under this evidence substrate the model adds nothing beyond the
aggregation the rule already performs. *Not equivalent:* the interval falls outside, so the
decisions differ materially and RQ3 characterises where. *Undetermined:* the interval straddles the
margin. Because the verdict is reported across the whole margin range, the undetermined outcome is a
stated interval of margins rather than a null result, and what gets written in each branch is
written before the result is seen.

Read across the ladder these outcomes combine, and the combination is the actual result. Equivalence
in the first contrast together with material divergence in the second is the informative case: it
locates the model's contribution in evidence a deterministic rule cannot represent. Equivalence in
both says the additional rungs do not change what the model decides, which is a negative result
about language models rather than about this pack, and is reported as such. Divergence in the first
contrast is a statement about aggregation alone and is interpreted without reference to the higher
rungs.

The per-date measures behind the test are the mean absolute weight deviation, the sign-agreement
rate relative to 60/40, the correlation of the two weight paths, whether the deviation distribution
is centred on zero or systematically one-directional, and the turnover of each system.

== RQ3: divergence analysis

RQ3 runs only where RQ2 finds material divergence, and it asks two things of that divergence: is it
*stable*, and is it *state-associated*.

Stability reuses the RQ1 machinery. A divergence that survives perturbation and repeated runs is a
property of the model's judgment; one that dissolves under them is a property of its noise, and
saying which it is, with numbers, is itself a result.

State association is where the LLM can plausibly earn its keep, so it is stated as a directional
hypothesis before the data are seen rather than discovered afterwards. The design prediction is
that if the LLM adds anything to an equally weighted linear composite, it adds *regime-conditional*
weighting: treating a signal differently in a volatility spike than in a calm trend, which C2 by
construction cannot do. The states named in advance are the volatility regime, the
financial-conditions regime, and the stock-bond correlation regime. The last matters most, because
the sign of that correlation is driven by the relative volatility of growth and inflation shocks
@campbell-pflueger-viceira @aqr-stock-bond, and a 60/40 benchmark silently assumes bonds hedge
equities. "Divergence concentrates in states X, Y, Z" is a testable claim that survives the
sample-size problem, because it is a claim about *where* the systems differ and not about which one
earned more.

#openq[
  *Open:* the exact state definitions and the pre-registered directional hypotheses. These must be
  written before the evaluation runs, or RQ3 degrades into a search over subsamples.
]

== Retrieval behaviour <sec:retrieval>

The agent loop produces an observable a static pipeline cannot. Every run logs which signals the
model requested, in what order, and how many of its call budget it spent. That trace is free once
the invariants of Stage 2 are in place, and it supports questions the comparison itself cannot
reach: does the model's retrieval change with the evidence state, does it look harder when the
briefing shows signals in conflict, does it consistently ignore part of the substrate, and is
retrieval as unstable under meaning-preserving perturbation as the decision is.

The last question matters most, because it separates two failure modes that look identical from
outside. A model whose weight moves under paraphrase while its retrieval stays constant is unstable
in judgment. One whose retrieval also scatters is not reading the evidence in any stable way at all.
The perturbation harness of RQ1 answers this at no extra cost, since the traces are already logged
for runs that are already happening.

Retrieval behaviour also feeds the divergence analysis. Where the LLM and C2 disagree materially,
the trace shows whether the model was even looking at the signals driving C2's tilt. Nothing in the
LLM-finance literature reports this at the allocation level, and it is a plausible standalone
section of the final report rather than a diagnostic footnote.

#openq[
  *Open:* which retrieval statistics are pre-registered as endpoints and which stay descriptive. The
  temptation is to report everything the trace makes available and call the pattern that appears a
  finding; the discipline is the same one @sec:prereg applies elsewhere.
]

== RQ4: risk translation in place of performance <sec:risk-translation>

RQ4 is declared unanswerable in advance, on the grounds set out in @sec:rqs. In its place the
project translates decisions into portfolio consequence: equity beta, duration, tracking error
against the 60/40 benchmark, and behaviour under a named scenario set.

*The translation is unconditional.* It is computed for the full weight path of every system, on
every branch of RQ2, not only where a material difference is found. Making it conditional would
chain it behind two gates, and @sec:rqs already identifies the inconclusive branch as the most
likely outcome on this sample; RQ3 and RQ4 would then both evaporate on precisely the result the
design expects. Reported unconditionally, equivalence becomes the statement that both systems
occupy the same risk space, quantified rather than asserted; an inconclusive result still shows how
much risk space the unresolved uncertainty spans, which is what a committee needs in order to know
what is at stake; and material divergence receives the translation as originally intended, with the
full paths as context. The computation is the same in all three cases, so removing the condition
costs nothing.

*The risk model is a project artifact, not an assumption.* Beta, duration and tracking error require
a covariance structure and factor exposures, and a scenario set is a list of named factor shocks
with justified magnitudes. The practice partner is asked for their production model and scenario
set, which would make the reported numbers ones they already recognise. That request carries a
deadline and a fallback, on the same pattern as the certification of C2: sample covariance of the
two index return series estimated on pre-cut-off history, effective duration taken from the bond
index's published figure, and beta from a regression of the blended portfolio on the equity index.
The fallback is transparent and cheap, and it keeps RQ4 off the partner's critical path (D13).

The translation is *ex ante*, computed from the weights and a risk model, not from realized
outcomes. That distinction has to hold in the write-up as well as in the code. Reporting realized
return differences alongside the risk translation would let the thesis become a performance study
by implication, which is precisely what the reframe exists to prevent. Where realized figures
appear at all, they are labelled as not interpretable, with the reason. The discipline is enforced
by sequence rather than by intention: realized returns are not computed at all until the RQ1 to RQ3
results are committed. Removing the temptation is more reliable than resisting it at write-up time,
and the commit history makes the claim checkable rather than merely stated.

== Leakage and memorisation <sec:leakage>

A post-cut-off window does most of the work here, and the earlier three-part protocol was heavier
than the residual risk justifies. The design is therefore reordered: *measure first, mitigate on
evidence.*

*What the cut-off genuinely buys.* The model cannot have memorised outcomes that had not occurred
when its training stopped. That is a strong guarantee and it covers the headline worry, which is
that a recommendation is really a recollection of what happened next.

*What it does not cover.* Two residuals survive, and only the first is worth spending on. Published
cut-offs are *nominal*: web crawls carry unreliable timestamps, later-crawled pages discuss earlier
events, and post-training data is routinely more recent than the pretraining corpus, so models
frequently demonstrate knowledge past their stated date. The window therefore opens with a *buffer*
after the documented cut-off rather than at it. That is a one-line change and it handles most of
this. The second residual is period recognition rather than outcome memorisation: the model may
identify a regime from a distinctive evidence state and apply remembered narrative instead of
reading the pack. How much scope that has depends entirely on the rung, since L1 ships banded
z-scores and L4 ships real names, index levels and dates.

*The probe, run at every rung.* Each realized pack is handed back to the model with a single
question: which period does this describe? Recognition rate per rung is then a measured quantity.
The probe costs one extra call against runs that are happening anyway, it is the cheapest component
of the whole design, and a null result is worth reporting: "we tested for this and found nothing at
L1 to L3" is a positive claim where "our protocol prevents it" is an assumption.

#panel[
  *Contingent mitigation.* The representation controls below are specified in advance and held in
  reserve. They are applied only if the probe finds material recognition at the rung in question,
  and the trigger threshold is fixed in the pre-registration before the probe is run.

  - *Banding.* Ship standardised or banded quantities rather than absolute levels, such that every
    realized pack state at a rung is consistent with at least $m$ distinct historical weeks. This is
    the expensive control: it constrains how every number in the pack is presented, and it is not
    worth paying for a problem the probe has not found.
  - *Entity substitution at L3.* Replace named entities and events with class descriptions rather
    than deleting them, following @glasserman-lin. More defensible than banding on the evidence,
    but it degrades L3 as a text signal, which is L3's entire purpose. That tension is real and is
    recorded rather than hidden.
  - *No calendar dates* in any rung below L4, and decision dates run in shuffled order. Both are
    free, so both are applied unconditionally.
]

*The headline diagnostic is unchanged.* Recognition rate and divergence from C2, both plotted
against the rung. If divergence rises faster than recognition between L1 and L3, the model is using
the additional evidence rather than recalling the period. If the two rise together, it is recalling,
and the design has demonstrated that rather than assumed the opposite. Running this at the
asset-allocation level, rather than the single-stock level where nearly all existing work sits, is
one of the project's contributions.

#openq[
  *Open:* the size of the post-cut-off buffer; the exact probe prompt and how a "recognition" is
  scored; the trigger threshold above which the contingent controls are applied; and, if they are
  triggered, the banding constant $m$ and the L3 substitution dictionary. All are pre-registration
  items, and the trigger threshold in particular must be fixed before the probe is run, or the
  decision to band becomes a decision made after seeing the answer. See D14 in
  @sec:open-decisions.
]

== Report quality

The report-generation layer is evaluated separately from the decision results. For a sample of
generated reports, each material claim is checked against the realized pack, meaning the briefing
together with everything the agent actually retrieved, and against the source metadata carried by
each value. The evaluation records whether the report is grounded in the available evidence,
internally consistent with the machine-readable allocation decision, and free from temporal
leakage. Faithfulness is the point: a report whose stated rationale does not match the evidence the
decision actually responded to is a governance failure even when the decision itself is defensible.

== Pre-freeze feasibility check <sec:dry-run>

The failure mode most likely to void this project is not weak predictive power but a pack that does
not move. Criterion 5 of @sec:evidence-pack names it and nothing else in the design would detect it:
if the signals sit near-constant across the evaluation window, C2's weight is near-constant, the
LLM sees near-identical packs week after week and also outputs a near-constant weight, and the
measured divergence collapses to an offset plus noise. RQ3 would then have no states to speak of
because there was only ever one. The budget would be spent before any of this surfaced, and by then
the pre-registration prevents changing the pack.

A feasibility check therefore runs before the freeze, on history *preceding the implementation
model's cut-off*. The pack is built and the three comparators are run over that window. This
generates no model calls, uses no evaluation-window data, and touches no decision the
pre-registration covers; the window is off limits to the evaluation in any case, which is what makes
it free to calibrate on.

The acceptance criteria are fixed before the check is run:

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Property], [Acceptance criterion]),
  [C2's dynamic range], [Its 10th-to-90th-percentile band of equity weight exceeds the materiality margin (D2). If C2's entire historical range is narrower than the difference we call material, the comparison cannot produce a material result and the pack or the tilt mapping is rebuilt. This check is also what keeps the margin honest: a margin the pack cannot reach is one we set wrong.],
  [Per-signal movement], [Each shipped signal's z exceeds $plus.minus 1$ in at least a stated fraction of weeks, in the units the pack actually ships.],
  [Non-redundancy], [No pair of block composites correlated above a stated bound. Criterion 6 of @sec:evidence-pack asks for this; here it is measured rather than asserted.],
  [State frequency], [Each RQ3 state occupies at least a stated fraction of weeks, so that state-association is detectable if it is present.],
  [Tilt-mapping scale], [The mapping from z to percentage points of equity produces a range that is neither degenerate nor implausible.],
)

*This is a power analysis, not a backtest, and the distinction is enforced rather than promised.*
The check computes only properties of the input distribution and of the input-to-weight
transformation. No return, Sharpe ratio, drawdown, or profit-and-loss figure is computed for any
signal or comparator, and the script has no access to a forward-return column, which makes the
constraint auditable instead of merely declared. Selecting a comparator on its historical returns,
or keeping signals because they predicted returns, would rebuild exactly the fitted model
@sec:comparator exists to avoid. The check runs once; a second iteration requires a written reason,
because enough iterations against any criterion eventually fit the data even with no returns in
sight. The criteria, the run, and its results are committed by hash before the freeze.

*Why pack selection cannot bias RQ2 in any case.* The estimand is a difference between systems
consuming identical inputs. Whatever selection entered the pack entered both arms of every contrast
in @sec:contrasts, including the within-model contrast where both arms are the same model on nested
inputs, and cancels in the pairing. A second-order residual remains, in that choosing signals with
dynamic range is a mild selection on the input distribution and input distributions are not
perfectly independent of return distributions. It is recorded in the limitations rather than
dismissed.

== Pre-registration and freeze <sec:prereg>

None of the above is credible if it can be adjusted after the results are seen. The commitments are
therefore written into a pre-registration document, committed to this repository and referenced by
commit hash before the first evaluation run:

- the four questions and the gate conditions between them;
- every endpoint and how it is computed;
- the materiality margin, in both percentage points of equity weight and basis points of tracking
  error, together with the range over which the margin curve is reported;
- the ensemble size $k$, how the $k$-curve is estimated, and the total call budget;
- the perturbation taxonomy, the number of arms, $k$, and the stratified date subsample;
- the ladder rungs of @sec:ladder, the exact content of each, the banding criterion, and the L3
  substitution dictionary;
- the acceptance criteria of the feasibility check (@sec:dry-run), fixed before it is run;
- the risk model and the scenario set behind the RQ4 translation, or the fallback in their place;
- the frozen evidence pack and the three comparators, by commit hash;
- the model identifier, version, and generation settings;
- the RQ3 state definitions and directional hypotheses;
- what is written in each branch of RQ2, including the inconclusive branch;
- the analysis code, written before the evaluation data exist.

The pack and the comparators are frozen jointly with the practice partner and documented before
anything is evaluated, so that neither side can change the inputs after seeing results. Git commit
hashes are what make that claim checkable rather than merely asserted.

// ---------------------------------------------------------------------------
// 6. Scope and Limitations
// ---------------------------------------------------------------------------

= Scope and Limitations

#status(tag-settled)[Carried over from the submitted proposal. Any narrowing or widening of scope
is recorded in @sec:deviations.]

The project is deliberately limited to one decision-support workflow: the stock/bond allocation
report. It covers weekly allocation recommendations between equities and bonds, one representative
index per asset class, with the equity weight free from 0 to 100 per cent and no turnover cap,
based on a sealed point-in-time evidence store that combines deterministic quantitative signals
with text-based sentiment input. The numerical side includes market risk and return indicators,
interest-rate and yield-curve information, and macro-financial indicators where these are
available in point-in-time form. The text-based side is limited to one controlled sentiment source
(i.e. Alpha Vantage, or any other sentiment data provider), so that the provenance and timing of
the input can be audited @alpha-vantage. We verify that retrieved sentiment records reflect the
information available at each decision date, rather than any later revision, to avoid look-ahead
bias.

A broad evaluation of different LLMs, model bias, or fine-tuning strategies is out of scope, beyond
the descriptive model-version arm of RQ1. The project uses one fixed model configuration for the
evaluation itself.

The system generates an investment report and a machine-readable allocation decision, but it does
not trade. It does not create orders, execute transactions, select individual securities, or
optimize an unconstrained portfolio. The LLM is used only in the retrieval-and-report stage and works
from the sealed point-in-time substrate built in Stage 1. It calls tools against that substrate
under a fixed budget, and it is not allowed to browse the web, read arbitrary news, reach any live
service, see a calendar date, or invent facts the substrate does not contain. The concrete model can be adapted to
partner constraints, including a self-hosted option if privacy or deployment requirements demand
it, but model comparison and fine-tuning are outside the first evaluation phase. The model version
and generation settings (e.g., temperature zero) are fixed for the duration of the backtest so that
results stay reproducible and unaffected by silent model updates.

The recommendations are compared against the three deterministic comparators of @sec:comparator on
decision-level endpoints and with structured report-quality checks. The project makes no claim of
out- or underperformance and does not attempt to establish one: the available window cannot support
it, and saying so in advance is part of the design rather than a caveat added at the end. The
project also does not attempt a broad benchmark study, multi-asset allocation, personalized
financial advice, production-grade compliance approval, or live investment operations. The prototype is therefore an auditable
committee-support system, not an autonomous investment system.

// ---------------------------------------------------------------------------
// 7. Deliverables
// ---------------------------------------------------------------------------

= Deliverables

#status(tag-settled)[Carried over from the submitted proposal.]

The project will deliver a working prototype and evaluation package for the two-stage workflow
shown in @fig:system-workflow. The deliverables are:

- the two-stage allocation-report pipeline, comprising the sealed point-in-time substrate, the
  constrained tool layer, and the bounded agent loop;
- the briefing and realized-pack formats, including the tool-call trace;
- the generated investment-report template, illustrated in @app:example-report;
- the machine-readable allocation-decision format;
- the audit log covering data sources, prompts, model settings, generated outputs, and run
  metadata;
- the three deterministic comparators of @sec:comparator, frozen and versioned;
- the four-rung information ladder of @sec:ladder, including the L3 substitution dictionary;
- the perturbation harness behind RQ1, together with the per-rung leakage canary;
- the pre-freeze feasibility report (@sec:dry-run), committed with its acceptance criteria;
- the comparison harness producing the RQ2 and RQ3 endpoints;
- the retrieval traces and the analysis behind @sec:retrieval;
- the risk model and scenario set behind the RQ4 translation, whether the partner's or the fallback;
- the pre-registration document (@sec:prereg), committed before the first evaluation run;
- the final written report describing the architecture, implementation, evaluation results,
  limitations, and possible extensions.

// ---------------------------------------------------------------------------
// 8. Division of Labour
// ---------------------------------------------------------------------------

= Division of Labour with the Practice Partner <sec:labour>

#status(tag-drafting)[As set out in the partner's written summary of 25 August 2026, pending our
confirmation. The graded assessment rests with the supervisors, not with the partner.]

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Side], [Owns]),
  [Us], [Selecting and justifying the candidate evidence variables from the factor-model literature; building the three comparators of @sec:comparator from those same variables; building the two-stage pipeline and the evidence-pack builder; running the perturbation and comparison harnesses; writing the analysis.],
  [Partner], [Checking availability for candidate series we cannot source ourselves, as a fallback rather than the default source; certifying C2 as a rule they would genuinely deploy, before it is frozen; commenting on the materiality margin we set, which is recorded as a marked point on the margin curve rather than as the threshold itself; supplying the risk model and scenario set for @sec:risk-translation, or interpreting ours where the fallback is used.],
)

The variable selection and the comparator rule are core thesis content and are ours to defend.
Sourcing goes public first (FRED and its vintage archive, authors' posted predictor datasets), then
the databases HSG licenses, and only what neither route covers is flagged to the partner. The final
pack and the comparators are then frozen jointly and documented before anything is evaluated
(@sec:prereg).

#openq[
  *Open, and to be settled in the confirmation reply.* Three of the partner's obligations sit on our
  critical path and need dates attached. The materiality margin is now ours to set, so it no longer
  blocks RQ1. Certification of C2 needs a deadline, with RQ2 falling back to C0 and C1 if it stalls.
  The risk model and scenario set are needed before the freeze rather than before the write-up, with
  the fallback of @sec:risk-translation used if they do not arrive (D13). Separately: this reframe
  moves the centre of gravity of the thesis from finance towards evaluation methodology, and both
  supervisors should sign off on that before we confirm the structure in writing.
]

// ---------------------------------------------------------------------------
// 9. Work Plan and Milestones
// ---------------------------------------------------------------------------

= Work Plan and Milestones <sec:milestones>

#status(tag-drafting)[Dates are fixed by the course; the work packages between them are not.]

The graded components of the IMP are a progress presentation (10%), a final presentation (25%), and
the project documentation (65%), all assessed as a group grade.

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Date], [Weight], [Milestone]),
  [14.09.2026], [], [Semester starts; project work begins.],
  [08.10.2026], [10%], [Progress presentation, 5 min plus Q\&A (SQUARE).],
  [02.12.2026], [], [90-second video due on Canvas.],
  [06.12.2026], [], [Final-presentation slides due on Canvas.],
  [08.12.2026], [25%], [Final presentation, 7 min plus Q\&A, SCS Student Conference.],
  [15.01.2027], [65%], [Project documentation: code repository, prototype with documentation, project report, and a contribution statement per member.],
)

#openq[
  *Open:* the work packages and internal checkpoints between these dates. The feasibility check
  (@sec:dry-run) and RQ1 are the natural targets for 8 October: neither needs forward returns, both
  are demonstrable, and the feasibility check answers the question that decides whether the rest of
  the design is viable at all. A chart of C2's weight path over pre-cut-off history with the
  materiality margin drawn across it is the most informative single slide the progress
  presentation could carry. The largest schedule risk is long clean point-in-time history for the
  candidate variables, which is the argument for keeping the shipped pack to five to eight signals.
]

// ---------------------------------------------------------------------------
// 10. Open Decisions
// ---------------------------------------------------------------------------

= Open Decisions <sec:open-decisions>

#status(tag-open)[Working list. Closed decisions move into the relevant section above and, where
they warrant a record of the reasoning, into an ADR under `docs/adrs/`.]

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Id], [Decision], [Needed by]),
  [D1], [Which signals from the catalogue enter the shipped pack, scored against the rubric in @sec:evidence-pack, and from which sources.], [Before the first end-to-end run],
  [D2], [The materiality margin, in percentage points of equity weight and in basis points of tracking error, set and justified by us, plus the range over which the margin curve is reported. The partner's own view is recorded as one marked point on that curve.], [Before the freeze],
  [D3], [The mechanical rule that turns the LLM report into portfolio weights, and whether the 0 to 100 action space is constrained.], [Before the freeze],
  [D4], [The implementation model, its version and documented cut-off, which set the evaluation window.], [Before the freeze],
  [D5], [The sentiment source and how its point-in-time property is verified.], [Before the first end-to-end run],
  [D6], [The concrete indices used for the equity and bond legs, including cost assumptions.], [Before the freeze],
  [D7], [The exact form of C1 and C2: risk budget, z-score window, tilt mapping, treatment of missing signals.], [Before the freeze],
  [D8], [The perturbation taxonomy, the number of arms, the $k$-curve grid, and the stratified date subsample.], [Before RQ1],
  [D9], [The RQ3 state definitions and the directional hypotheses attached to them.], [Before the freeze],
  [D10], [The model-call budget and runtime. $k$ multiplies every date, rung and contrast, so this is what bounds the ensemble size; a first cost estimate is needed early.], [Before RQ1],
  [D11], [How report quality and faithfulness are scored, and by whom.], [Before the evaluation write-up],
  [D12], [Whether the project title still fits after the reframe.], [Before the progress presentation],
  [D13], [The risk model and scenario set behind the RQ4 translation: the partner's production model with a deadline attached, or the fallback of @sec:risk-translation in its place.], [Before the freeze],
  [D14], [The exact content of each ladder rung (@sec:ladder); the post-cut-off buffer; the probe prompt and how recognition is scored; the trigger threshold above which the contingent representation controls apply; and, only if triggered, the banding constant $m$ and the L3 substitution dictionary.], [Trigger threshold before the probe runs; the rest before the freeze],
  [D15], [The tool API surface, the per-decision call budget, what the briefing carries before the first call, and which retrieval statistics are pre-registered endpoints rather than descriptive.], [Before the freeze],
)

// ---------------------------------------------------------------------------
// 11. Deviations from the submitted proposal
// ---------------------------------------------------------------------------

= Deviations from the Submitted Proposal <sec:deviations>

#status(tag-drafting)[This section is the audit trail between what was promised on 6 July 2026 and
what is actually built.]

The submitted proposal is frozen at `docs/proposal/proposal.typ`. Where this document departs from
it, the change is recorded here with its reason, so the final report can explain the difference
rather than quietly absorb it.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Date], [Section], [Change from the proposal], [Reason]),
  [2026-08-25], [2 Research question], [The single out-of-sample performance question is replaced by four decision-level questions: robustness, practical equivalence, divergence, and a risk translation in place of an economic-outcome claim.], [The evaluation window is bounded below by the model's knowledge cut-off, leaving roughly two years. Ample for measuring how the system decides; far too short to resolve return-based performance for any tactical strategy.],
  [2026-08-25], [3 Objectives], [Objective 2 split into building and freezing the comparator, and evaluating the decisions. Sharpe, certainty-equivalent return and turnover-adjusted return removed as success criteria.], [Follows from the reframe. Those metrics are not estimable on the available sample, so promising them would be promising something undeliverable.],
  [2026-08-25], [4 System design], [The single rule-based baseline becomes three comparators, and the composite rule is explicitly unfitted.], [A constant benchmark cannot isolate the LLM's aggregation. A fitted multi-variable model would be built from precisely the class the out-of-sample literature reports as failing.],
  [2026-08-25], [5 Evaluation plan], [Backtest-and-compare replaced by the perturbation harness, the equivalence test, the divergence analysis, the risk translation, an explicit leakage protocol, and a pre-registration step.], [Follows from the reframe, and makes the freeze auditable rather than merely promised.],
  [2026-08-25], [6 Scope], [Rebalancing set to weekly; one representative index per asset class; equity weight free from 0 to 100 per cent with no turnover cap.], [Decision setting agreed with the practice partner. Weekly is the partner's actual committee cadence. It is not adopted for sample-size reasons: consecutive weekly evidence states are persistent, so the effective sample rises far less than the nominal count, which is why the intervals are built by block bootstrap.],
  [2026-08-25], [8 Division of labour], [New section.], [Records who owns what, following the partner's written summary of 25 August 2026.],
  [2026-08-25], [4 System design], [The pipeline becomes agentic. The LLM reaches evidence through a constrained tool layer over a sealed point-in-time store under a fixed call budget, instead of receiving one static pack. The audit artifact becomes the realized pack, including the full tool-call trace, and retrieval behaviour becomes an evaluated observable.], [Fixed by decision of 24 August 2026. A prompt template over a fixed JSON blob is not the agentic workflow the project claims to study. Auditability is unaffected because the trace is logged, and the loop yields an observable a static design cannot produce. Safety is preserved by invariants in the store and tool layers rather than by withholding retrieval.],
  [2026-08-25], [4 System design], [The evidence pack becomes a nested information ladder, L1 to L4, with the rung as the primary experimental factor of the evaluation.], [A pack of scalars alone makes the LLM's task identical to the rule's, so equivalence would follow mechanically and say nothing about language models. The ladder gives the model evidence a deterministic rule cannot represent, while the nesting keeps the resulting divergence decomposable.],
  [2026-08-26], [2 RQs, 5 Evaluation plan], [RQ1 stops being a pass/fail gate that could void RQ2. A decision becomes an ensemble of $k$ samples at randomized presentation, and RQ1 reports dispersion against $k$, with the reported $k$ a headline result.], [The gate could have ended the project on a property of the instrument rather than a finding about it. Averaging over randomized presentations shrinks both sampling noise and presentation sensitivity at the root-$k$ rate, so the question becomes how much sampling is needed rather than whether measurement is possible. The ensemble is also the artifact anyone would deploy.],
  [2026-08-26], [5 Evaluation plan], [RQ2's primary endpoint becomes the fraction of decision dates on which the gap exceeds the margin, not the mean weight deviation. The margin is set and justified by us rather than supplied by the partner, and the verdict is reported as a function of the margin. The within-model contrast is promoted to first.], [A mean over a persistent series was the worst case for precision and made the inconclusive branch the expected outcome. A per-date proportion resolves far better on the same data, a margin curve turns "inconclusive" into a stated range, and a partner-supplied threshold could have been unreachable. The within-model contrast has the narrowest intervals available because both arms are the same model on the same dates.],
  [2026-08-26], [5 Evaluation plan], [Leakage reordered to measure-then-mitigate: the per-rung probe runs first, the representation controls are held in reserve and triggered only on measured recognition, and the window opens with a buffer after the nominal cut-off.], [The post-cut-off window already covers outcome memorisation. Banding every quantity is expensive and was solving a problem not yet shown to exist, whereas the probe is one extra call and converts the assumption into a measurement. The buffer is a one-line fix for the fact that published cut-offs are nominal.],
  [2026-08-25], [5 Evaluation plan], [RQ2 is run as three contrasts rather than one; the leakage canary runs at every rung and the level-and-entity anonymisation is replaced by rung-based representation control; a pre-freeze feasibility check is added; the RQ4 risk translation becomes unconditional and acquires a named risk model with a fallback.], [Separating the aggregator difference from the information difference by design rather than by argument; measuring leakage per rung rather than assuming a protocol works; detecting a non-moving pack before the freeze rather than after the budget is spent; and keeping RQ3 and RQ4 from evaporating on the RQ2 branch the design itself expects.],
)

// ---------------------------------------------------------------------------
// 12. From this document to the final documentation
// ---------------------------------------------------------------------------

= From This Document to the Final Documentation <sec:to-final>

#status(tag-drafting)[Intended mapping; refined once the report structure is agreed with the
supervisors.]

The project documentation due on 15 January 2027 consists of the code repository, the prototype
with its documentation, the project report, and a contribution statement per member. This document
is the source for the report and for the parts of the repository documentation that describe intent
rather than code.

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Section here], [Becomes, in the final report]),
  [1 Motivation], [Introduction and problem statement.],
  [2 Research questions], [Research questions and the argument for evaluating decisions rather than returns.],
  [3 Objectives], [Objectives, each answered with what was achieved.],
  [4 System design], [Architecture and implementation chapter, extended with what was actually built.],
  [5 Evaluation plan], [Method chapter, followed by the results chapter.],
  [6 Scope and limitations], [Limitations chapter, extended with limitations found during the work.],
  [7 Deliverables], [Repository and prototype overview.],
  [8 Division of labour], [Collaboration with the practice partner, and the contribution statements.],
  [10 Open decisions and 11 Deviations], [Design-decision discussion and the reflection on how the project changed.],
)

// ---------------------------------------------------------------------------
// References
// ---------------------------------------------------------------------------

#pagebreak()

#bibliography("references.bib", title: "References", style: "ieee")

// ---------------------------------------------------------------------------
// Appendix
// ---------------------------------------------------------------------------

#pagebreak()

#set heading(numbering: (..n) => if n.pos().len() == 1 {
  "Appendix " + numbering("A", ..n) + ":"
} else {
  numbering("A.1", ..n)
})
#counter(heading).update(0)

= Example Generated Allocation Report <app:example-report>

The following example is illustrative. It shows the intended shape of the generated report, not an
actual investment recommendation.

#panel[
  *Investment Committee Allocation Report*\
  *Decision date:* week 13, evaluation year 1 (dates anonymised, see @sec:leakage)\
  *Evaluation horizon:* Next weekly rebalancing interval\
  *Universe:* Global equities and investment-grade bonds\
  *Current benchmark:* 60/40 stock/bond allocation

  *Recommended allocation*\
  The system recommends a moderate underweight to equities for the next interval:

  - stocks: 55%;
  - bonds: 45%.

  *Evidence summary*\
  The numerical evidence points to a less supportive risk environment than in the previous
  rebalancing window. Equity momentum remains positive but has weakened, valuation indicators are
  above their long-run median, and realized volatility has increased. Yield-curve and rates data
  suggest that duration risk remains material, but the bond allocation still improves portfolio
  stability under the current risk model.

  The text-based sentiment input is mixed but slightly risk-off. Market news sentiment is less
  positive than in the previous window, with recurring references to tighter financial conditions,
  slower earnings growth, and uncertainty around central-bank communication. No single article or
  sentiment signal is treated as decisive; the report uses the sentiment input only as supporting
  evidence alongside the numerical indicators.

  *Rationale*\
  The recommended 55/45 allocation keeps the portfolio close to the conventional 60/40 benchmark
  while reducing equity exposure in response to weaker sentiment and higher measured risk. A larger
  shift is not recommended because the evidence summary does not show a severe deterioration in
  macro or market conditions, and the equity signal remains positive on some measures.

  *Main risks*\
  The recommendation may underperform the 60/40 benchmark if equity markets continue to rally or
  if the risk-off sentiment proves temporary. It may also underperform the risk-scaled comparator
  C1 if bond yields rise sharply during the holding period. The allocation should therefore be treated as a
  controlled tilt, not as a high-conviction market-timing signal.

  *Audit notes*\
  The report was generated from a sealed, timestamped evidence store. The agent made 11 tool calls
  against that store, all logged in the realized pack; it did not browse the web, reach any
  live service, or use data the store does not contain. The stored audit bundle contains the
  briefing, the ordered call trace, the source references, model identifier, prompt version,
  generation settings, and the machine-readable allocation decision.
]

= Document Map <app:doc-map>

Where the project's written material lives.

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 6pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  table.header([Path], [Contents]),
  [`docs/master/`], [This document. The living single source of truth; grows into the final report.],
  [`docs/proposal/`], [The proposal as submitted on 6 July 2026, plus the management summary. Frozen.],
  [`docs/evidence-pack/`], [Working catalogue of candidate signals and tools for Stage 1.],
  [`docs/adrs/`], [Architecture decision records for closed design decisions.],
  [`docs/papers/`], [Literature used for the project.],
)

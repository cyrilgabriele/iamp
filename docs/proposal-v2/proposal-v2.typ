#set document(
  title: "A Reusable Agentic Platform for Sentiment-Aware Dynamic Asset Allocation",
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
#show heading: set block(above: 1.3em, below: 0.7em)
#show heading.where(level: 1): set text(size: 13pt)
#show heading.where(level: 2): set text(size: 11.5pt)

// Links in a subtle colour
#show link: set text(fill: rgb("#1a4f8a"))

#show table: set text(size: 9.5pt)
#show table.cell.where(y: 0): strong

// Shared highlight block, as in the submitted proposal.
#let panel(body) = block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[#body]

#let tbl(..args) = table(
  inset: (x: 7pt, y: 5pt),
  stroke: 0.4pt + rgb("#dddddd"),
  align: left,
  ..args,
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
  #text(size: 10pt, style: "italic")[Project Proposal, revised version]

  #v(0.9em)
  #text(size: 10pt)[
    Supervisors:\
    Prof. Dr. Alexander Braun, School of Finance #h(0.6em) · #h(0.6em) main supervisor\
    Prof. Dr. Siegfried Handschuh, Institute of Computer Science #h(0.6em) · #h(0.6em) technical advisor
  ]
]

#v(1em)

// ---------------------------------------------------------------------------
// 1. Motivation
// ---------------------------------------------------------------------------

= Motivation

Banks and asset managers increasingly use AI to support information-heavy work, but financial
decisions still require governance, documentation, risk control, and human oversight
@reuters-banks @eu-ai-act @reuters-eba. This is especially relevant for dynamic stock/bond
allocation, since the high-level split between equities and bonds drives much of a portfolio's
risk and return @brinson.

Traditional quantitative models can process valuations, momentum, macro data, rates, and risk
indicators, but they usually do not incorporate text-based market sentiment in an auditable way.
Generic LLM assistants have the opposite weakness: they summarize narratives, but provide no
deterministic analytics, no point-in-time traceability, and no controlled link to an asset manager's
existing models. Published work covers financial LLM platforms, trading agents, report-generation
systems, and agentic allocation pipelines @finrobot @finmem @tradingagents @finteam
@self-driving-portfolio @cn-buzz2portfolio, but to the best of our knowledge it has not addressed
the narrower workflow targeted here, and it has not asked how reproducible such a system's decisions
are or how far they differ from what a transparent rule would have said.

This project builds a controlled two-stage system for an asset-management partner. Numerical and
sentiment inputs are sealed into a timestamped, point-in-time evidence store; an agent then reaches
that store through a constrained tool layer and produces an investment report and a
machine-readable stock/bond allocation decision, with every retrieval logged. The system does not
trade, execute allocation changes, or replace the investment committee. It supports the people
making the decision, and the project evaluates the decisions it makes.

// ---------------------------------------------------------------------------
// 2. Applied Research Questions
// ---------------------------------------------------------------------------

= Applied Research Questions <sec:rqs>

What a committee needs to know about such a system is whether its recommendations are reproducible,
whether they are defensible, and whether they differ from what a transparent rule fed the same
evidence would have said. Those are properties of the *decision*, and they are what this project
measures. Returns are not: weekly tilts over a two-year window produce on the order of one hundred
decisions, fewer in effect because consecutive weekly evidence states barely move, and no
return-based verdict survives that sample. The window cannot be widened, since it opens at the
implementation model's knowledge cut-off (@sec:leakage). Even a decade is thin: over the ten years
to April 2023 the average tactical allocation fund returned roughly a third of a US 60/40 mix
@morningstar-tactical.

#panel[
  *RQ1, reproducibility.* How far does an LLM-generated tactical allocation decision move under
  meaning-preserving perturbations of an identical information set, and how many samples per
  decision does it take to make the system as reproducible as the difference RQ2 tests for?

  #v(0.4em)
  *RQ2, practical equivalence.* Are LLM-generated bond/equity allocation decisions practically
  equivalent to those of a pre-registered deterministic rule that could be deployed instead? The
  question is asked twice: on identical inputs, at the rung of the evidence ladder the rule can
  fully consume (@sec:ladder), and again with the model given the rungs it cannot represent.

  #v(0.4em)
  *RQ3, divergence analysis.* Where the systems diverge materially, is the divergence stable across
  perturbations and repeated runs, does it decompose into an aggregator and an information
  component, and is it associated with identifiable characteristics of the evidence state?

  #v(0.4em)
  *RQ4, risk translation.* What do each system's decisions, and any difference between them, mean
  in beta, duration, tracking-error and scenario terms?
]

*How the questions relate.* RQ1 comes first because it needs no forward returns and because its
answer sizes the system RQ2 compares. A decision here is not one model call but an ensemble: the
model is sampled $k$ times per date, each sample with independently randomized signal order,
phrasing and numeric format, and the recommended weight is their median (@sec:stage2). Both sampling
noise and sensitivity to presentation then fall as $k$ grows, so RQ1's output is a curve of
dispersion against $k$, and the $k$ carried into RQ2 is the smallest one at which the system is as
reproducible as the difference RQ2 tests for. That makes RQ1 a design parameter with an answer
rather than a gate that could void the comparison, and the value of $k$ is itself a result: it puts
a number on what a language model costs where a deterministic rule is reproducible by construction.
RQ2 is the core comparison, and RQ3 characterises whatever material divergence it finds. RQ4 is not
a further step in that chain but a reporting layer applied to every weight path on every branch, so
that whatever RQ2 concludes is expressed in units a committee acts on.

Every branch yields a reportable answer. Equivalence at the matched rung means the model reproduces,
at higher cost, an aggregation a transparent rule already performs; equivalence there combined with
material divergence at the higher rungs locates its contribution in evidence a deterministic rule
cannot represent, which is the claim usually made for language models here and has not been tested
at the allocation level.

// ---------------------------------------------------------------------------
// 3. Project Objectives
// ---------------------------------------------------------------------------

= Project Objectives

== Objective 1: Build a controlled two-stage evidence-to-report pipeline

A reproducible pipeline in which a deterministic offline stage builds a sealed point-in-time
substrate, and the LLM reaches it through a constrained tool layer to produce a standardized
allocation report. The model may retrieve, but not browse the web, reach a live service, trade, or
see a calendar date.

#panel[
  *Success criterion:* For every rebalancing date the system produces a realized evidence pack (the
  briefing plus the full ordered trace of tool calls), a human-readable investment report, a
  machine-readable allocation decision, and a record of the model, prompt, data sources, and
  generation settings.
]

== Objective 2: Build and freeze a deployable deterministic comparator

The deterministic rule that RQ2 compares against, built from the same evidence the LLM consumes and
frozen before any evaluation runs. It is multi-variable in that it ingests the whole pack, and
unfitted in that no coefficient is estimated on history (@sec:comparator). Two simpler anchors sit
alongside it so that divergence decomposes rather than arriving as a single number.

#panel[
  *Success criterion:* Three comparators exist as frozen, versioned code: a static 60/40, a
  volatility-targeted 60/40, and the composite rule over the full pack. Each is simple enough to run
  in production, and the freeze is recorded by commit hash before the first evaluation run.
]

== Objective 3: Evaluate the decisions, not the returns

Measure the stability of the LLM's decisions under meaning-preserving perturbation (RQ1), test
whether they are practically equivalent to the comparator's on identical evidence (RQ2),
characterise any material divergence (RQ3), and translate every weight path into risk terms (RQ4).

#panel[
  *Success criterion:* For every decision date the evaluation reports how much the recommended equity
  weight varies when nothing changes, how much more it varies when the same evidence is re-presented
  differently, how far it sits from each comparator's weight, and what that distance means in beta,
  duration and tracking error. Where the sample cannot separate a real difference from noise, the
  result is reported as inconclusive rather than as agreement.
]

== Objective 4: Assess report quality, auditability, and leakage control

Evaluate whether the generated reports are grounded in the evidence the agent actually retrieved,
internally consistent with the allocation recommendation, and protected against temporal leakage.

#panel[
  *Success criterion:* Each report can be audited against its realized pack, and no material factual
  claim relies on information unavailable at the decision date. Whether the model can recognise the
  period a pack describes is tested at each rung of the ladder rather than assumed.
]

// ---------------------------------------------------------------------------
// 4. Proposed System
// ---------------------------------------------------------------------------

= Proposed System

Stage 1 is offline and deterministic: it builds a sealed, point-in-time store of quantitative,
macro-financial and text-based evidence. Stage 2 is a bounded agent loop: at each decision date the
model receives a short briefing, reaches into that store through a constrained tool layer, and
produces an investment report together with a machine-readable allocation decision (Appendix
@app:example-report). The link between the stages is a loop rather than a single handoff. The model
is the aggregator: there is no optimiser and no Black-Litterman step between it and the weights.

== Stage 1: the sealed substrate <sec:evidence-pack>

Stage 1 writes every signal into a frozen store keyed by signal, as-of date, vintage date and value,
before any decision date is evaluated. Because the model retrieves rather than receives, the evidence
pack is three artifacts: the *sealed substrate*, which tools alone may read; the *briefing*, a
deliberately thin opening context per decision date carrying universe, portfolio state, constraints,
the signal manifest and the block composites; and the *realized pack*, the briefing plus the complete
ordered trace of tool calls and returns. The realized pack is the audit record required by Objective
1, recording not only what evidence existed but what the model chose to look at.

The shipped pack is deliberately small: five to eight point-in-time signals covering both the equity
and the bond leg. Which signals those are is selected against a written rubric and recorded in the
candidate catalogue maintained alongside this proposal, then frozen before any evaluation runs
(@sec:prereg). Two constraints on that selection are fixed here, because RQ2 depends on them. No
signal is chosen on its performance inside the evaluation window, which would fit a hundred
decisions with a catalogue of candidates and rebuild exactly the kind of model @sec:comparator
exists to avoid. And every signal needs a genuine vintage source, since a value silently revised
after the fact is not point-in-time evidence whatever its predictive record.

#figure(
  image("diagrams/v4_architecture.svg", width: 55%),
  caption: [Two-stage workflow: a sealed point-in-time store, a constrained tool layer, a bounded
    agent loop, and the decision-level evaluation against three deterministic comparators.],
) <fig:system-workflow>

== The information ladder <sec:ladder>

A pack of z-scores alone makes the LLM's task identical to the deterministic rule's: average the
numbers. RQ2 would then return equivalence for mechanical reasons, saying something about arithmetic
rather than about language models. The pack is therefore built in four nested rungs, each strictly
containing the one below and each derived from the same data. What separates them is how much of the
evidence a deterministic rule can represent.

#tbl(
  columns: (auto, 1fr, auto, auto),
  table.header([Rung], [Contains], [Rule can consume], [Leakage risk]),
  [L1], [Z-scores, percentiles, and the block composites.], [In full], [Low],
  [L2], [Plus cross-signal disagreement, dispersion, conflict flags, reliability and vintage metadata, and missingness.], [No], [Low],
  [L3], [Plus themed sentiment summaries with topic salience and direction, a qualitative regime description, and named entities and events replaced by class descriptions.], [No], [Moderate, measured],
  [L4], [Plus raw article text, real entities, absolute index levels, and calendar dates.], [No], [High, contaminated],
)

L2 is second-order structure about the evidence set itself, computed from what is already in L1
rather than new information about the world. A z-score-and-average rule cannot consume it without
becoming a different and fitted rule; a language model can. That inability is intrinsic to what a
deployable rule is, not a handicap imposed for the experiment.

The rung is a permission level on the tool layer rather than a document format: it governs what
tools may return, so a run at L1 cannot reach L3 content however the agent asks. Richer rungs carry
more leakage risk, so recognition is probed at each rung rather than assumed (@sec:leakage), and the
rung is the primary experimental factor of the evaluation (@sec:contrasts). L4 bounds the
contamination rather than being reported as a result.

== Stage 2: the bounded agent loop <sec:stage2>

The model opens with the briefing, reaches further evidence by calling tools against the sealed
substrate, and closes by producing the report and the machine-readable decision. Model identifier,
prompt version, and generation settings are pinned and stored with every run.

*A decision is an ensemble, not a single call.* At each date the loop is run $k$ times, each run
with independently randomized signal order, phrasing and numeric format, and the recommended weight
is the median across runs; one run's report is retained in full as the committee-facing memo, with
the others kept for the dispersion measure. This is how such a system would actually be deployed,
since a single sample from a stochastic model is not a product, and it is what allows RQ1 to report
the sampling cost of using a language model as the aggregator rather than treating its variance as
an obstacle. Letting it retrieve
rather than handing it a fixed pack costs nothing in auditability, since the trace is logged, and it
yields an observable a static design cannot produce: *retrieval behaviour* (@sec:retrieval).

Safety rests on invariants enforced in code, not on prompt instructions. The decision date is
injected by the harness and never passed by the agent: no tool signature accepts a date, because an
agent that can name a date can name a future one. Tools read the frozen store only, never a live
service, so leakage is a property of how the store was built and can be tested once rather than
chased through the agent loop. Every value carries its vintage, and the filter `vintage <= t` is
applied in the store layer, below the tool layer, where the agent cannot reach it. No tool returns
content above the active ladder rung, the comparators' outputs are never visible to the agent, and
every call is logged.

Both systems make the same decision in the same setting: weekly, one representative index per asset
class, equity weight free from 0 to 100 per cent, no turnover cap. Weekly matches the frequency at
which the partner computes its own signals. The translation from the LLM output into portfolio
weights is a reproducible mechanical rule, specified and fixed before the evaluation runs.

== The deterministic comparator <sec:comparator>

RQ2 needs a counterparty that consumes the identical pack and does something principled with it.
Comparing the LLM to a static 60/40 would measure whether it moves, not whether it aggregates
evidence differently from a principled aggregator. Three comparators are built, and their
divergences decompose the LLM's behaviour.

#tbl(
  columns: (auto, 1fr, 1fr),
  table.header([Comparator], [What it is], [What its divergence isolates]),
  [C0, static], [Constant 60/40.], [The triviality floor: whether either system moves at all.],
  [C1, risk-based], [Equity weight scaled to a fixed risk budget off the pack's volatility block @moreira-muir, and nothing else.], [How much of the LLM's behaviour is risk-scaling that requires no view.],
  [C2, composite], [Every signal z-scored on an expanding window, each z mapped to a tilt, the tilts equally weighted.], [The rest of the evidence. This is the rule that is frozen.],
)

C2 is multi-variable but deliberately not fitted. Estimating coefficients over pre-evaluation
history would build the comparator out of exactly the class of model the out-of-sample literature
reports as failing @goyal-welch-zafirov. Equal weighting is the defensible alternative: simple
combination beats estimated weights out of sample for equity-premium forecasts @rapach-combination,
for the same reason equal weighting across assets beats an estimated covariance matrix @demiguel.
The comparator is not required to outperform; its job is to be an honest, transparent,
pre-registered reference decision @cederburg.

// ---------------------------------------------------------------------------
// 5. Expected Deliverables
// ---------------------------------------------------------------------------

= Expected Deliverables

- the two-stage pipeline: sealed point-in-time substrate, constrained tool layer, bounded agent loop;
- the briefing, realized-pack and allocation-decision formats, the report template of Appendix
  @app:example-report, and the audit log covering data sources, prompts, model settings and outputs;
- the four-rung information ladder (@sec:ladder) and the three comparators (@sec:comparator), frozen
  and versioned;
- the perturbation harness and ensemble behind RQ1 with the per-rung recognition probe, the comparison harness
  producing the RQ2 and RQ3 endpoints, the retrieval-trace analysis, and the risk model behind the
  RQ4 translation;
- the pre-registration document and the pre-freeze feasibility report (@sec:prereg), committed before
  the first evaluation run;
- the final written report describing the architecture, implementation, evaluation results,
  limitations, and possible extensions.

// ---------------------------------------------------------------------------
// 6. Evaluation Plan
// ---------------------------------------------------------------------------

= Evaluation Plan

Every endpoint is a property of the decision: the recommended equity weight at a decision date, or
the difference between two such weights. None requires forward returns, which is what makes the
design viable on the available window; realized returns enter the risk translation
(@sec:risk-translation) only, never signal selection, comparator tuning, or a performance claim. The
evaluation runs weekly over the post-cut-off window against the three comparators, and for a
decision date $t$ and comparator $C$ the paired endpoint is the weight deviation
$d_(C, t) = w_(t)^("LLM") - w_(t)^(C)$.

== RQ1: reproducibility and the size of the ensemble <sec:rq1>

Three sources of variation are measured separately, because conflating them makes every downstream
result unattributable. *Sampling noise at fixed input:* the same pack and prompt run repeatedly,
since temperature zero is not determinism and an agent that chooses its own tool calls carries a
second source of variance. *Meaning-preserving perturbation:* the same evidence re-presented, with
signal order permuted, the briefing paraphrased, units and precision varied, and equivalent formats
swapped. *Model-version drift:* the same pack on a different checkpoint, descriptive only, since the
evaluation pins one version.

The first two are what the ensemble of @sec:stage2 averages over, and separating them matters
because they behave differently. Averaging repeated runs at a fixed presentation shrinks the first
while leaving the second untouched: it would estimate very precisely what the model says under one
arbitrary wording. Randomizing the presentation within the ensemble folds the second into the first,
so both fall at the usual root-$k$ rate. What does not average away is any bias common to every
presentation, and that is not noise but the model's behaviour, which is what RQ2 is there to
measure.

RQ1's primary output is therefore a curve: dispersion of the ensemble's recommended weight against
$k$, estimated on a stratified subsample of decision dates spanning calm, stressed and transitional
evidence states. The reported $k$ is the smallest at which that dispersion falls below the margin
RQ2 tests against, and it is reported as a headline figure rather than a nuisance parameter. If
dispersion at fixed input is of the same order as dispersion under perturbation, the model is not
responding to presentation but to nothing in particular, which is a finding in its own right.
Because $k$ multiplies every decision date and every ladder rung, the total call count is computed
and fixed before the evaluation runs; that budget, not the statistics, is what bounds $k$.

== RQ2: practical equivalence

Equivalence is a claim that the difference lies inside a pre-specified margin, so the margin exists
before the test runs. We set and justify it ourselves, in percentage points of equity weight and the
basis points of tracking error those translate into (@sec:risk-translation), and register it before
any result is seen. The verdict is additionally reported as a function of the margin, so a reader
who considers a different difference material can read off the answer at their own threshold instead
of inheriting ours. That also keeps the result from resting on a single number that could be set too
tight to be reachable or too loose to be informative.

The comparison is paired by decision date, and since the comparator is deterministic while the
ensemble is not, the repeat-to-repeat uncertainty is propagated into the interval rather than
discarded.

*The primary endpoint is a proportion, not a mean.* Averaging the weight deviation across dates
estimates a single number from a series whose consecutive states barely move, which is close to the
worst case for precision. With $k$ samples per date, each date instead yields its own tight estimate
of the gap and its own uncertainty, so the endpoint is the *fraction of decision dates on which the
gap exceeds the margin*. Proportions resolve far better than means under persistence: a result of
the form "the systems differ materially on 34 per cent of dates, 95 per cent interval 25 to 44" is
reportable where a mean over the same data would not be. The mean deviation is still reported, as a
secondary descriptive figure rather than as the test.

=== The three contrasts <sec:contrasts>

Handing the LLM information the comparator lacks would, on its own, destroy RQ2: divergence would
have two indistinguishable causes, a different aggregator or a larger information set. The ladder
makes the rung an experimental factor, so the two are separated by design.

#tbl(
  columns: (auto, auto, 1fr),
  table.header([Contrast], [Holds fixed], [Measures]),
  [LLM(L3) against LLM(L1)], [Aggregator], [The information difference, and the best-powered of the three: same model, same dates, nested inputs, so model-level anchoring and every other nuisance cancels in the pairing. This is where a capability advantage would have to appear, and it carries the project's most resolvable claim.],
  [LLM(L1) against C2], [Information], [The aggregator difference. Equivalence here means that, given identical scalar evidence, the model adds nothing beyond the averaging the rule already performs.],
  [LLM(L3) against C2], [Nothing], [The total divergence, which the two contrasts above decompose.],
)

The three are not equally well powered, and they are reported in that order. The within-model
contrast comes first because nothing but the rung differs between its arms; the two cross-system
contrasts answer RQ2 as posed and are reported alongside, with their wider intervals stated rather
than glossed. L2 and L4 run on the RQ1 date subsample rather than on every date, L2 to locate where
any information effect enters and L4 to bound the contamination.

Persistence is still the constraint on the cross-system contrasts: consecutive weekly evidence
states barely move, so a naive paired test would overstate precision. Intervals are built by block
bootstrap, with the effective sample size reported next to the nominal one.

*The verdict is a curve, not a single word.* Rather than testing at one threshold, the analysis
reports the equivalence conclusion as a function of the margin, in the form "equivalent at margins
above 6.2 points of equity weight, materially different below 3.1, undetermined between". Within any
chosen margin the three branches are pre-committed and written before the result is seen.
*Equivalent:* the interval falls inside the margin, so the model reproduces the rule and adds
nothing beyond the aggregation it performs. *Not equivalent:* the interval falls outside, so the
decisions differ materially and RQ3 characterises where. *Undetermined:* the interval straddles the
margin. Reporting the whole curve means the undetermined region is a stated range rather than a
failure to answer, which is what keeps the project's central comparison from resting on whether one
pre-chosen number happened to be reachable.

Behind the test sit the mean absolute weight deviation, the sign-agreement rate relative to 60/40,
the correlation of the two weight paths, and each system's turnover and within-ensemble dispersion,
the last two reported jointly with divergence so that a model swinging widely on noise is not
mistaken for one exercising judgment.

== RQ3: divergence, and what the retrieval trace shows <sec:retrieval>

RQ3 runs where RQ2 finds material divergence and asks whether it is stable and whether it is
state-associated. Stability reuses the RQ1 machinery: divergence that survives perturbation and
repeated runs is a property of the model's judgment, one that dissolves is a property of its noise,
and saying which, with numbers, is itself a result.

State association is stated as a directional hypothesis before the data are seen: if the LLM adds
anything to an equally weighted linear composite, it adds regime-conditional weighting, treating a
signal differently in a volatility spike than in a calm trend, which C2 by construction cannot do.
The states named in advance are the volatility regime, the financial-conditions regime, and the
stock-bond correlation regime. The last matters most, because the sign of that correlation is driven
by the relative volatility of growth and inflation shocks @campbell-pflueger-viceira
@aqr-stock-bond, and a 60/40 benchmark silently assumes bonds hedge equities. "Divergence
concentrates in states X, Y, Z" survives the sample-size problem, because it is a claim about where
the systems differ rather than which one earned more.

The retrieval trace supports this at no extra cost, since it is logged anyway. It records which
signals the model requested and in what order, which separates two failure modes that look identical
from outside: a model whose weight moves under paraphrase while
its retrieval stays constant is unstable in judgment, while one whose retrieval also scatters is not
reading the evidence in any stable way.

== RQ4: risk translation <sec:risk-translation>

Decisions are translated into portfolio consequence: equity beta, duration, tracking error against
the 60/40 benchmark, and behaviour under a named scenario set. The translation covers the full
weight path of every system on every branch of RQ2, not only where a material difference is found.
Reported that way, equivalence becomes the statement that both systems occupy the same risk space,
quantified rather than asserted; an inconclusive result still shows how much risk space the
unresolved uncertainty spans; and material divergence receives the translation with the full paths
as context.

The risk model is a project artifact rather than an assumption. The practice partner is asked for
their production covariance structure and scenario set, so the reported numbers are ones they
already recognise, with a documented fallback: sample covariance of the two index return series on
pre-cut-off history, effective duration from the bond index's published figure, and beta from a
regression of the blended portfolio on the equity index. The translation is ex ante, computed from
the weights and the risk model rather than from realized outcomes; reporting realized return
differences alongside it would let the thesis become a performance study by implication. Realized
returns are therefore not computed until the RQ1 to RQ3 results are committed.

== Leakage, memorisation, and report quality <sec:leakage>

Language models recall index levels and headline dates from inside their training window; one 2025
study reports a near-perfect correlation between recalled and actual annual index returns
@lopez-lira-memorisation. The primary control is cut-off discipline. The implementation model is
pinned, the evaluation window opens after its documented knowledge cut-off with a buffer, since
published cut-offs are nominal and training corpora routinely contain later material, and no
decision date precedes that start. At each decision date the system may use only information
available then, and every input is fixed before the next period's returns are observed.

Whether that is sufficient is tested rather than assumed. Each realized pack is probed by asking the
model to identify the period it describes, run at every rung of the ladder, so that any residual
recognition is a measured quantity per rung rather than a claim about the protocol as a whole. The
probe is close to free, since it is one additional call against runs that are happening anyway, and
it costs nothing to report a null result. Further representation controls over how the pack is
presented are specified in advance but applied only if that probe finds material recognition; the
test design and the contingent controls are set out in the project's method document.

Report quality is assessed separately. For a sample of reports, each material claim is checked
against the realized pack and its source metadata, recording whether the report is grounded,
internally consistent with the machine-readable decision, and free from temporal leakage. A report
whose stated rationale does not match the evidence the decision responded to is a governance failure
even when the decision itself is defensible.

== Feasibility check, pre-registration, and freeze <sec:prereg>

The failure mode most likely to void the project is a pack that does not move: near-constant signals
leave C2 near-constant, the LLM sees near-identical packs week after week, and the divergence
collapses to an offset plus noise. A feasibility check therefore runs before the freeze, on history
preceding the model's cut-off, building the pack and running the three comparators; it generates no
model calls and uses no evaluation-window data. Acceptance
criteria are fixed beforehand: C2's 10th-to-90th-percentile band of equity weight must exceed the
materiality threshold, each shipped signal must move by a stated amount in a stated fraction of
weeks, block composites must not be correlated above a stated bound, and each RQ3 state must occupy
a stated fraction of weeks. This is a power analysis, not a backtest: no return, Sharpe ratio or
drawdown is computed for any signal or comparator, and the script has no access to a forward-return
column, which makes the constraint auditable rather than declared.

None of the design is credible if it can be adjusted after the results are seen, so the commitments
go into a pre-registration document, committed and referenced by commit hash before the first
evaluation run: the four questions and the gates between them; every endpoint and how it is
computed; the materiality threshold; the perturbation taxonomy, the number of arms, $k$, and the
date subsample; the size $k$ of the ensemble and how it was chosen; the content of each ladder rung
and the representation controls held in reserve; the
feasibility-check criteria; the risk model, or its fallback; the frozen pack, comparators, model
version and generation settings; the RQ3 states and hypotheses; what is written in each branch of
RQ2; and the analysis code, written before the evaluation data exist.
The pack and comparators are frozen jointly with the practice partner, so that neither side can
change the inputs after seeing results.

// ---------------------------------------------------------------------------
// 7. Scope and Limitations
// ---------------------------------------------------------------------------

= Scope and Limitations

The project is limited to one decision-support workflow: the stock/bond allocation report. It covers
weekly recommendations between equities and bonds, one representative index per asset class, equity
weight free from 0 to 100 per cent, no turnover cap. The numerical side includes market risk and
return indicators, interest-rate and yield-curve information, and macro-financial indicators where
these are available in point-in-time form. The text-based side draws on commercial sentiment feeds
such as Alpha Vantage @alpha-vantage, chosen so that provenance and timing can be audited; we verify
that retrieved records reflect the information available at each decision date rather than any later
revision.

The system generates an investment report and a machine-readable decision, but it does not trade,
create orders, select individual securities, or optimize an unconstrained portfolio. The LLM works
from the sealed substrate and may not browse the web, reach any live
service, see a calendar date, or invent facts the substrate does not contain. The model can be
adapted to partner constraints, including a self-hosted option, but model comparison and fine-tuning
are outside the first evaluation phase, beyond the descriptive model-version arm of RQ1; version and
generation settings (e.g. temperature zero) are fixed so that results stay unaffected by silent
model updates.

The project makes no claim of out- or underperformance: the available window cannot support one, and
saying so in advance is part of the design rather than a caveat added at the end. One second-order
residual is recorded rather than dismissed: selecting signals with dynamic range is a mild selection
on the input distribution, which is not perfectly independent of the return distribution. Also out
of scope are a broad benchmark study, multi-asset allocation, personalized advice, compliance
approval, and live operations. The prototype is an auditable committee-support system, not an
autonomous investment system.

// ---------------------------------------------------------------------------
// References
// ---------------------------------------------------------------------------

#v(0.8em)

#bibliography("references.bib", title: "References", style: "ieee")

// ---------------------------------------------------------------------------
// Appendix
// ---------------------------------------------------------------------------

#pagebreak()

= Appendix: Example Generated Allocation Report <app:example-report>

The following example is illustrative. It shows the intended shape of the generated report, not an
actual investment recommendation.

#panel[
  *Investment Committee Allocation Report*\
  *Decision date:* week 13, evaluation year 1 (dates anonymised, see @sec:leakage)\
  *Horizon:* Next weekly rebalancing interval #h(1em) · #h(1em) *Universe:* Global equities and
  investment-grade bonds #h(1em) · #h(1em) *Benchmark:* 60/40

  *Recommended allocation*\
  A moderate underweight to equities for the next interval: stocks 55%, bonds 45%.

  *Evidence summary*\
  The numerical evidence points to a less supportive risk environment than in the previous window.
  Equity momentum remains positive but has weakened, valuation indicators are above their long-run
  median, and realized volatility has increased. Yield-curve and rates data suggest that duration
  risk remains material, but the bond allocation still improves portfolio stability under the current
  risk model. The sentiment input is mixed but slightly risk-off, with recurring references to
  tighter financial conditions, slower earnings growth, and uncertainty around central-bank
  communication. No single sentiment signal is treated as decisive; sentiment is used only as
  supporting evidence alongside the numerical indicators.

  *Rationale*\
  The 55/45 allocation keeps the portfolio close to the 60/40 benchmark while reducing equity
  exposure in response to weaker sentiment and higher measured risk. A larger shift is not
  recommended because the evidence does not show a severe deterioration in macro or market
  conditions, and the equity signal remains positive on some measures.

  *Main risks*\
  The recommendation may underperform the 60/40 benchmark if equity markets continue to rally or if
  the risk-off sentiment proves temporary, and the risk-scaled comparator C1 if bond yields rise
  sharply during the holding period. It should be treated as a controlled tilt, not a
  high-conviction market-timing signal.

  *Audit notes*\
  Generated from a sealed, timestamped evidence store. The agent made 11 tool calls against that
  store, all logged in the realized pack; it did not browse the web, reach any live service, or use
  data the store does not contain. The stored audit bundle contains the briefing, the ordered call
  trace, the source references, model identifier, prompt version, generation settings, and the
  machine-readable allocation decision.
]

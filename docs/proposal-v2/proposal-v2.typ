#set document(
  title: "A Reusable Agentic Platform for Auditable, Sentiment-Aware Dynamic Asset Allocation",
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

#let panel(body) = block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[#body]

#align(center)[
  #text(size: 18pt, weight: "bold")[
    A Reusable Agentic Platform for Auditable,\
    Sentiment-Aware Dynamic Asset Allocation
  ]

  #v(0.6em)

  Cyril Gabriele #h(1em) · #h(1em) Gian Seifert

  #v(0.4em)

  #text(size: 10pt, style: "italic")[Project Proposal - Revised Version]

  #v(0.8em)

  #text(size: 10pt)[
    Supervisors:\
    Prof. Dr. Alexander Braun, School of Finance\
    Prof. Dr. Siegfried Handschuh, Institute of Computer Science
  ]
]

= Motivation

Asset managers increasingly use AI to support information-intensive investment processes, while allocation decisions remain subject to requirements for governance, documentation, risk control, and human oversight @reuters-banks @eu-ai-act @reuters-eba.

Traditional quantitative models process valuation, momentum, macroeconomic, interest-rate, and risk indicators in a transparent way, but are less suited to incorporating unstructured information. LLMs can interpret textual and contextual evidence, but introduce stochasticity, limited traceability, and potential temporal leakage.

This project therefore develops an auditable LLM-based decision-support system for tactical stock/bond allocation. Numerical and textual evidence is stored point-in-time, accessed through a constrained tool layer, and translated by the LLM into a standardized investment report and machine-readable allocation decision.

The system does not trade or replace the investment committee. The thesis evaluates the quality and properties of its *allocation decisions*.

= Applied Research Questions <sec:rqs>

The available post-cut-off evaluation window is sufficient to observe repeated allocation decisions, but too short to support credible inference about tactical investment performance. The thesis therefore evaluates decisions rather than realized returns.

#panel[

*RQ1, reproducibility.*
The stability of LLM allocation decisions is evaluated across meaning-preserving perturbations and repeated runs of identical information sets.

#v(0.4em)

*RQ2, practical equivalence.*
LLM-generated bond/equity allocation decisions are tested for practical equivalence against a pre-registered deterministic comparator receiving the same point-in-time information.

#v(0.4em)

*RQ3, divergence analysis.*
Economically meaningful differences between the LLM and deterministic comparator are assessed for stability and for systematic association with identifiable characteristics of the evidence state.

#v(0.4em)

*RQ4, risk translation.*
Because return-based performance inference is not supportable on the available sample, material allocation differences are translated into their implications for portfolio beta, duration, tracking error, and predefined scenarios.

]

The evaluation proceeds sequentially from *stability* to *comparison*, *explanation*, and *economic interpretation*. RQ1 establishes whether the LLM is a sufficiently stable decision instrument. RQ2 compares it with a transparent deployable alternative. RQ3 examines persistent material differences, and RQ4 translates those differences into portfolio-risk consequences.

= Project Objectives

== Objective 1: Build an auditable point-in-time evidence-to-decision pipeline

Develop a reproducible two-stage pipeline in which an offline deterministic process constructs a sealed point-in-time evidence store and the LLM accesses it only through a constrained and fully logged tool layer.

#panel[
*Success criterion:* For every decision date, the system stores the realized evidence pack, complete retrieval trace, standardized investment report, machine-readable allocation decision, and relevant model, prompt, source, and generation metadata.
]

== Objective 2: Build and freeze the deterministic comparator framework

Construct a transparent multi-variable deterministic allocation rule using the same point-in-time evidence available to the LLM. The rule, parameters, and materiality threshold are fixed before evaluation. A static 60/40 allocation and a volatility-based rule serve only as secondary diagnostic benchmarks.

#panel[
*Success criterion:* The primary deterministic comparator and both diagnostic benchmarks exist as versioned, reproducible code and are frozen before the first evaluation run. The primary rule is transparent and sufficiently simple to represent a realistically deployable alternative.
]

== Objective 3: Evaluate allocation decisions

Evaluate reproducibility (RQ1), practical equivalence (RQ2), material and persistent divergence (RQ3), and the resulting portfolio-risk implications (RQ4).

#panel[
*Success criterion:* The evaluation quantifies decision dispersion, deviation from the primary comparator, the frequency and stability of material divergences, and their implications for beta, duration, tracking error, and predefined scenarios.
]

== Objective 4: Validate report quality and evaluation integrity

Assess whether generated reports are grounded in the evidence actually retrieved, consistent with the machine-readable allocation decision, and protected against temporal leakage.

#panel[
*Success criterion:* Every evaluated report can be traced to its realized evidence pack, material factual claims are supported by point-in-time evidence, and temporal recognition or leakage is explicitly tested.
]

= Proposed System

The system consists of two stages.

== Stage 1: Sealed point-in-time evidence store <sec:evidence-pack>

The first stage deterministically constructs a frozen store of quantitative, macro-financial, and textual evidence. Every observation is indexed by its as-of date and information-availability or vintage date.

Only information genuinely available at decision date $t$ may enter a decision:

$
"vintage" <= t
$

The evidence architecture consists of three artifacts:

- the *sealed substrate*: the full frozen evidence store;
- the *briefing*: the limited opening context supplied to the LLM;
- the *realized pack*: the briefing plus the complete ordered trace of information actually retrieved.

The final evidence set contains approximately five to eight signals covering both the equity and bond legs. Candidate variables are selected from the factor and return-predictability literature according to economic rationale, point-in-time availability, publication lag, revision properties, and historical coverage.

No signal is selected using performance in the evaluation window.

The textual evidence is drawn from a commercial sentiment feed with per-record publication timestamps, such as Alpha Vantage @alpha-vantage, so that provenance and timing remain auditable as the system is evaluated.

== Information ladder <sec:ladder>

The system is evaluated at increasing levels of information richness.

- *L1:* standardized quantitative signals and block-level composites;
- *L2:* additional cross-signal disagreement, reliability, vintage, and missingness information;
- *L3:* qualitative regime descriptions and structured sentiment summaries;
- *L4:* minimally controlled information used only as a leakage or contamination diagnostic.

L1 is the primary level for RQ2 because the LLM and deterministic comparator receive the same information.

The comparison between L3 and L1 measures whether richer information representation changes the LLM's decisions. L3 versus the deterministic comparator is reported separately as a system-level comparison rather than as the primary equivalence test.

== Stage 2: Bounded LLM decision loop <sec:stage2>

At each decision date, the LLM receives the briefing, retrieves further evidence through the constrained tool layer, and produces:

- a standardized investment report; and
- a machine-readable equity/bond allocation.

The model cannot browse the web, access live services, trade, access future observations, or change the decision date.

All calls are logged.

Because LLM output is stochastic, one decision is defined as an ensemble of $k$ independent runs. Signal ordering, equivalent phrasing, and numerical presentation may be perturbed across runs.

The reported allocation is the pre-specified ensemble statistic, for example the median recommended equity weight.

The value of $k$ is calibrated using non-evaluation pilot evidence packs and frozen before the main evaluation begins.

= Deterministic Comparator <sec:comparator>

The primary comparator C2 is a transparent multi-variable rule operating on the same L1 evidence as the LLM.

Its exact specification, including any parameters estimated exclusively from pre-evaluation history, is fixed before evaluation and jointly frozen with the practice partner.

Two secondary benchmarks aid interpretation:

- *C0  Static:* constant 60/40 allocation;
- *C1  Risk-based:* allocation adjusted only for measured portfolio or equity risk;
- *C2  Primary composite:* deterministic aggregation of the complete quantitative evidence set.

C0 answers whether the system moves at all. C1 indicates how much movement can be explained by simple risk scaling. C2 is the substantive comparator used for RQ2.

The comparator is not required to outperform markets. Its purpose is to provide a transparent, reproducible, and deployable reference decision.

= Expected Deliverables

The project delivers:

- the sealed evidence store, briefing format, constrained tool layer, and bounded LLM loop;
- the realized-pack, audit-log, report, and machine-readable allocation formats;
- the frozen evidence set and deterministic comparator framework;
- the perturbation and repeated-run harness for RQ1;
- the equivalence and divergence analysis for RQ2 and RQ3;
- the portfolio-risk translation for RQ4;
- the pre-registration and freeze record;
- the final thesis documenting the system, evaluation, limitations, and results.

= Evaluation Plan

For decision date $t$, let

$
w_t^("LLM")
$

denote the LLM ensemble allocation and

$
w_t^("C2")
$

the deterministic comparator allocation.

The decision-level deviation is

$
d_t = w_t^("LLM") - w_t^("C2").
$

Post-decision realized returns are not used to assess RQ1--RQ4.

== RQ1: Reproducibility

Three sources of variation are distinguished:

1. repeated-run variation under identical inputs;
2. variation under meaning-preserving presentation changes;
3. descriptive model-version drift.

The primary outputs are the dispersion of recommended equity weights and the probability that presentation or repeated-run variation exceeds an economically meaningful threshold.

The ensemble size $k$ is fixed before the evaluation sample is analysed.

== RQ2: Practical equivalence

A materiality margin $delta$ is defined in percentage points of equity allocation and translated into portfolio-risk terms.

For each date:

$
I_t = 1(|d_t| > delta).
$

The primary endpoint is the proportion of decision dates with a material difference:

$
p_delta = P(|d_t| > delta).
$

A pre-registered acceptable exceedance rate $q$ determines the interpretation:

- *Equivalent:* the upper confidence bound for $p_delta$ is below $q$;
- *Not equivalent:* the lower confidence bound exceeds $q$;
- *Inconclusive:* the confidence interval overlaps $q$.

Confidence intervals account for persistence across weekly observations, for example through a block bootstrap.

Mean absolute deviation, direction agreement, correlation, turnover, and within-ensemble dispersion are reported as secondary descriptive statistics.

The primary RQ2 comparison is:

$
"LLM"("L1") " versus " "C2"
$

because both systems receive identical information.

== RQ3: Divergence analysis <sec:retrieval>

RQ3 is activated where RQ2 identifies economically material differences.

First, the analysis tests whether the divergence persists across repeated runs and meaning-preserving perturbations.

Second, persistent divergence is examined for systematic association with pre-specified evidence states, such as:

- volatility regime;
- financial-conditions regime;
- stock-bond correlation regime;
- cross-signal disagreement.

The objective is association rather than causal attribution.

Retrieval traces provide an additional diagnostic: divergence accompanied by unstable retrieval indicates a different failure mode from divergence produced despite stable retrieval behaviour.

== RQ4: Risk translation <sec:risk-translation>

Every allocation path is translated into portfolio-risk characteristics rather than judged by subsequent realized performance.

The primary outputs are:

- equity beta;
- bond duration exposure;
- tracking error relative to 60/40;
- outcomes under a pre-specified scenario set.

The risk model is frozen before evaluation. Partner risk models are used where available; otherwise documented pre-evaluation estimates provide the fallback.

Historical data may therefore be used to estimate risk-model parameters, but post-decision returns are not used to claim superior or inferior investment performance.

== Leakage, grounding, and report quality <sec:leakage>

Temporal validity is enforced structurally rather than through prompting.

Every evidence item carries an information-availability timestamp and the store prevents access to information unavailable at decision date $t$.

The model's ability to identify the underlying period from the supplied information is tested separately at each information rung.

For a sample of generated reports, each material claim is checked against the realized evidence pack for:

- factual grounding;
- consistency with the allocation decision;
- provenance;
- temporal validity.

== Pre-registration and freeze <sec:prereg>

Before the first evaluation run, the following are documented and frozen:

- research questions and decision gates;
- final evidence variables;
- comparator specification;
- materiality margin $delta$ and exceedance tolerance $q$;
- perturbation taxonomy;
- ensemble size $k$;
- evaluation window;
- information-ladder definitions;
- RQ3 state definitions;
- risk model and scenario set;
- model version and generation settings;

The evidence set and primary comparator are frozen jointly with the practice partner before evaluation results are observed.

= Scope and Limitations

The project evaluates one tactical allocation decision-support workflow: weekly allocation between one representative equity index and one representative bond index.

The equity weight may vary between 0 and 100 per cent. No turnover constraint is imposed, although turnover is reported.

The project does not:

- execute trades;
- select individual securities;
- perform unconstrained portfolio optimization;
- fine-tune or systematically compare LLMs;
- provide personalized investment advice;
- make claims of investment outperformance.

The limited post-cut-off window prevents credible performance inference. This is treated as a design constraint rather than a limitation introduced after observing the results.

The resulting prototype is an auditable investment-committee support system, not an autonomous investment system.

= References

#bibliography("references.bib", title: "References", style: "ieee")

#pagebreak()

= Appendix: Example Allocation Report <app:example-report>

#panel[

*Investment Committee Allocation Report*

*Decision:* 55% equities / 45% bonds

*Evidence summary:*
The quantitative evidence indicates a moderately less supportive risk environment. Equity momentum remains positive but has weakened, measured volatility has increased, and valuation indicators remain elevated. Rates and yield-curve indicators imply continued duration risk, while the sentiment evidence is moderately risk-off.

*Rationale:*
The recommendation therefore represents a moderate equity underweight relative to 60/40 rather than a high-conviction tactical position.

*Risk interpretation:*
The allocation reduces equity beta relative to 60/40 while increasing bond exposure and changing duration and tracking-error characteristics according to the frozen risk model.

*Audit note:*
The report was generated exclusively from the sealed point-in-time evidence store. All retrieved information, tool calls, model settings, prompt versions, and the machine-readable allocation decision are retained in the realized evidence pack.

]

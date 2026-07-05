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
#show heading: set block(above: 1.4em, below: 0.8em)
#show heading.where(level: 1): set text(size: 13pt)
#show heading.where(level: 2): set text(size: 11.5pt)

// Links in a subtle colour
#show link: set text(fill: rgb("#1a4f8a"))

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
  #text(size: 10pt, style: "italic")[Project Proposal]

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
numerical and sentiment inputs are converted into a timestamped evidence summary. Second, an LLM
uses that summary to generate an investment report and a machine-readable stock/bond allocation
decision. The system does not trade, execute allocation changes, or replace the investment
committee; it supports the people making the decision.
// ---------------------------------------------------------------------------
// 2. Applied Research Question
// ---------------------------------------------------------------------------

= Applied Research Question

#block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[
  #text(fill: orange)[How does an LLM-based stock-bond allocation strategy perform out of sample relative to naive 50/50 @demiguel and conventional 60/40 benchmarks?]
]
#text(fill: orange)[The strategy uses only point-in-time quantitative, macro-financial, and sentiment evidence, and translates the LLM-generated allocation report into portfolio weights through a pre-specified mechanical rule. Performance is measured using Sharpe ratio, certainty-equivalent return, and turnover-adjusted returns.]


This is an applied question, not a purely academic one. The point is to build and evaluate a working prototype, and to see whether agentic AI can be useful, controllable, and inspectable in a realistic allocation workflow the partner actually cares about.

// ---------------------------------------------------------------------------
// 3. Project Objectives
// ---------------------------------------------------------------------------

= Project Objectives

== Objective 1: Build a controlled two-stage evidence-to-report pipeline

Develop a reproducible pipeline in which deterministic tools first generate a structured evidence pack, and the LLM then transforms that evidence into a standardized allocation report. The LLM must not freely browse, trade, or invent unsupported data.

#block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[
  *Success criterion:* For every rebalancing date, the system produces:

  - a structured evidence pack,
  - a human-readable investment report,
  - a machine-readable allocation decision,
  - a record of the model, prompt, data sources, and generation settings.
]

== Objective 2: Evaluate allocation recommendations against 50/50 and 60/40 benchmarks

Compare the system's recommended stock/bond allocations against two simple baselines: equal-weight 50/50 and conventional 60/40. The 50/50 baseline is the two-asset version of the naive 1/N benchmark used in the portfolio-choice literature @demiguel. The evaluation should focus on realized out-of-sample portfolio outcomes after each report date. #text(fill: red)[To isolate the LLM's contribution from the evidence pack itself, the system is also compared against a rule-based allocator that consumes the same evidence pack but applies a fixed decision rule instead of the LLM.]

#block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[
  *Success criterion:* The system is evaluated using a predefined set of performance metrics, including return, volatility, Sharpe ratio, #text(fill: orange)[certainty-equivalent return,] drawdown, turnover, and transaction-cost-adjusted performance.
]

== Objective 3: Assess report quality, auditability, and leakage control

Evaluate whether the generated reports are factually grounded in the evidence pack, internally consistent with the allocation recommendation, and protected against temporal leakage.

#block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[
  *Success criterion:* Each report can be audited against the evidence pack, and no material factual claim should rely on information unavailable at the decision date.
]

// ---------------------------------------------------------------------------
// 4. Proposed System
// ---------------------------------------------------------------------------

= Proposed System

The prototype follows a two-stage workflow. First, numerical inputs from the quant models and
text-based inputs from sentiment sources are converted into a structured evidence summary. Second,
an LLM uses that summary to generate the investment report and the machine-readable allocation
decision. Appendix @app:example-report shows an illustrative example of the report format this
workflow is meant to produce.
#text(fill: orange)[The exact translation from the LLM output into portfolio weights will be specified ex ante as a reproducible mechanical rule before the evaluation is run.]

#figure(
  image("diagrams/v3_architecture.svg", width: 100%),
  caption: [High-level two-stage workflow for the allocation report prototype.],
) <fig:system-workflow>


// ---------------------------------------------------------------------------
// 5. Expected Deliverables
// ---------------------------------------------------------------------------

= Expected Deliverables

The project will deliver a working prototype and evaluation package for the two-stage workflow
shown in @fig:system-workflow. The deliverables are:

- the two-stage allocation-report pipeline;
- the structured evidence-summary format;
- the generated investment-report template, illustrated in Appendix @app:example-report;
- the machine-readable allocation-decision format;
- the audit log covering data sources, prompts, model settings, generated outputs, and run
  metadata;
- the evaluation harness comparing the recommendations against 50/50 and 60/40 baselines#text(fill: red)[, plus a rule-based, no-LLM baseline using the same evidence pack];
- the final written report describing the architecture, implementation, evaluation results,
  limitations, and possible extensions.

// ---------------------------------------------------------------------------
// 6. Evaluation Plan
// ---------------------------------------------------------------------------

= Evaluation Plan

The evaluation follows an out-of-sample backtesting design, following the portfolio-choice
benchmarking logic used by DeMiguel, Garlappi, and Uppal @demiguel. The implementation model is
chosen so that its knowledge cut-off date is known. The backtest period then starts strictly after
that cut-off date, so the model cannot rely on memorized information about the evaluated market
period. At each rebalancing date, the system may use only information that would have been
available at that date. The numerical inputs, sentiment input, evidence summary, prompt
configuration, generated report, and allocation decision are all fixed before the next-period
returns are observed. This prevents the LLM or the evaluation code from using information from the
future.

For each monthly or quarterly rebalancing date $t$, the pipeline produces a recommended
stock/bond allocation $w_t$. This allocation is then held over the next evaluation interval
$(t, t+1]$. The realized portfolio return of the system is compared with two static benchmark
portfolios over the same interval: a 50/50 stock/bond allocation and a 60/40 stock/bond allocation.
The interval-level benchmark-relative return differences are recorded as:

$
  Delta_("50/50", t+1) &= R_("dynamic", t+1) - R_("50/50", t+1) \
  Delta_("60/40", t+1) &= R_("dynamic", t+1) - R_("60/40", t+1)
$

#text(fill: red)[With monthly or quarterly rebalancing, a single backtest period yields on the order of ten to thirty allocation decisions, too few to establish statistical significance. The performance comparisons are therefore treated as an illustrative check of the system's behavior rather than as a claim of outperformance.]

The report-generation layer is evaluated separately from the economic results. For a sample of
generated reports, each material claim is checked against the evidence summary and its source
metadata. The evaluation records whether the report is grounded in the available evidence,
internally consistent with the machine-readable allocation decision, and free from temporal
leakage.

#text(fill: orange)[The final assessment therefore has two parts: first, whether the pipeline produces traceable, point-in-time allocation recommendations without leakage; second, how those recommendations behave relative to the 50/50 and 60/40 benchmarks in an illustrative, statistically limited backtest.]

// ---------------------------------------------------------------------------
// 7. Scope and Limitations
// ---------------------------------------------------------------------------

= Scope and Limitations

The project is deliberately limited to one decision-support workflow: the stock/bond allocation
report. It covers dynamic allocation (monthly or quarterly) recommendations between equities and bonds,
based on a controlled evidence summary that combines deterministic quantitative signals with
text-based sentiment input. The numerical side includes market risk and return indicators,
interest-rate and yield-curve information, and macro-financial indicators where these are
available in point-in-time form. The text-based side is limited to one controlled sentiment source,
(i.e. Alpha Vantage, or any other sentiment data provider), so that the provenance and timing of the input can be audited @alpha-vantage. #text(fill: red)[We verify that retrieved sentiment records reflect the information available at each decision date, rather than any later revision, to avoid look-ahead bias.]

#text(fill: orange)[A broad evaluation of different LLMs, model bias, or fine-tuning strategies is out of scope. The project uses one fixed model configuration for the backtest.]

The system generates an investment report and a machine-readable allocation decision, but it does
not trade. It does not create orders, execute transactions, select individual securities, or
optimize an unconstrained portfolio. The LLM is used only in the report-generation stage and works
from the previously prepared evidence summary. It is not allowed to browse freely, read arbitrary
news, call discretionary tools, or invent unsupported data. The concrete model can be adapted to
partner constraints, including a self-hosted option if privacy or deployment requirements demand
it, but model comparison and fine-tuning are outside the first evaluation phase. #text(fill: red)[The model version and generation settings (e.g., temperature zero) are fixed for the duration of the backtest so that results stay reproducible and unaffected by silent model updates.]

The recommendations are compared against the 50/50 and
60/40 stock/bond baselines, using economic performance measures and structured report-quality
checks. The project does not attempt a broad benchmark study, multi-asset allocation, personalized
financial advice, production-grade compliance approval, or live investment operations. The
prototype is therefore an auditable committee-support system, not an autonomous investment system.

// ---------------------------------------------------------------------------
// References
// ---------------------------------------------------------------------------

#pagebreak()

#bibliography("references.bib", title: "References", style: "ieee")

// ---------------------------------------------------------------------------
// Appendix
// ---------------------------------------------------------------------------

#pagebreak()

= Appendix: Example Generated Allocation Report <app:example-report>

The following example is illustrative. It shows the intended shape of the generated report, not an
actual investment recommendation.

#block(
  fill: rgb("#f7f7f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 2pt,
  width: 100%,
)[
  *Investment Committee Allocation Report*\
  *Decision date:* 2027-03-31\
  *Evaluation horizon:* Next monthly rebalancing interval\
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
  if the risk-off sentiment proves temporary. It may also underperform the 50/50 benchmark if bond
  yields rise sharply during the holding period. The allocation should therefore be treated as a
  controlled tilt, not as a high-conviction market-timing signal.

  *Audit notes*\
  The report was generated from a timestamped evidence summary. The LLM did not browse the web,
  call additional tools, or use data outside the evidence pack. The stored audit bundle contains
  the source references, model identifier, prompt version, generation settings, and the
  machine-readable allocation decision.
]

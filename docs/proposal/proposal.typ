// A Reusable Agentic Platform for Auditable, Sentiment-Aware Dynamic Asset Allocation
// Project proposal (Typst source)

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

Banks and asset managers are turning to AI to help analysts, portfolio managers, and risk teams
get through information-heavy work. In these settings, though, the system has to stay under human
control: it needs to be auditable, explainable, and robust, and it has to leave the final call to
a person. That is also where regulators have landed. The recent supervisory debate on AI in
finance is about governance, documentation, risk management, and human oversight, not about
handing decisions to a model @reuters-banks @eu-ai-act @reuters-eba.

The split between stocks and bonds is one of the biggest decisions an asset manager makes. That
single high-level allocation drives most of a portfolio's risk and return, and many firms revisit
it on a regular schedule (a dynamic, or tactical, allocation process), using quantitative
signals (valuations, momentum, macro and rates data, risk models) together with a read on the
prevailing market narrative. Quantitative models handle the measurable side well. What they
rarely capture is how a shift in narrative, news sentiment, or market attention should feed into
a tactical tilt. Generic LLM assistants have the opposite weakness: they can summarize a
narrative, but they offer no deterministic analytics, no traceability, no link to a firm's own
models, and little workflow control.

This project is run with an asset-management partner that wants a system to support exactly this
decision. We propose a reusable agentic platform for finance and test it on one concrete use
case: auditable, sentiment-aware recommendations for a portfolio's bond/stock split, written up
as an investment-committee report. Where possible, the platform incorporates some of the tools and
models the firm already uses; where those cannot be shared or integrated directly, it aims to
reproduce similar behaviour through stand-ins with the same interface. On top of that it adds a
sentiment-simulation layer and orchestrates the pipeline. It does not try to rebuild the firm's
quantitative stack.

The system does not trade, move the allocation, give personalized advice, or stand in for the
investment committee. It supports the people who do those things: gathering evidence, building
and simulating sentiment scenarios, working out what a candidate allocation does to the
portfolio, checking its own claims, and producing a recommendation memo with an audit trail
behind it.

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
  How can a reusable LangGraph-based agentic platform support an investment committee in
  producing auditable, sentiment-aware recommendations for a portfolio's dynamic bond/stock
  allocation, by combining the firm's existing quantitative models, source-grounded market
  narratives, multi-agent sentiment simulation via a dedicated agentic engine, and deterministic portfolio
  risk analytics?
]

This is an applied question, not a purely academic one. The point is to build and evaluate a
working prototype, and to see whether agentic AI can be useful, controllable, and inspectable in
a realistic allocation workflow the partner actually cares about.

// ---------------------------------------------------------------------------
// 3. Project Objectives
// ---------------------------------------------------------------------------

= Project Objectives

The project has five objectives.

A reusable platform. We design an agentic platform for financial workflows that handles
orchestration, state, tool use, memory, validation, and human-in-the-loop control, and that can
be extended beyond the allocation case. LangGraph fits well here, since it is built for
long-running, stateful agent workflows with persistence, durable execution, tracing, and human
oversight @langgraph.

One concrete workflow. On top of the platform we build a dynamic bond/stock allocation
workflow. Given a sandbox portfolio, a mandate, the firm's signals, and a market context, it
retrieves the relevant information, builds and simulates sentiment scenarios, computes the risk
and return of candidate equity/bond mixes, and writes a memo recommending whether and how far to
shift the split.

Integration and simulation. We look at how the platform can plug into the partner's existing
tools and models, and how a sentiment-simulation component fits alongside them. The aim is to
incorporate some of the firm's models, signals, and feeds as callable tools where that is feasible,
and otherwise to provide similar behaviour through stand-ins rather than reimplementing the firm's
stack. The exact engine is left open: the sentiment-simulation component is provided by an
external multi-agent simulation engine such as OASIS, a multi-agent social simulation
framework @oasis. We use
simulation cautiously: not to forecast prices or returns, but to model how sentiment spreads, how
stakeholders react, and what second-order effects a narrative shift might have. We keep it an
optional, isolated component, with a small internal adapter we write ourselves as the default.

Reasoning module. The platform needs a reasoning step that turns the gathered evidence into a
bounded _outlook_: a view on the bond/stock tilt with explicit uncertainty that feeds the
deterministic analytics. In its basic form this is a single step. If time allows, we extend it
with the macro/micro decomposition from the Nexus forecasting framework @nexus, where a macro step
reads the prevailing regime and a micro step weighs near-term catalysts before the two are
combined. Either way the module is an input to the analytics, not a price or return predictor and
not the recommendation on its own, and we deliberately leave out the backtest-driven calibration
loop.

Evaluation. We evaluate the prototype on a post-cutoff backtest and against transparent baselines
rather than a chat assistant: a static benchmark split (e.g. a fixed 60/40) and a traditional
indicator-driven rule set built on classic signals such as equity valuations (P/E ratio or equity
earnings yield versus bond yields), Fed rate-path expectations, and US labour-market data. The
exact baseline is fixed after a short literature review and discussion with the practical partner's
experts. Following Nexus @nexus, evaluation runs on data after the models' knowledge cutoff to
avoid leakage, and looks at decision quality together with source grounding and auditability.

// ---------------------------------------------------------------------------
// 4. Proposed System
// ---------------------------------------------------------------------------

= Proposed System

The prototype has seven main components.

+ Agentic orchestration layer. A LangGraph supervisor coordinates the specialized agents, holds
  the workflow state, logs intermediate output, and enforces the human approval points. This is
  the reusable core of the platform.

+ House-model and data integration layer. Where feasible, this incorporates some of the firm's
  quantitative models, signals, and data feeds as deterministic tools the platform can call. Where
  a model or feed cannot be shared or integrated directly, a stand-in with the same interface
  provides similar behaviour. This is the piece that connects the platform to the firm's existing
  tools.

+ Research and RAG agent. Retrieves and summarizes relevant financial news, macro and rates
  commentary, company filings, and market reports. Claims in the memo are linked back to their
  sources wherever possible.

+ Sentiment scenario agent. Turns retrieved information and user-defined themes into structured
  sentiment scenarios for the equity/bond decision: a risk-off rotation out of equities, a hawkish
  central-bank surprise, a growth scare, weak credit sentiment, a geopolitical escalation, or a
  move away from high-duration assets.

+ Sentiment-simulation module. Simulates how different market participants might react to an
  initial narrative shock. The output is a structured picture of exposure (which sectors, factors,
  or parts of the split are most affected) that feeds the reasoning rather than acting as a trading
  signal or a return forecast. It runs through an integration with an external agentic engine such
  as OASIS or, by default, a small internal adapter we write ourselves.

+ Allocation analytics tools. Deterministic Python tools that compute the risk and return of
  candidate bond/stock mixes: returns, volatility, drawdowns, VaR/CVaR, concentration, factor and
  sector exposure, benchmark-relative metrics, scenario losses, and how sensitive the split is to
  its inputs. Classical methods such as mean-variance optimization or risk parity @markowitz give
  a transparent reference allocator, but any optimization stays secondary to the decision-support
  framing.

+ Validation, reporting, and audit layer. A validation agent flags unsupported claims, separates
  fact from assumption, notes the limitations, and drafts the committee memo. The audit layer
  records sources, tool calls (including which house models ran), model versions, scenario and
  simulation assumptions, intermediate outputs, validation checks, and human approvals.

== Reasoning backbone

At its core the reasoning step is a single component that produces the outlook: it reads the
gathered evidence and returns a bounded view on the tilt with explicit uncertainty. It registers
as one _outlook_ tool that feeds the deterministic analytics and the memo. It does not predict
prices or returns, and it does not produce the recommendation by itself.

As an optional extension, if time allows, we structure that step as the macro/micro split from
Nexus @nexus:

- A macro-reasoning step sets the broad regime behind the bond/stock decision (the rate cycle,
  the growth-versus-inflation backdrop, and the overall risk-on/risk-off posture), which gives the
  direction of the tilt.
- A micro-reasoning step weighs near-term catalysts: data releases, central-bank meetings,
  earnings, and the sentiment shocks the simulation module surfaces.
- A synthesizer step merges the two into one view and spells out how they were weighed.

Either way we leave the backtest-driven calibration loop out of scope.

Each run produces two artifacts:

+ an investment-committee allocation memo: whether and by how much to change the bond/stock
  split, with the rationale, scenario analysis, and the assumptions and limits behind it;
+ an audit bundle: the run configuration, data sources, tool and model calls, simulation
  assumptions, validation results, a claim-to-evidence matrix, and the recorded human approvals.

// ---------------------------------------------------------------------------
// 5. Expected Deliverables
// ---------------------------------------------------------------------------

= Expected Deliverables

The list is trimmed to what a working, evaluable prototype actually needs:

- the reusable agentic platform (LangGraph orchestration: workflow state, tool registry,
  validation, human-in-the-loop control, and audit logging);
- the dynamic bond/stock allocation workflow built on the platform, incorporating the partner's
  models and data where feasible (or stand-ins with the same interface), producing the committee
  memo and its audit bundle;
- deterministic allocation analytics tools, with tests;
- the reasoning module that produces the bounded outlook, with an optional macro/micro split
  inspired by Nexus @nexus (no calibration) if time allows;
- the sentiment-simulation component, either an external agentic-engine integration (e.g. OASIS)
  or, by default, a minimal internal adapter we write ourselves;
- the evaluation: a post-cutoff backtest harness, the two baselines (static benchmark and
  traditional indicator-based allocation), and the comparison against the platform, with component
  ablations and reasoning-quality results;
- a final report covering architecture, integration, evaluation, limitations, governance, and
  extendability.

// ---------------------------------------------------------------------------
// 6. Evaluation Plan
// ---------------------------------------------------------------------------

= Evaluation Plan

The evaluation is kept light. Backtests are used to sanity-check and stress the decision logic, not
to claim investment performance or present a tradeable strategy.

Baselines. The platform is compared against two transparent baselines:

+ a static benchmark allocation, a fixed split such as 60/40, standing in for taking no active
  view; and
+ a traditional allocation baseline, a deterministic rule set that maps classic indicators (for
  example equity valuations, Fed rate-path expectations, and US labour-market data) to a tilt. Its
  exact specification follows a short literature review and discussion with the practical partner's
  experts, and is frozen before any results are looked at, so the comparison stays fair.

Post-cutoff backtesting. Following Nexus @nexus, evaluation runs only on data after the language
models' knowledge cutoff, so a model cannot simply recall a known outcome. This is the main leakage
control.

What we measure. On each window we compare the proposed tilts with the baselines on a small set
of risk-adjusted and stability measures, for example realized volatility, maximum drawdown, a
Sharpe-type ratio, and the directional hit rate of the tilt. We also check that the memo is
well-grounded: each material claim should trace through the audit bundle to a source, a tool
output, or human input. Finally, the partner and supervisors give a short human judgment of whether
the memo is committee-ready.

// ---------------------------------------------------------------------------
// 7. Scope and Limitations
// ---------------------------------------------------------------------------

= Scope and Limitations

The project does not cover live trading, allocation execution, personalized advice, or
production-grade compliance, and it uses public, synthetic, or sandbox/anonymized data. The
prototype is decision support for the investment committee, not an autonomous system. The scope is
deliberately narrow: one platform and one evaluated workflow (the bond/stock split), though the
platform is designed to extend to other finance workflows later.

On the sentiment simulation, the default path is a minimal internal adapter we write ourselves,
with an external agentic-engine integration (such as OASIS) treated as an optional, isolated
experiment. The engine is not a price-prediction engine; its role is to generate structured
sentiment and stress scenarios that
complement the deterministic analytics.

// ---------------------------------------------------------------------------
// References
// ---------------------------------------------------------------------------

#bibliography("references.bib", title: "References", style: "ieee")

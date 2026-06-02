// A Reusable Agentic Platform for Auditable, Sentiment-Aware Dynamic Asset Allocation
// Management summary (Typst source)

#set document(
  title: "Management Summary: A Reusable Agentic Platform for Auditable, Sentiment-Aware Dynamic Asset Allocation",
  author: ("Cyril Gabriele", "Gian Seifert"),
)

#set page(
  paper: "a4",
  margin: (x: 2.4cm, top: 2.6cm, bottom: 2.4cm),
)

#set text(
  font: ("New Computer Modern", "Times New Roman"),
  size: 11pt,
  lang: "en",
)

#set par(justify: true, leading: 0.68em, spacing: 1.05em)

#show link: set text(fill: rgb("#1a4f8a"))

// ---------------------------------------------------------------------------
// Title block
// ---------------------------------------------------------------------------

#align(center)[
  #block(inset: (bottom: 0.3em))[
    #text(size: 15pt, weight: "bold")[
      A Reusable Agentic Platform for Auditable,\
      Sentiment-Aware Dynamic Asset Allocation
    ]
  ]

  #v(0.3em)
  #text(size: 11pt, style: "italic")[Management Summary]

  #v(0.3em)
  #text(size: 10pt)[Cyril Gabriele #h(1em) · #h(1em) Gian Seifert]
]

#v(0.8em)

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------

Deciding how a portfolio is split between stocks and bonds is one of the most consequential calls
an asset manager makes, and it has to be revisited as markets move. Many firms still rely on
traditional, indicator-driven rules for this. The problem is that such rules are static: they map a
fixed set of indicators to a fixed response and are not adjusted when the market narrative or the
surrounding context changes. We aim to build an inherently dynamic alternative, one that can take
in new information and shifting sentiment and reflect it in the allocation, while keeping a person
in control of the final decision.

Banks and asset managers increasingly want AI support for this kind of information-heavy decision,
but the process has to stay auditable, explainable, and under human oversight, with the final call left to a
person. Generic AI assistants do not meet that bar. They can summarize a market narrative, but they
give no reliable analytics, no traceability, and no link to a firm's own models.

Together with an asset-management partner, we aim to build a reusable agentic platform for asset
allocation decisions and proving it on one concrete use case: dynamic, sentiment-aware recommendations for a portfolio's
bond and stock split, delivered as an investment-committee memo with a full audit trail behind it.
This platform handles the orchestration, workflow state, tool use, validation, and human approval
steps. On top of it runs the allocation workflow, which integrates the partner's existing quantitative
models and data where feasible, retrieves and grounds the relevant market information, builds and
simulates sentiment scenarios, computes the risk and return of candidate allocations, and writes
the memo.

The system supports the people who decide rather than replacing them. It does not trade, move the
allocation, give personalized advice, or stand in for the investment committee. To show that it
works, we test the prototype on data from after the models' knowledge cutoff and compare it against
two transparent baselines: a fixed 60/40 split and a traditional indicator-driven rule set. We look
at the decision quality together with how well each recommendation can be traced back to its sources.

What the project delivers: the reusable agentic platform, the dynamic bond and stock allocation
workflow, the deterministic analytics tools with tests, the reasoning module, the
sentiment-simulation component, the evaluation harness with its baselines, and a final report
covering the architecture, integration, evaluation, limitations, and governance. The scope is
deliberately narrow: one platform and one evaluated workflow (the bond/stock split), though the
platform is designed to extend to other finance workflows later (e.g. commodities).

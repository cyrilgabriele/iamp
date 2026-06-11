# Scope Proposal: Agentic Stock–Bond Allocation Report System

**Working title:** Agentic Report Generation for Dynamic Stock–Bond Allocation  
**Document purpose:** Self-contained project scope for discussion with academic supervisor and project partner  
**Version:** 0.1  
**Date:** 2026-06-11

---

## 1. Executive Summary

This project proposes a **non-trading agentic investment research system** for dynamic allocation between **equities and bonds**. The system does not execute trades and does not act as an autonomous portfolio manager. Instead, it produces a structured **investment report** and a machine-readable allocation recommendation that a human decision-maker could review.

The project is intentionally scoped around a **two-stage pipeline**:

1. **Stage 1 — Evidence generation:** deterministic tools and quantitative models collect and transform market, macro, interest-rate, return, risk, and sentiment data into a structured evidence pack.
2. **Stage 2 — Report generation:** a large language model uses only the evidence pack to produce a standardized investment report and a constrained stock/bond allocation recommendation.

The primary model for the first implementation should be **Claude 3.5 Sonnet**, because it offers strong report-writing, synthesis, long-context handling, and tool-oriented workflow capabilities. If a project partner requires stricter data privacy, local deployment, or model control, the system can be migrated to a **self-hosted Llama model**, most plausibly **Llama 3.1 70B Instruct**. Such a migration should be treated as a scope trade-off, not as a free substitution: self-hosting improves control and privacy but may require reducing other project components.

The evaluation should be deliberately narrow. The system should be compared against only two main allocation benchmarks:

- **50/50 stock/bond allocation**, interpreted as the DeMiguel-style `1/N` benchmark for a two-asset universe.
- **60/40 stock/bond allocation**, interpreted as the conventional balanced portfolio benchmark.

The main academic contribution is not that an LLM “predicts markets.” The more defensible contribution is that an LLM can serve as an **auditable report-generation and evidence-synthesis layer** on top of controlled quantitative inputs, while the resulting allocation recommendations are evaluated against simple and robust baselines.

---

## 2. Applied Research Question

**Can a two-stage agentic system, consisting of a deterministic evidence-generation layer and an LLM-based report-generation layer, produce auditable stock–bond allocation reports and recommendations that are competitive with simple 50/50 and 60/40 allocation benchmarks?**

A stricter version suitable for an academic proposal:

> To what extent can an LLM-based report-generation layer, operating only on point-in-time quantitative, macro-financial, and sentiment evidence, support dynamic stock–bond allocation decisions relative to naive 50/50 and conventional 60/40 benchmarks?

This question deliberately avoids claiming that the LLM itself discovers alpha. Instead, it asks whether the full system improves the **decision-support process** and whether the resulting allocation recommendations are economically competitive with simple baselines.

---

## 3. Three Clear Objectives

### Objective 1 — Build a controlled two-stage evidence-to-report pipeline

Develop a reproducible pipeline in which deterministic tools first generate a structured evidence pack, and the LLM then transforms that evidence into a standardized allocation report. The LLM must not freely browse, trade, or invent unsupported data.

**Success criterion:** For every rebalancing date, the system produces:

- a structured evidence pack,
- a human-readable investment report,
- a machine-readable allocation decision,
- a record of the model, prompt, data sources, and generation settings.

### Objective 2 — Evaluate allocation recommendations against 50/50 and 60/40 benchmarks

Compare the system’s recommended stock/bond allocations against two simple baselines: equal-weight 50/50 and conventional 60/40. The evaluation should focus on realized out-of-sample portfolio outcomes after each report date.

**Success criterion:** The system is evaluated using a predefined set of performance metrics, including return, volatility, Sharpe ratio, drawdown, turnover, and transaction-cost-adjusted performance.

### Objective 3 — Assess report quality, auditability, and leakage control

Evaluate whether the generated reports are factually grounded in the evidence pack, internally consistent with the allocation recommendation, and protected against temporal leakage.

**Success criterion:** Each report can be audited against the evidence pack, and no material factual claim should rely on information unavailable at the decision date.

---

## 4. Project Scope

### 4.1 In Scope

The project includes:

- stock/bond allocation only;
- report generation, not trading;
- monthly or quarterly rebalancing;
- deterministic quantitative signal generation;
- interest-rate and yield-curve information;
- macro-financial indicators where available in point-in-time form;
- market risk and return indicators;
- sentiment input from one controlled provider, initially Alpha Vantage;
- Claude 3.5 Sonnet as the first implementation model;
- optional migration to a self-hosted Llama model if partner constraints require it;
- comparison against 50/50 and 60/40 only;
- economic evaluation of allocation recommendations;
- qualitative and structured evaluation of report quality.

### 4.2 Out of Scope

The project explicitly excludes:

- autonomous trading or execution;
- direct order generation;
- security selection within equities or bonds;
- multi-asset allocation beyond stocks and bonds;
- comparison against a large benchmark zoo;
- unrestricted web browsing by the LLM;
- unrestricted news reading by the LLM;
- discretionary LLM access to arbitrary tools during report generation;
- unconstrained portfolio optimization by the LLM;
- personalized financial advice to individual investors;
- fine-tuning during the first evaluation phase.

The strict exclusion of autonomous trading is important. The system is a **decision-support and reporting tool**, not an investment execution system.

---

## 5. System Architecture

## 5.1 Stage 1 — Evidence Generation

Stage 1 creates the structured input for the LLM. This stage should be deterministic, reproducible, and auditable.

### Inputs

Potential inputs include:

- equity index returns;
- bond index returns;
- stock/bond volatility;
- stock/bond drawdowns;
- rolling correlations;
- short-term and long-term interest rates;
- yield-curve slope;
- inflation indicators;
- growth indicators;
- valuation indicators, if available;
- equity and bond momentum;
- macro regime indicators;
- Alpha Vantage market news and sentiment indicators.

### Sentiment Input

Sentiment should be included only as a controlled Stage 1 signal. The LLM should not independently search the news.

The preferred sentiment source is the Alpha Vantage `NEWS_SENTIMENT` endpoint. Relevant Alpha Vantage topics for this project include:

- `financial_markets`,
- `economy_monetary`,
- `economy_macro`,
- `economy_fiscal`,
- possibly `finance`.

The sentiment signal should be aggregated before it is passed to the LLM. For example, for each decision date, the evidence pack could include:

```json
{
  "sentiment_source": "Alpha Vantage NEWS_SENTIMENT",
  "sentiment_window": "30D",
  "topics": ["financial_markets", "economy_monetary", "economy_macro"],
  "article_count": 182,
  "average_sentiment_score": 0.08,
  "sentiment_label": "mildly positive",
  "negative_article_share": 0.34,
  "positive_article_share": 0.42,
  "trend_vs_previous_window": "improving"
}
```

This avoids turning the LLM into a free-form news reader and makes the sentiment input testable.

### Stage 1 Output: Evidence Pack

The output of Stage 1 should be a fixed-schema evidence pack. Example:

```json
{
  "decision_date": "2025-03-31",
  "rebalance_frequency": "monthly",
  "asset_universe": ["equities", "bonds"],
  "current_allocation": {
    "equities": 0.60,
    "bonds": 0.40
  },
  "benchmark_50_50": {
    "equities": 0.50,
    "bonds": 0.50
  },
  "benchmark_60_40": {
    "equities": 0.60,
    "bonds": 0.40
  },
  "quant_signals": {
    "equity_momentum": "positive",
    "bond_momentum": "neutral",
    "yield_level": "high",
    "yield_curve_slope": "inverted",
    "equity_volatility_regime": "elevated",
    "bond_volatility_regime": "moderate"
  },
  "sentiment_signals": {
    "financial_market_sentiment": "mildly positive",
    "monetary_policy_sentiment": "mixed",
    "macro_sentiment": "weakening"
  },
  "candidate_allocation": {
    "equities": 0.55,
    "bonds": 0.45
  },
  "constraints": {
    "no_shorting": true,
    "no_leverage": true,
    "equity_min": 0.20,
    "equity_max": 0.80,
    "max_single_period_turnover": 0.10
  }
}
```

The exact variables may change, but the schema should remain fixed once evaluation begins.

---

## 5.2 Stage 2 — Report Generation

Stage 2 uses the LLM to generate a standardized investment report from the evidence pack.

The LLM should receive:

- the evidence pack;
- the report template;
- the allowed allocation range;
- the allowed output schema;
- any methodological notes needed to interpret the signals.

The LLM should not receive:

- future returns;
- post-decision-date information;
- unrestricted internet access;
- raw unfiltered news articles unless they are explicitly timestamped and included in the evidence pack;
- permission to execute trades;
- permission to call external tools during final report generation unless this is logged and restricted.

### Stage 2 Output

Each run should produce two outputs.

#### A. Human-readable report

Suggested report structure:

1. Metadata and decision date
2. Executive summary
3. Recommended allocation
4. Change versus prior allocation
5. Signal dashboard
6. Market and macro interpretation
7. Sentiment interpretation
8. Investment rationale
9. Risks and counterarguments
10. Scenario analysis
11. Monitoring triggers
12. Data and model audit trail

#### B. Machine-readable allocation record

Example:

```json
{
  "decision_date": "2025-03-31",
  "model": "Claude 3.5 Sonnet",
  "rebalance_frequency": "monthly",
  "recommended_allocation": {
    "equities": 0.55,
    "bonds": 0.45
  },
  "confidence": "medium",
  "main_rationale": "mixed macro environment with attractive bond yields and still-positive equity momentum",
  "main_risk": "equity markets continue to rally despite defensive signal mix",
  "constraints_satisfied": true,
  "uses_only_evidence_pack": true
}
```

This structured record is essential because the report text itself is difficult to backtest. Portfolio evaluation should be based on the machine-readable allocation.

---

## 6. Model Decision

## 6.1 Primary Model: Claude 3.5 Sonnet

The first implementation should use **Claude 3.5 Sonnet**.

### Rationale

Claude 3.5 Sonnet is preferred for the initial version because the main task is high-quality financial report generation, not low-level numerical optimization. The model is suitable for:

- long-context synthesis;
- structured report generation;
- nuanced interpretation of conflicting signals;
- disciplined writing;
- generating a readable investment committee-style report;
- following detailed formatting and output instructions.

This choice is also pragmatic. Starting with Sonnet reduces implementation risk and makes it easier to demonstrate a convincing first prototype.

### Strict Implementation Requirement

The model version must be pinned. The project should avoid using a moving alias if a fixed snapshot is available. The report metadata should always store:

- model name and version;
- provider;
- prompt version;
- temperature and generation parameters;
- evidence pack hash or identifier;
- run timestamp.

### Known Weakness

Claude 3.5 Sonnet is a closed model. That creates limitations:

- no self-hosting;
- weaker reproducibility than open-weight models;
- dependence on provider availability;
- limited fine-tuning/control;
- possible privacy concerns for partners;
- potential model-version drift if not pinned carefully.

Therefore, Sonnet is the best **initial product-quality model**, not necessarily the best **long-term privacy or reproducibility model**.

---

## 6.2 Alternative Model Path: Self-Hosted Llama

If the project partner requires stronger data privacy or local deployment, the project should migrate to a self-hosted Llama model.

The most plausible candidate is:

> **Llama 3.1 70B Instruct**

### Rationale

Llama 3.1 70B Instruct is attractive because it is:

- open-weight;
- self-hostable;
- reproducible as a fixed checkpoint;
- adaptable through fine-tuning or continued training;
- better suited for privacy-sensitive deployments;
- sufficiently capable for structured report generation if the evidence pack and prompt are well designed.

### Scope Trade-Off

A move from Claude 3.5 Sonnet to self-hosted Llama should be treated as a **scope decrease elsewhere**. This is important. Self-hosting is not simply a model swap; it introduces infrastructure, performance, and maintenance complexity.

Potential compensating scope reductions:

- use fewer macro indicators;
- use monthly rebalancing only, not monthly and quarterly;
- use a shorter evaluation period;
- simplify the report template;
- reduce the sentiment component to a single aggregate score;
- delay human evaluation of report quality;
- avoid fine-tuning in the first version;
- restrict allocation recommendations to discrete buckets.

Recommended discrete allocation buckets under a Llama-based reduced-scope version:

- 40% equities / 60% bonds,
- 50% equities / 50% bonds,
- 60% equities / 40% bonds,
- 70% equities / 30% bonds.

This makes the task easier, reduces output instability, and improves interpretability.

---

## 7. Allocation Constraints

The system should not output arbitrary portfolios. It should operate under explicit constraints.

Recommended constraints:

- equities and bonds only;
- no leverage;
- no shorting;
- equity weight between 20% and 80%;
- bond weight between 20% and 80%;
- weights sum to 100%;
- maximum turnover per rebalance, for example 10 percentage points;
- allocation rounded to 5 percentage-point increments.

The 5 percentage-point increment is useful because it prevents false precision. A recommendation such as 57.36% equities is not credible for this type of report system.

---

## 8. Benchmarks

The evaluation should use only two main benchmarks.

### Benchmark 1 — 50/50 Stock/Bond Allocation

This is the DeMiguel-style `1/N` benchmark adapted to a two-asset universe.

If the available assets are:

- equities,
- bonds,

then `N = 2`, so the naive allocation is:

- 50% equities,
- 50% bonds.

This benchmark is academically important because DeMiguel et al. show that simple naive diversification can be difficult to beat out of sample once estimation error and turnover are considered.

### Benchmark 2 — 60/40 Stock/Bond Allocation

This is the conventional balanced portfolio benchmark.

It is practically important because many investors and institutions use 60/40 as a natural reference point for balanced stock/bond exposure.

### Excluded Benchmarks

The first version should not include:

- risk parity;
- rolling mean-variance optimization;
- all-equity portfolio;
- all-bond portfolio;
- trend-following benchmark;
- valuation-based benchmark;
- macro timing benchmark.

These may be useful later, but they are excluded from the initial scope to keep the project focused.

---

## 9. Evaluation Design

## 9.1 Economic Evaluation

The economic evaluation should assess whether the recommended allocations perform competitively against 50/50 and 60/40.

For each rebalancing date `t`:

1. Stage 1 generates the evidence pack using only information available at or before `t`.
2. Stage 2 generates the report and allocation recommendation.
3. The recommended allocation is applied to the next holding period, for example `t+1` month.
4. Realized performance is measured after the holding period.

### Core Metrics

Use the following metrics:

- cumulative return;
- annualized return;
- annualized volatility;
- Sharpe ratio;
- maximum drawdown;
- turnover;
- transaction-cost-adjusted return;
- hit rate versus 50/50;
- hit rate versus 60/40.

Optional utility metric:

- certainty-equivalent return.

Certainty-equivalent return is useful because it connects the evaluation to the DeMiguel-style portfolio-choice literature, but it can be included as a secondary metric if the project needs to remain simple.

---

## 9.2 Report Quality Evaluation

The report should be evaluated separately from portfolio performance.

Suggested report-quality dimensions:

| Dimension | Evaluation question |
|---|---|
| Evidence grounding | Are all material claims supported by the evidence pack? |
| Decision clarity | Is the allocation recommendation explicit and understandable? |
| Consistency | Does the report rationale match the machine-readable allocation? |
| Risk awareness | Does the report include credible risks and counterarguments? |
| Temporal discipline | Does the report avoid post-decision-date information? |
| Usefulness | Would a human reviewer find the report decision-relevant? |

A simple scoring scale can be used:

- 1 = poor,
- 2 = weak,
- 3 = acceptable,
- 4 = good,
- 5 = excellent.

The report-quality score should not be confused with investment performance. A report can be well grounded and still recommend an allocation that underperforms. That distinction is important.

---

## 9.3 Leakage Control

LLM temporal leakage is a central methodological risk.

The evaluation should distinguish three layers:

### A. Quantitative backtest

The deterministic quantitative model can be backtested historically if all market and macro data are point-in-time or properly lagged.

### B. Full LLM-agent evaluation

The full report-generation system should preferably be evaluated only:

- after the model’s documented knowledge cutoff, and/or
- prospectively from the project start date onward.

### C. Historical LLM experiments

Historical LLM experiments before the model’s knowledge cutoff should be labeled exploratory, not clean evidence of predictive performance.

Strict rule:

> The LLM-generated report may only use evidence contained in the evidence pack. No material claim should rely on unstated model memory or future information.

---

## 10. Report Template

The report should be standardized to improve comparability across rebalancing periods.

Suggested template:

```markdown
# Stock–Bond Allocation Report

## 1. Metadata
- Decision date:
- Rebalancing horizon:
- Model:
- Evidence pack ID:
- Current allocation:
- Recommended allocation:
- Benchmarks: 50/50 and 60/40

## 2. Executive Summary
Short summary of the recommendation and the main reasons.

## 3. Recommended Allocation
Table showing current allocation, recommended allocation, and change.

## 4. Signal Dashboard
Summary of market, macro, rates, risk, and sentiment indicators.

## 5. Market and Macro Interpretation
Interpretation of the evidence pack.

## 6. Sentiment Interpretation
Summary of the sentiment signal and whether it supports or conflicts with quantitative indicators.

## 7. Investment Rationale
Explanation of why the recommendation follows from the evidence.

## 8. Risks and Counterarguments
Discussion of why the recommendation could be wrong.

## 9. Scenario Analysis
Soft landing, recession, inflation rebound, risk-on/risk-off scenarios.

## 10. Monitoring Triggers
Conditions under which the recommendation should change at the next rebalance.

## 11. Audit Trail
Sources, data timestamp, model version, prompt version, and constraints.
```

---

## 11. Proposed Minimum Viable Study

The minimum viable study should include:

- one equity proxy;
- one bond proxy;
- monthly rebalancing;
- 50/50 benchmark;
- 60/40 benchmark;
- Claude 3.5 Sonnet as report generator;
- one Alpha Vantage sentiment signal;
- one standardized report template;
- one machine-readable allocation record per period;
- evaluation of returns, volatility, Sharpe ratio, drawdown, and turnover;
- report-quality audit on a sample of generated reports.

This is already enough for a strong applied project. Additional complexity should only be added after this version works.

---

## 12. Expected Contribution

The expected contribution is an applied research prototype and evaluation framework for a **non-trading LLM-based allocation report system**.

The contribution has three parts:

1. **System contribution:** a two-stage architecture separating deterministic evidence generation from LLM-based report generation.
2. **Evaluation contribution:** a narrow and transparent comparison against 50/50 and 60/40 allocation baselines.
3. **Governance contribution:** explicit handling of LLM temporal leakage, data provenance, model versioning, and report auditability.

This contribution is more defensible than claiming that the LLM independently forecasts markets.

---

## 13. Strict Positioning Statement

The project should be described as:

> A controlled agentic reporting system for stock–bond allocation decisions, where deterministic tools generate a point-in-time evidence pack and an LLM generates a standardized investment report plus a constrained allocation recommendation. The system is evaluated against 50/50 and 60/40 benchmarks and is explicitly designed to avoid autonomous trading and minimize temporal leakage.

The project should not be described as:

> An autonomous LLM portfolio manager that uses news and macro data to beat the market.

That second framing is too broad, too risky, and methodologically weaker.

---

## 14. Key Design Decisions

| Decision | Final scoped choice |
|---|---|
| Primary output | Investment report plus allocation record |
| Trading | Out of scope |
| Asset universe | Stocks and bonds only |
| Pipeline | Two stages: evidence generation, then report generation |
| Primary LLM | Claude 3.5 Sonnet |
| Privacy fallback | Self-hosted Llama 3.1 70B Instruct |
| Sentiment source | Alpha Vantage `NEWS_SENTIMENT` |
| Main benchmarks | 50/50 and 60/40 |
| Rebalancing | Monthly by default; quarterly optional |
| Evaluation | Economic performance plus report quality |
| Leakage treatment | Point-in-time evidence pack and post-cutoff/prospective evaluation for full LLM system |
| Model freedom | Constrained allocation, no unconstrained optimization |

---

## 15. References and Source Notes

- DeMiguel, V., Garlappi, L., & Uppal, R. The project uses their `1/N` benchmark logic as the academic motivation for the 50/50 stock/bond baseline in a two-asset universe.
- Anthropic announced Claude 3.5 Sonnet in June 2024 and describes it as strong for complex instructions, high-quality writing, multi-step workflows, and long-context use.
- Anthropic’s model documentation emphasizes model versioning and the use of pinned model identifiers, which is relevant for reproducible evaluation.
- Meta’s Llama 3.1 model card describes Llama 3.1 as available in 8B, 70B, and 405B sizes, with a 128k context window, December 2023 knowledge cutoff, July 2024 release date, and static offline training status.
- Alpha Vantage documents the `NEWS_SENTIMENT` endpoint with topic filters such as `financial_markets`, `economy_monetary`, `economy_macro`, and `economy_fiscal`, plus `time_from` and `time_to` parameters for time-bounded news retrieval.

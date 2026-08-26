# Evidence Pack: Signal and Tool Catalogue

**Status:** open catalogue for signals and data. The *architecture* is now fixed; the
*content* is not.

**Closed decisions (24 Aug 2026)** — these are settled and this document assumes them:

| # | Decision |
|---|---|
| C1 | The pipeline is agentic. |
| C2 | The LLM is the aggregator. It weighs the evidence and emits the allocation itself. |
| C3 | The agent reaches data and tools on its own and reasons over what it retrieves, rather than receiving one static pack. |
| C4 | No Black-Litterman, no mean-variance step, no external optimiser between the model and the weights. The layer beneath the agent is a constraint validator only. |
| C5 | The two-stage structure of the v3 architecture diagram stands. |
| C6 | Evaluation is difference-first: establish whether the agent differs from a simple aggregator on identical evidence, then interpret the differences. |

Everything else remains a superset of candidates rather than a selection. No signal is
excluded for being expensive, hard to source, or weakly evidenced; sourcing and
inclusion decisions come later.

**Purpose.** Define what the Stage 1 evidence pack *could* contain so that Stage 2
(the LLM report layer) has the best possible chance of producing a defensible
stock/bond allocation. Each entry records what the signal is, where it can come
from (usually several options), how it behaves under point-in-time constraints,
the horizon it is documented to work at, and how strong the published evidence is.

---

## 0. Framing: what "outperformance" can and cannot mean here

Stated up front because it drives signal selection.

The published record on aggregate return prediction is harsh:

| Finding | Source |
|---|---|
| Of 29 predictors from 26 post-2008 papers plus the original 17: more than a third lose in-sample significance; of the survivors, half fail out-of-sample. A small number survive both. | Goyal, Welch & Zafirov (2024), *RFS* 37(11) |
| Volatility-managed portfolios are not implementable in real time. Across 103 equity strategies the managed version wins 53, the unmanaged 50. | Cederburg, O'Doherty, Wang & Yan (2020), *JFE* |
| The Cochrane-Piazzesi forward-rate factor has large in-sample R² but produces no out-of-sample Sharpe or utility gain for a mean-variance investor. | Thornton & Valente (2012) |
| Asset-by-asset regressions show little evidence of time-series momentum in or out of sample; the strategy performs about as well as one requiring no predictability. | Huang, Li, Wang & Zhou (2020), *JFE* 135(3) |

Three further results that should shape how any signal is graded:

- **Post-publication decay is quantified.** McLean & Pontiff (2016, *JF* 71(1)) across
  97 predictors: returns are 26% lower out-of-sample and 58% lower post-publication,
  implying roughly 32% decay attributable to publication itself. Favour signals with an
  economic risk-premium rationale, which decay less.
- **The significance bar is higher than t=2.** Harvey, Liu & Zhu (2016, *RFS*) argue a
  new factor needs t > 3.0 given the multiple testing embedded in the literature.
- **The real-world track record is dismal.** Morningstar (decade to April 2023): the
  average tactical allocation fund returned 2.3% p.a., roughly a third of a US 60/40
  mix; 22 of 34 funds died over the period; among the twelve survivors, not one beat
  60/40 on return or Sharpe. Category expense ratios average 1.55%. This is the honest
  outside view on what the project is attempting.

Combined with the project's own constraint (backtest starts after the model's
knowledge cutoff, giving roughly 10-30 decisions), statistical outperformance is
not establishable. Selecting signals by whether they beat 60/40 in that sample is
fitting ~30 observations with a library of ~50 candidates.

So outperformance is treated as a **design objective** (build what a real allocator
would want, using signals with the best documented record) rather than as a
measured success criterion. The proposal's existing honest evaluation framing stays.

**Where durable edge plausibly lives in a two-asset problem:**

1. **Risk control rather than return prediction.** Volatility is persistent and
   forecastable in a way returns are not. Most robust Sharpe improvement in
   stock/bond allocation comes from scaling equity exposure to risk.
2. **The stock-bond correlation regime.** Campbell, Pflueger & Viceira (2020, *JPE*)
   show the sign of the stock-bond correlation is driven by the inflation/output-gap
   relationship, and flipped in 2001. It flipped back positive in 2022 for the first
   time since roughly 1998, which is why 60/40 had its worst year in decades. AQR
   (Brixton, Brooks, Hecht, Ilmanen, Maloney & McQuinn 2023, *JPM* 49(4), "A Changing
   Stock-Bond Correlation") give the operational version: their model, driven by the
   relative volatility of growth versus inflation shocks, explains around 70% of
   long-term variation in the US stock-bond correlation with similar results
   internationally, while explaining short-term fluctuations much less well. A 60/40
   benchmark silently assumes bonds hedge equities. Detecting when that assumption
   breaks is economically real, not mined, and it is the most defensible reason a
   dynamic stock/bond system should exist at all.
3. **Bond carry.** Starting yield mechanically explains most of subsequent long-horizon
   bond returns. Identity plus reinvestment, not a fitted regression.
4. **Regime-conditional signal weighting.** A fixed rule weights momentum the same in
   a vol spike as in a calm trend. This is where an LLM could plausibly beat a linear
   rule, and making it testable is the project's actual research contribution.

---

## 1. Pack envelope: decisions about form, not content

These are structural choices that let the pack stay flexible. They do not commit to
any signal.

### 1.1 Every signal is a self-describing record

Qualitative labels alone (`"equity_momentum": "positive"`) destroy information and
hard-code the designers' thresholds into the pack. The thresholds that turn 8.2%
into "positive" *are* the allocation policy. It also contaminates the LLM-vs-rule
comparison, since both then consume the same human judgment.

Proposed record shape (fields optional, add freely):

```json
{
  "id": "equity_mom_12_1",
  "block": "trend",
  "value": 0.082,
  "unit": "total return, 12m excluding most recent month",
  "pctile_expanding": 0.71,
  "z_expanding": 0.58,
  "history_start": "1990-01-31",
  "as_of": "2027-03-31",
  "vintage": "2027-03-31",
  "revision_risk": "none",
  "documented_sign": "positive -> higher expected equity excess return",
  "documented_horizon": "1-12m",
  "evidence_grade": "contested",
  "evidence_note": "Huang et al. (2020) find asset-by-asset evidence weak",
  "source": "CRSP / FRED SP500",
  "label": "above median, weakening"
}
```

The label is kept, but alongside the number, never instead of it.

### 1.2 Normalisation is expanding-window only

Percentiles and z-scores computed on an expanding window ending strictly before the
decision date. Full-sample normalisation is the most common silent leak in this kind
of work.

### 1.3 Point-in-time is a property of the record, not the pipeline

Each record states its own vintage and revision risk. Three classes:

- **No revision** (market prices, yields, spreads, VIX): as-of = vintage.
- **Revised** (GDP, payrolls, CPI, industrial production): must come from a vintage
  store. FRED API supports this via `realtime_start` / `realtime_end` and
  `series/vintagedates`; ALFRED exists for exactly this.
- **Constructed** (CAPE, EBP, term premium estimates): the model that constructs them
  was itself estimated on some sample. Note whether the published series is
  retroactively recomputed. Most are. Flag it.

### 1.4 Reliability metadata travels with the signal

Each signal carries an evidence grade and, where computable, its own expanding-window
OOS R² and hit rate. This gives the LLM a legitimate basis for downweighting a signal,
which a fixed linear rule structurally cannot do. It is also the governance story made
concrete. This does not appear to exist in the LLM-finance literature.

### 1.5 Disagreement is a first-class field

Explicitly compute how much blocks conflict (trend risk-on vs credit risk-off).
Conflicting evidence is precisely where a fixed rule is arbitrary and reasoning might
add value. With ~30 decisions you cannot test performance, but you can characterise
behaviour conditional on disagreement.

### 1.6 Versioned and hashed

Three hashes go into the audit record: the store snapshot, the briefing, and the
realized pack (briefing plus the full tool trace, see section 3.1). Together with the
pinned model identifier, prompt version and generation settings, that is enough to
reconstruct any recommendation after the fact.

Sentiment and any API-sourced text is retrieved once with hard time bounds and written
into the frozen store, never re-fetched at run time.

---

## 2. Signal catalogue

Evidence grades: **strong** (survives OOS scrutiny or is close to mechanical),
**moderate** (documented but contested), **contested** (published, later challenged),
**exploratory** (plausible, thin or no aggregate-level evidence), **short-history**
(evidence unavailable because the series is young).

### Block A — Risk and uncertainty

Highest expected value. Volatility forecasting is the one thing that reliably works.

| Signal | Definition | Sources | Freq | PIT | Horizon | Grade |
|---|---|---|---|---|---|---|
| Realized equity vol 21d / 63d / 252d | annualised stdev of daily log returns | any price feed | D | clean | 1m | strong |
| Vol acceleration | ratio of 21d to 252d realized vol | derived | D | clean | 1m | strong |
| VIX level and percentile | CBOE implied vol | FRED `VIXCLS`, CBOE | D | clean | 1-3m | strong |
| VIX term structure slope | VIX9D / VIX / VIX3M / VIX6M | CBOE | D | clean | 1m | moderate |
| **Variance risk premium** | VIX² minus realized variance | derived | D/M | clean | **quarterly** | moderate-strong |
| Realized bond vol | on 10y futures or agg index | prices | D | clean | 1m | strong |
| MOVE index | implied Treasury vol | ICE / Bloomberg (licensed) | D | clean | 1m | moderate |
| **Realized stock-bond correlation** | 63d and 252d rolling | derived | D | clean | 1-12m | strong |
| Correlation regime change | sign flip / rolling-window break test | derived | M | clean | 1-12m | moderate |
| **Growth-vs-inflation shock vol ratio** | AQR correlation model driver: relative volatility of growth and inflation shocks | derived from FRED vintages | Q | revised | 1-5y | moderate-strong (explains ~70% of long-run correlation variation) |
| Equity drawdown from peak | trailing max drawdown | prices | D | clean | n/a | mechanical |
| Downside/upside vol ratio | semi-deviation asymmetry | prices | D | clean | 1m | exploratory |
| Realized skew and kurtosis | higher moments of daily returns | prices | D | clean | 1-3m | exploratory |
| Options skew / SKEW index | OTM put vs call implied vol | CBOE | D | clean | 1-3m | exploratory |
| Jump/tail measure | bipower variation, jump component | intraday | D | clean | 1-3m | exploratory |
| VVIX / vol-of-vol | implied vol of VIX | CBOE | D | clean | 1-3m | exploratory |
| **Martin SVIX lower bound** | option-implied lower bound on the equity premium | derived from SPX options | D/M | clean | 1-12m | moderate (Martin 2017, *QJE*; theory-grounded) |

The variance risk premium is worth flagging: Bollerslev, Tauchen & Zhou (2009, *RFS*)
report it explains over 15% of quarterly return variation 1990-2005 and dominates P/E,
default spread and cay. Crucially it is strongest at the **quarterly** horizon, which
is an argument in favour of quarterly rather than monthly rebalancing. Later work has
moderated the magnitude.

### Block B — Regime, financial conditions, credit

The differentiator for a stock/bond system. Answers: is the bond leg still a hedge?

| Signal | Definition | Sources | Freq | PIT | Horizon | Grade |
|---|---|---|---|---|---|---|
| Chicago Fed NFCI | broad financial conditions | FRED `NFCI` | W | revised | 1-12m | moderate |
| Adjusted NFCI | NFCI orthogonalised to growth/inflation | FRED `ANFCI` | W | revised | 1-12m | moderate |
| **Excess bond premium** | credit spread net of expected default | Fed FEDS Notes, updated monthly | M | recomputed | 3-12m | strong |
| GZ credit spread | Gilchrist-Zakrajsek spread level | Fed | M | recomputed | 3-12m | strong |
| HY OAS and 3m change | ICE BofA US HY option-adjusted spread | FRED `BAMLH0A0HYM2` | D | clean | 1-12m | moderate-strong |
| IG OAS and 3m change | ICE BofA US Corporate OAS | FRED `BAMLC0A0CM` | D | clean | 1-12m | moderate |
| BAA-AAA spread | classic default spread | FRED `BAA`, `AAA` | D | clean | 1-12m | contested (GW: weak OOS) |
| TED spread / SOFR-OIS | funding stress | FRED | D | clean | 1-3m | moderate |
| St. Louis Fed Financial Stress Index | composite | FRED `STLFSI4` | W | revised | 1-12m | moderate |
| Kansas City Fed FSI | composite | FRED `KCFSI` | M | revised | 1-12m | moderate |
| **Trailing core CPI YoY** | inflation regime level | FRED, ALFRED vintages | M | **revised** | 1-12m | strong (regime) |
| Inflation volatility | rolling stdev of CPI YoY | derived | M | revised | 1-12m | moderate |
| 5y5y forward breakeven | market inflation expectations | FRED `T5YIFR` | D | clean | 1-12m | moderate |
| 10y breakeven | market inflation expectations | FRED `T10YIE` | D | clean | 1-12m | moderate |
| **Inflation-output gap correlation** | rolling corr, CPV regime detector | derived from FRED vintages | Q | revised | 1-12m | strong (theory) |
| ADS Business Conditions Index | real-time growth nowcast | Philadelphia Fed | D | real-time by construction | 1-6m | moderate |
| Real-time Sahm rule | unemployment-based recession trigger | FRED `SAHMREALTIME` | M | real-time by construction | 0-12m | moderate |
| Unemployment gap | u minus CBO NAIRU | FRED | M | revised | 3-12m | moderate |
| ISM / S&P Global PMI | survey diffusion index | ISM (licensed), S&P Global | M | minor revision | 1-6m | moderate |
| OECD Composite Leading Indicator | international growth signal | OECD | M | heavily revised | 3-12m | contested |
| Chicago Fed National Activity Index | 85-indicator growth composite | FRED `CFNAI` | M | revised | 3-12m | moderate |
| Term spread 10y-3m | canonical recession predictor | FRED `T10Y3M` | D | clean | 6-18m | moderate |
| Term spread 10y-2y | curve slope | FRED `T10Y2Y` | D | clean | 6-18m | moderate |
| Curve curvature | 2y-10y-30y butterfly | FRED | D | clean | 3-12m | exploratory |
| Near-term forward spread | Engstrom-Sharpe alternative to 10y-3m | Fed | D | clean | 6-18m | moderate |
| Real fed funds rate | policy stance | FRED | M | revised | 3-12m | moderate |
| Policy surprise | fed funds futures implied path vs. SEP dots | CME, Fed | M | clean | 1-6m | exploratory |
| Money growth / credit impulse | M2, bank credit change | FRED | M | revised | 6-18m | contested |
| Dollar index level and momentum | broad trade-weighted USD | FRED `DTWEXBGS` | D | clean | 1-12m | exploratory |
| Oil price level and 12m change | inflation input | FRED `DCOILWTICO` | D | clean | 1-12m | exploratory |
| Commodity index momentum | broad commodity trend | Bloomberg/S&P GSCI | D | clean | 1-12m | exploratory |
| **NY Fed recession probability** | Estrella-Mishkin 10y-3m probit, published monthly | NY Fed (free) | M | recomputed | 6-24m | moderate-strong (has preceded every US recession since 1969; one near-miss 1998) |
| Atlanta Fed GDPNow | GDP nowcast | Atlanta Fed (free) | ~weekly | real-time by construction | 0-3m | moderate |
| NY Fed Staff Nowcast | GDP nowcast | NY Fed (free) | weekly | real-time by construction | 0-3m | moderate |
| Conference Board LEI | 10-component leading index | Conference Board (licensed) | M | revised | 3-12m | moderate |
| Initial jobless claims (4wk MA) | high-frequency labour signal | FRED `ICSA` | W | minor revision | 1-6m | moderate |
| Copper/gold ratio | growth-vs-fear proxy | prices | D | clean | 3-12m | exploratory |

### Block C — Valuation and carry

Long-horizon anchors. Weak at monthly horizon. Include with an explicit
`documented_horizon` field so the LLM does not over-trade CAPE.

| Signal | Definition | Sources | Freq | PIT | Horizon | Grade |
|---|---|---|---|---|---|---|
| CAPE / Shiller P/E | 10y inflation-adjusted earnings yield | Shiller online data (free) | M | recomputed | 5-10y | moderate long-horizon, weak monthly |
| Trailing E/P | earnings yield | Shiller, Compustat | M | revised | 1-5y | contested (GW: e/p fails) |
| Dividend-price ratio | D/P | Goyal predictor dataset, Shiller | M | clean-ish | 1-5y | contested (GW: some power) |
| Dividend yield | D/Y | as above | M | clean-ish | 1-5y | contested |
| Book-to-market | aggregate B/M | Goyal dataset | M | revised | 1-5y | contested |
| Net equity expansion (ntis) | issuance minus repurchase | Goyal dataset | M | revised | 1-5y | contested (fails post-2008) |
| CAPE yield minus 10y real yield | real-yield-adjusted equity risk premium | derived | M | mixed | 1-5y | moderate |
| Nominal Fed model gap | E/P minus 10y nominal | derived | M | clean | 1-5y | weak (Asness 2003: conflates real and nominal) |
| **10y nominal yield** | bond carry | FRED `DGS10` | D | clean | 5-10y | strong (near-mechanical) |
| **10y real yield** | TIPS yield | FRED `DFII10` | D | clean | 5-10y | strong |
| ACM term premium | Adrian-Crump-Moench decomposition | NY Fed | D | recomputed | 1-5y | moderate |
| Kim-Wright term premium | alternative decomposition | Fed | D | recomputed | 1-5y | moderate |
| Cochrane-Piazzesi factor | tent-shaped forward rate combination | derived from FRED/GSW | M | recomputed | 1y | contested (Thornton-Valente: no OOS value) |
| Ludvigson-Ng macro factors | PCA over large macro panel | derived from FRED-MD | M | revised | 1y | contested |
| Agg index duration and convexity | interest rate sensitivity of the bond leg | index provider | M | clean | n/a | mechanical |
| Roll-down / carry on the curve | expected return from curve shape | derived | D | clean | 1-12m | moderate |
| CAPE vs its own trailing average | de-trended valuation | derived from Shiller | M | recomputed | 1-5y | moderate (better than raw CAPE as a timing input) |
| P-CAPE / payout-adjusted CAPE | CAPE corrected for changing payout policy | derived | M | recomputed | 5-10y | exploratory |
| Fair-value CAPE | CAPE adjusted for the level of real yields | derived | M | recomputed | 1-5y | exploratory |
| Damodaran implied ERP | DCF-implied equity risk premium | Damodaran site (free, monthly) | M | recomputed | 1-5y | moderate |
| CAY (consumption-wealth ratio) | Lettau-Ludvigson cointegrating residual | FRED / Ludvigson site | Q | **recomputed with full-sample cointegrating vector** | 1-4q | contested (well-documented look-ahead problem in the standard series) |
| Kelly-Pruitt 3PRF | three-pass regression filter over many predictors | derived | M | recomputed | 1-12m | exploratory |

### Block D — Trend and momentum

Best framed as drawdown control, which is its most durable documented property, rather
than as return prediction.

| Signal | Definition | Sources | Freq | PIT | Horizon | Grade |
|---|---|---|---|---|---|---|
| Equity 12-1m total return | time-series momentum | prices | M | clean | 1-12m | contested (Huang et al. 2020) |
| Equity 6-1m, 3-1m | shorter lookbacks | prices | M | clean | 1-6m | contested |
| Price vs 200d MA | trend filter | prices | D | clean | 1-6m | moderate |
| Price vs 10-month MA | Faber-style trend filter | prices | M | clean | 1-6m | moderate |
| MA crossover (1-9, 2-12 etc.) | Neely et al. technical indicator set | prices | M | clean | 1-6m | moderate |
| Momentum of momentum / acceleration | second difference of trend | prices | M | clean | 1-3m | exploratory |
| Bond 12-1m total return | duration trend | prices | M | clean | 1-12m | contested |
| Equity-minus-bond relative 12m | cross-asset relative strength | derived | M | clean | 1-12m | exploratory |
| On-balance-volume / volume trend | Neely et al. volume indicator | prices+volume | M | clean | 1-6m | moderate |
| 52-week high proximity | distance from trailing high | prices | D | clean | 1-6m | exploratory |

Neely, Rapach, Tu & Zhou (2014, *Management Science*) find technical indicators
complement macro variables and perform best around business-cycle peaks. That is a
regime-conditional claim, which fits the LLM-weighting research angle directly.

**On grading trend `contested`.** Huang et al. (2020) attack time-series momentum as
*predictability*: asset-by-asset, the forecasting evidence is weak. Hurst, Ooi &
Pedersen (2017, *JPM*, "A Century of Evidence on Trend-Following Investing") document
the opposite side of the same coin as a *strategy*: across 67 markets, 1880-2016,
positive average returns in every market at roughly 0.4 Sharpe, and positive returns in
8 of the 10 largest peak-to-trough drawdowns of a 60/40 portfolio. Faber (2007, updated
2013) shows a 10-month SMA switch producing equity-like returns with bond-like
drawdowns; his GTAA5 held 2008 to roughly a 12% drawdown against 40%+ for static 60/40.

These are consistent, and together they justify the framing used here: **trend is
drawdown control ("crisis alpha"), not return prediction.** That is the property worth
carrying into the pack.

Counterweight: Zakamulin (2017, *Market Timing with Moving Averages*) shows all
moving-average rules reduce to weighted moving averages of past price changes, that
parameter choice is a data-mining surface, and that some published MA results contain
look-ahead bias. So: pick the lookback ex ante from the literature (10-month SMA, 12-1
momentum), never by search.

### Block E — Text and sentiment

The project's stated novelty. Three structural points before the list.

**Extract change and surprise, not level.** News sentiment is highly autocorrelated;
the level is largely a slow-moving fixed effect. Calomiris & Mamaysky (2019, *JFE*)
find it is topic-specific sentiment plus *frequency* and *unusualness* that predict
returns, volatility and drawdowns. So: tone level, tone change vs prior window,
cross-article dispersion, article volume vs its own normal, topic shares.

**Alpha Vantage alone is a single point of failure.** Its news feed history is shallow
(exact start date needs verifying against the docs; reports suggest roughly 2022
onward). Shallow history means no meaningful percentiles or conditional statistics for
this block, which is most of its value. Pair it with a long-history backbone.

**Never expose raw headlines to the LLM.** A headline about a specific bank failure or
Fed meeting instantly dates the pack and destroys leakage control. Aggregate statistics
only, or strictly current-window text with enforced timestamps. This is the
asset-allocation analogue of the entity anonymization used in the LLM look-ahead
literature (section 4.2).

**On the strength of the text evidence.** Bybee, Kelly, Manela & Xiu (2024, *JF* 79(5))
extract topic attention from roughly 800,000 WSJ articles 1984-2017 and find news
attention tracks a wide range of economic activity and explains 25% of aggregate stock
market returns. That is the strongest aggregate-level text result available and a much
better anchor for this block than generic sentiment scoring.

**Alternative data is deprioritised, deliberately.** Satellite imagery, card
transactions, web traffic, app downloads, shipping/AIS, Google Trends, social media.
Almost all documented alt-data alpha is single-stock and does not aggregate to an
index-level allocation signal. The canonical index-level claim, Preis, Moat & Stanley
(2013) Google Trends "debt", selected over 98 search terms and relies on a
non-deterministic sampling API; it is not robustly replicable. Listed here for
completeness, not recommended.

| Signal | Definition | Sources | Freq | PIT | History | Grade |
|---|---|---|---|---|---|---|
| Aggregate news tone | mean sentiment score over window | Alpha Vantage `NEWS_SENTIMENT` | D | bounded by `time_from`/`time_to` | ~2022+ | short-history |
| Tone change vs prior window | first difference of the above | derived | D | clean | ~2022+ | short-history |
| Sentiment dispersion | cross-article stdev | derived | D | clean | ~2022+ | short-history |
| Article volume vs normal | attention spike measure | derived | D | clean | ~2022+ | moderate |
| Topic shares | monetary / macro / fiscal / markets mix | Alpha Vantage topic filters | D | clean | ~2022+ | exploratory |
| **GDELT tone and themes** | global news tone, thematic counts | GDELT (free) | 15min | archived | **1979+** | exploratory but long history |
| GDELT unusualness / entropy | Calomiris-Mamaysky style surprise measure | derived from GDELT | D | clean | 1979+ | moderate |
| **Economic Policy Uncertainty** | Baker-Bloom-Davis newspaper index | FRED `USEPUINDXD` | D | clean | 1985+ | moderate |
| Geopolitical Risk index | Caldara-Iacoviello | free, monthly + daily | D/M | clean | 1900+ | exploratory |
| NVIX (news-implied volatility) | Manela-Moreira text-based VIX proxy | free dataset | M | recomputed | 1890+ | moderate |
| **FOMC statement/minutes tone** | Loughran-McDonald or LLM scoring of Fed text | Fed website (free, perfectly timestamped) | per meeting | clean | 1994+ | moderate |
| Fed speech tone | central bank communication | Fed, BIS speech archive | irregular | clean | long | exploratory |
| Beige Book sentiment | regional conditions narrative | Fed (free) | 8/yr | clean | 1970+ | exploratory |
| 10-K/10-Q risk-factor change | aggregate corporate risk language | SEC EDGAR full-text (free) | Q | clean, timestamped | 1993+ | exploratory |
| Earnings call transcript tone | aggregate management sentiment | Alpha Vantage, licensed vendors | Q | vendor-dependent | 15y (AV) | exploratory |
| Baker-Wurgler sentiment index | composite investor sentiment | Wurgler website (free) | M | recomputed | 1965+ | contested |
| AAII bull-bear spread | retail survey | AAII (free) | W | clean | 1987+ | contested |
| Investors Intelligence | advisor survey | licensed | W | clean | 1963+ | contested |
| Put/call ratio | options positioning | CBOE | D | clean | long | exploratory |
| CFTC Commitments of Traders | futures positioning in ES and Treasuries | CFTC (free) | W | clean, lagged 3d | 1986+ | exploratory |
| Google Trends recession/inflation | search attention | Google (free) | W | recomputed, unstable | 2004+ | exploratory |
| Fund flows equity vs bond | ICI / EPFR flows | ICI free, EPFR licensed | W | clean | long | exploratory |
| **News attention shares** | Bybee-Kelly-Manela-Xiu topic attention over WSJ text | replicable from news corpora | M | clean | 1984+ | moderate-strong |
| Recession-conditional news tone | Garcia (2013): news sentiment predicts returns mainly *in recessions* | derived | D/M | clean | long | moderate (regime-conditional) |
| Lazy Prices signal | year-on-year textual change in 10-K/10-Q language | SEC EDGAR (free) | Q | clean | 1993+ | exploratory at index level |

### Block F — Portfolio state and action space

Not predictive, but required for the decision to be well-posed.

| Field | Notes |
|---|---|
| Current weights | after drift since last rebalance |
| Drift since last rebalance | how far the portfolio moved on its own |
| Distance from each benchmark | vs 50/50 and vs 60/40 |
| Remaining turnover budget | if a per-period cap is imposed |
| Transaction cost assumptions | bps per unit turnover, stated ex ante |
| Admissible action set | e.g. 5pp increments, 20-80% equity band, no leverage, no shorting |
| Prior recommendation and realized outcome | include as an ablation arm, not a default: may aid calibration or induce performance chasing. Testing which is a cheap result |
| Rebalance calendar | fixed ex ante, never signal-dependent |

### Block G — Derived / composite

| Signal | Definition | Grade |
|---|---|---|
| **Equal-weight combination forecast** | mean of individual signal forecasts, sign-constrained non-negative | moderate (Rapach-Strauss-Zhou 2010; Campbell-Thompson 2008) |
| Block-level composites | one z-score per block (risk, regime, valuation, trend, sentiment) | structural |
| Cross-block disagreement | dispersion across block composites | structural |
| Regime classification | discrete label from inflation regime + correlation sign + financial conditions | moderate (CPV theory) |
| Conditional base rates | next-period equity-minus-bond excess return distribution given current bucket of each signal, with n and sample-half stability | see note below |

**Note on conditional base rates.** For each signal, computed strictly on data before
the decision date: current bucket, historical mean/median/p10 of next-period
equity-minus-bond excess return conditional on that bucket, observation count, and
whether the relationship holds in both sample halves. This converts the LLM from a
narrative generator into a base-rate aggregator and makes every claim in the report
auditable to a number. Kept as an ablation arm so its contribution is measurable
rather than assumed.

---

## 3. Agent interface: how the LLM reaches data and tools

**Fixed by decision (24 Aug 2026):** the pipeline is agentic, the LLM is the aggregator,
and it reaches data and tools itself. There is no Black-Litterman step and no external
optimiser sitting between the model and the weights. The two-stage shape of
`docs/master/diagrams/v3_architecture.svg` is unchanged; what changes is that the arrow
from Stage 1 to Stage 2 becomes a loop rather than a single handoff.

### 3.1 What "evidence pack" now means

Under agent-driven retrieval the pack is three artifacts, not one.

| Artifact | What it is | When it exists |
|---|---|---|
| **Sealed substrate** | frozen point-in-time store; every value carries a vintage. The only thing tools may read | built once, offline, before any run |
| **Briefing** | compact opening context: universe, portfolio state, constraints, signal manifest, block composites | assembled per decision date |
| **Realized pack** | the briefing plus the complete ordered trace of tool calls and returns | produced by the run; this is the audit artifact |

The audit record required by Objective 1 is the **realized pack**. This is stronger than
a static pack, not weaker: it records not only what evidence existed but what the agent
actually chose to look at.

That difference creates an observable a static design cannot produce: **retrieval
behaviour**. Which signals did the agent request, in what order, how many, and did that
change with the regime or with the level of disagreement in the evidence? Nothing in the
LLM-finance literature reports this. It costs nothing once the trace is logged and it is
a plausible standalone section of the final report.

### 3.2 Safety invariants

Non-negotiable. Each is enforced in code, not by prompt instruction.

1. **The decision date is injected by the harness, never passed by the agent.** No tool
   signature accepts a date. This is the single most important invariant: an agent that
   can name a date can name a future one.
2. **Tools read the frozen store only.** No tool hits a live API during a run. Leakage
   then becomes a property of how the store was built, which can be tested once and for
   all, rather than a property of the agent loop, which cannot.
3. **Every returned value carries its vintage.** Filtering is `vintage <= t`, applied in
   the store layer, below the tool layer.
4. **No tool returns raw article text, headlines, absolute index levels, or calendar
   dates** when the anonymised arm is active. Relative quantities only.
5. **Every call is logged**: name, arguments, return, ordinal position, latency.
6. **The rule-based baseline's output is never visible to the agent.** See 3.3.
7. **A hard call budget per decision.** See 3.5.

### 3.3 The briefing

What the agent starts with, without spending a tool call. Kept deliberately thin: the
briefing exists so the agent knows what exists and where to start, not so it can skip
retrieval.

| Field | Why it is in the briefing |
|---|---|
| Decision index and rebalancing horizon | needed to reason about holding period; an opaque index rather than a real date in the anonymised arm |
| Universe and benchmarks | 50/50 and 60/40 definitions |
| Current portfolio state | weights, drift since last rebalance, distance from each benchmark |
| Constraint set and admissible action space | bands, increments, turnover cap, no leverage, no shorting |
| **Signal manifest** | every available signal id with a one-line description, block, evidence grade, and availability flag. This is how the agent knows what to ask for |
| Block composite z-scores | five numbers, one per block, so budget is not wasted locating the interesting block |
| Cross-block disagreement score | one number; flags whether the evidence is coherent or conflicted |

**Not in the briefing, deliberately:**

- **The rule-based allocator's recommendation.** This is a correction to an earlier
  version of this document, which suggested shipping the combination forecast so that
  deviation from it would be clean. Under the difference-first evaluation in section 4.3
  that is backwards: if the agent sees the rule's answer, any measured difference is
  confounded by anchoring, and you are measuring willingness to deviate from an anchor
  rather than independent judgment. Keep it hidden. It may be shown in a separate
  ablation arm, labelled as such.
- Raw signal values. Those cost a call. That is the point.
- Anything about past performance of the system itself, unless running the feedback
  ablation.

### 3.4 Tool API

Signatures are indicative, not final. All are pure functions of the store at `t`, with
`t` bound by the harness.

**Discovery**

| Tool | Returns |
|---|---|
| `list_signals(block=None, min_grade=None)` | signal ids with description, block, evidence grade, availability. Free, does not count against budget |

**Retrieval**

| Tool | Returns |
|---|---|
| `get_signals(ids: list[str])` | the self-describing records from section 1.1. Batched, so one call can pull many |
| `get_signal_history(id, lookback)` | summarised recent history (level, change, percentile path), not raw daily series |
| `get_block(block)` | composite plus every constituent record in one call |

**Context and base rates**

| Tool | Returns |
|---|---|
| `get_conditional_outcomes(id)` | current bucket, historical next-period equity-minus-bond excess return distribution given that bucket, n, sample-half stability |
| `get_historical_analogues(ids, k)` | k most similar past dates under a metric fixed ex ante, with realized forward outcomes |
| `get_regime()` | deterministic regime label plus its components (inflation regime, correlation sign, financial conditions) |
| `get_benchmark_stats(window)` | realized 50/50 and 60/40 statistics over a past window |

**Decision support**

| Tool | Returns |
|---|---|
| `get_portfolio_state()` | duplicate of the briefing field, for agents that ask rather than read |
| `simulate_allocation(weights)` | ex-ante portfolio vol, turnover, transaction cost, distance to benchmarks, worst historical one-period outcome in comparable regimes |
| `check_constraints(weights)` | pass/fail plus specific violations |

**Submission**

| Tool | Returns |
|---|---|
| `submit_decision(weights, confidence, evidence_refs, rationale)` | terminates the episode; validates constraints before accepting |

`evidence_refs` is the important field. Requiring the agent to name the signal ids and
tool calls that support its recommendation makes grounding **machine-checkable** rather
than a manual audit. Two metrics follow automatically:

- **Citation precision** — does every cited id appear in the agent's own retrieval trace?
- **Citation coverage** — of the signals that actually moved materially this period, how
  many did the agent cite?

That turns Objective 3 from an aspiration into a computed number, which matters for a
deliverable weighted at 65%.

**Explicitly out of bounds for any tool:** web search, code execution, any
date-parameterised call, anything returning data after `t`, anything returning raw
article text.

### 3.5 Call budget

Cap tool calls per decision, e.g. 15-25 excluding `list_signals`.

Without a cap the agent pulls everything, which reproduces the static pack with extra
latency and destroys the retrieval-behaviour observable. With a cap the agent must
choose, and choosing is the behaviour worth measuring. The budget is also a clean
ablation axis: does behaviour, stability, or the LLM-vs-rule difference change as the
budget varies?

### 3.6 Building the substrate before the tools

Practical consequence and probably the first ADR: **build the frozen point-in-time store
first, then the tools are trivially safe.** A store keyed by
`(signal_id, as_of_date, vintage_date, value)` with tool queries filtering
`vintage_date <= t` makes leakage impossible by construction. If instead tools call live
APIs, every tool is an independent leakage risk that has to be argued rather than proven.

---

## 3b. Deterministic machinery behind the tools

The LLM is the aggregator, so nothing here decides weights. These are the calculations
that produce what the tools return.

### 3b.1 Regime labelling

| Method | Notes |
|---|---|
| **Deterministic threshold label** | regime = f(inflation regime, correlation sign, financial conditions). Zero estimation fragility, fully auditable, cannot over-switch. Recommended baseline |
| Markov-switching (Hamilton 1989, *Econometrica*) | foundational; documented local-maxima and sample-sensitivity problems |
| Joint stock/bond four-state model (Guidolin & Timmermann 2007, *JEDC*) | crash / slow growth / bull / recovery; finds stock-bond correlation changing sign across regimes. The most on-topic regime paper for this system |
| Turbulence / growth / inflation regimes (Kritzman, Page & Turkington 2012, *FAJ*) | dynamic beat static in backtests, especially for loss-averse investors |
| HMM + MPC allocation (Nystrup et al. 2015-2018) | higher return, materially lower risk than buy-and-hold after costs and a one-day lag |
| Statistical jump models (Shu, Yu & Mulvey 2024) | explicit switching penalty, designed to reduce over-switching |

Consistent finding: regime methods reliably reduce **drawdowns** out of sample by
de-risking before or into bear regimes. Consistent caveat: estimation is fragile and
over-switching destroys net returns after costs.

**Scope note.** Fitting and validating an HMM is a real scope risk for a 300-360 h per
person project already carrying an agent loop, an evaluation harness and a
report-quality audit. The deterministic label encodes the same CPV/AQR economics and is
auditable. Treat HMM as a stretch goal or an ablation arm.

### 3b.2 The weight layer

The LLM emits weights directly via `submit_decision`. The layer beneath it is a
**validator, not an optimiser**:

- clamp to the allocation band (e.g. 20-80% equity);
- round to the fixed increment (5pp);
- enforce the per-period turnover cap;
- reject and return violations rather than silently correcting, so that a rejected
  attempt is visible in the trace.

Rounding to 5pp increments matters: a recommendation of 57.36% is false precision for a
system of this kind, and discretisation reduces output instability, which section 4.3
depends on.

No Black-Litterman, no mean-variance step, no view-to-weight mapping. Recorded as a
closed decision; the alternatives considered are kept in section 5 only as a record of
what was rejected and why.

### 3b.3 Risk and covariance estimation

Feeds `simulate_allocation` and the correlation signals. The stock-bond correlation is
central to the whole thesis, so the estimator choice is not cosmetic.

| Method | Notes |
|---|---|
| Sample covariance, rolling window | baseline; noisy |
| Ledoit-Wolf shrinkage | standard fix, near-free improvement |
| EWMA | responsive to regime change, one decay parameter |
| DCC-GARCH | explicitly models time-varying correlation, which is the quantity of interest |
| Realized covariance from daily data | model-free, needs a window choice |

### 3b.4 Combination, shrinkage, costs

Feeds the rule-based baseline and the `simulate_allocation` cost model.

- Equal-weight combination across signals (Rapach-Strauss-Zhou 2010) is the natural
  form of the no-LLM baseline: same evidence, fixed weighting, no reasoning.
- Campbell-Thompson (2008) sign and magnitude constraints. An out-of-sample R² around
  0.5% monthly is considered good in this literature; calibrate expectations to that.
- Shrink toward the 60/40 prior rather than toward zero. The benchmark is the null.
- Explicit turnover penalty and transaction-cost model. The gap between paper alpha and
  net alpha is where most tactical allocation strategies die (see the Morningstar record
  in section 0).

---

## 3c. Backtest validity: which statistics apply where

The signal-screening stage runs on decades of data with many candidate signals and is
exposed to multiple testing. The agent stage runs on roughly 30 decisions with one
configuration, where most of these statistics are meaningless. Being precise about which
applies where matters: misapplying a deflated Sharpe ratio to an n=30 arm would read
worse than not using one.

| Tool | Applies to | Purpose |
|---|---|---|
| Deflated Sharpe ratio (Bailey & Lopez de Prado 2014, *JPM*) | signal screening | corrects an observed Sharpe for the number of trials |
| Probability of backtest overfitting | signal screening | chance the selected configuration is in-sample luck |
| Combinatorial purged cross-validation | signal screening | avoids leakage across overlapping windows |
| Walk-forward analysis | signal screening, rule baseline | honest sequential evaluation |
| Harvey-Liu-Zhu t > 3.0 | signal screening | multiple-testing-aware significance bar |
| White's Reality Check / Hansen SPA | signal screening | best-of-N against the benchmark |
| Paired difference tests on weights | **agent stage** | see section 4.3 |
| Generation-stability dispersion | **agent stage** | the noise floor; see section 4.3 |
| Retrieval-behaviour statistics | **agent stage** | descriptive, no null hypothesis needed |

**Protocol warning.** A tempting gate is "the deterministic core must beat 60/40 before
we add the LLM; if not, fix the core." That is an overfitting loop: iterating on the core
until it clears a bar on the data you will report on burns the out-of-sample. The
defensible protocol is to specify the core ex ante from the literature, run it once, and
report what happened. A core that fails to beat 60/40 is consistent with the entire
literature in section 0, not a bug.

---

## 4. Methodological items that outweigh any individual signal

### 4.1 Buy a longer clean evaluation window

The evaluation window is bounded below by the model's knowledge cutoff. Llama 3.1
documents a December 2023 cutoff, so a post-cutoff backtest from January 2024 gives
roughly 32 monthly decisions, meaningfully more than a frontier model with a 2025
cutoff. An older open-weight checkpoint also gives a frozen artifact, which is better
for reproducibility than a hosted API.

Caveat specific to the agentic decision: the model must be a competent tool-caller. Tool
use is exactly where older and smaller open-weight models are weakest, and an agent that
calls tools badly produces a difference from the rule that reflects incompetence rather
than judgment. Verify tool-calling reliability on a handful of dates before committing
to a checkpoint. This is a genuine tension between window length and agent capability,
and it should be resolved empirically rather than by assumption.

### 4.2 LLM look-ahead and memorisation

The first-order methodological threat, and unlike the signal questions it has a formal
literature to build on rather than being improvised:

- **Glasserman & Lin (2023, *Journal of Financial Data Science*)** show GPT can exploit
  knowledge of post-headline returns, separate genuine look-ahead bias from a
  "distraction effect", and find that anonymising company identifiers improves genuine
  sentiment measurement.
- **Sarkar & Vafa (2024)** and **Lopez-Lira, Tang & Zhu (2025)** show models recall S&P
  500 levels and headline dates inside their training window. One 2025 study reports a
  100% correlation between GPT-4.1-recalled and actual annual S&P 500 returns, a clean
  upper bound on how bad the contamination can get.
- **He, Lv, Manela & Wu (2025)** propose chronologically consistent LLMs as a structural
  fix.

Mitigations, in increasing strength:

1. Strict post-training-cutoff test window (already in the proposal).
2. **Entity and level anonymisation.** Ship z-scores and percentiles; never absolute
   index levels, calendar dates, or named events. This is the asset-allocation analogue
   of Glasserman-Lin's identifier anonymisation, and it resolves the tension between
   "the LLM must never see prices for the backtest period" and "the evidence is derived
   from prices."
3. **Leakage canary.** Probe each realized pack by asking the model to date it. If it
   can guess the month from the numbers, there is leakage regardless of pipeline
   hygiene. Then ablate anonymisation on and off and measure whether recognition drops
   and whether behaviour drops with it.
4. A chronologically consistent or frozen open-weight checkpoint.

The canary plus the anonymisation ablation is not yet standard practice, and running it
at the **asset-allocation** level rather than the single-stock level, where nearly all
existing work sits, is a genuine gap.

### 4.3 Evaluation: difference first, interpretation second

Matches the agreed two-step protocol. Step 1 is fully specified below; step 2 is
sketched and needs work.

#### Step 1 — is there a difference at all?

With roughly 30 decisions you cannot test performance. You *can* test agreement, because
agreement is measured per decision and yields ~30 paired observations of a weight
difference. Run the LLM agent and the rule-based aggregator over identical decision
dates against the identical substrate, and measure:

| Measure | Definition |
|---|---|
| Mean absolute deviation | mean of \|w_LLM − w_rule\| across dates |
| Sign agreement rate | share of dates where both tilt the same way relative to 60/40 |
| Weight-series correlation | correlation of the two weight paths |
| Deviation distribution | is it centred on zero, or systematically one-directional? |
| Paired test on deviations | sign test or bootstrap on the deviation series |
| Turnover difference | does the agent trade more or less than the rule? |

**The noise floor comes first.** Before any of the above means anything, run the agent
k times (k ≈ 10) on the same decision date and measure the dispersion of its own
recommendations. Temperature zero is not deterministic across API calls, and an agent
that also chooses which tools to call has a second source of variance. If within-agent
dispersion at a single date is as large as the agent-vs-rule dispersion across dates,
then the "difference" is sampling noise, not reasoning, and everything downstream is
void. This is cheap, it must be measured first, and it is poorly reported in the
existing literature.

So step 1 has two possible outcomes, and **both are publishable results**:

- **No material difference.** The agent reproduces the rule. Conclusion: under this
  evidence substrate the LLM adds nothing beyond the aggregation the rule already does.
  That is a clean negative result, entirely consistent with the literature in section 0,
  and it costs nothing to obtain.
- **A material difference above the noise floor.** Proceed to step 2 with a concrete
  set of deviations to explain.

Neither outcome requires a claim about outperformance, which is what makes the protocol
sound at n ≈ 30.

#### Step 2 — do the differences make sense?

Not yet worked out. What follows is a candidate structure, to be developed rather than
adopted.

1. **Taxonomy of deviations.** For each date where the agent and the rule differ:
   direction, magnitude, prevailing regime, which signals the agent retrieved, and which
   it cited in `evidence_refs`. This is descriptive and needs no statistical power.
2. **Internal consistency.** Is the stated rationale consistent with what the agent
   actually retrieved, and with the direction of the deviation? Computable from
   `evidence_refs` plus the trace. Already required by Objective 3.
3. **Conditional structure.** Do deviations concentrate in high-disagreement periods, in
   particular regimes, or around specific signals? If deviations are unstructured noise,
   that is itself the finding.
4. **Ex-post correctness.** Was each deviation right? Report as descriptive counts with
   the sample size stated, never as a significance test.
5. **Blind expert scoring.** Show a finance-literate reader the realized pack plus both
   recommendations with the source labels removed, and ask which reasoning is better and
   which recommendation they would take to a committee. FinTeam's human acceptance-rate
   design is the nearest precedent.

Item 5 is the most defensible way to answer "do the differences make sense" without
depending on 30 return observations, and it converts a question about markets into a
question about decision quality, which is what the system is actually for. It needs a
protocol: how many raters, how many cases, what scale, and how disagreement between
raters is handled.

#### Ablation ladder

Everything runs over identical decision dates and an identical substrate.

| # | Arm | Isolates |
|---|---|---|
| 1 | 60/40 static | benchmark |
| 2 | 50/50 static | naive 1/N benchmark |
| 3 | Deterministic core from the literature, specified ex ante, run once | what non-LLM signal processing gets you |
| 4 | Rule-based aggregator over the same substrate | the aggregation step, without reasoning |
| 5 | **Agent, full tool access** | the primary system |
| 6 | Agent, briefing only, no tool calls | the value of retrieval itself |
| 7 | Agent, reduced call budget | how much retrieval is enough |
| 8 | Agent, anonymisation off | LLM look-ahead exposure |
| 9 | Agent, rule's answer shown | anchoring effect |

Arms 4 and 5 are the step-1 comparison. Arm 6 is the sharpest test of whether agent-driven
retrieval earns its complexity over a static pack. Arm 8 is the leakage result. Arm 9 is
the check that arm 5's independence is real.

---

## 5. Open axes, deliberately not decided

Closed decisions C1-C6 are listed at the top of this document and are not repeated here.
Black-Litterman and the view-to-weight mapping were considered and rejected under C4;
they are recorded in the change note at the end of this section rather than as live
options.

| Axis | Options | Notes |
|---|---|---|
| Data sourcing | free public / HSG library (WRDS, Refinitiv, Bloomberg) / partner feed / any combination | Design ingestion against a source-agnostic interface so this can stay open |
| Stage 2 architecture | static sealed pack / narrow logged tool set / both as ablation arms | Tool set is more genuinely agentic and still auditable; static is simpler and matches current proposal text |
| Conditional base rates | always included / ablation arm / excluded | Strongest single idea in the pack, but partly does the LLM's job for it |
| Rebalance frequency | monthly / quarterly | VRP evidence favours quarterly; vol and trend favour monthly; quarterly halves the sample |
| Output granularity | continuous weight / 5pp increments / discrete buckets | Discrete reduces false precision and output instability |
| Model | frontier hosted / older open-weight checkpoint | Trades capability against window length and reproducibility |
| Sentiment source | Alpha Vantage only / plus GDELT / plus EPU and FOMC text | Long-history backbone needed for normalisation |
| Universe proxies | which specific equity and bond indices | Affects data sourcing and transaction cost assumptions |
| Regime method | deterministic threshold label / HMM or Markov-switching / jump model | Deterministic is auditable and cheap; HMM is more impressive and more fragile, and is a real scope risk |
| Tool call budget | uncapped / 15-25 / tighter | Uncapped collapses to a static pack and destroys the retrieval observable; too tight starves the agent |
| Tool granularity | many narrow tools / few broad ones | Narrow tools make the trace more informative; broad ones are easier for a weaker model to use correctly |
| Briefing thickness | manifest only / manifest plus block composites / near-full pack | Controls how much retrieval the agent has to do, which is the thing being measured |
| Agent loop shape | single pass with tool calls / plan-then-retrieve / reflect-and-revise | More structure improves reliability but adds prompt surface that must be frozen ex ante |
| Rule baseline form | equal-weight combination / sign-constrained combination / simple threshold score | This is the thing the agent is compared against, so it has to be defensible on its own |
| Anonymisation level | absolute levels shown / z-scores and percentiles only / both as ablation arms | Directly controls the LLM look-ahead exposure; strongest candidate for a headline result |
| Cash as a third asset | stocks/bonds only / stocks/bonds/cash | Cash makes de-risking meaningful when the correlation is positive and both legs fall together, which is exactly the 2022 case. Widens scope beyond the proposal's stated two-asset universe |

**Rejected under C4, recorded for the design-decision discussion.** Black-Litterman
(Black & Litterman 1992) was considered as the mechanism for turning an LLM view plus
confidence into weights, including the variant of Lee et al. (2025) that uses variance
across repeated generations as the confidence matrix. It was rejected because it removes
the aggregation step from the LLM, which is the object of study, and because it
introduces tau, delta, Omega and a covariance estimator as free parameters that would
have to be frozen ex ante without any principled basis for their values. For a two-asset
problem the mean-variance instability that Black-Litterman exists to solve barely
arises, so the cost is not offset by a benefit. The literature stays in section 6 because
the rejection is worth explaining in the final report.

---

## 6. References to add to references.bib

Already cited in the proposal: `demiguel`, `brinson`, `alpha-vantage`.

New, in rough order of importance to this document:

- Goyal, A., Welch, I. & Zafirov, A. (2024). A Comprehensive 2022 Look at the Empirical
  Performance of Equity Premium Prediction. *Review of Financial Studies* 37(11), 3490-3557.
- Campbell, J. Y., Pflueger, C. & Viceira, L. M. (2020). Macroeconomic Drivers of Bond
  and Equity Risks. *Journal of Political Economy* 128(8).
- Cederburg, S., O'Doherty, M. S., Wang, F. & Yan, X. S. (2020). On the Performance of
  Volatility-Managed Portfolios. *Journal of Financial Economics*.
- Moreira, A. & Muir, T. (2017). Volatility-Managed Portfolios. *Journal of Finance* 72(4).
- Gilchrist, S. & Zakrajsek, E. (2012). Credit Spreads and Business Cycle Fluctuations.
  *American Economic Review* 102(4), 1692-1720.
- Bollerslev, T., Tauchen, G. & Zhou, H. (2009). Expected Stock Returns and Variance
  Risk Premia. *Review of Financial Studies* 22(11), 4463-4492.
- Rapach, D. E., Strauss, J. K. & Zhou, G. (2010). Out-of-Sample Equity Premium
  Prediction: Combination Forecasts and Links to the Real Economy. *RFS* 23(2), 821-862.
- Campbell, J. Y. & Thompson, S. B. (2008). Predicting Excess Stock Returns Out of
  Sample: Can Anything Beat the Historical Average? *RFS* 21(4).
- Neely, C. J., Rapach, D. E., Tu, J. & Zhou, G. (2014). Forecasting the Equity Risk
  Premium: The Role of Technical Indicators. *Management Science* 60(7).
- Huang, D., Li, J., Wang, L. & Zhou, G. (2020). Time Series Momentum: Is It There?
  *Journal of Financial Economics* 135(3), 774-794.
- Moskowitz, T. J., Ooi, Y. H. & Pedersen, L. H. (2012). Time Series Momentum. *JFE* 104(2).
- Cochrane, J. H. & Piazzesi, M. (2005). Bond Risk Premia. *American Economic Review* 95(1).
- Thornton, D. L. & Valente, G. (2012). Out-of-Sample Predictions of Bond Excess Returns
  and Forward Rates: An Asset Allocation Perspective. *RFS* 25(10).
- Calomiris, C. W. & Mamaysky, H. (2019). How News and Its Context Drive Risk and Returns
  Around the World. *Journal of Financial Economics* 133(2).
- Tetlock, P. C. (2007). Giving Content to Investor Sentiment: The Role of Media in the
  Stock Market. *Journal of Finance* 62(3).
- Baker, S. R., Bloom, N. & Davis, S. J. (2016). Measuring Economic Policy Uncertainty.
  *Quarterly Journal of Economics* 131(4).
- Manela, A. & Moreira, A. (2017). News Implied Volatility and Disaster Concerns. *JFE* 123(1).
- Asness, C. (2003). Fight the Fed Model. *Journal of Portfolio Management* 30(1).
- Adrian, T., Crump, R. K. & Moench, E. (2013). Pricing the Term Structure with Linear
  Regressions. *Journal of Financial Economics* 110(1).

Added after merging the second research pass:

- McLean, R. D. & Pontiff, J. (2016). Does Academic Research Destroy Stock Return
  Predictability? *Journal of Finance* 71(1), 5-32.
- Harvey, C. R., Liu, Y. & Zhu, H. (2016). ...and the Cross-Section of Expected Returns.
  *Review of Financial Studies* 29(1).
- Brixton, A., Brooks, J., Hecht, P., Ilmanen, A., Maloney, T. & McQuinn, N. (2023). A
  Changing Stock-Bond Correlation. *Journal of Portfolio Management* 49(4).
- Hurst, B., Ooi, Y. H. & Pedersen, L. H. (2017). A Century of Evidence on
  Trend-Following Investing. *Journal of Portfolio Management* 44(1), 15-29.
- Faber, M. T. (2007, updated 2013). A Quantitative Approach to Tactical Asset
  Allocation. *Journal of Wealth Management*.
- Zakamulin, V. (2017). *Market Timing with Moving Averages*. Palgrave Macmillan.
- Estrella, A. & Mishkin, F. S. (1998). Predicting U.S. Recessions: Financial Variables
  as Leading Indicators. *Review of Economics and Statistics* 80(1).
- Hamilton, J. D. (1989). A New Approach to the Economic Analysis of Nonstationary Time
  Series and the Business Cycle. *Econometrica* 57(2).
- Guidolin, M. & Timmermann, A. (2007). Asset Allocation under Multivariate Regime
  Switching. *Journal of Economic Dynamics and Control* 31(11).
- Kritzman, M., Page, S. & Turkington, D. (2012). Regime Shifts: Implications for
  Dynamic Strategies. *Financial Analysts Journal* 68(3).
- Nystrup, P., Madsen, H. & Lindström, E. (2015-2018). Regime-based asset allocation
  papers, *JPM* / *Quantitative Finance* / *Journal of Asset Management*.
- Shu, Y., Yu, C. & Mulvey, J. M. (2024). Statistical jump models for regime
  identification.
- Black, F. & Litterman, R. (1992). Global Portfolio Optimization. *Financial Analysts
  Journal* 48(5).
- He, G. & Litterman, R. (1999). The Intuition Behind Black-Litterman Model Portfolios.
  Goldman Sachs.
- Lee, Y., Kim, Y., Kim, J., Kim, S. & Lee, Y. (2025). LLM-Enhanced Black-Litterman
  Portfolio Optimization. arXiv:2504.14345. (PDF already in
  `docs/papers/gian/proposal_research/`.)
- Martin, I. (2017). What Is the Expected Return on the Market? *Quarterly Journal of
  Economics* 132(1).
- Lettau, M. & Ludvigson, S. (2001). Consumption, Aggregate Wealth, and Expected Stock
  Returns. *Journal of Finance* 56(3). (Note the full-sample cointegrating-vector
  look-ahead issue in the standard CAY series.)
- Bybee, L., Kelly, B., Manela, A. & Xiu, D. (2024). Business News and Business Cycles.
  *Journal of Finance* 79(5), 3105-3147.
- Garcia, D. (2013). Sentiment during Recessions. *Journal of Finance* 68(3).
- Cohen, L., Malloy, C. & Nguyen, Q. (2020). Lazy Prices. *Journal of Finance* 75(3).
- Bailey, D. H. & Lopez de Prado, M. (2014). The Deflated Sharpe Ratio. *Journal of
  Portfolio Management* 40(5).
- Ledoit, O. & Wolf, M. (2004). A Well-Conditioned Estimator for Large-Dimensional
  Covariance Matrices. *Journal of Multivariate Analysis* 88(2).
- Glasserman, P. & Lin, C. (2023). Assessing Look-Ahead Bias in Stock Return
  Predictions Generated by GPT Sentiment Analysis. *Journal of Financial Data Science*.
- Sarkar, S. K. & Vafa, K. (2024). Lookahead bias in pretrained language models.
- Lopez-Lira, A., Tang, Y. & Zhu, M. (2025). The memorization problem in LLM-based
  financial forecasting.
- He, S., Lv, D., Manela, A. & Wu, J. (2025). Chronologically Consistent Large Language
  Models.
- Ptak, J. / Arnott, A. (2023). Morningstar analyses of the tactical allocation fund
  category, decade to 30 April 2023.
- Chen, A. Y. & Zimmermann, T. (2022). Open Source Cross-Sectional Asset Pricing.
  *Critical Finance Review*. (Reference dataset for honest benchmarking.)

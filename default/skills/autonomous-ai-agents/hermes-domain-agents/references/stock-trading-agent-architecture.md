# Stock Trading Agent — Skill Architecture & ClawHub Catalog

## Layered Architecture

A well-structured stock trading agent separates concerns into layers. Each layer has a specific role and depends on the layer below it.

```
📊 Data Acquisition Layer
│   Raw market data, financials, sector data
├── akshare-stock          — A-share quotes, financials, sector data (AkShare-based)
├── claw-stock-watcher-pro — Personal watchlist + Tonghuashun real-time quotes
└── stock_data             — Global stock prices, valuation, financials, dividends

📈 Analysis & Decision Layer
│   Technical/fundamental analysis, buy/sell signals
├── china-stock-analysis   — A-share/HK stock trend analysis + buy/sell suggestions
├── claw-stock             — Individual stock value scoring
├── xiaodi-financial-analysis-team — Stock analysis + fund recommendations + portfolio review
└── akshare-stock-analysis — K-line charts + technical indicators + risk analysis

🔔 Monitoring & Alert Layer
│   Real-time price alerts, threshold triggers
├── stock-monitor-skill    — Multi-rule stock alerts for A-shares
├── stock-monitor-a        — A-share real-time data + anomaly alerts
└── stock-valuation-monitor — ETF/stock valuation level monitoring

📰 Reporting & Output Layer
│   Scheduled reports, market sentiment, push notifications
├── astock-report          — A-share morning/evening reports + sentiment scoring + WeChat push
└── astock-video-report    — Daily A-share recap video generation

🔍 Search & Research Layer
│   Web search, news aggregation, fundamental research
├── proxy-web-search       — Proxied web search with engine selection
├── dexter                 — Autonomous financial research (stocks + crypto)
└── multi-search-engine    — 17 search engines (8 CN + 9 international)
```

## Recommended Skill Set for a New Stock Agent

For a Chinese A-share focused agent, the minimum viable skill set:

**Must-have (data + analysis):**
- `akshare-stock` — primary data source
- `china-stock-analysis` — core analysis engine
- `stock-monitor-skill` — alert system

**Nice-to-have (enhanced capabilities):**
- `astock-report` — if you want automated daily reports
- `xiaodi-financial-analysis-team` — for fund analysis and portfolio review
- `claw-stock-watcher-pro` — for Tonghuashun integration

**Auxiliary:**
- `proxy-web-search` or `multi-search-engine` — for news/research

## ClawHub Skill Catalog (Stock Trading)

Discovered on `cn.clawhub-mirror.com` as of 2026-08-31:

| Skill | ClawHub ID | Author | Description |
|-------|-----------|--------|-------------|
| akshare-stock | `akshare-stock` | @zuoyunlai | A-share quotes, financials, sector data |
| astock-report | `astock-report` | @cookfish1979 | A-share morning/evening reports + WeChat push |
| china-stock-analysis | `china-stock-analysis` | @zuoyunlai | A-share/HK stock trend analysis |
| claw-stock | `claw-stock` | @yoborlon-alpha | Individual stock value scoring |
| claw-stock-watcher-pro | `claw-stock-watcher-pro` | @williamwang-wh | Watchlist + Tonghuashun quotes |
| stock-monitor-skill | `stock-monitor-skill` | @thirtyfang | Multi-rule A-share alerts |
| xiaodi-financial-analysis-team | `xiaodi-financial-analysis-team` | @mx6315909 | Stock + fund analysis + portfolio review |
| proxy-web-search | `proxy-web-search` | @whyhit2005 | Proxied web search |

**Notable alternatives found on ClawHub:**

| Skill | ClawHub ID | Use case |
|-------|-----------|----------|
| stock_data | `stock-data-skill` | Global stock data (not A-share specific) |
| Select Super Stock | `select-super-stock` | Quality stock screening (A/HK/US) |
| Stock Analysis | `manus-stock-analysis` | Enterprise-level stock research |
| stock watch | `stock-watchlist` | Real-time global quotes + markdown watchlist |
| Eastmoney Select Stock | `eastmoney-select-stock-1-0-2` | Eastmoney-based stock screening |
| longbridge-stock | `longbridge-stock` | Longbridge Securities integration |
| A Stock Holding Monitor | `a-stock-holding-monitor` | Portfolio stop-loss + support break alerts |
| stock-monitor-lite | `stock-monitor-lite` | 11 alert rules, CN investor habits |
| AKShare股票分析 | `akshare-stock-analysis` | Technical indicators + sector rotation |

## Dependencies

Most A-share skills depend on `akshare` Python package:
```bash
pip install akshare
```

Some skills (like `claw-stock-watcher-pro`) depend on Tonghuashun API — check their SKILL.md for API key requirements.

---
name: akshare-stock
description: "快速获取A股行情、财务及板块数据，支持股票查询、选股与财务分析"
version: 1.0.0
author: zuoyunlai
license: MIT-0
tags: [stock, finance, akshare, china, A股, 量化]
---

# A股量化 - AkShare 数据接口

## 快速开始

安装依赖：
```bash
pip install akshare
```

## 支持的功能

### 1. 实时行情查询
```python
import akshare as ak

# 个股实时行情
stock_zh_a_spot_em()
stock_zh_a_spot_em(symbol="北证A股")
```

### 2. 历史K线数据
```python
import akshare as ak

# 日K线
stock_zh_a_hist(symbol="000001", period="daily", start_date="20240101", end_date="20241231", adjust="qfq")

# 周K线
stock_zh_a_hist(symbol="000001", period="weekly", start_date="20240101", end_date="20241231", adjust="qfq")

# 月K线
stock_zh_a_hist(symbol="000001", period="monthly", start_date="20240101", end_date="20241231", adjust="qfq")
```

### 3. 财务数据
```python
import akshare as ak

# 财务报表
stock_financial_abstract_ths(symbol="000001", indicator="按报告期")

# 主要财务指标
stock_financial_analysis_indicator(symbol="000001")
```

### 4. 板块/行业分析
```python
import akshare as ak

# 行业板块行情
stock_board_industry_name_em()

# 概念板块行情
stock_board_concept_name_em()

# 板块内个股
stock_board_industry_cons_em(symbol="半导体")
```

### 5. 资金流向
```python
import akshare as ak

# 个股资金流向
stock_individual_fund_flow(stock="000001", market="sh")

# 大单净流入
stock_individual_fund_flow(stock="000001", market="sh", symbol="大单净流入")
```

### 6. 龙虎榜
```python
import akshare as ak

# 每日龙虎榜
stock_lhb_detail_em(date="20240930")

# 机构调研
stock_zlzj_em()
```

### 7. 新股/IPO
```python
import akshare as ak

# 新股申购
stock_new_ipo_em()

# 待上市新股
stock_new_ipo_start_em()
```

### 8. 融资融券
```python
import akshare as ak

# 融资融券
stock_margin_sse(symbol="600000")

# 融资融券明细
stock_rzrq_detail_em(symbol="600000", date="20240930")
```

## 常用股票代码

- 平安银行: 000001
- 贵州茅台: 600519
- 宁德时代: 300750
- 比亚迪: 002594
- 招商银行: 600036

## 注意事项

- 数据来源为东方财富、同花顺等公开数据接口
- 请遵守相关数据使用协议
- 仅供学习研究使用，不构成投资建议

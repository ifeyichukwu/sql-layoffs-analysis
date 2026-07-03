# SQL Layoffs Analysis: Data Cleaning & Exploratory Data Analysis

An end-to-end SQL project covering data cleaning and exploratory data analysis on a real-world global layoffs dataset, using MySQL.

## Objective
To clean a raw, messy layoffs dataset and extract meaningful insights about layoff trends across companies, industries, countries and time periods between March 2020 and March 2023.

## Dataset
- **Source:** [layoffs.fyi](https://layoffs.fyi) — a crowdsourced database of tech layoffs
- **Raw rows:** 2,362
- **Clean rows:** 1,995
- **Columns:** company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions

## Tools
- MySQL 8.0
- MySQL Workbench

## Process

### Data Cleaning
1. **Staging table** — created a working copy of the raw data to preserve the original throughout the cleaning process
2. **Duplicate removal** — used `ROW_NUMBER()` with `PARTITION BY` across all 9 columns to flag and remove 5 verified duplicate rows
3. **Standardization** — trimmed whitespace from company names, unified inconsistent industry labels (e.g. Crypto/Crypto Currency/CryptoCurrency → Crypto, Fin-Tech → Finance), fixed trailing period in country values (United States.), corrected encoding issues in location names (DÃ¼sseldorf → Dusseldorf), fixed a typo (Ferdericton → Fredericton)
4. **Date conversion** — converted date column from text (M/D/YYYY) to proper DATE type using `STR_TO_DATE()` and `ALTER TABLE ... MODIFY`
5. **NULL and blank handling** — traced blank industry values back to matching company rows and filled them using `UPDATE`, then dropped 367 rows where both `total_laid_off` and `percentage_laid_off` were NULL (no analytical value)
6. **Column removal** — dropped the `row_num` helper column after deduplication

### Exploratory Data Analysis
- Date range, scale, and severity checks
- Companies that shut down completely (percentage_laid_off = 1)
- Total layoffs by company, industry, country, and year
- Rolling cumulative monthly totals using window functions
- Top 5 companies by layoffs per year using `DENSE_RANK()`

## Key Insights
- **1,995 clean records** representing 383,159 total job losses across 3 years
- **Consumer and Retail** were the hardest hit industries, driven by post-COVID demand normalization after aggressive pandemic-era hiring
- **2021 was the calm before the storm** — only ~15,000 layoffs as tech companies were still in hiring mode
- **2022-2023 saw exponential acceleration** — it took 23 months to reach the first 100,000 cumulative layoffs, then only 9 months for the next 100,000, then just 4 months for the following 100,000+
- **Katerra** raised $1.6B in funding and still shut down completely — the standout outlier among 116 companies with 100% workforce reduction
- **2023's top 5** (Google, Microsoft, Ericsson, Amazon, Salesforce) laid off more in 3 months than most industries did across the entire 3-year period
- The layoff wave shifted from **movement-dependent industries in 2020** (Uber, Airbnb, Booking.com) to **pure tech giants in 2022-2023**, reflecting two distinct phases: COVID survival cuts vs. overhiring correction

## Repository Structure
```
sql-layoffs-analysis/
├── layoffs_cleaning_eda.sql   # Full SQL script: cleaning + EDA queries
├── layoffs_cleaned.csv        # Final cleaned dataset (world_layoffs_staging_2)
└── README.md
```

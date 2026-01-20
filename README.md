# SQL Data Warehouse Project: K-Drama Industry Analysis

**Full Documentation (Notion):**  
https://mercury-capri-35c.notion.site/SQL-Data-Warehouse-Project-KDRAMA-ecf8c9957353835cb316813ef897a8ba?source=copy_link

---

## Project Background

This project is framed from the perspective of a data analyst supporting a **Content Strategy and Analytics team at a global streaming platform** that licenses and distributes Korean television dramas (K-Dramas) to international audiences.

The platform operates in the digital media and entertainment industry and competes on content quality, genre positioning, and long-term audience engagement. Business decisions focus on which production networks to partner with, which genres to prioritize, and which titles to invest in for global promotion.

My objective was to design a SQL-based analytical system that enables leadership to evaluate network performance, genre specialization, and title success using context-aware benchmarks rather than relying only on raw ratings or popularity lists.

Insights and recommendations are provided across four strategic areas:

- Network Scale vs Content Quality  
- Genre Specialization by Network  
- Year-Normalized Title Performance  
- Portfolio Focus vs Diversification Strategy  

---

## Data Structure & Initial Checks

I prepared and ingested a relational dataset of approximately **250 top-ranked K-Dramas** into MySQL. The schema was designed to support many-to-many relationships between:

- Dramas  
- Genres  
- Original Networks  

Before ingestion, I cleaned and validated the data in Excel, including numeric formatting of ranking fields and consistency checks to ensure accurate typing in the database. After ingestion, I implemented relational constraints and trigger-based validation to enforce:

- Realistic rating ranges  
- Valid release years  
- Unique network–drama and genre–drama relationships  

This structure allowed advanced analysis using window functions, ranking, aggregation, and year-normalized baselines while maintaining data integrity.

---

## Executive Summary

My analysis shows that production scale does not consistently correlate with content quality, that networks exhibit strong genre-specific performance patterns, and that year-normalized benchmarks are essential for identifying true breakout titles. Networks with focused genre portfolios tend to achieve stronger average performance, while diversified portfolios trade consistency for broader market coverage. These insights support more informed decisions around partner selection, genre investment, and global content promotion.

---

## Insights Deep Dive

### 1. Network Scale vs Content Quality

High-volume networks dominate overall output but do not always achieve the highest average ratings. For example, large broadcasters such as KBS and SBS appear frequently in the catalog by volume, yet smaller networks such as ENA and platforms like Apple TV+ achieve comparable or higher average ratings despite having far fewer titles.

This indicates that scale alone is not a reliable proxy for quality. A curated portfolio of a few strong titles can generate higher audience reception than a large catalog with mixed performance. For a Content Strategy Manager, this means partnership decisions should be guided by consistency and quality signals, not just catalog size.

---

### 2. Genre Specialization by Network

Network–genre performance analysis shows that networks tend to excel in specific genres rather than performing uniformly across all content types. For instance, Apple TV+ demonstrates particularly strong average ratings in Drama and Historical genres, while ENA’s limited catalog also performs strongly within its focused genre mix.

When networks operate outside their core genre strengths, performance tends to be more volatile. This suggests that creative capability, production expertise, and audience alignment are genre-specific, reinforcing the importance of matching networks to the genres where they historically perform best.

---

### 3. Year-Normalized Title Performance

Using release-year baselines reveals standout titles that outperform their competitive cohort even when their absolute ratings are not the highest across all years. Historical titles such as *Jewel in the Palace* (2003), *Queen Seon Deok* (2009), and *Dong Yi* (2010) rank at or near the top within their respective release years and exceed the yearly average by a meaningful margin.

These dramas are not just highly rated in isolation but performed exceptionally relative to other titles released in the same period. This type of year-normalized evaluation is more effective for identifying culturally impactful and globally marketable content than raw ratings alone.

---

### 4. Portfolio Focus vs Diversification

When comparing genre diversity with average network ratings, a pattern emerges in which more focused networks often show stronger quality signals. Networks that concentrate on a small set of genres, particularly Romance and Drama, tend to maintain higher and more stable average ratings than those spreading production across many genres.

This highlights a strategic tradeoff. Specialization supports consistent quality and brand identity, while diversification increases coverage and experimentation but may dilute performance.

---

## Recommendations

Based on these findings, I would recommend that a Content Strategy team:

1. Evaluate production partners using quality-weighted metrics rather than output volume alone.  
2. Align genre investment decisions with each network’s historically strongest performance areas.  
3. Use year-normalized benchmarks to guide promotion, licensing, and international distribution priorities.  
4. Define whether the platform’s strategy prioritizes prestige-driven specialization or coverage-driven diversification and allocate budgets accordingly.  

---

## Assumptions and Caveats

- The analysis is based on approximately **250 top-ranked dramas**, representing a high-quality subset rather than the full population of all releases.  
- Ratings are used as a proxy for audience reception and perceived quality, recognizing that they do not directly measure viewership volume or revenue.  
- Some network–genre combinations have small sample sizes, which may introduce volatility in average rating estimates.  
- The dataset is static. In a future extension of this project, I plan to integrate live data via public APIs to continuously ingest new releases and update performance benchmarks in near real time.  

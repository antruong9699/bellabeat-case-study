# Bellabeat Marketing Analysis — Smart Device Usage Case Study

## Overview
Analyzed FitBit fitness tracker data from 35 users to uncover smart device usage
trends and translate those findings into high-level marketing strategy recommendations
for Bellabeat, a health-focused smart device company targeting women. This is the
capstone project for the Google Data Analytics Professional Certificate.

## Tools & Methods
- **SQL:** Google BigQuery (data cleaning, aggregation, quality checks)
- **Python:** pandas, matplotlib, seaborn (analysis, visualization)
- **Approach:** Descriptive analysis, correlation analysis, user segmentation
- **Techniques:** Boolean masking, groupby aggregation, regression visualization,
  function-based segmentation using CDC/WHO activity benchmarks

## Key Results
| Metric | Value |
|--------|-------|
| Users analyzed | 35 FitBit users |
| Tracked days | 457 daily activity records |
| Avg. daily steps | 7,405 (vs. 10,000 benchmark) |
| Avg. sedentary minutes | 937 min/day (~15.6 hours) |
| Avg. wear rate | 94% among consistent users |
| Sedentary vs. sleep correlation | r = -0.59 |
| Active users (≥ 7,500 steps/day) | 45.8% |
| Sedentary + Lightly Active users | 54.2% |

## Key Findings
1. **High wear consistency:** Users averaged a 94% wear rate, indicating already-habitual
   device use — the marketing opportunity is deepening engagement with data, not building
   the wear habit from scratch.
2. **Activity gap:** Mean daily steps (7,405) fall short of the 10,000-step benchmark,
   with 54% of users classified as Sedentary or Lightly Active.
3. **Peak activity windows:** Two clear daily peaks at 12pm and 7pm suggest optimal
   timing for App notifications and wellness prompts.
4. **Sedentary-sleep link:** Higher sedentary time correlates meaningfully with shorter
   sleep duration (r = -0.59), creating a natural cross-promotion angle between the
   App's activity and sleep tracking features.
5. **Weekend patterns:** Saturday maintains near-weekday activity while Sunday dips
   noticeably — a recovery-day content opportunity for the App.
6. **Demographic gap:** The FitBit dataset contains no gender data; Pew Research (Vogels,
   2020) provides supplementary demographic context showing women adopt fitness trackers
   at slightly higher rates than men (25% vs. 18%).

## Project Structure
```
bellabeat-case-study/
├── sql/
│   └── Bellabeat_Process_Cleaning.sql   — Full BigQuery cleaning pipeline:
│                                           7 raw tables → 11 clean/aggregated tables,
│                                           with duplicate checks, null checks,
│                                           and documented column decisions
├── notebooks/
│   └── Bellabeat_Section4_Analyze.ipynb — Python analysis and visualization:
│                                           summary statistics, correlation analysis,
│                                           peak activity hours, weekday patterns,
│                                           and user segmentation
├── visuals/
│   ├── hourly_steps.png                 — Average steps by hour of day (line chart)
│   ├── sedentary_vs_sleep.png           — Sedentary minutes vs. sleep duration (scatter)
│   ├── steps_by_day.png                 — Average steps by day of week (bar chart)
│   └── user_segments.png               — User segments by activity level (pie chart)
└── data/
    └── README.md                        — Dataset source and download instructions
```

## Dataset
**FitBit Fitness Tracker Data** — CC0 Public Domain, available via
[Kaggle (Mobius)](https://www.kaggle.com/datasets/arashnic/fitbit).
Raw data files are not included in this repository due to size.
See `data/README.md` for download instructions.

**Known limitations:**
- Small sample (35 users, ~1 month, March–April 2016)
- No gender, age, or demographic fields
- Collected via Amazon Mechanical Turk (self-selected panel)
- Data is approximately a decade old

## Background
This project was completed as the capstone for the Google Data Analytics Professional
Certificate. The scenario: acting as a junior analyst on Bellabeat's marketing team,
tasked with analyzing non-Bellabeat smart device usage data and applying insights to
one Bellabeat product — the Bellabeat App — to inform marketing strategy for the
executive team.

The analysis follows the six-phase data analysis process: **Ask → Prepare → Process →
Analyze → Share → Act.**

## Author
**An Truong**  
BS Public Relations, Boston University | MS Applied Analytics, Columbia University  
[LinkedIn](https://linkedin.com/in/antruong9699) | [Portfolio](https://antruong-portfolio.netlify.app)

# Reciprocal F1 hybrids: B6D2F1 against D2B6F1

**Exploratory, 21 November 2026.** Run by Opus 5.5 Extra (Claude, Anthropic) after Rob Williams had seen the two crosses' survival: "The difference between the survivorship structure of B6D2F1s and D2B6F1 is quite large and really surprised me."
- **Code:** [`Gompertz/Reciprocal_F1.R`](../Gompertz/Reciprocal_F1.R).
- **Output:** [`output/Reciprocal_F1.txt`](../output/Reciprocal_F1.txt), with every F1 listed.
- **Data:** ages and set-up ages from Suheeta Roy's curated file (`data/original/BXD_Mortality_for_Mapping_Arends.xlsx`). Birth dates and status (natural death or euthanized) come from her body-weight workbook, matched by ear tag. All are females.

## In brief

- **The two crosses differ, but in opposite directions on the two diets.**
  - On high fat, D2B6F1 (DBA/2J mother) live longer: median 878 days against 664.
  - On chow, the two are close: medians 791 and 822 days.
  - The cross × diet interaction has P = 0.019.
- **The crosses were raised years apart, in different vivaria.**
  - **D2B6F1:** all 17 were born in 2011–2014, mostly at Nash.
  - **B6D2F1:** 26 of the 35 were born in 2022 at TSRB, and 21 of those 26 were euthanized. No D2B6F1 was.
- **So the data cannot yet say whether the mother's strain matters.** Cross, birth cohort, vivarium, set-up age and euthanasia practice all change together.

## The mice

| Cross | Diet | Mice | Median age at death (IQR), days | Range | Set-up age | Vivarium (1 Nash, 2 Nash then TSRB, 3 TSRB) | Born | Euthanized |
|---|---|---|---|---|---|---|---|---|
| B6D2F1 | chow | 20 | 822 (691–886) | 435–1,080 | 37–258 | 1: 1, 2: 3, 3: 16 | 2013–2015: 6; 2022: 14 | 10 |
| D2B6F1 | chow | 7 | 791 (666–848) | 585–996 | 140–210 | 1: 5, 2: 2 | 2011–2014: 7 | 0 |
| B6D2F1 | high fat | 15 | 664 (494–791) | 342–898 | 28–186 | 1: 3, 3: 12 | 2013–2015: 3; 2022: 12 | 11 |
| D2B6F1 | high fat | 10 | 878 (695–964) | 421–1,161 | 113–487 | 1: 8, 2: 2 | 2011–2014: 10 | 0 |

For comparison, the parents' medians are 805 days on chow and 714 on high fat for C57BL/6J, and 619 and 667 for DBA/2J (`output/Reciprocal_F1.txt`).
- **On high fat, D2B6F1 outlive both parents.** Their median, 878 days, is 164 days above C57BL/6J's.
- **B6D2F1 on high fat do not:** their median, 664 days, is close to DBA/2J's.

## Survival

Cox models with left truncation at set-up age: each mouse enters the risk set at set-up and is followed to death. The hazard ratio compares D2B6F1 with B6D2F1, so a ratio below 1 means D2B6F1 die at a lower rate.

| Diet | Mice | Hazard ratio, D2B6F1 / B6D2F1 (95% CI) | P |
|---|---|---|---|
| Chow, all | 20 B6D2F1, 7 D2B6F1 | 1.27 (0.53–3.04) | 0.6 |
| Chow, born 2011–2015 | 6, 7 | 2.66 (0.82–8.65) | 0.11 |
| High fat, all | 15, 10 | 0.34 (0.13–0.87) | 0.025 |
| High fat, born 2011–2015 | 3, 10 | 0.08 (0.01–0.80) | 0.031 |

**The cross × diet interaction** is a likelihood-ratio test of the cross × diet term, in a Cox model that already has cross and diet. It gives P = 0.019 for all mice and P = 0.00034 for mice born 2011–2015.

**Restricting to the years when both crosses were born** removes the 2022 TSRB cohort, but leaves few B6D2F1:
- **On chow, the 6 B6D2F1 born 2013–2015 lived long:** 856, 879, 880, 912, 992 and 1,080 days. The 7 D2B6F1 lived 585 to 996 days.
- **On high fat, only 3 B6D2F1 were born then.** They died at 342, 447 and 450 days, against 421 to 1,161 days for the 10 D2B6F1. The high-fat result for these years rests on those 3 mice.

**These P values are animal-level and exploratory.** With one genotype per cross, no strain-level test is possible, and the analysis was run after the difference had been seen.

## Why it may not be the cross

Four things change with the cross:
- **Birth cohort.** D2B6F1 were born in 2011–2014. Most B6D2F1 (26 of 35) were born in 2022.
- **Vivarium.** D2B6F1 lived at Nash, or at Nash and then TSRB. Most B6D2F1 lived at TSRB only. Part 5 found vivarium and birth year matter for nicotinamide.
- **Set-up age.** Most B6D2F1 were set up young (28 to 66 days in the 2022 cohort). D2B6F1 were set up at 113 to 487 days, so every D2B6F1 had already survived to at least 113 days. Left truncation corrects for this in the Cox models, but not in the medians.
- **Euthanasia.** 21 of the 26 B6D2F1 born in 2022 were euthanized; no D2B6F1 was. If euthanasia came earlier than natural death would have, it shortens B6D2F1 lives in particular.

## What could differ between reciprocal F1s

Reciprocal F1 females have the same nuclear genome, including one X from each parent. They differ in three ways, any of which could act through diet:
- **Mitochondria,** which come from the mother: C57BL/6J in B6D2F1, DBA/2J in D2B6F1.
- **The maternal environment:** the uterus, milk and care of a C57BL/6J or a DBA/2J mother.
- **Imprinted genes,** which are expressed from one parent's copy only.

The data here cannot separate these, or separate any of them from the confounds above.

## What would settle it

- **Both crosses raised together:** born in the same years and housed in the same vivarium, with the same set-up age and euthanasia criteria.
- **A Gompertz fit per cross and diet** would split any difference into level (mortality at 600 days) and slope (MRDT), as in Parts 1 and 2. With 7 to 20 mice per group, those estimates would be too wide to help yet.

# How fast does mortality rise with age? Gompertz analyses of BXD and UM-HET3 mice

**Parts 1–3: diet, proximal Chr 1 and F1 hybrids in the BXD family, and Vita1a and Vita1b in UM-HET3 mice**

Exploratory report, 26 October 2026. Prepared by Claude (Anthropic) with Rob Williams, for Suheeta Roy, Danny Arends and Khyobeni Mozhui. All code, data and figures: [github.com/robwwilliams/bxd_mortality_rates_2026](https://github.com/robwwilliams/bxd_mortality_rates_2026).

## Summary

- **Part 1, diet (BXD females).** A high-fat diet raises mortality about 1.4-fold at every age. It does not change how fast mortality rises with age: the mortality rate doubling time (MRDT) is 153 days on chow and 149 days on high fat (P = 0.55).
  - **Within strains, the diet effect is larger and varies.** Compared within each strain, high fat raises mortality about 1.8-fold, and strains differ in how much (P = 0.0002).
  - **Within strains the MRDT is 113 days, not 151.** Pooling strains flattens the curve.
- **Part 2, genotype (BXD).**
  - **Proximal Chr 1 (Vita1a and Vita1b).** The haplotype changes the level of mortality, not its doubling time. On high fat, B strains die at twice the rate of D strains at 600 days; on chow, 1.25 times.
  - **F1 hybrids.** Hybrids of two short-lived strains start with a quarter of their parents' mortality, but their mortality rises faster, so the advantage narrows with age.
- **Part 3, Vita1a and Vita1b (UM-HET3).**
  - **The genotype calls on proximal Chr 1 are faulty at two of the three sites.** At UM and UT, some markers fail to see the paternal D allele. This produces the 2:1 excess of paternal H over D in the published tables, and an almost complete loss of BD calls at Vita1b. At JL the calls are clean. The fault lies in one of the two genotyping marker sets, which was used for about half of the UM mice and all of the UT mice.
  - **The paternal D haplotype at Vita1a raises mortality about 1.2-fold.** This holds within sites and cohorts.
  - **Whether it also shortens the MRDT is not settled.** The published Table 2 suggests it does (P ≈ 0.04), but the effect disappears when the miscalls and site differences are taken into account.
  - **The D haplotype acts in opposite directions in the two populations.** In BXD chow females, proximal Chr 1 D lowers mortality relative to B. In UM-HET3 females, paternal D raises it relative to H (C3H).
  - **Neither population shows a convincing proximal Chr 1 effect on MRDT.**

## A five-minute Gompertz primer

You need only a few ideas to read this report.

**1. Mortality rate.** Of the mice alive at a given age, how many die per day? We count it as deaths per 1,000 mouse-days. A mouse-day is one mouse alive for one day.
- **Example:** 200 mice followed for 15 days give 3,000 mouse-days. If 6 of them die, the mortality rate is 2 deaths per 1,000 mouse-days.
- **Also called the hazard.** Life tables and the Gompertz literature use both words.

**2. The Gompertz law.** After early adulthood, mortality rises exponentially with age: it doubles at a steady interval. We write it in base 2, so the numbers read directly:

h(t) = R0 · 2^(t / MRDT)

- h(t) is the mortality rate at age t, in days.
- **MRDT, the mortality rate doubling time,** is the number of days it takes mortality to double. In our mice it is about 90–160 days. In people it is about 8 years.
- **R0** is the rate extrapolated back to birth. It is not a rate anyone observes.

**3. Read the figures on a log2 axis.** On a log2 axis every gridline is one doubling of mortality, so a Gompertz curve is a straight line.
- **The steepness of the line is the MRDT:** a steeper line means a shorter MRDT, a faster rise.
- **The height of the line is the level of mortality.** We report the level as the rate at 600 days, a typical age of death, rather than R0.
- **Why not R0?** A slightly steeper line that starts a little lower fits almost as well as a flatter line that starts higher. So R0 and MRDT trade off against each other in any fit. This is the Strehler–Mildvan correlation. The level at 600 days does not suffer from it.

**4. Level effects and slope effects.** These are the two ways a diet or a gene can change mortality, and the report keeps them apart.
- **A level effect** multiplies mortality by the same factor at every age: the line moves up or down, with the same slope.
  - The multiple is constant, but the extra deaths are not. 1.4 times a high rate adds far more deaths than 1.4 times a low rate, so a level effect adds most of its deaths late in life.
- **A slope effect** changes the MRDT: the two lines diverge or converge with age.

**5. A note on words.** MRDT is often called the "demographic rate of aging". It measures only how fast mortality rises with age. We have no measures of aging itself here, so we speak of MRDT and mortality, not of aging.

**6. Entry ages and fitting.**
- **Left truncation.** Mice enter a study at different ages: in the BXD colony, at their age at set-up. Each mouse is counted as at risk only from its entry age. Otherwise mice that entered late would make the early ages look safer than they were.
- **Maximum likelihood.** The fit finds the Gompertz line that makes the observed ages at death most probable.
- **Likelihood-ratio test.** To ask whether two groups have different MRDTs, we compare a fit in which they share one MRDT with a fit in which each has its own. The P value says how surprising the improvement would be if the MRDTs were in fact equal.

**7. The strain is the unit.** Mice of one BXD strain are genetically identical, so 30 mice of one strain are not 30 independent tests of a genotype.
- **We use a delete-one-strain jackknife.** Each strain is dropped in turn and everything refitted, and the spread of the results gives the uncertainty.
- **Animal-level P values are too optimistic.** In simulations with no true difference, the animal-level likelihood-ratio test gave false positives 14% of the time, against 5.5% for the jackknife.

**8. Mixtures flatten the curve.** Pool groups whose mortality levels differ, and the high-risk animals die first. The survivors at old ages are mostly low-risk animals, so the pooled curve rises more slowly than any group within it.
- **In the BXDs:** pooled MRDTs are 140–165 days, but within single strains they are mostly 86–110 days.

---

# Part 1. Does a high-fat diet change the mortality rate doubling time?

## Question

Does a high-fat diet change how fast mortality rises with age (the MRDT), or does it raise mortality by the same factor at every age (the level), or both?

## Data

- **Source:** Suheeta Roy's curated file of BXD family females used for actuarial mapping (`data/original/BXD_Mortality_for_Mapping_Arends.xlsx`), unchanged.
- **Included:** 1,934 females of 124 genotypes, 1,044 on chow (CD) and 890 on high fat (HF).
  - The genotypes are 120 BXD strains, the parental strains C57BL/6J and DBA/2J, and the reciprocal F1 hybrids B6D2F1 and D2B6F1.
  - The BXD × BXD F1 hybrids of Part 2 are not in this file.
  - 98 genotypes have mice on both diets.
- **Excluded:** 172 females on high fat with 1% NAM.
- **Every mouse in the file died,** so there is no censoring. Each mouse is at risk from its age at set-up (26 to 877 days).

## Results

| | Chow | High fat |
|---|---|---|
| Females | 1,044 | 890 |
| MRDT (95% CI) | 153 d (144–163) | 149 d (140–159) |
| Median age at death | 683 d | 611 d |

- **The slopes do not differ.** The likelihood-ratio test of equal MRDTs gives P = 0.55, and the bootstrap difference is −4 days (95% CI −24 to +15).
- **High fat raises mortality 1.42-fold at every age** (95% CI 1.29–1.55), given a shared MRDT of 151 days. A Cox model agrees: hazard ratio 1.44, with no departure from proportional hazards (P = 0.85).
- **The numbers hang together.** A 1.42-fold rise is half a doubling (log2 1.42 = 0.50). With an MRDT of 151 days, half a doubling equals being 76 days older. The observed difference in median age at death is 72 days.

**In plain words:** on high fat, a BXD female has the mortality of a chow-fed female about 2½ months older, at every age. The diet moves the line up; it does not tilt it.

![Fig. 1](../output/Fig1_Gompertz_hazard.png)

**Fig. 1 | A high-fat diet raises mortality at every age without changing the mortality rate doubling time.** Mortality rates of BXD-family females fed chow (CD, brown; *n* = 1,044 mice of 119 genotypes) or a high-fat diet (HF, blue; *n* = 890 mice of 103 genotypes), as a function of age. Genotypes are 120 BXD strains, the parental strains C57BL/6J and DBA/2J, and the reciprocal F1 hybrids B6D2F1 and D2B6F1. Points show occurrence/exposure rates in 30-day intervals, in deaths per 1,000 mouse-days at risk, with each mouse at risk from its age at set-up (left truncation). Intervals with at least 20 mice at risk are shown; point diameter scales with the square root of the number of deaths. Lines show maximum-likelihood Gompertz fits, h(*t*) = *R*0 · 2^(*t* / MRDT), drawn over the ages covered by the data. The *y* axis is log2-scaled, so each gridline marks one doubling of mortality. The key gives each diet's mortality rate doubling time (MRDT) with its 95% Wald confidence interval (CI). The slopes do not differ (likelihood-ratio test, *χ*² = 0.36, 1 d.f., *P* = 0.55). With a shared slope (MRDT 151 days), HF mortality is 1.42-fold that of CD (95% CI 1.29–1.55; likelihood-ratio test of equal levels, *χ*² = 56, 1 d.f., *P* = 7 × 10⁻¹⁴), that is, 0.50 doublings higher at every age. All mice died; none are censored. Mice are treated here as independent; Fig. 5 analyses the diet effect within strains.

![Fig. 2](../output/Fig2_Survival_from200d.png)

**Fig. 2 | Survival and actuarial survivorships by diet.** **a**, Kaplan–Meier survival of mice alive at 200 days (CD, *n* = 1,018; HF, *n* = 865), each at risk from the later of its set-up age and 200 days. Dashed lines show survival predicted by the Gompertz fits of Fig. 1, conditional on survival to 200 days; median ages at death are given for each diet. **b**, Mean age at death of each diet's survivorship relative to both diets combined, as a function of the minimum inclusion age (T-age), in 15-day steps, as in Arends et al. 2026, Fig. 1b. Each survivorship includes the mice alive and under observation at that T-age. Lines indicate means and shaded bands represent s.e.m. Lines end where either diet falls below 20 mice (T935); numbers at the top give the mice alive (CD / HF). HF survivors die 65–69 days earlier than CD survivors up to T400. The difference narrows between T650 and T850, faster than the Gompertz fits predict, and reverses after T860, when few HF mice remain.

## Checks

| Analysis | Chow MRDT (95% CI) | High-fat MRDT (95% CI) | Equal slopes, P |
|---|---|---|---|
| Primary | 153 (144–163) | 149 (140–159) | 0.55 |
| Mice that survived to 200 d | 152 (142–163) | 152 (142–163) | 0.99 |
| Mice that survived to 365 d | 155 (142–168) | 177 (160–196) | 0.035 |
| BXD strains only | 156 (146–167) | 149 (139–159) | 0.31 |
| Binned regression from 200 d (de Magalhães et al. 2018) | 152 (143–162) | 144 (127–167) | – |

- **Early deaths do not drive the result.** Dropping deaths before 200 days leaves the two MRDTs identical.
- **One check disagrees.** Among mice that survived past a year, high fat has a *flatter* rise (MRDT 177 days, P = 0.035). It is one nominal result among four tests, uncorrected, so it is a lead, not a finding. A likely reason is the mixture effect of primer point 8: high fat removes frail mice sooner, which flattens the late part of its curve.
- **A Makeham term is not needed.** Adding a constant mortality that does not rise with age (Gompertz–Makeham) changes nothing; the constant comes out near zero.
- **Resampling tells the same story** (Fig. 4). Across 2,000 bootstrap resamples, the MRDTs of the two diets overlap almost completely, while their levels at 600 days do not overlap at all.

![Fig. 3](../output/Fig3_MRDT_estimates.png)

**Fig. 3 | Estimates of the mortality rate doubling time are robust to analytical choices.** MRDT (days) for CD (brown) and HF (blue) in the primary analysis (*n* = 1,044 and 890) and in five alternatives: mice surviving to 200 days (1,018 and 865) or to 365 days (944 and 792), each at risk from that age; BXD strains only (929 and 818); a Gompertz–Makeham fit; and the binned regression of de Magalhães et al. from 200 days. Points indicate estimates and bars indicate 95% CI: Wald intervals on the log scale of the slope, except in the bootstrap row (2.5th–97.5th percentiles of 2,000 resamples) and the binned-regression row (regression standard error). *P* values at right are from likelihood-ratio tests of equal slopes (1 d.f.). Only the mice surviving to 365 days give a nominally different slope (*χ*² = 4.4, *P* = 0.035, not corrected for the four tests); in that subset HF has the flatter rise. The Makeham constant is estimated near zero on both diets.

![Fig. 4](../output/Fig4_Bootstrap_level_MRDT.png)

**Fig. 4 | Resampling shows that the diets differ in the level of mortality, not in its doubling time.** **a**, Distributions of the MRDT across 2,000 bootstrap resamples per diet (mice resampled with replacement within diet; fixed seed), each fitted by maximum likelihood as in Fig. 1. **b**, Distributions of the mortality rate at 600 days, in deaths per 1,000 mouse-days (log2 scale), from the same resamples. Shaded curves are kernel density estimates. Points above the curves indicate full-data estimates and bars indicate 95% CI (2.5th–97.5th percentiles of the resamples). The MRDT distributions overlap almost completely: HF minus CD is −4 days (95% CI −24 to 15). The level distributions do not overlap: HF raises mortality at 600 days 1.42-fold (95% CI 1.28–1.57). The level is reported at 600 days, a typical age at death, rather than as *R*0, the rate extrapolated to birth. Across resamples, estimates of *R*0 and MRDT are tightly correlated (*r* = 0.95 for CD, 0.97 for HF; the Strehler–Mildvan correlation), so *R*0 changes whenever MRDT does. The level at 600 days is much less tied to MRDT (*r* = 0.19 and −0.64).

## The diet effect strain by strain (exploratory)

These analyses were added after the results above were seen (`Gompertz/Diet_by_strain.R`).

- **Within strains, high fat raises mortality about 1.8-fold, not 1.4-fold** (Fig. 5b).
  - A Cox model stratified by strain gives 1.78 (95% CI 1.61–1.98). A Gompertz fit with a level for each strain gives 1.76 (1.60–1.95).
  - The pooled estimate is smaller because pooling mixes strains whose mortality levels differ (primer point 8).
  - This is close to the 2.0 that Roy et al. (2021) report with strain as a random effect.
- **Within strains the MRDT is 113 days** (95% CI 108–117), against 151 days pooled. The pooled MRDT is that of a mixture.
- **Why the interval is so tight.** Each strain's own ratio is noisy. The stratified estimate combines within-strain comparisons from 98 strains and about 1,900 mice.
- **Strains differ in how much high fat harms them** (Fig. 5a).
  - Among the 76 genotypes with at least 5 mice per diet, the ratios spread more than chance allows (P = 0.0002). Within strain × vivarium, P = 0.004.
  - The between-strain standard deviation of the log ratio is 0.36. So about 95% of strains would have true ratios between about 0.9 and 3.8.
- **What we can say about single strains is limited.**
  - With 8–15 mice per diet, a strain's ratio must lie more than about 2- to 2.7-fold from the common ratio to stand out.
  - Only the largest groups do better: C57BL/6J (61 mice) and DBA/2J (74) resolve about 1.7-fold.
  - Eight genotypes depart from the common ratio at nominal P < 0.05, against 3.8 expected by chance.
  - **For single strains, use the shrunken estimates** in `output/Diet_by_strain.txt`. They pull each strain toward the common ratio in proportion to its noise.
- **A lead: the mother's strain.**
  - High fat raises mortality 2.2-fold in C57BL/6J but not at all in DBA/2J (1.00; P = 0.04 for the difference).
  - The reciprocal F1s follow their mothers: 2.5-fold in B6D2F1 (B6 mother) and 0.55 in D2B6F1 (D2 mother; P = 0.02).
  - The two F1s carry the same nuclear genome, so a maternal or mitochondrial effect is possible.
  - The numbers are small (17–35 mice per F1 type) and the P values uncorrected, so this is a lead, not a finding.

![Fig. 5](../output/Fig5_Diet_by_strain.png)

**Fig. 5 | Within strains, a high-fat diet raises mortality about 1.8-fold, and strains differ in how much.** **a**, Hazard ratio, HF / CD, in each of the 76 genotypes with at least 5 mice on each diet (*n* = 1,725 mice; 10–74 per genotype), plotted against the number of mice in the genotype. Ratios come from Cox proportional-hazards models fitted separately within each genotype, with each mouse at risk from its age at set-up. Both axes are log2-scaled. BXD strains are grey, the parental strains pink and the reciprocal F1 hybrids green. The solid line marks the common ratio (inverse-variance-weighted mean of the log hazard ratios, 1.79) and the thin line marks no effect. Dashed curves mark the approximate 95% range expected if every genotype shared the common ratio: ±1.96 × 2 / √*n* on the log scale, for equal numbers on the two diets. Genotypes differ more than chance allows (diet × strain likelihood-ratio test in a strain-stratified Cox model, *χ*² = 127.0, 75 d.f., *P* = 1.7 × 10⁻⁴). The difference persists within strain × vivarium strata (*P* = 0.004). The between-strain standard deviation of the log hazard ratio is 0.36 (DerSimonian–Laird; *I*² = 35%). Eight genotypes depart from the common ratio at nominal *P* < 0.05, against 3.8 expected by chance. C57BL/6J (2.23) and DBA/2J (1.00) differ (*P* = 0.04), as do the reciprocal F1s B6D2F1 (2.48) and D2B6F1 (0.55; *P* = 0.02); *P* values are uncorrected. **b**, The diet hazard ratio estimated five ways. Open points are pooled over all 124 genotypes: Cox, and Gompertz with a shared MRDT (as in Fig. 1). Filled points are within strains: Cox stratified by strain (98 genotypes on both diets); Gompertz with a level for each genotype and one MRDT; and the random-effects mean of the 76 estimates in **a**. Points indicate estimates and bars indicate 95% CI. The MRDT is given at right: 151 days pooled, against 113 days (95% CI 108–117) within strains. Exploratory: added after the results of Figs 1–4 were seen.

## Things to keep in mind

- **The MRDTs in Figs 1–4 are those of a mixture of 124 genotypes:** 120 BXD strains, the two parental strains and the two reciprocal B6D2 F1s. The BXD × BXD F1 hybrids of Part 2 are not included. Within strains the MRDT is 113 days (Fig. 5b).
- **Vivarium and cohort are not adjusted for in Figs 1–4.** The design is balanced by strain across diets. Stratifying by strain and vivarium leaves the within-strain ratio unchanged (1.85 in the 76 genotypes of Fig. 5a).

---

# Part 2. Does genotype change the mortality rate doubling time? BXD proximal Chr 1 and F1 hybrids

## The plan, fixed before any fit

Two tests were written into an analysis plan and committed before any fit was made (`notes/PREREGISTRATION_secondary.md`, 24 October 2026). Claude wrote the plan. Its amendments record what Rob did and did not agree to.
- **H1, proximal Chr 1.** BXD strains with D across proximal Chr 1 (3–30 Mb, covering Vita1a and Vita1b) against strains with B across it. Two-tailed: Rob had no prediction about the direction of any change in MRDT.
- **H2, F1 hybrids.** BXD × BXD F1 hybrids against their inbred parents.
  - **Rob's question,** before the plan was written: "Does being an F1 flatten the MRDT. For me this is a pre-registered one-tailed test."
  - **Claude read "flatten" as a longer MRDT** and tested that direction.
  - **Rob's prediction, as he stated after the results:** "I was guessing that F1 hybrids would be more vigorous and more buffered to the hard knocks of being a mouse born into a vivarium from the moment of birth and throughout life. Full stop. This is not a rate of change assertion."
  - **So Rob's prediction was about level:** F1 mortality lower at every age.

Each test fits one MRDT per group, shared by both diets, and a separate level for each group and diet. Mice are counted from 200 days. Uncertainty comes from the delete-one-strain jackknife.

## Results

| Test | MRDT, first group | MRDT, second group | Ratio (95% CI) | P |
|---|---|---|---|---|
| H1: D strains / B strains | B: 141 d | D: 154 d | 1.10 (0.80–1.51) | 0.57, two-tailed |
| H2: F1 hybrids / inbred parents | Parents: 165 d | F1: 107 d | 0.65 (0.43–0.97) | 0.98, one-tailed for a longer F1 MRDT |

**H1: proximal Chr 1 changes the level of mortality, not the MRDT.**
- **Level, on high fat:** at 600 days, B strains die at 5.8 per 1,000 mouse-days and D strains at 2.8, about twice as fast.
- **Level, on chow:** 3.1 against 2.5, a ratio of 1.25.
- **The D haplotype nearly cancels the high-fat penalty.** High fat raises mortality at 600 days 1.86-fold in B strains but only 1.15-fold in D strains. This matches the diet dependence of Vita1a and Vita1b on lifespan, and it acts through the level.

**H2: the F1 MRDT is not longer. It is shorter.**
- **The registered direction is not supported.** Under the plan, the opposite direction is reported as an estimate, not a discovery.
- **Rob's prediction holds where it matters most.** The effect lies in the crosses between short-lived strains:

| Comparison | Parents | F1s | Ratio of MRDTs (95% CI) |
|---|---|---|---|
| Short × short F1s / short-lived parents (BXD9, 170, 172, 197) | 156 d | 98 d | 0.63 (0.49–0.81) |
| Long × long F1s / long-lived parents (BXD65, 73b, 77, 102) | 110 d | 105 d | 0.95 (0.72–1.27) |
| B6D2F1 and D2B6F1 / C57BL/6J and DBA/2J | 116 d | 134 d | 1.15 (0.86–1.55) |

- **The short × short F1s start far lower.** At 600 days on chow they die at a quarter of their parents' rate: 1.4 against 5.4 per 1,000 mouse-days.
- **Their mortality then rises faster.** The curves would meet near 1,100 days on chow and near 950 days on high fat. So the hybrids gain most in early and middle adult life, and the gain narrows with age.

![Fig. 6](../output/Fig6_MRDT_ratios.png)

**Fig. 6 | The F1 hybrids of short-lived BXD strains have a shorter mortality rate doubling time than their parents; the proximal Chr 1 haplotype does not change it.** Ratio of the MRDT of the second group to that of the first (log2 scale) for each comparison; values below 1 mean a steeper rise of mortality with age in the second group. The MRDTs (second / first, days) are given at right. Females surviving to 200 days, each at risk from the later of its set-up age and 200 days. Each group has one MRDT, shared by its diets, and each group × diet cell has its own level. Points indicate estimates. Bars indicate 95% CI from a delete-one-strain jackknife (delete one F1 type for the F1 comparisons), except for S2, which has four genotypes and uses a Wald interval. The two registered tests used *t* = log2 ratio / jackknife s.e., each at *α* = 0.025. H1, D strains / B strains across proximal Chr 1 (*n* = 459 mice of 34 strains and 483 of 33): ratio 1.10 (95% CI 0.80–1.51), *t* = 0.58, 66 d.f., two-sided *P* = 0.57. H2, F1 hybrids / inbred parents (*n* = 320 mice of 13 F1 types and 218 of 8 strains): ratio 0.65 (0.43–0.97), *t* = −2.26, 20 d.f., one-sided *P* = 0.98 for the registered direction, a longer F1 MRDT. Secondary analyses (S1–S6) were specified in advance and are shown as estimates only; the largest is S1, short × short F1s / short-lived parents, 0.63 (0.49–0.81). Open points are exploratory refits, made after the registered results were seen, that give each genotype × diet cell its own level.

![Fig. 7](../output/Fig7_Hazard_by_class.png)

**Fig. 7 | F1 hybrids start with lower mortality and lose their advantage with age; across the Vita1a–Vita1b interval, D and B strains differ in level, not slope.** **a**,**b**, Mortality rates of BXD strains homozygous for the D haplotype (orange) or the B haplotype (purple) across the whole of proximal chromosome 1, from the first marker at 3.0 Mb to 30 Mb, on chow (**a**) and high fat (**b**). This interval spans Vita1a and Vita1b of Arends et al. 2026. Haplotypes were called from sequence-based BXD genotypes (441 markers in the interval). Strains with a recombination in the interval (48 in these data) or with a heterozygous block are excluded. *n* = 459 females of 34 D strains and 483 of 33 B strains alive at 200 days. **c**,**d**, Mortality rates of 13 types of BXD × BXD F1 hybrid (green; *n* = 320) and their 8 inbred parental strains (pink; *n* = 218) on chow (**c**) and high fat (**d**). Points show occurrence/exposure rates in 60-day intervals, in deaths per 1,000 mouse-days at risk, where at least 10 mice were at risk; point diameter scales with the square root of the number of deaths. Lines show the registered model, fitted by maximum likelihood from 200 days and drawn over the ages covered by the data: one MRDT per group, shared by both diets, and a level for each group × diet cell. The *y* axis is log2-scaled. *n* in the keys is the number of females alive at 200 days. The registered tests are given in Fig. 6 (H1, *P* = 0.57; H2, *P* = 0.98). At 600 days on high fat, B strains die at 5.8 and D strains at 2.8 per 1,000 mouse-days; on chow, at 3.1 and 2.5. On chow at 600 days, short × short F1s die at a quarter of their parents' rate (1.4 against 5.4).

## Exploratory checks, added after the registered results were seen

- **A level for each genotype.** The registered model pools genotypes with different levels, which flattens a group's curve (primer point 8). Giving each genotype × diet its own level:
  - halves the overall F1 gap (ratio 0.79, 95% CI 0.61–1.02);
  - leaves the short × short steepening unchanged (0.62, 0.45–0.84);
  - leaves H1 null (0.98).
  - MRDTs within genotypes are mostly 86–110 days.
- **Gamma-Gompertz.** This model lets mice within a group differ in frailty. The B strains and the inbred parents need no frailty term; the D strains and the F1s do. With it, H1 reverses sign. So there is no consistent evidence that proximal Chr 1 changes the MRDT.

## A model: how many genes make the F1 difference?

This is a model, not an analysis of data. It asks Sewall Wright's question of the F1 experiment: do a few or many recessive loci explain the hybrids' gains?
- **The setup.** Inbred strains carry a "load" of homozygous harmful alleles at 10 or 200 loci. An F1 expresses a harmful recessive only where both parents carry it.
- **Two ways for load to act:**
  - **multiply:** load multiplies the age-rising Gompertz mortality, so it changes the level only;
  - **add:** load adds deaths of its own that rise slowly with age, the "hard knocks".
- **What the model shows** (Fig. 8):
  - **How load acts sets which F1s gain more.** Under "add", hybrids of short-lived strains gain more than hybrids of long-lived strains.
  - **The number of loci sets how large the gains are.** With 200 loci, F1s would outlive their parents by 550–1,000 days, far more than observed.
  - **The data fit a few effective factors, with load adding its own deaths.** Observed gains are 178 days for short × short F1s and 32 days for long × long. The model with 10 loci predicts 177 and 121 days.
- **The insight.** In this model, a short-lived inbred strain has a long MRDT because its extra deaths from load rise slowly with age. Its long MRDT is a sign of load, not of slower aging. Removing the load in the F1 leaves a steeper rise, as observed.

![Fig. 8](../output/Model_effective_factors.png)

**Fig. 8 | A few effective factors, with load that adds its own deaths, reproduce the F1 gains and their steeper rise of mortality.** Simulated BXD strains carry 10 or 200 recessive loci. Load either multiplies the Gompertz hazard ("multiply") or adds a hazard of its own that doubles every 300 days ("add"). Each model is calibrated so that inbred strains live 400–950 days. **a**, Gain in mean age at death of F1s over the mean of their two parents (days), for short × short (filled) and long × long (open) crosses. Points indicate medians and bars indicate the 10th–90th percentiles of 200 simulated experiments (fixed seed). At right are the observed gains of the 13 F1 types, each shown as a small point. **b**, MRDT of parents (squares) and F1s (circles), one per group, for the short-lived (filled) and long-lived (open) sets. Exploratory model, not a fit to the data.

## In plain words

- **Proximal Chr 1** changes *how many* BXD mice die at a given age, especially on high fat, but not *how fast* their risk doubles.
- **Crossing two short-lived BXD strains** gives hybrids that are much less likely to die in early and middle adult life. Their risk then climbs faster, so by very old ages they lose much of their advantage.

---

# Part 3. Vita1a and Vita1b in UM-HET3 mice

## 3.1 Why look at UM-HET3 mice

- **Arends et al. 2026** mapped 29 lifespan loci (Vita loci) in 6,438 genotyped UM-HET3 mice. Two of them lie on proximal Chr 1:
  - **Vita1a,** 3.0–8.0 Mb, peak at 3.0 Mb (marker 1_3010274), with its highest LOD in the T860 survivorship;
  - **Vita1b,** 16.0–31.1 Mb, peak at 24.0 Mb (marker 1_24042124), with its highest LOD at T695.
- **This is the same region as the BXD Chr 1 test (H1, 3–30 Mb).** So we asked of the UM-HET3 mice the question we asked of the BXDs: does proximal Chr 1 change the level of mortality, its MRDT, or both?
- **Arends et al. describe Vita1a and Vita1b as "durable, late" loci.** Their effects on life expectancy are stable from T42 to about T890, but their effects on mortality are concentrated late in life (their Fig. 1h,i and Table 1).

**UM-HET3 genetics in brief.**
- **Mothers** are CByB6F1 (BALB/cByJ × C57BL/6J), so each mouse inherits a maternal **C** or **B** haplotype.
- **Fathers** are C3D2F1 (C3H/HeJ × DBA/2J), so each mouse inherits a paternal **H** or **D** haplotype.
- **That gives four genotypes at every locus:** CH, CD, BH and BD, expected in equal numbers.
- **Every UM-HET3 mouse is heterozygous.** The B and D haplotypes are the same as in the BXDs, but B comes only from mothers and D only from fathers. So the UM-HET3 contrast that involves D is **D against H** (DBA/2 against C3H), not D against B.

## 3.2 Data

- **Supplementary Data Table 2 of Arends et al.** Deaths per 15-day window and numbers alive by genotype, for each Vita locus, for females, males and both sexes. As published, no file names its first column. Clean copies with the header fixed, each checked for internal consistency, are in `data/umhet3/Table2/`.
  - **The checks:** columns add up; numbers alive fall by exactly the deaths; female + male = combined. All 87 files pass.
- **The Vita1a block of Rob's expanded Table 1** (sheet Table_1f) is Table 2's both-sexes file. Its columns are in the order CH, CD, BH, BD, not as labeled (CH, BH, BD, CD).
- **Individual mice** (Supplementary Table 7, the R/qtl file used for mapping): age at death, sex, site, cohort, drug group and every marker call. We used it to check the genotype calls and to refit by site.

## 3.3 Problems with the haplotypes and genotypes

### What we expected and what we found

- **Expected:** paternal H and D in equal numbers at every locus. Each father passes on his C3H or his DBA/2 copy with a probability of one half.
- **Found:** at Vita1a and Vita1b, Table 2 has twice as many paternal H as paternal D.

| Locus | Paternal H : D | Maternal C : B | Mice with a call, of 6,438 |
|---|---|---|---|
| Vita1a | 2.02 | 0.96 | 3,133 |
| Vita1b | 1.91 | 0.95 | 5,174 |
| Vita1d | 1.39 | 0.98 | 4,764 |
| Vita1c | 1.15 | 1.04 | 5,485 |
| 25 loci off Chr 1 | 0.91–1.11 | 0.88–1.07 | 2,753–6,319 |

The excess is paternal only, on Chr 1 only, and in both sexes.

### How a genotype is called in a four-way cross

- **Most markers report only one parent.** At most SNPs, the two mother strains carry the same allele, so the SNP can only tell which haplotype came from the father. At other SNPs it is the reverse.
- **R/qtl codes each call accordingly:** 7 = father H, 8 = father D, 5 = mother C, 6 = mother B, with codes 1–4 for the rare full calls.
- **We confirmed the codes on the X chromosome.** Every daughter receives her father's X, and a C3D2F1 father's X comes from his C3H mother. Females on X carry only "father H" codes.
- **The genotype at a Vita peak is inferred** from the nearest markers that report the father and the nearest that report the mother.

### Four lines of evidence that the excess is a genotyping error (Fig. 9)

1. **Two SNPs 2 bp apart disagree.** At 3.01 Mb, 1_3010272 gives 42% H and 1_3010274 gives 71% H. No recombination can occur in 2 bp.
   - In the 741 mice called at both SNPs, the two agree in every mouse (42% H).
   - All of the excess comes from 1,825 mice called only at 1_3010274, which are 82% H.
   - The same holds at 31.06 Mb, for two SNPs 21 bp apart: in mice called at both, 52% H; in the 3,238 called only at 1_31062737, 74% H.
2. **The error is confined to two sites.**
   - At **JL** (Jackson Laboratory) every proximal Chr 1 marker gives 48–52% H.
   - At **UM** (Michigan) and **UT** (UT Health San Antonio), 1_3010274 gives 77% and 70% H, and 1_31062737 gives 73% and 75%.
   - The sites were also typed with partly different marker sets. UT mice have no call at 4.34 Mb at all.
3. **The Vita1b error depends on the mother's haplotype.** At UM and UT, when the mother's haplotype at 24 Mb is B, the 31.06 Mb marker calls the father H in 94% (UM) and 99% (UT) of mice. When the mother's haplotype is C, it does so in 51%.
   - A distortion in the fathers' transmission could not depend on the mother's allele.
   - BD itself cannot be lethal: B6D2F1 hybrids are B/D at every locus and live long.
   - **So at UM and UT, true BD mice are called BH.** This is the "BD-only" deficit at Vita1b.
4. **There is a hole in the map.** No marker reports the father's haplotype between 4.3 and 31.1 Mb. So the paternal call at the Vita1b peak (24 Mb) must be inferred from the faulty 31.06 Mb marker. This is the map problem "right after Vita1b" that Rob recalled.

**The likely mechanism** is heterozygous calls lost to allele dropout. At these SNPs the C3H allele matches the mothers' allele, so a paternal-D mouse is heterozygous. If its DBA/2 allele is not seen, it looks homozygous and is called "father H".

**Two consequences for any analysis of Vita1a and Vita1b:**
- **Misclassification:** many D mice sit in the "H" group, which dilutes any genotype difference.
- **Composition:** the miscalls cluster by site and cohort. The "H" group is therefore enriched for UM and UT mice and for particular cohorts, which differ in lifespan. Any genotype comparison that pools sites can mix in site and cohort effects.

**Lessons for the new low-pass sequencing (1–3X, Ultima Genomics).**
- **Low depth will under-call heterozygotes at single SNPs.** That is the same failure as here, only more general. Calls should come from haplotype-aware imputation across many SNPs, not from single sites.
- **Two routine checks:**
  - the paternal and the maternal ratio along every chromosome, by site and by batch, which should be 1:1;
  - the fraction of heterozygous calls at each SNP.
- **The JL mice are a natural benchmark,** because their MonsterPlex calls on proximal Chr 1 look clean.

![Fig. 9](../output/Fig9_UMHET3_Chr1_genotype_calls.png)

**Fig. 9 | Paternal genotype calls on proximal Chr 1 are biased towards H at two of the three sites.** **a**, Fraction of paternal calls that are H (C3H/HeJ) rather than D (DBA/2J) at each proximal Chr 1 marker that reports the father's haplotype, by site: JL, Jackson Laboratory (circles); UM, University of Michigan (triangles); UT, UT Health San Antonio (squares). Point area scales with the number of calls. Shaded bands mark the Vita1a and Vita1b intervals of Arends et al. 2026; ticks at the bottom mark markers that report only the mother's haplotype. The dashed line marks the expected 0.5. **b**, Fraction of paternal calls that are H at 1_31062737 (31.06 Mb) by site, for mice whose maternal haplotype at 1_24042124 (24.0 Mb) is B (purple) or C (grey). Numbers give mice called at both markers. The bias follows the genotyping marker set rather than the site. Arends et al. Supplementary Table 5 holds two MonsterPlex marker sets. All JL mice were genotyped with one set, and the other set was used for 1,497 of 2,750 UM mice and all 1,883 UT mice. That second set loses heterozygous calls at 11 incidental SNPs, including 1_3010274 and 1_31062737 (`UMHET3/vcf_set_check.R`). Data: 6,438 mice of Arends et al. Supplementary Table 7.

## 3.4 Initial findings

### Using the published Table 2

Each sex gets its own curves, because male and female MRDTs differ greatly.
- **About male MRDTs:** male mortality is higher than female mortality in mid-life (about 1.1 against 0.55 deaths per 1,000 mouse-days at 600 days). It doubles more slowly (MRDT about 155 against 100 days), so the sexes converge by about 860 days.
- **Why separate curves:** pooling the sexes mixes two different curves and overstated the genotype effect on MRDT (P = 0.005 pooled).

From 200 days of age:

| Contrast | Sex | MRDT, D group | MRDT, other | Mortality ratio at 600 d | at 860 d |
|---|---|---|---|---|---|
| Vita1a: paternal D / H | Females | 94 d | 101 d | 1.19 | 1.36 |
| | Males | 146 d | 159 d | 1.25 | 1.38 |
| Vita1b: BD / CH, CD, BH | Females | 97 d | 105 d | 1.16 | 1.33 |
| | Males | 139 d | 152 d | 1.29 | 1.44 |

- **Level.** Paternal D at Vita1a, and BD at Vita1b, raise mortality about 1.2-fold at 600 days and about 1.4-fold at 860 days, in both sexes.
- **Slope.** The ratio grows with age, so the D group's MRDT is shorter. A test that lets each sex have its own curves, and asks whether D changes the slope by the same amount in both, gives P = 0.041 for Vita1a and P = 0.046 for Vita1b. The two sexes do not differ (P = 0.8).
- **These are not two independent results.** The loci are 20 Mb apart on one chromosome and share the faulty markers.

### Checking the result where the calls are clean

We refitted from individual mice, using each mouse's raw marker calls, by maximum likelihood. Each site × cohort has its own level, so genotypes are compared within cohorts.

| Vita1a, paternal D / H | Sex | n, H / D | MRDT, H / D | Ratio at 600 d | at 860 d | Equal slopes, P |
|---|---|---|---|---|---|---|
| JL (clean calls) | Females | 274 / 343 | 88 / 105 d | 1.29 | 0.92 | 0.007 |
| | Males | 414 / 385 | 140 / 134 d | 0.97 | 1.03 | 0.48 |
| UM + UT (biased calls) | Females | 775 / 419 | 104 / 99 d | 1.22 | 1.33 | 0.31 |
| | Males | 1,006 / 442 | 144 / 132 d | 1.17 | 1.31 | 0.13 |
| All three sites | Both sexes | | | 1.10–1.22 | 1.18–1.21 | 0.22 (2 df) |

- **At JL, paternal H and D are about 1:1** (D is 56% of females and 48% of males). There is no distortion where the genotyping is clean.
- **The level effect of paternal D survives.** Within cohorts it raises mortality about 1.2-fold at 600 days at UM and UT, in both sexes, and 1.3-fold in JL females.
- **The slope effect does not survive.**
  - At UM and UT the D group's MRDT is a little shorter, but not significantly.
  - At JL the females go the other way: D is *flatter* (MRDT 105 against 88 days, P = 0.007), with a gap that closes by 860 days. JL males show no difference.
  - Across all sites, P = 0.22.
- **Vita1b cannot be judged outside JL,** because BD mice are almost never called at UM and UT. At JL, BD females have 1.36-fold mortality at 600 days and 1.14-fold at 860 days; BD males show no difference. Neither slope differs.
- **The late-life rise of the D/H ratio seen in Table 2 comes from UM and UT** (Fig. 10c, d). At JL it is not seen. We cannot yet tell whether JL simply differs, or whether the late-life pattern partly reflects the miscalls. Re-genotyped data should settle it.

**For comparison with Arends et al.:** their Fig. 1 describes D as strongly disadvantageous before 900 days and H after 1,000 days. In Table 2, the D/H ratio in both sexes combined is above 1 to 1,100 days (1.7 at 1,000–1,100 days) and falls to 0.95 after 1,100 days, when few D mice remain.

![Fig. 10](../output/Fig10_UMHET3_Vita1a_by_sex.png)

**Fig. 10 | At Vita1a, the paternal D haplotype raises mortality in both sexes; its growing effect with age is seen only at the two sites with biased calls.** **a**,**b**, Mortality rates of UM-HET3 females (**a**) and males (**b**) by paternal Vita1a haplotype, H (C3H/HeJ, grey) or D (DBA/2J, orange), from the published Supplementary Table 2 (all sites). Points show rates in 60-day intervals, in deaths per 1,000 mouse-days, where at least 20 mice were at risk; point area scales with the number of deaths. Lines show Poisson Gompertz fits from 200 days, with a level for each of the four genotypes and an MRDT for each paternal haplotype. Each line is the geometric mean of its haplotype's two genotypes. *n* is the number of mice genotyped. A slope change shared by the sexes gives *P* = 0.041 (likelihood-ratio test, 1 d.f.); the sexes do not differ in it (*P* = 0.80). **c**,**d**, Mortality ratio, paternal D / H, by age window (log2 scale), for females (**c**) and males (**d**). Grey squares and line show Table 2, all sites. The other points use individual mice and raw marker calls (1_3010272, 1_3010274 and 1_4344820, where they agree), at JL (black circles) and at UM and UT (teal triangles). Bars indicate 95% CI from the Poisson counts of deaths. Fitted to individual mice, with a level for each site × cohort, the slope change is not supported (*χ*² = 3.1, 2 d.f., *P* = 0.22). Exploratory; *P* values are not corrected for multiple tests.

## 3.5 UM-HET3 females against BXD chow females

| Females, from 200 days | BXD, chow | UM-HET3 (Table 2, all sites) |
|---|---|---|
| Contrast | D strains / B strains, proximal Chr 1 | Paternal D / H, Vita1a |
| Mice | 249 D, 260 B | 499 D, 969 H |
| MRDT | D 155 d, B 157 d | D 94 d, H 101 d |
| Mortality at 600 d, per 1,000 mouse-days | D 2.49, B 3.17 | D 0.64, H 0.53 |
| Mortality ratio at 600 d, D / other | **0.79** | **1.19** |

**Three points:**

1. **UM-HET3 females die at a much lower rate in mid-life, but their mortality rises faster.**
   - At 600 days their mortality is about a fifth of the BXD chow females'.
   - Their MRDT is about 100 days against 155. The curves meet near 1,000 days (Fig. 11a).
   - This is the same pattern as the BXD F1 hybrids against their inbred parents in Part 2: lower level, steeper rise. UM-HET3 mice are four-way hybrids, heterozygous almost everywhere.
   - The BXD MRDT of 155 days is that of a mixture of about 67 strains (primer point 8). Within single strains it is closer to 105 days, near the UM-HET3 value.
   - The colonies, diets and eras differ, so compare shapes more than absolute levels.
2. **The D haplotype on proximal Chr 1 points in opposite directions.**
   - In BXD chow females, D lowers mortality relative to B (ratio 0.79 at 600 days; on high fat, 0.47).
   - In UM-HET3 females, paternal D raises it relative to H (1.19).
   - **This need not be a contradiction,** because the comparisons differ: the BXDs compare D with B, and UM-HET3 mice compare D with C3H. In UM-HET3 mice the maternal B and C haplotypes do not differ (Table 2 levels: BH 0.52 against CH 0.55, BD 0.65 against CD 0.62).
   - **Two readings fit:**
     - **A protective C3H allele.** If C3H carries an allele that B6, BALB/c and DBA/2 lack, "H is good" in UM-HET3 mice and B and D do not differ at that variant. The BXD difference would then come from a different variant in the interval.
     - **Different variants within a large interval.** Vita1b spans 15 Mb.
   - **The founder sequence variants can separate these readings** (Supplementary Table 17, now on Rob's computer). For example: sites at 3–8 Mb where C3H differs from the other three founders.
   - The genotyping problems mean the UM-HET3 contrast itself needs confirmation.
3. **Neither population shows a convincing proximal Chr 1 effect on MRDT.**
   - BXD chow: 155 against 157 days (Part 2, with the strain jackknife).
   - UM-HET3: the Table 2 slope signal does not survive the site and cohort check.
   - **In both populations, Chr 1 acts on the level of mortality.**

![Fig. 11](../output/Fig11_BXD_vs_UMHET3_females.png)

**Fig. 11 | Proximal Chr 1 acts on the level of mortality in both populations, in opposite directions for the D haplotype.** **a**, Mortality rates of BXD females on chow by proximal Chr 1 haplotype (filled circles and solid lines: B strains purple, *n* = 260; D strains orange, *n* = 249). Also shown are UM-HET3 females by paternal Vita1a haplotype (open triangles and dashed lines: H grey, *n* = 969; D orange, *n* = 499). Rates are in 60-day intervals from 200 days (log2 scale); point area scales with the number of deaths. Lines show Gompertz fits: for BXD, one MRDT per haplotype class with strains pooled (Part 2, analysis S4); for UM-HET3, as in Fig. 10a. **b**, Mortality ratio of D to the other haplotype by age window (log2 scale): BXD chow, D strains / B strains (black circles); UM-HET3, paternal D / H (open triangles; Table 2, all sites). Bars indicate 95% CI from the Poisson counts of deaths. At 600 days the ratio is 0.79 in BXD (D / B) and 1.19 in UM-HET3 (D / H). The UM-HET3 comparison is with C3H/HeJ, not C57BL/6J, so the two ratios need not agree. Exploratory.

## 3.6 What next

1. **Re-genotype proximal Chr 1** with the low-pass sequencing, using imputation and the ratio checks above. Then refit Vita1a and Vita1b by sex, site and cohort. Until then, treat the UM-HET3 Chr 1 results as provisional.
2. **Founder variants at Vita1a and Vita1b** (Supplementary Table 17), to test the "protective C3H allele" reading.
3. **Level and MRDT for all 29 Vita loci, by sex,** from Table 2, as a principled redo of the "rate of aging modulator" list. Treat the four Chr 1 loci with care.
4. **A Makeham check** on the short-lived BXD parents against their short × short F1s: do the parents carry extra deaths that rise little with age, as the model in Fig. 8 suggests?

---

## Appendix: files

All paths are in the repository.

| What | Code | Output |
|---|---|---|
| Part 1 | `Gompertz/MRDT_Diet.R`, `Gompertz/Diet_by_strain.R`, `Gompertz/Figures_MRDT_Diet.R` | `output/MRDT_by_diet.txt`, `output/Diet_by_strain*.txt`, Figs 1–5 |
| Part 2 | `Gompertz/MRDT_Secondary.R`, `Gompertz/Figures_MRDT_Secondary.R` | `output/MRDT_secondary_*.txt`, Figs 6–7 |
| Part 2 model | `Models/effective_factors.R`, `Models/fig_effective_factors.R` | `output/Model_effective_factors.*` (Fig. 8) |
| Table 2, clean copy | `UMHET3/clean_table2.R` | `data/umhet3/Table2/` |
| Genotype checks | `UMHET3/chr1_marker_check.R`, `UMHET3/vcf_set_check.R` | `output/UMHET3_markers_*.txt`, `output/UMHET3_31Mb_father_by_mother.txt`, `output/UMHET3_VCF_*` |
| Table 2 fits by sex | `UMHET3/vita1a_gompertz.R`, `UMHET3/vita_sex_stratified.R` | `output/UMHET3_Vita1_sex_stratified.txt` |
| Fits by site and cohort | `UMHET3/vita1_site_check.R` | `output/UMHET3_Vita1_site_check.txt` |
| Part 3 figures | `UMHET3/Figures_Part3.R` | Figs 9–11 |

**Sources.**
- Arends D, Ashbrook DG, Roy S, … Miller RA, Williams RW (2026). Dynamics of genetic and somatic trade-offs in ageing and mortality. *Nature* 654:437.
- Roy S, Bou Sleiman M, Jha P, … Auwerx J, Williams RW (2021). Gene-by-environment modulation of lifespan and weight gain in the murine BXD family. *Nature Metabolism* 3:1217–1227.
- de Magalhães JP, et al. (2018). A reassessment of genes modulating aging in mice using demographic measurements of the rate of aging. *Genetics* 208:1617–1630.

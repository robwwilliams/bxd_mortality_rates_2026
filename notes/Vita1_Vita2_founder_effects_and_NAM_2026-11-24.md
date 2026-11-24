# Vita1 and Vita2: founder effects from both families, and nicotinamide by Vita1 genotype

**Exploratory, 24 November 2026,** by Claude (Opus 5.5) for Rob Williams, after the maps were seen. Rob: "Just do them both."

## 1. The effect of each founder allele, from BXD and UM-HET3 together

**Method** ([`founder_effects_joint.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/founder_effects_joint.R) in the fork).
- **Three contrasts, from two families, fix all four founder effects** up to a constant:
  - BXD *D* − *B*, a homozygote difference, so twice the per-allele effect;
  - UM-HET3 paternal *D* − *H*;
  - UM-HET3 maternal *B* − *C*.
- **Effects are in days of lifespan per allele, relative to *B*,** at each UM-HET3 marker on Chr 1 (0–45 Mb) and Chr 2 (100–182 Mb).
- **Data:** females; BXD on chow; three life stages matched on the 40-day grid.
- **Assumptions:** additivity, and the same allele effects in both families. Nothing here tests that, because three contrasts leave no degrees of freedom.

[![Founder effects](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Founder_effects_joint.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Founder_effects_joint.png)

**Per-allele effects, mean over the markers in each interval** (± s.e.; [`founder_effects_joint_summary.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/founder_effects_joint_summary.txt)):

| Interval | Early life (BXD T110, UM-HET3 T125) | Middle (T410, T525) | Late (T740, T965) |
|---|---|---|---|
| Vita1a, 3–8 Mb | H +43, D +24, C +1: **H > D > C ≈ B** | H +33, D +11, C −5 | H +19, D +12, C −5 |
| Vita1b, 22–26 Mb | H +42, D +34, C −2 | H +22, D +13, C −6 | H +8, D +2, C −5 |
| Vita1y, 34–38 Mb | **D +14 > H +4**, C −6 | D +7, H −4, C −11 | D +8, H +4, C −6 |
| *Mrps5* locus, 124–129 Mb | H +36, C −4, D −2 | H +26, C +2, D −7 | C +6, H +1, D −8 |
| UM-HET3 peak, 140–153 Mb | H +18, C −2, D −17 | H +17, C +2, D −15 | C +7, H −3, D −12 |
| Vita2b, 153–159 Mb | **D −38**, H −5, C 0 | D −25, H +6, C +1 | D −13, H −2, C +7 |

What the table says:
- **Vita1a and Vita1b: the allelic series *H* > *D* > *B* holds at every life stage,** with *C* close to *B* (the flat maternal map). *D* is +11 to +34 days per allele and *H* +8 to +43, shrinking toward late life. The two families' "opposite signs" are one ordering of founders. The same ordering at Vita1a and Vita1b may mean the two share a haplotype structure, or that the UM-HET3 calls, biased toward *H* on proximal Chr 1, color both.
- **Vita1y differs: *D* is the best allele** (*D* > *H*, and both above *B*). It is a separate locus from Vita1a and Vita1b in founder terms too.
- **Distal Chr 2: *D* is the worst allele from 105 to 157 Mb,** bottoming at Vita2b (−38 days per allele early in life), while *H* is the best up to about 150 Mb.
- **A sharp boundary near 158–160 Mb:** beyond it, *D* and *H* both turn positive. With *Mrps5* (127.6 Mb) in the long *D*-negative stretch, Chr 2 looks like at least two loci with different founder orderings, as Rob expected ("a set of loci and sets of DNA variants").

**Cautions:**
- UM-HET3 has 891 markers, so the lines are drawn between sparse points.
- The standard errors are per marker, about ±6–15 days, and neighboring markers are not independent.
- BXD chow alone is used here; high fat would change the BXD contrast at Vita1b and Vita2b, where the BXD loci are high-fat loci.

## 2. Nicotinamide by Vita1 genotype

**The grant's pilot result** (Mozhui, Roy, Bajwa et al., R01 resubmission, June 2026): "NAM rescues the effect of HFD only in mice with the B allele, and this GxE interaction is particularly strong at Vita1b."

**Method** ([`Gompertz/NAM_by_Vita1.R`](../Gompertz/NAM_by_Vita1.R); results in [`output/NAM_by_Vita1.txt`](../output/NAM_by_Vita1.txt)).
- **Mice:** BXD females at TSRB, on high fat or on high fat + 1% NAM, with Beni's corrected NAM ages.
- **Genotypes** at Vita1a (5.02 Mb) and Vita1b (23.52 Mb).
- **The strain is the unit.**

| Analysis | Strains | Vita1a: genotype × NAM | Vita1b: genotype × NAM |
|---|---|---|---|
| Strain means on HF and on NAM (different strains in each arm) | 34 HF, 21 NAM | HF: B 503, D 577 days; NAM: B 594, D 623 | HF: **B 464, D 587**; NAM: **B 617, D 587** |
| Paired: strains with ≥ 3 mice in both arms | 8 | D − B, NAM effect +8 days, P = 0.98 | −71 days (B +98, D +27; only 2 B strains), P = 0.71 |
| Every TSRB mouse, mixed model with a random strain intercept | 66 (26 with NAM) | −96 days; mouse-level P = 0.035, **strain permutation P = 0.24** | −121 days; mouse-level P = 0.009, **strain permutation P = 0.14** |

- **The direction and size match the grant:** NAM helps *B* strains by about 100–120 days more than *D* strains, and at Vita1b it closes the *D* advantage on high fat.
- **With the strain as the unit, it is not significant yet.** Only 26 strains have NAM mice, and only 8 have three or more mice in both arms.
- **A crossover interaction like this would explain the null average effect** of NAM in Part 5: gains in *B* strains cancel losses in *D* strains.
- **Caution:** NAM mice were born about three years after most high-fat controls, and at TSRB mortality rose with year of birth. If the high-fat controls of *B* and *D* strains differ in birth year, that can mimic an interaction. Birth-year-matched controls are the next check.
- **What would settle it:** more strains with mice in both arms, chosen by Vita1a and Vita1b genotype. That fits the design of Aim 1 of the grant.

### Birth year at TSRB (added the same day, at Rob's question)

| Born | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 |
|---|---|---|---|---|---|---|---|---|---|
| High fat | 11 | 34 | 39 | 62 | 16 | 3 | **0** | 12 | 38 |
| High fat + NAM | 0 | 0 | 0 | 9 | 19 | 2 | **100** | 13 | 0 |

- **Not a hard confound, but not matched either.** TSRB high-fat controls were born on both sides of the NAM cohort (131 from 2018 on), but none in 2021, when 100 of the 143 NAM mice were born.
- **With birth year as a covariate,** genotype × NAM stays at −89 days (Vita1a) and −97 (Vita1b); mouse-level P = 0.035 and 0.024; strain permutation P = 0.21 and 0.18.
- **With high-fat controls born from 2018 on** (54 strains), it shrinks to −39 and −68 days; strain permutation P = 0.63 and 0.43.
- **A further bias, independent of year:** Vita1a and Vita1b were found in these same high-fat mice, at the markers where *D* beat *B* most. In any new sample, including NAM mice, the *D* − *B* difference is expected to come out smaller (regression toward the mean), which reads as "NAM erases the genotype effect" even with no true interaction. A fair test fixes the locus in data that exclude the high-fat controls used in the comparison, or estimates the high-fat effect out of sample.

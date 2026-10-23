# Initial Gompertz analysis: does a high-fat diet change the mortality rate doubling time?

Exploratory analysis, 23 October 2026. Code: `Gompertz/`. Tables and figures: `output/`.

## Short answer

**No.** The high-fat diet raises mortality by about 1.4-fold at every age, but it does not change how fast mortality rises with age:

| | Chow (CD) | High fat (HF) |
|---|---|---|
| Females | 1,044 | 890 |
| MRDT (Wald 95% CI) | 153 d (144–163) | 149 d (140–159) |
| MRDT (bootstrap 95% CI) | 153 d (143–164) | 149 d (132–165) |
| Median age at death | 683 d | 611 d |

- **The two slopes do not differ.** HF minus CD is −4 d, with a bootstrap 95% CI of −24 to +15 d. The likelihood-ratio test of equal slopes gives p = 0.55.
- **With a shared slope** (MRDT 151 d), HF mortality is **1.42 times** CD mortality at every age (95% CI 1.29–1.55). The diet acts on R0, not on the rate of aging.
- **A Cox model agrees.** The hazard ratio is 1.44 (1.32–1.58), and the proportional-hazards test finds no departure (p = 0.85).
- **The numbers hang together.** With equal slopes, a 1.42-fold hazard is the same as being MRDT × log2(1.42) = **76 d** older. The observed difference in median age at death is **72 d**.

This is the de Magalhães et al. (2018) pattern: an intervention that changes lifespan through age-independent mortality rather than through the demographic rate of aging.

## Data

- **Source.** Suheeta Roy's curated file, `data/original/BXD_Mortality_for_Mapping_Arends.xlsx`, unchanged.
- **Kept.** All females on CD or HF: 1,747 BXD (929 CD, 818 HF), 135 C57BL/6J and DBA/2J, and 52 B6D2F1 and D2B6F1.
- **Dropped.** The 172 HF + 1% NAM animals. The file has no males and no BXD × BXD F1s.
- **Left truncation.** Each animal counts as at risk only from its age at set up, which ranges from 26 to 877 d.
- **No censoring.** Every animal in the file died.

## Method

- **Model.** Gompertz hazard h(t) = a·e^(bt), fitted by maximum likelihood to individual ages at death with left truncation. MRDT = ln 2 / b.
- **Fitting code.** Analytic gradients and BFGS, in `Gompertz/gompertz.R`.
- **Checked on simulated data** (`Gompertz/test_gompertz.R`). From 200 simulated studies of 1,000 left-truncated animals:
  - the mean MRDT estimate is 119.7 d against a true 120 d;
  - 93% of the 95% intervals contain the truth;
  - the equal-slope test rejects in 3.5% of runs when the slopes are in fact equal.
- **Tests,** all likelihood-ratio tests between the diets:
  - equal slope b (equal MRDT), with separate a;
  - equal a, given a shared slope;
  - one curve for both diets.
- **Intervals.** Wald intervals come from the Hessian on the log(b) scale. Bootstrap intervals come from 2,000 resamples of animals within each diet.

## Robustness

| Analysis | CD MRDT (95% CI) | HF MRDT (95% CI) | Same slope, p |
|---|---|---|---|
| Primary | 153 (144–163) | 149 (140–159) | 0.55 |
| Survived to 200 d (26 CD and 25 HF early deaths dropped) | 152 (142–163) | 152 (142–163) | 0.99 |
| Survived to 365 d | 155 (142–168) | 177 (160–196) | 0.035 |
| BXD strains only | 156 (146–167) | 149 (139–159) | 0.31 |
| Gompertz–Makeham (adds a constant hazard c) | 153 (144–163) | 149 (140–159) | – |
| Binned regression from 200 d (de Magalhães method) | 152 (143–162) | 144 (127–167) | – |

- **The Makeham constant is negligible.** It comes out near 1e-8 per day on both diets, so these data need no age-independent term.
- **The early deaths do not drive the result.** Dropping deaths before 200 d leaves the two slopes identical. This bears on whether to keep the 2018 LowOutliers.
- **One analysis disagrees.** Among animals that survived past one year, HF has a *shallower* slope (MRDT 177 d, p = 0.035), and the Cox proportional-hazards test is borderline (p = 0.07). This is one nominal result out of four tests, uncorrected, so treat it as a lead, not a finding.
- **Two possible explanations for that lead:**
  - **Heterogeneity.** A higher hazard removes frail animals sooner, which flattens the population curve at late ages.
  - **Fitting degeneracy.** a and b trade off along a ridge (see below).
- **Figure 2 points the same way.** The Gompertz curve fits HF less well than CD: HF mortality runs steeper from about 600 to 850 d and flatter after that.

## Things to keep in mind

- **The a–b ridge.** Bootstrap estimates of ln(a) and ln(b) correlate at r = −0.95 (CD) and −0.97 (HF), as Figure 4 shows. This is the Strehler–Mildvan degeneracy that Tarkhov et al. (2017) describe. MRDT on its own is much less certain than the difference in R0 at a shared slope, so compare slopes with the joint likelihood-ratio test, as here, not by eye.
- **This is the MRDT of a mixture.** Pooling 124 genotypes flattens the population curve relative to the strains within it. Stratifying a Cox model by strain raises the diet hazard ratio from 1.44 to **1.78** (1.61–1.98), close to the 2.0 that Roy et al. (2021) report with strain as a random effect. Within-strain MRDTs are probably shorter than 150 d.
- **Animals still alive are not in the file.** For the latest cohorts this under-represents long-lived animals. The early cohorts are unaffected.
- **No adjustments yet.** Vivarium and set-up cohort are not adjusted for. The design is balanced by strain across diets, but vivarium 3 holds more CD than HF animals (440 against 232).

## Suggested next steps

1. **Mouse type and strain.** Fit a and b per strain, or per type (BXD, parent, F1), with shrinkage, for example a mixed model with strain random effects on ln a and ln b. Then ask whether some strains change slope on HF while most change only R0. This gives an MRDT for each strain and diet that can be mapped.
2. **Heterogeneity.** A gamma-Gompertz (frailty) model separates the individual-level slope from population heterogeneity. It tests the explanation for the past-365-d result and corrects the "mixture" MRDT.
3. **Vivarium and cohort,** as covariates on ln a (and on ln b, as a check).
4. **The final data set.** Rerun on the curated data once Suheeta approves it. The scripts read from `data/original/` and run in under a minute.

## Figures

All four are in `output/` as SVG files with editable text in Arial, plus PNG previews made with CairoSVG.
- **Fig 1.** Mortality rate in 30-day bins (point size ∝ deaths) with the two Gompertz fits: parallel lines, HF above.
- **Fig 2.** Kaplan–Meier survival from 200 d, with the Gompertz fits dashed.
- **Fig 3.** MRDT with 95% intervals by diet across the six analyses, with the equal-slope p values.
- **Fig 4.** Bootstrap estimates of ln(R0) against MRDT: two parallel ridges, separated along R0.

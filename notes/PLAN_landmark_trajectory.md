# Do early body-weight trajectories predict survival in BXD mice? A landmark analysis: plan

**Written by Claude (Opus 5.5) on 29 October 2026, before any model was fitted.** Rob asked for the analysis to be run on the full BXD data: "Can you not only write it but run it? Us our full BXD data and see if we provide support." He did not review this plan before the run. Every analysis not listed here is exploratory and will be labeled so.

## Question

A trajectory paper by colleagues assigns mice to latent classes of body-weight trajectory and finds that the classes predict survival. A reviewer objected that each mouse's class is assigned from its whole weight record, which includes the weight loss before death, so the classes partly describe lifespan rather than predict it.

1. **Prediction:** In BXD females, do classes assigned from weights taken before a landmark age predict survival after that age plus a gap?
2. **Individual or genetic:** Does any such prediction hold among mice of the same strain, across strains, or both?
3. **Trajectory or size:** Do the classes predict survival better than one body weight at the landmark?
4. **The reviewer's mechanism:** How much stronger is the association when classes are assigned from whole weight records, and how much of that excess disappears when the last 120 days before death are removed?

## Data

- **Mice:** all 2,621 females of `data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx`, sheet `BXD_Females` (BXD strains, C57BL/6J, DBA/2J, B6D2F1 and D2B6F1), on chow (CD) or high fat (HF).
- **Weighings:** the baseline weight at set-up and up to 20 later weighings. Excluded:
  - the 266 weighings flagged in `qc/BodyWeight_flags.txt`;
  - weights outside 10–100 g;
  - weighings after the mouse's end age (`AgeAtDeath`).
- **Outcome:** age at the end of follow-up (`AgeAtDeath`).
  - **Deaths:** status Natural or Euthanized (euthanized when moribund).
  - **Censored at the end age:** Harvest, Other and LowOutlier. Whether every harvest was planned is being confirmed with Suheeta Roy.
- **Time scale:** age in days. Each mouse enters the risk set at the start of follow-up defined below.

## Class model (the same in every analysis)

- **Model:** a latent class mixed model, `lcmm::hlme`, of weight in grams.
  - Fixed effects common to all classes: diet, diet × t and diet × t², where t = (age − 365) / 365.
  - Class-specific fixed effects: intercept, t and t².
  - Random effects: intercept and t, with an unstructured covariance, proportional across classes (`nwg = TRUE`).
- **Number of classes:** 1 to 4. Models with 2 or more classes start from the one-class fit, with `gridsearch` (20 random starts, 30 iterations each).
- **Selection:** the lowest BIC among converged models in which every class holds at least 5% of mice (by posterior assignment).
- **Seed:** 20261029.

## A. Landmark analyses

- **A1 (primary): landmark L = 365 days, gap g = 120 days.**
  - Mice weighed at least three times before 365 days and still under observation at 485 days.
  - The class model is fitted to these mice, using only weighings before 365 days.
  - Survival is counted from 485 days.
- **A2: L = 365 days, no gap.** Mice under observation at 365 days; survival counted from 365 days. It shows what the gap changes.
- **A3: L = 545 days (18 months), g = 120 days.** Mice weighed at least three times before 545 days and under observation at 665 days.

**Tests in each landmark analysis:**
- **P1, prediction (primary in A1):** a Cox model of class, stratified by diet, with standard errors robust to clustering by strain. Robust Wald test of class (G − 1 degrees of freedom).
- **P2, within strains:** the same model stratified by strain × diet; likelihood-ratio test of class.
- **P3, trajectory beyond size:** likelihood-ratio test of class added to a model with the last weight before L (standardized within diet), stratified by diet.
- **P4, between and within strains:** for each mouse, the posterior probability of the high-gain class, defined without the outcome as the class whose mean chow trajectory gains most from 120 to 365 days (from 120 to 545 days in A3). This probability is split into its strain × diet mean and the mouse's deviation from that mean, and both enter one Cox model stratified by diet. The strain-mean term is tested with a delete-one-strain jackknife; the deviation term with robust standard errors.
- **Reported for each class:** size, mean trajectory, Kaplan–Meier median age at death from the start of follow-up, and hazard ratio against the largest class. Harrell's concordance of the class model.

## B. The reviewer's mechanism

- **B1, whole record:** mice weighed at least three times in all. The class model is fitted to every weighing up to the end age. Cox model of class from the age at set-up, stratified by diet, robust by strain.
- **B2, whole record without the last 120 days:** the same mice and model, after removing every weighing in the 120 days before the end age (for censored mice too, so that deaths and censored mice are treated alike). Mice left with fewer than three weighings are dropped.
- **Compared across B1, B2 and A1:** the Wald χ² per degree of freedom and Harrell's concordance of class. In B1 and B2, the hazard ratio of the early-peak class: the class whose mean chow trajectory peaks at the youngest age.
- **Expected if the reviewer is right:** B1 is much stronger than B2 and A1.

## Sensitivity

- **S1:** A1 with the 59 Other and LowOutlier mice excluded rather than censored.

## What counts as support

- **For prediction from early trajectories:** P1 in A1 with P < 0.05.
- **For individual-level prediction:** P2 with P < 0.05.
- **For genetic-level prediction:** the strain-mean term of P4 with a jackknife 95% CI that excludes a hazard ratio of 1.
- **For trajectory over size:** P3 with P < 0.05.
- P values are not corrected for the number of tests; the four questions are reported together.

## Software and outputs

- R 4.6.1, lcmm 2.2.2, survival 3.8.12. Code: `Trajectory/landmark_trajectory.R`. Tables: `output/Landmark_*.txt`. Results: `notes/Landmark_trajectory_results.md`.

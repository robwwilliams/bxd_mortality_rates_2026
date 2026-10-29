# Do early body-weight trajectories predict survival in BXD mice? A landmark analysis: results

**Written by Claude (Opus 5.5) on 29 October 2026.** The plan, `notes/PLAN_landmark_trajectory.md`, was fixed before any model was fitted (SHA-256 `00c7560c…837721`, recorded at 11:22:46 CDT). Rob did not review the plan before the run. Analyses added after results were seen are labeled exploratory.

## Answer

- **Prediction holds:** Latent classes assigned only from weights taken before 365 days predict survival after 485 days, with no weights from near death involved. The test is robust to clustering by strain (P = 0.004).
- **It holds among mice of the same strain:** P = 0.012. The signal belongs, at least in part, to the individual mouse and not only to its genotype.
- **It is modest:** Harrell's concordance is 0.539. Among pairs of mice whose order of death is known, the class model puts the pair in the right order 53.9% of the time; chance is 50%.
- **A single weight does as well:**
  - **The last weight before 365 days:** it has a concordance of 0.538, against 0.539 for the classes. Class and that weight each add a little to the other, and together they reach 0.542.
  - **One weight at a fixed age (exploratory):** within each diet, a weight taken at any one age from 3 to 11 months ranks 50.6% to 56.0% of pairs correctly, against 51.7% to 56.8% for the classes in the same mice.
- **At 18 months, recent change predicts and size does not (exploratory):** A mouse's weight at 17 months shows no association with survival after 22 months. The change in its weight from 12 to 17 months does predict survival (P = 0.0013), as well as the four classes do.
- **Whole records inflate the association:** Take the A1 mice and count survival from 485 days, as in A1. When their classes are assigned instead from their whole weight records, the riskiest class's hazard ratio rises from 1.82 to 3.01, and the Wald χ² rises from 13.4 to 80.7 (exploratory, E1).
- **Removing the last 120 days of each record does not cure the inflation:** The hazard ratio is 2.47 and χ² = 41.8 (exploratory, E2). The excess χ² over A1 falls from 67.3 to 28.4, so 42% of it remains.

## Data as analyzed

- **Mice:** 2,621 females, sheet `BXD_Females` of `data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx`.
  - **Deaths:** 1,943 (Natural 1,401; Euthanized 542).
  - **Censored:** 678 (Harvest 619; Other 34; LowOutlier 25).
- **Weighings:** 18,580.
  - **Dropped:** 186 flagged in `qc/BodyWeight_flags.txt`, 11 outside 10–100 g and none after the end age.
  - **The plan said 266 flagged weighings.** That number counts the flags in all workbooks; 186 of them belong to this sheet.
- **Duplicated ear tag 5039 (C57BL/6J, chow):**
  - **The two rows:** the workbook holds two rows with this ear tag. They have the same set-up age (309 days) and the same two weights (29.9 g at 309 days, 32.9 g at 373 days). One records a natural death at 706 days, the other a harvest at 414 days.
  - **Landmark analyses:** A1, A2 and S1 exclude the mouse, which has no weighing before 365 days other than its baseline. A3 includes the death row with each weight counted twice.
  - **Whole-record analyses:** in B1 and B2, the death row received both rows' weighings and the harvest row received none. The Cox models therefore used 2,342 and 2,050 mice, not the 2,343 and 2,051 shown in `output/Landmark_tests.txt`.
  - **For Suheeta Roy:** which row is correct.
- **Missing set-up age:** two DBA/2J mice (ear tags 4909 and 4910) have none. They enter the landmark analyses, which do not need it, but not B1 or B2.

## The class models

- **Number of classes:** every analysis selected four classes. Four was the most the plan allowed, and the BIC was still falling at four in every analysis. With a higher limit, the models would have chosen more classes. The classes are a convenient partition of the weight curves, not natural groups of mice.
- **Range of the curves:** the class curves are quadratics in age. They describe a class only over the ages at which its mice were weighed. Outside that range they extrapolate, and in B1 and B2 they reach impossible negative weights by 730–900 days.

## A1, the primary analysis (landmark 365 days, gap 120 days)

**Mice:** 1,462 mice of 99 strains, weighed at least three times before 365 days and alive at 485 days; 1,233 later died.

**Classes, with observed mean weights on chow and on high fat:**

| Class | Mice: chow, high fat | Weight before 150 d (g): chow, high fat | Weight at 330–364 d (g): chow, high fat | Median age at death (d) | Hazard ratio (95% CI) |
|---|---|---|---|---|---|
| 3, lean | 614, 275 | 21.0, 21.1 | 28.3, 36.7 | 728 | 1 (reference) |
| 1, early gain | 102, 202 | 24.8, 25.2 | 40.7, 54.5 | 685 | 1.17 (0.97–1.41) |
| 4, steady gain | 11, 103 | 22.3, 23.3 | 45.1, 54.0 | 662 | 1.26 (0.95–1.66) |
| 2, heavy early | 18, 137 | 27.9, 28.8 | 36.6, 62.7 | 640 | 1.82 (1.31–2.52) |

- **Weights:** means of the weighings in each age bin, from `output/Landmark_strain_diet.txt` (exploratory). The weighings before 150 days are mostly the baselines at set-up. Chow mice stayed on chow; high-fat mice were switched from chow at set-up.
- **The 18 heavy-early mice on chow:** they peak at 44.6 g at 210–269 days and weigh 36.6 g at 330–364 days.
- **Class curves:** the first version of this note gave the class model's mean curves for a chow mouse instead (for class 2, 33.1 g at 120 days and 45.6 g at 365 days). Those curves misdescribe classes made up mostly of high-fat mice, and the observed weights replace them. Classes 1 and 4 were renamed to match: from "moderate gain" and "light early, steep gain".
- **Median ages at death:** Kaplan–Meier estimates among mice alive at 485 days.
- **Hazard ratios:** from a Cox model stratified by diet, with confidence intervals robust to clustering by strain. Each hazard ratio is therefore a comparison within diet. This matters for class 2, 88% of whose mice are on high fat.

**The plan's criteria for support:**

| Question | Test | Result | Support |
|---|---|---|---|
| Prediction | P1: robust Wald test of class | χ² = 13.35, 3 df, P = 0.0039 | Yes |
| Individual level | P2: class within strain × diet strata | LR = 10.95, 3 df, P = 0.012 | Yes |
| Genetic level | P4: strain mean of the probability of the high-gain class (class 4) | HR 0.78, jackknife 95% CI 0.40–1.52 | No |
| Trajectory beyond size | P3: class added to the last weight before 365 days | LR = 14.28, 3 df, P = 0.0026 | Yes |

- **P4 within strains:** the mouse's deviation from its strain's mean probability of class 4 has no association with survival either (HR 1.07, 0.74–1.55).
- **The high-gain class is not the riskiest:** P4 tests the class whose fitted chow curve gains most from 120 to 365 days, which the plan defined without using survival. That class is class 4, not the heavy-early class 2.

**Class against a single weight (exploratory):** this comparison was computed after the results were seen, from `output/Landmark_mice.txt`. Without clustering:

| Model | LR χ² | df | Concordance |
|---|---|---|---|
| Class alone | 31.4 | 3 | 0.539 |
| Last weight before 365 days alone | 26.2 | 1 | 0.538 |
| Both | | 4 | 0.542 |
| Weight added to class | 9.0 | 1 | |
| Class added to weight (P3) | 14.3 | 3 | |

**Weight per standard deviation:**
- the hazard ratio is 1.17;
- the robust Wald χ² is 11.2 on 1 df, against 13.4 on 3 df for class.

**Sensitivity, S1:** excluding the 59 Other and LowOutlier mice instead of censoring them changes nothing material: P1 P = 0.0032, P2 P = 0.0068, P3 P = 0.0020, and a heavy-early class with HR 1.81 (1.32–2.49).

## Diet, strain and genotype type in A1 (exploratory)

**Source:** computed after the results were seen, by `Trajectory/landmark_strain_diet.R` (`output/Landmark_strain_diet.txt`).

**What the strain tests above ask:** P2 and P4 ask whether class predicts survival within and between strains. They do not ask whether class depends on strain. This section does.

**Diet:**
- **Weight:** at the last weighing before 365 days, mice weigh 48.0 g on high fat and 30.2 g on chow. At the first weighing (mean age about 116 days, usually the set-up, when high-fat mice were switched from chow), they weigh 22.4 g and 22.0 g.
- **Gain:** 12.4 g per 100 days on high fat, against 3.6 g on chow.
- **Class:** 82% of chow mice are in the lean class, against 38% of high-fat mice. Of the 155 heavy-early mice, 137 (88%) are on high fat (χ² = 327, 3 df).
- **Why diet shapes the classes:** the class model includes diet terms common to all classes, so it removes the average effect of diet before it forms the classes. High-fat mice depart further from their diet's average curve, so they fill the heavy classes.

**Strain:**
- **The table:** intraclass correlations within diet: the share of the variation that lies between strains. They are computed over the 126 strain × diet groups with at least 5 mice (1,307 mice).

| | Chow | High fat |
|---|---|---|
| Weight at the first weighing | 0.34 | 0.38 |
| Weight at the last weighing before 365 d | 0.49 | 0.53 |
| Gain | 0.30 | 0.47 |
| Membership of class 3, lean | 0.38 | 0.35 |
| Membership of class 1, early gain | 0.23 | 0.13 |
| Membership of class 4, steady gain | 0.04 | 0.18 |
| Membership of class 2, heavy early | 0.20 | 0.37 |

- **Shared class:** on average, 74.1% of a group's mice share its most common class. If class were unrelated to strain, that figure would be 64.8% (95% range 63.9–65.8%, from 2,000 shuffles of the class labels within diet).
- **Groups of 10 or more mice:** in 18 of the 64 groups this size, every mouse is in the same class.
- **Class tracks strain less tightly than weight does:** class membership is a coarse, two-valued measure. A mouse near a class boundary can land in either class, and an intraclass correlation computed on values of 0 and 1 is lower than one computed on grams.

**Genotype type:** about half the mice of each type are on high fat.

| Class | BXD strains (1,278 mice) | Parental strains (115) | F1 hybrids (69) |
|---|---|---|---|
| 3, lean | 61.5% | 71.3% | 30.4% |
| 1, early gain | 20.5% | 11.3% | 42.0% |
| 4, steady gain | 6.9% | 14.8% | 13.0% |
| 2, heavy early | 11.1% | 2.6% | 14.5% |

## A2 (no gap) and A3 (landmark 545 days)

| | A1 (365 d, gap 120 d) | A2 (365 d, no gap) | A3 (545 d, gap 120 d) |
|---|---|---|---|
| Mice; deaths | 1,462; 1,233 | 1,787; 1,457 | 886; 791 |
| P1 Wald χ² (3 df); P | 13.35; 0.0039 | 28.79; 2.5 × 10⁻⁶ | 15.65; 0.0013 |
| Concordance of class | 0.539 | 0.553 | 0.522 |
| P2 within strains; P | 10.95; 0.012 | 13.26; 0.0041 | 3.83; 0.28 |
| P3 class beyond weight; P | 14.28; 0.0026 | 36.95; 4.7 × 10⁻⁸ | 19.21; 0.00025 |
| Concordance of the last weight alone (exploratory) | 0.538 | 0.538 | 0.493 |
| P4 between strains: HR (95% CI) | 0.78 (0.40–1.52) | 0.59 (0.28–1.23) | 0.26 (0.10–0.65) |
| Riskiest class: HR (95% CI) | 1.82 (1.31–2.52) | 2.38 (1.65–3.42) | 1.79 (1.26–2.54) |

**A2:**
- **Without the gap, the riskiest class is heavy from the start.**
  - **High-fat mice:** 99 of its 110 mice. They weigh 28.9 g before 150 days, and their mean weight levels off at about 57 g from 270 days.
  - **Chow mice:** the 11 in this class peak at 45.3 g at 210–269 days and weigh 39.1 g at 330–364 days.
- **Those mice die soon:** their median age at death is 563 days, against 640 days for A1's heavy-early class.
- **The gap excludes the early deaths:** A1 excludes the 35 of these 110 mice that died or were censored before 485 days (29 died). The riskiest class's hazard ratio is 2.38 in A2 and 1.82 in A1.
- **Not shown:** these means do not show whether weight loss before death causes the difference. On high fat, the class's mean weight has stopped rising by 1 year, but it has not fallen.
- **Correction:** the first version of this note said these mice were already losing weight at the landmark. That came from the class model's chow curve.

**A3:**
- **Size versus trajectory:** at 545 days, no association of a single weight with survival was detected (concordance 0.493), but class still predicts survival.
- **No prediction within strains:** the class association is not detected within strains (P = 0.28).
- **The association lies between strains:** the high-gain class (class 3: 46 mice, 38 of them on high fat, which weigh 21.2 g before 150 days and 52.1 g at 480–544 days) marks strains that live longer after 665 days. Strains whose mice have a higher probability of membership in that class live longer: the hazard ratio is 0.26 (0.10–0.65; jackknife P = 0.004) for a strain whose mice all belong to the class against one whose mice belong to none.
- **The contrast rests on few mice:** most strain × diet groups have a mean probability near 0 (median 0.003). The 46 mice of the class are spread over 27 groups, 38 of them on high fat, and only BXD91 on high fat holds several (6 of its 7 mice). The hazard ratio compares a mean probability of 1 with one of 0, and only groups of one to seven mice come near 1.

## Single weights and recent change in weight, against the classes (exploratory)

**Source:** added after the results above were seen, at Rob's request, by `Trajectory/landmark_single_weight.R` (`output/Landmark_single_weight.txt`). Claude fixed the definitions before these models were fitted.

### One weight at a fixed age, landmark at 1 year

**Design:**
- **Mice and survival:** A1 mice, with survival counted from 485 days.
- **The weight:** for each age from 90 to 330 days in steps of 30, each mouse's weighing within 20 days of that age, standardized within diet.
- **Models:** a Cox model of that weight on each diet, with the A1 classes fitted to the same mice for comparison.

| Age (d) | Chow: mice | Chow: C of weight (P) | Chow: C of classes | High fat: mice | High fat: C of weight (P) | High fat: C of classes |
|---|---|---|---|---|---|---|
| 90 | 273 | 0.529 (0.036) | 0.532 | 254 | 0.527 (0.028) | 0.550 |
| 120 | 455 | 0.545 (0.0077) | 0.529 | 411 | 0.546 (0.00046) | 0.553 |
| 150 | 415 | 0.551 (0.0023) | 0.517 | 406 | 0.553 (0.0024) | 0.568 |
| 180 | 478 | 0.547 (0.00011) | 0.539 | 463 | 0.554 (0.000085) | 0.547 |
| 210 | 451 | 0.552 (0.0079) | 0.519 | 427 | 0.560 (0.000011) | 0.558 |
| 240 | 522 | 0.526 (0.055) | 0.521 | 463 | 0.525 (0.012) | 0.532 |
| 270 | 406 | 0.559 (0.00057) | 0.540 | 411 | 0.557 (0.00030) | 0.563 |
| 300 | 456 | 0.532 (0.0098) | 0.518 | 394 | 0.506 (0.16) | 0.546 |
| 330 | 427 | 0.559 (0.00076) | 0.537 | 440 | 0.548 (0.0015) | 0.558 |

**Results:**
- **Heavier mice die sooner:** at every age and on both diets, the hazard ratio per SD of weight is 1.09 to 1.29.
- **One weight against the classes:** one weight ranks 50.6% to 56.0% of pairs of mice correctly, and the classes 51.7% to 56.8%, in the same mice.

**The first weighing is not a fixed-age weight:**
- **Its age varies widely:** in A1 mice, the age of each mouse's first weighing ranges from 37 to 235 days on chow and from 40 to 223 days on high fat (5th to 95th percentiles), and its weight correlates 0.66 and 0.65 with that age.
- **Taken as is, it hides its signal:** it shows no association with survival (C 0.499, P = 0.18 on chow; 0.513, P = 0.077 on high fat).
- **Adjusted for the age at which it was taken, it predicts:** C 0.532 (P = 0.0032) on chow and 0.545 (P = 0.00025) on high fat.
- **A retraction:** an earlier exploratory comparison, reported to Rob in conversation, treated the first weighing as a weight at about 3 months and concluded that it predicted nothing. That conclusion was wrong.

### Recent change in weight, landmark at 18 months

**Design:** A3 mice with weighings near 12 and 17 months: 737 mice of 93 strains, of which 663 later died. Survival is counted from 665 days.
- **Size:** the weighing nearest 515 days, within 480–544 days.
- **Change:** size minus the weighing nearest 365 days (within 320–410 days), in grams per 100 days.
- **Percent of peak:** size as a percentage of the mouse's highest weight before 545 days.
- **Scaling and models:** each measure is standardized within diet. The Cox models are stratified by diet, with P values robust to clustering by strain.

**The measures, as medians:**
- **On chow:** change 0.0 g per 100 days (SD 2.4); 49% of mice are lighter at about 515 days than at about 365 days.
- **On high fat:** change 3.3 g per 100 days (SD 5.2); 20% are lighter.

| Predictor | C | Hazard ratio per SD (P) |
|---|---|---|
| Size | 0.489 | 1.02 (0.64) |
| Change | 0.544 | 0.88 (0.0013) |
| Percent of peak | 0.538 | 0.87 (0.00019) |
| Size and change | 0.539 | |
| The four A3 classes | 0.519 | |

**Nested tests:**
- **Change beyond size:** LR = 11.4, 1 df, P = 0.00074.
- **Percent of peak beyond size:** LR = 13.7, 1 df, P = 0.00021.
- **Class beyond size and change:** LR = 7.1, 3 df, P = 0.07.
- **Size and change beyond class:** LR = 3.1, 2 df, P = 0.21.
- **Concordance:** C(size and change) − C(class) = 0.021 (95% CI −0.002 to 0.043).

**Within strains:** no effect of change beyond size was detected (stratified by strain × diet: LR = 1.9, P = 0.17). The hazard ratio per SD, 0.90, points the same way.

**Each diet on its own (C):**

| | Size | Change | Size and change | Classes |
|---|---|---|---|---|
| Chow (455 mice) | 0.485 | 0.533 | 0.520 | 0.512 |
| High fat (282 mice) | 0.500 | 0.571 | 0.578 | 0.571 |

**Results:**
- **Size:** at 17 months, a mouse's size shows no association with survival after 22 months.
- **Change:** its change in weight over the previous 5 months, or how far it has fallen below its peak, does predict survival.
- **Against the classes:** two weights predict at least as well as the four classes.

**Interpretation, not tested here:** the signal may be the slow start of the decline before death, seen four to six months ahead. Chow mice are already at 96% of their running peak 120–180 days before death. It is a prediction in the landmark sense, because no weight from the 120 days before 665 days is used. But it may reflect illness already under way, not a trajectory type that a mouse carries through life.

### What this means for the classes

As predictors of survival in BXD females, the classes add nothing detectable beyond one weight at a fixed age before 1 year, or two weights at 18 months.

## B, the reviewer's mechanism

**Design:** both analyses fit the class model to mice weighed at least three times in all, and count survival from the age at set-up.

| | A1 | B1, whole record | B2, whole record minus the last 120 days |
|---|---|---|---|
| Mice in the Cox model; deaths | 1,462; 1,233 | 2,342; 1,835 | 2,050; 1,664 |
| Wald χ² per df | 4.45 | 36.7 | 32.4 |
| Concordance of class | 0.539 | 0.558 | 0.572 |
| Riskiest class: HR (95% CI) | 1.82 (1.31–2.52) | 2.40 (1.94–2.96) | 2.41 (1.91–3.05) |
| Riskiest class: mice on chow, high fat | 18, 137 | 41, 288 | 32, 179 |
| Peak of the riskiest class's fitted chow curve (d) | — | 360 | 340 |
| Its median age at death (d) | 640 | 573 | 563 |

**Expectation:** the plan stated, "Expected if the reviewer is right: B1 is much stronger than B2 and A1."

**Outcome:**
- **B1 against A1:** B1 is much stronger than A1.
- **B1 against B2:** B1 is not stronger than B2.

**What B2 shows:**
- **The cut changes little:** removing every weighing in the last 120 days before the end age barely changes the association.
- **The classes are still early peaks:** in both analyses, the riskiest class consists mostly of high-fat mice.
  - **Observed weights:** their mean weight peaks at 390–509 days (63.1 g in B1, 65.5 g in B2) and is lower at later ages.
  - **Caution:** the later means include only the mice still alive, so they mix weight loss with the earlier deaths of the heaviest mice.

**A caveat:** the B analyses count survival from set-up and so include early deaths, which A1 excludes. Their numbers are not directly comparable with A1. E1 and E2 make the comparison like for like.

## E1 and E2: whole-record classes in the A1 mice and window (exploratory)

**Design:** added after the B results were seen. E1 and E2 take the classes from B1 and B2 and test them in the 1,460 A1 mice that are also in B1 and B2, with survival counted from 485 days. The two DBA/2J mice without a set-up age are the difference. The mice, the deaths and the window are the same as in A1; only the weighings used to assign the classes differ.

| | A1: weights before 365 d | E2: whole record minus the last 120 d | E1: whole record |
|---|---|---|---|
| Wald χ² (3 df) | 13.35 | 41.75 | 80.68 |
| Concordance of class | 0.539 | 0.549 | 0.567 |
| Within strains, LR (3 df) | 10.95 | 13.22 | 36.87 |
| Class beyond weight, LR (3 df) | 14.28 | 39.51 | 89.34 |
| Riskiest class: HR (95% CI) | 1.82 (1.31–2.52) | 2.47 (1.85–3.29) | 3.01 (2.37–3.84) |

**Results:**
- **Whole records:** classes assigned from whole records give six times the χ² of classes assigned before the landmark, and a riskiest-class hazard ratio of 3.0 instead of 1.8.
- **Trimmed records:** removing the last 120 days lowers the excess χ² over A1 from 67.3 to 28.4, so 42% of it remains. The trimmed classes still give three times the χ² of A1.

**Why trimming falls short (an interpretation, not tested here):** in E2, a mouse that dies at 900 days has its record cut at 780 days. Two things still connect its class to its lifespan:
- **Weights taken during follow-up:** its class still uses weights taken from 485 to 780 days, while survival is being counted. The slow loss of weight on chow begins more than 120 days before death: chow mice are at 96% of their running peak at 120–180 days before death.
- **Record length:** a short record still marks a short life, and a quadratic fitted to a short record of a heavy, fast-gaining mouse peaks early.

Only a landmark separates the weights used to assign the classes from the survival being predicted.

## What this means for trajectory analyses

**Support for the claim:** BXD females support the claim that early weight trajectories predict later survival, without the weights taken near death.

**Three qualifications:**
- **Size and recent change:** in the first year, one weight at a fixed age predicts as well as the classes. At 18 months, no association of size with survival was detected, but the change in weight over the previous 5 months predicts as well as the classes.
- **Inflation:** classes assigned from whole records overstate the hazard ratios. In these mice, the overstatement is from 1.8 to 3.0.
- **Trimming is not enough:** removing the last months of each record leaves much of the excess.

**Benchmarks:** class models should be compared against one weight at the landmark and the change in weight over the months before it.

**Correction to our earlier advice:** an earlier note to colleagues recommended removing the last 17 weeks of each record as a second test that keeps every mouse. B2 and E2 show that this test does not remove the inflation. Only the landmark design should be recommended.

## Limitations

- **Population:** BXD females on chow and high fat, not UM-HET3 mice of both sexes.
- **Classes:** the number of classes was capped at four (see "The class models").
- **P values:**
  - the model-based P value of weight in `output/Landmark_tests.txt` is not robust to clustering by strain;
  - P values are not corrected for the number of tests.

## Files

- **Code:** `Trajectory/landmark_trajectory.R` (seed 20261029).
  - **Exploratory follow-ups:**
    - `Trajectory/landmark_strain_diet.R` writes `output/Landmark_strain_diet.txt`;
    - `Trajectory/landmark_single_weight.R` writes `output/Landmark_single_weight.txt`.
- **Run:** R 4.6.1, lcmm 2.2.2 and survival 3.8.12, about 30 minutes on 6 cores.
- **Tables:**
  - `output/Landmark_models.txt` (class models and BIC);
  - `output/Landmark_classes.txt` (class sizes and curves);
  - `output/Landmark_tests.txt` (tests and hazard ratios);
  - `output/Landmark_mice.txt` (each mouse's class, entry, end and weight z-score, for checking).
- **Log:** `output/Landmark_trajectory.log`.

# Plan: terminal weight loss and the per diem cost of late life

**Status: approved by Rob on 26 October 2026** ("Yes, run the analysis as the plan describes"), before any comparison was run. Written by Claude on 26 October 2026, from Rob's idea. This is exploratory: the pooled weights aligned on death have been seen (below), but no comparison of strains, F1s, parents or diets has been made.

## Rob's idea, in his words

> "consider our mouse models as if we changed mouse per diem rates and made them essentially free until XXX days (say 500 days in BXDs and 700 days in UM-HET3), but then started to increase the per diem rates for the investigators as a function of the rate of change of body weight."

> "sharp weight loss over the last 5% of life is a great alignment tool."

The question behind it: do longer-lived genotypes, the F1 hybrids in particular, spend longer in terminal decline (expansion of morbidity), or about the same time or less (Fries's compression of morbidity)?

## Data

From Suheeta Roy's `Roy_RawData_To_Danny.zip` (SHA-256 `1381de76…9f42`). The three weight workbooks are in `data/original/` unchanged (see its README).

| Mice | File and sheet | Weighings | Last weighing before death |
|---|---|---|---|
| BXD family females: Suheeta's 1,934 mapping mice (CD 1,044; HF 890) | `AgingBXD_BodyWeightData_updated31Dec2024.xlsx`, `BXD_Females` | up to 20; median 7, about every 66 days | median 31 days |
| BXD × BXD F1 females that died or were euthanized: 309 of 18 F1 types | `AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx`, `NaturalDeath` | up to 18; median 10 | median 27 days |

- **Linkage.** Every mapping mouse is in the weight file by ear tag, and strain and diet agree for all of them. Age at death agrees for 1,933 of 1,934.
- **Excluded:** harvested mice, mice alive at the data freeze (neither has a terminal phase), and the NAM mice (a separate question).

## What has been seen

Weights pooled by diet, aligned on death, as a fraction of each mouse's peak:
- **Chow:** about 0.95 from 400 to 120 days before death, then 0.86 at 30–90 days and 0.77 in the last 30 days.
- **High fat:** still rising to 1.00 at 120–180 days before death, then 0.96 at 60–90 days, 0.87 at 30–45 days and 0.71 in the last 15 days.

So terminal decline takes about the last 3–4 months, not the last 5% of life, and is steepest in the final month.

## Definitions

1. **Peak:** the mouse's highest weight at least 120 days before death.
2. **In decline:** a weighing below 90% of the peak, with no later weighing back at 90% or more.
3. **Onset of terminal decline:** halfway between the last weighing at 90% or more and the first weighing in decline.
   - **Morbidity span** = age at death − onset.
   - **A mouse whose last weighing is still at 90% or more** has no observed decline. Its span is recorded as at most the days from that weighing to death.
4. **Per diem, as Rob proposed,** free until X = 500 days:
   - **base:** 1 unit for each day alive after 500 days (the "pension");
   - **surcharge:** *s* units for each day in decline after 500 days, with *s* = 4, and *s* = 1 and 10 as sensitivity checks;
   - **rate-based alternative:** a surcharge proportional to the weight lost per 30 days above 2%.
   - Each mouse gets its pension days, decline days and total cost.

## Questions

The unit is the genotype. Uncertainty comes from a delete-one-genotype jackknife; tests are permutations over genotypes.

- **Q1, compression across BXD strains.** Does the strain-mean morbidity span rise with strain-mean lifespan?
  - Fries predicts a slope of zero or less;
  - expansion of morbidity predicts a slope above zero;
  - proportional change predicts a constant ratio of span to lifespan.
- **Q2, F1 hybrids.** Morbidity span, decline days and per diem cost: F1s against their parents, separately for short × short and long × long crosses.
- **Q3, diet.** High fat against chow, within strains.
- **Q4, cost.** Total per diem cost by group, split into pension and surcharge.

## Euthanasia

- **The share of deaths that were euthanasia differs a lot:** 28% of BXD deaths but 54% of F1 deaths.
- **Euthanasia at a humane endpoint stops the decline early.** If weight loss is one of the criteria, it also caps how much weight can be lost.
- **So every result is reported:**
  - for all deaths;
  - for natural deaths only;
  - with the euthanasia rate of each group, which is itself an end-of-life decision, as in Rob's human analogy.
- **Needed from Suheeta:** the euthanasia criteria, and the years they applied.
- **Rob, 26 October 2026, on the F1s:** "Do not exclude euthanasia of F1s. We killed them to harvest tissue when we judge them to be end of life by veterinary standards."
  - So euthanized mice stay in every primary analysis; natural deaths alone remain a sensitivity check.
  - **Check:** do euthanized mice look like end-of-life deaths? Compare them with natural deaths of the same group on age at death and on weight at the last weighing relative to peak.

## Implementation details, fixed before the comparisons were run

Written by Claude on 26 October 2026, after Rob's approval and before any comparison was run.

- **Weighings.** The weight at set-up counts as a weighing. Weighings dated after the recorded death (24 in the BXD file) are dropped. A mouse needs a weighing at least 120 days before death to have a peak; mice without one are left out.
- **Age at death.** For the 1,934 mapping mice, from `BXD_Mortality_for_Mapping_Arends.xlsx`; for F1s, from the F1 workbook.
- **Morbidity span: the midpoint of what is known.**
  - For a mouse in decline, onset lies between the last weighing at 90% or more and the first below; the span uses the midpoint.
  - For a mouse with no observed decline, the span lies between 0 and the days from its last weighing to death; the span uses half that.
  - Sensitivity: the lower and upper bounds of the span.
- **Q1: split halves.** Strain-mean lifespan contains the span, so regressing one on the other from the same mice is biased upward. So each strain's mice are split at random into two halves: the mean lifespan comes from one half and the mean span from the other.
  - The slope is averaged over 200 splits, with a fixed seed.
  - Each diet is analyzed separately, using BXD strains with at least 6 mice that have a span.
  - The 95% CI comes from a delete-one-strain jackknife. *P* comes from 2,000 permutations of strain labels between the two halves.
  - Proportional change predicts a slope equal to mean span / mean lifespan.
- **Q2: genotype × diet cells with at least 3 mice.**
  - The model is cell mean ~ type (F1 or parent) + diet, fitted separately to the short and long sets.
  - The 95% CI comes from a delete-one-genotype jackknife.
  - *P* comes from an exact permutation of the type labels across genotypes.
  - F1 types whose parents fall in neither set are left out.
- **Q3: BXD strains with at least 3 mice on each diet.** The statistic is the mean over strains of HF − CD. *P* comes from 10,000 random sign flips; the CI from a jackknife.
- **Rate-based surcharge.** For each pair of consecutive weighings after 500 days, the loss is measured as a fraction of peak per 30 days. The surcharge per day is 100 × (that loss − 0.02) when the loss exceeds 2%, so a 6% loss per 30 days costs 4 units a day, the same as *s* = 4. No surcharge is charged between the last weighing and death, because that interval is unobserved.
- **Natural deaths only:** status "Natural".
- **Seeds are fixed.**

## Changes after the first results, 27 October 2026

Made at Rob's instruction after the first results were seen, so the revised results are labeled as such.

- **BXD73 F1 labels.** Rob: "Checking but I am fairly certain that we only used BXD73b. Our goal was 10 or more F1s per type so this is likely to be an error. Genetically there will be minimal difference between the two types so merging is acceptable. Please do combine and labeled all as BXD73b."
  - Six F1s labeled BXD73 × BXD65 or BXD73 × BXD77 become BXD73b crosses. GeneNetwork (`BDL_10002`) already lists them that way.
- **Euthanized F1s.** Rob: "if the F1s are as old or older than the means of the "natural" deaths then we typically euthanized them when they were within a week or two of natural death based on our assessment of their level of frailty. We harvested organs at these euthanasias for biobanking. Relabeled them a natural deaths for purposes of analysis."
  - Every euthanized F1 counts as a natural death, whatever its age; the recorded cause is kept. Euthanized mice of the BXD family file stay euthanized.
  - So the sensitivity analysis "natural deaths only" now keeps every F1 and drops only euthanized BXD-family mice, parents included.
- **Where.** Both corrections are made in `data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt` (`BodyWeight/F1_weights_corrected.R`), which the analysis now reads. The workbook in `data/original/` is unchanged.

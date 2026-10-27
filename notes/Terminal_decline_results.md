# Terminal weight loss and the per diem cost of late life: results

Exploratory analysis, run on 26 October 2026 as set out in `notes/PLAN_terminal_decline.md`, which Rob approved before any comparison was run. The code is in `BodyWeight/terminal_decline.R` and `BodyWeight/Figures_terminal_decline.R`. The tables are `output/Terminal_decline_*.txt`, and the figure is Fig. 12 (`output/Fig12_Terminal_decline.svg`).

**Revised on 27 October 2026** with two corrections to the F1 data from Rob, made after the first results were seen (see Data). They change only the long × long comparison, and only slightly.

## Summary

- **Weight loss marks the end of life.** Aligned on death, median body weight holds near its peak until about 120 days before death, then falls. In the last 15 days it is 82% of peak on chow and 74% on high fat.
- **Across BXD strains, longer-lived strains spend longer in decline,** about 11–13 more days of decline per 100 more days of life. That is close to proportional, and it is not the compression Fries predicted (Q1).
- **Short × short F1 hybrids live 171 days longer than their short-lived parents, with the same length of decline** (difference 0 days, 95% CI −32 to 32). So decline is compressed relative to lifespan, but not in absolute days (Q2).
- **Long × long F1s differ from their parents in nothing we measured.**
- **High fat shortens both life and the decline,** by 76 and 42 days within strains (Q3).
- **On Rob's per diem, free until 500 days, the extra cost of the short × short F1s is mostly pension.** Half of their short-lived parents die before 500 days and cost nothing. High fat is the cynic's diet: it cuts the bill per mouse by about 40% (Q4).

## Data

| | Mice | With a peak at least 120 days before death |
|---|---|---|
| BXD family females (Suheeta's mapping file), CD and HF | 1,934 | 1,812 |
| BXD × BXD F1 females that died, naturally or by euthanasia at end of life | 308, of 13 F1 types | 305 |

- **Weighings** come about every 66 days. Half the mice were last weighed within 33 days of death. 64 weighings dated after the recorded death were dropped.
- **Two corrections to the F1 data, by Rob on 27 October 2026.** They are made in a derived table, `data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt` (written by `BodyWeight/F1_weights_corrected.R`); the workbook in `data/original/` stays as received. Rob is confirming both with Suheeta.
  - **Six F1s labeled BXD73 × BXD65 or BXD73 × BXD77 are BXD73b crosses.** Rob: "Our goal was 10 or more F1s per type so this is likely to be an error. … Please do combine and labeled all as BXD73b." GeneNetwork (`BDL_10002`) already lists these six ear tags (3092–3097) as BXD73b crosses, with the same ages at death. They join the long × long set, which grows from 159 to 165 mice.
  - **Euthanized F1s count as natural deaths.** Rob: "we typically euthanized them when they were within a week or two of natural death based on our assessment of their level of frailty. We harvested organs at these euthanasias for biobanking. Relabeled them a natural deaths for purposes of analysis." The recorded cause stays in the table. Euthanized mice of the BXD family file stay euthanized.

## Weight aligned on death (Fig. 12a)

Median weight as a fraction of each mouse's peak, BXD strains:

| Days before death | Chow | High fat |
|---|---|---|
| 180–300 | 0.94 | 0.93 |
| 120–180 | 0.96 | 1.00 |
| 90–120 | 0.93 | 1.00 |
| 60–90 | 0.88 | 0.97 |
| 30–60 | 0.87 | 0.92 |
| 15–30 | 0.83 | 0.84 |
| 0–15 | 0.82 | 0.74 |

- **On chow,** weight drifts down from about four months before death.
- **On high fat,** mice are still at their peak three months before death, then lose a quarter of their weight. The decline is shorter and steeper.

## Q1. Does decline lengthen with lifespan across BXD strains?

**Lesson: why split halves.** A strain's mean lifespan includes its mean decline. Regressing one on the other from the same mice therefore produces a positive slope even when the two are unrelated. So each strain's mice were split at random: one half gives the mean lifespan, the other the mean decline.

| Diet | Strains | Slope: days of decline per day of life (95% CI) | *P* | Proportional change predicts |
|---|---|---|---|---|
| Chow | 68 | 0.13 (0.03–0.23) | 0.021 | 0.18 |
| High fat | 58 | 0.11 (0.05–0.17) | 0.0015 | 0.12 |

- **Longer-lived strains spend somewhat longer in decline,** at a little under the rate that proportional change predicts.
- **The bounds of the span give the same answer:** slopes of 0.12–0.13 on chow and 0.10–0.13 on high fat.
- **Natural deaths alone:** 0.17 on chow (*P* = 0.02) and 0.06 on high fat (*P* = 0.10).
- **So among BXD strains,** morbidity rises roughly in step with lifespan. That fits neither strict compression nor a strong expansion.

## Q2. F1 hybrids against their parents

Differences, F1 minus parents. The model is genotype × diet cell means ~ type + diet. CIs come from a delete-one-genotype jackknife; *P* from an exact permutation.

| | Short × short (6 F1 types, 4 parents) | *P* | Long × long (7 F1 types, 4 parents) | *P* |
|---|---|---|---|---|
| Age at death (days) | +171 (104 to 239) | 0.005 | +22 (−63 to 107) | 0.60 |
| Morbidity span (days) | 0 (−32 to 32) | 1.0 | −18 (−53 to 17) | 0.34 |
| Days in decline after 500 days | +36 (3 to 69) | 0.029 | −16 (−51 to 20) | 0.40 |
| Pension days (alive after 500 days) | +132 (75 to 188) | 0.005 | +22 (−54 to 97) | 0.55 |
| Per diem cost, *s* = 4 | +276 (96 to 455) | 0.010 | −41 (−231 to 149) | 0.69 |
| Weight at last weighing / peak | −0.03 (−0.14 to 0.07) | 0.52 | −0.05 (−0.14 to 0.05) | 0.32 |

- **The smallest *P* an exact permutation can give** is 0.005 for the short set (210 arrangements) and 0.003 for the long set.
- **The short × short F1s add 171 days of life and no days of decline.**
  - Relative to lifespan, decline is compressed: a span of about 90 days over a life of about 700, against 96 over about 520 in their parents (Fig. 12c).
  - In absolute days, it is unchanged.
  - Leaving out the parents that were euthanized gives the same result: span +3 days (*P* = 0.85), age at death +184 (*P* = 0.005). (Every F1 now counts as a natural death.)
- **They cost more, but mostly as pension.** Their parents' decline often ends before 500 days, when it is free. The F1s' decline falls after 500, so it is charged.

## Q3. High fat against chow, within BXD strains (81 strains)

| | HF − CD (95% CI) | *P* |
|---|---|---|
| Age at death (days) | −76 (−99 to −54) | < 0.0001 |
| Morbidity span (days) | −42 (−56 to −28) | < 0.0001 |
| Per diem cost, *s* = 4 | −224 (−289 to −158) | < 0.0001 |
| Weight at last weighing / peak | +0.01 (−0.02 to 0.04) | 0.47 |

High-fat mice die 2½ months sooner, after a decline six weeks shorter. They reach the same final loss of weight, so the decline is steeper. Natural deaths alone: span −55 days.

## Q4. Per diem cost per mouse (Fig. 12d)

Free until 500 days, then 1 unit per day alive plus 4 units per day in decline. Means per mouse:

| Group | Mice | Died before 500 days | Pension | Days in decline | Cost |
|---|---|---|---|---|---|
| BXD, chow | 739 | 18% | 200 | 94 | 575 |
| BXD, high fat | 681 | 28% | 128 | 56 | 353 |
| Short-lived parents | 92 | 49% | 76 | 50 | 275 |
| Short × short F1s | 140 | 9% | 212 | 83 | 543 |
| Long-lived parents | 120 | 8% | 259 | 121 | 743 |
| Long × long F1s | 165 | 6% | 271 | 100 | 672 |

- **The decline surcharge** is 60–72% of the bill at *s* = 4.
- **The ranking of groups is the same** at *s* = 1 and *s* = 10, and with the rate-based surcharge (`output/Terminal_decline_cost.txt`).

## Euthanasia

Rob, 26 October: "We killed them to harvest tissue when we judge them to be end of life by veterinary standards." The data agree. The table compares causes of death as recorded:

| Group | Status | Mice | Median age at death | Last weight / peak | In observed decline |
|---|---|---|---|---|---|
| Short × short F1s | Euthanized | 83 | 743 | 0.77 | 64% |
| | Natural | 57 | 676 | 0.87 | 53% |
| Long × long F1s | Euthanized | 84 | 792 | 0.76 | 68% |
| | Natural | 81 | 708 | 0.75 | 62% |
| BXD strains | Euthanized | 405 | 615 | 0.91 | 48% |
| | Natural | 1,015 | 663 | 0.87 | 55% |

- **Euthanized F1s were older and at least as thin as F1s that died naturally.** That looks like end of life. So, at Rob's instruction (27 October), every euthanized F1 now counts as a natural death.
- **Suheeta's notes give a reason for 21 of the 168 F1 euthanasias.** Most often it is a mass of about 2 cm or an ulcerated mass (12 mice); otherwise weight loss, a hunched posture, ataxia, head tilt or a skin lesion that did not heal.
  - 26 of the 83 euthanized short × short F1s, and 24 of the 84 long × long, were younger than the mean age of natural deaths in their set.
  - Of the 167 euthanized F1s in the analysis, 11 were younger than 500 days, the youngest 219 days (a 2 cm mass). One more, euthanized at 91 days, has no weighing 120 days before death and is not analyzed.
  - These look like humane endpoints for a fatal condition, which a mortality study usually counts as deaths.
- **Euthanized BXDs died somewhat younger and less thin,** perhaps after a shorter decline or for other conditions. Results from natural deaths alone agree in direction.

## Caveats

- **Weighings are about two months apart,** so onset is known to about ±1 month. No mouse was weighed at death.
- **The 90% threshold and the 120-day window for the peak are choices.** The bounds of the span give the same answers.
- **The per diem units are arbitrary;** only comparisons between groups mean anything.
- **Exploratory, with many measures** and no correction for multiple tests.
- **The UM-HET3 version,** free until 700 days, is not possible with Arends's weights (6, 18 and 24 months only).

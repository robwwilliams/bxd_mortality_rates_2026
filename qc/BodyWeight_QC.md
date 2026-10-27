# Body weights: odd cases for Suheeta to review

Rob, 27 October 2026: "Pull out the anomalous F1s. Hard to lose 161% of weight per month 😉 We can ask Suheeta to review the odd cases and decide whether there are extenuating circumstances."

`BodyWeight/weights_QC.R` checks every weighing of every mouse in the two workbooks Part 4 uses: the sheet `BXD_Females` of `AgingBXD_BodyWeightData_updated31Dec2024.xlsx` (2,621 mice) and the sheet `NaturalDeath` of `AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx` (310 F1s). Since 27 October 2026 it also checks the NAM workbook, `AgingBXD_NAM_BodyWeight_Feb2026.xlsx` (187 mice), with the same rules (see the NAM section below). It changes nothing: the workbooks in `data/original/` stay as received, and every analysis still uses every weighing. The full list, one row per flagged weighing with the mouse's whole series of `age:weight`, is `qc/BodyWeight_flags.txt`.

## Rules

The rules were set before the list was read, except rule D (see the note under the table).

| Rule | Flags a weighing that is | BXD | F1 | NAM |
|---|---|---|---|---|
| A | heavier than 120 g, or lighter than 10 g at 60 days or older | 1 | 1 | 0 |
| B | an isolated spike: more than 15% away from both neighbors, in the same direction, while the neighbors agree within 5% | 50 | 7 | 10 |
| C | a fast loss in an adult (120 days or older): more than 15% within 14 days, or more than 30% per 30 days | 9 | 2 | 23 |
| D | a fast gain in an adult (300 days or older, at least 150 days after set-up): more than 30% between two weighings | 61 | 11 | 5 |
| E | dated after the recorded age at death | 51 | 16 | 11 |
| F | at an age that differs by more than 2 days from its date minus the date of birth (BXD and NAM workbooks; the F1 workbook has no dates) | 3 | 0 | 0 |
| G | at an age lower than the weighing before it in the workbook | 18 | 1 | 3 |

- **In all:** 266 weighings in 192 mice, 177 of them in our analyses. A weighing can break more than one rule.
- **Before the NAM workbook was added:** 218 weighings in 159 mice, 148 of them in our analyses. Adding it left the BXD and F1 rows unchanged.
- **Rule D was narrowed after a first look.** As first written, it caught mice set up late on high fat, which gain fast for months after set-up. That gain is real, so the rule now starts 150 days after set-up.

## Cases to look at first

**Weighed long after the recorded death (rule E).** These matter beyond body weight: if the age at death is wrong, the lifespan analyses (Parts 1–3) carry the error too.

| Mouse | Strain, diet | Recorded age at death | Weighings after it | Last weighing |
|---|---|---|---|---|
| BXD 3276 | BXD218, chow | 631 | 10 | 1,263 days |
| F1 3662 | BXD172 × BXD197, chow | 506 | 8 | 982 days |
| BXD 4834 | BXD125, chow | 640 | 3 | 903 days |
| BXD 4894 | B6D2F1, chow | 435 | 5 | 676 days |
| BXD 2847 | BXD5, chow | 196 | 1 | 403 days |
| BXD 5925 | BXD81, high fat | 299 | 4 | 482 days |
| BXD 4832 | BXD2, chow | 571 | 3 | 748 days |
| F1 3634 | BXD172 × BXD197, chow | 771 | 3 | 940 days |

- **BXD 3276:** Suheeta's mapping file and GeneNetwork (L3276) both give 631 days.
- **Smaller excesses.** Another 26 mice have one or a few weighings 1–148 days after death.

**The F1s Rob asked about.**
- **F1 3663** (BXD172 × BXD197, chow) is the "161% per month". It weighs 43.0 g at 548 days, 29.6 g at 554 days and 43.2 g at 614 days.
  - The 29.6 g weighing sits in the column `Weight08`, before the 548-day weighing in `Weight09`, so its age may be wrong as well as its weight (rules B, C and G).
- **F1 3218** (BXD172 × BXD197, high fat) weighs 808.8 g at 412 days, between 72.6 and 82.2 g. Most likely 80.88 g.
- **F1 3233** (BXD102 × BXD77, chow) alternates between two weights. From 497 to 760 days it reads 25.3, 38.3, 23.7, 39.1 and 36.9 g, as if two mice's records were mixed.

**Large changes at euthanasia.** Several mice weighed on the day they were euthanized are far lighter, or far heavier, than at the weighing before.
- **Losses.** These may be real terminal crashes:
  - BXD 2837 (BXD15, high fat): 57.0 g, then 23.4 g 23 days later;
  - BXD 2693 (BXD172, high fat): 44.8 g, then 19.6 g 56 days later.
- **Gains.** A tumor, ascites or a recording slip could each explain them:
  - BXD 3057 (BXD184, chow): 20.1 g, then 31.4 g;
  - BXD 3130 (C57BL/6J, chow): 25.6 g, then 37.7 g;
  - BXD 2733 (BXD197, chow): 23.2 g, then 36.5 g.

## The NAM workbook

Added on 27 October 2026, after the note to Suheeta about the BXD and F1 workbooks had gone. 52 weighings in 33 mice are flagged, 29 of the mice in our analyses.

**Weighed after the recorded death (rule E).** As for the BXD mice, an age at death that is wrong also changes the lifespan analyses.

| Mouse | Strain | Recorded age at death | Weighings after it | Last weighing |
|---|---|---|---|---|
| NAM 4590 | BXD32 | 421 | 5 | 709 days |
| NAM 2887 | BXD40 | 389 | 2 | 692 days |
| NAM 3031 | BXD62 | 271 | 1 | 463 days |
| NAM 3527 | BXD172 | 638 | 1 | 698 days |
| NAM 5026 | BXD62 | 483 | 1 | 526 days |
| NAM 4558 | BXD15 | 155 | its only weighing, at set-up | 190 days |

- **NAM 4558** is also listed in Suheeta's mapping file as dying at 155 days after set-up at 190 days. One of the two ages must be wrong.

**Weight lost in the first weeks on the NAM diet (rule C, 23 weighings).** Most of these are not errors. Many NAM mice were weighed weekly for the first weeks, and some lost a great deal, then recovered:
- **BXD40 mouse 2888:** 28.0 g at set-up, then 20.3, 16.9 and 15.2 g over three weeks, then back to 25.1 and 31.9 g;
- **DBA/2J mouse 2879:** 18.6 g at set-up, then 14.3 g a week later.

Over the first five weeks, 13% of NAM mice lost more than 10% of their starting weight, against 0.2% of high-fat mice. The median NAM mouse gained 7% in that time, the median high-fat mouse 31%. Did the mice refuse the NAM diet at first? If so, they had a short spell of food restriction.

**Other changes to check:**
- **NAM 3020** (BXD101): 63.6 g at 707 days, then 27.6 g at death 7 days later.
- **NAM 3678** (BXD190): 44.4 g at 480 days, then 20.3 g at death at 526 days.
- **NAM 3587** (BXD101): 26.8 g at 310 days, between 53.9 g at 245 days and 71.0 g at 440 days. Probably a slip.
- **NAM 3698** (BXD170): 46.2 g at 233 days, then 24.2 g five days later at "set-up" (rules C and G). The set-up row may belong to another mouse.

## What we would like from Suheeta

For each flagged mouse, one of three answers:
1. **The record is right.** Note any extenuating circumstance, such as a tumor, a cage flood or a fight.
2. **The record is wrong, and here is the correct value.** We record the correction in a derived table under `data/corrected/`, keeping the value as recorded beside it.
3. **Cannot tell.** We keep the weighing and run every analysis with and without it.

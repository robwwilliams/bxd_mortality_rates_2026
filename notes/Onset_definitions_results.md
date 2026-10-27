# How much do the Part 4 conclusions depend on the definition of morbidity? Results

**Exploratory analysis, run on 27 October 2026** as set out in `notes/PLAN_morbidity_definitions.md`, which Rob approved before any definition other than Part 4's was run.
- **Code:** `BodyWeight/morbidity_functions.R`, `BodyWeight/onset_definitions.R` and `BodyWeight/Figures_onset_definitions.R`.
- **Tables:** `output/Onset_definitions_*.txt`.
- **Figure:** Fig. 13 (`output/Fig13_Onset_definitions.svg`).

## In brief

**Percent below peak, as a graded measure, predicts death best.** Mice at the same age were ranked by each rule at each weighing. Ranked by how far they had fallen below their highest weight so far, they died in that order 66% of the time (the concordance). The best threshold or rate rule managed 63%.

**Robust conclusions.** These held in at least 94% of the 568 definitions:
- **On high fat, longer-lived strains spend more days in decline.** All 568 definitions agree.
- **Short × short F1s spend the same number of days in decline as their short-lived parents** (94%), though they live 171 days longer.
- **Long × long F1s do not differ from their parents** (96–97%).
- **On chow, the decline is about the same share of life in short- and long-lived strains** (99%).
- **Weight holds near peak until about four months before death on chow, and falls later and faster on high fat.** This is true with every plateau.

**Sensitive conclusions:**
- **On chow, longer-lived strains spend more days in decline.**
  - This holds only when decline starts at a shallow line (90–95% of peak), and under the change point and the graded measures. 42% of definitions agree with Part 4.
  - With a line at 85% or 80% of peak, at equal risk, against a stable baseline, or with the rate rule, the effect disappears.
  - **The lesson:** the extra days of long-lived chow strains are days of mild loss, 5–10% below peak. They are not extra days of deep terminal decline.
- **High fat shortens the decline.** This holds when decline means days below a fixed fraction of peak (58% of definitions significant, as in Part 4). It reverses (22% significant the other way) when decline is measured at equal risk, by the rate of loss, against a stable baseline, or as excess risk.
  - **The lesson:** on high fat the decline is shorter in days, but steeper and riskier.
- **Relative compression in short × short F1s.** In 85% of definitions, the F1s spend a smaller share of life in decline than their parents. That is significant in only 12%, including the first-crossing rule and the change point. In Part 4 it was *P* = 0.07.
- **On high fat, the share of life spent below peak rises with lifespan** under the graded measures (both significant), but not under Part 4's definition.

**The definition that best predicts death agrees with Part 4 on every conclusion but one.** That definition is graded percent below peak (G1). The exception is the high-fat share of life.

## How to read Fig. 13 (a short lesson)

**A specification curve** runs one analysis many times, once for each defensible set of choices, and shows every result side by side. The question is not "what is the answer?" but "would a different reasonable choice have changed it?"

**Panels a–e:**
- each gray point is one definition's estimate divided by its standard error, and the points are sorted;
- the shaded band runs from about −2 to +2. Points outside it have a 95% CI that excludes zero;
- the black dot is Part 4's definition, and the open diamond the definition that best predicts death.

A robust conclusion puts nearly all its points on the same side, as panel b does. A sensitive one has points on both sides, as panel e does.

**Panel g** says which choice moves a conclusion. Each cell gives the percentage of definitions with that setting that reach Part 4's verdict. Two examples:
- in the first row (chow, days), O3, O4, O6, O10 and P4 sit near zero;
- in the C4 row, O10 and P4 are the low cells.

## Which rule predicts death best (validity)

At each weighing from 300 days of age, each rule asks: "Is this mouse in decline now?" A Cox model on age then asks how well the answer predicts death before the next weighing. These rules use only what could be known at the time.

| Rule (highest weight so far, all weighings) | Chow BXDs | High-fat BXDs | F1s | Mean |
|---|---|---|---|---|
| G: percent below peak, graded | 0.616 | 0.659 | 0.709 | 0.661 |
| O9: an interval losing more than 10% | 0.579 | 0.637 | 0.662 | 0.626 |
| O3: below 85% | 0.585 | 0.627 | 0.652 | 0.621 |
| O1: below 90% (Part 4) | 0.585 | 0.634 | 0.641 | 0.620 |
| O8: change point | 0.576 | 0.629 | 0.647 | 0.617 |
| O6: losing at least 2% a month | 0.572 | 0.629 | 0.640 | 0.614 |

- **Concordance** is the chance that, of two mice of the same age, the one with the worse value dies first. 0.5 is a coin toss.
- **The graded measure wins in every group.** Its hazard ratio corresponds to about 1.41-fold per 10 points below peak on chow. This repeats the exploratory finding of 27 October: the risk rises with each step of loss, so a single line throws information away.
- **Weight predicts death least well on chow,** where the decline is slow and mixed with ordinary aging loss.
- **The plateau and the weighing set barely matter.** For the graded measure, the highest weight so far beats the median of the three highest by 0.010 and the stable baseline by 0.025.

## Every conclusion

Part 4's estimate, then the share of the 568 definitions that agree with it.

| Conclusion | Form | Part 4 (95% CI) | Same direction | Same verdict | Best-predicting definition | Verdict |
|---|---|---|---|---|---|---|
| C1 chow: decline ~ lifespan | days per day | 0.13 (0.03 to 0.23) | 89% | 42% | significant + | **sensitive** |
| | share of life | ~0 (n.s.) | — | 99% | n.s. | robust |
| C1 high fat | days per day | 0.11 (0.05 to 0.17) | 100% | 100% | significant + | robust |
| | share of life | ~0 (n.s.) | — | 67% | significant + | **sensitive** |
| C2 short × short F1s − parents | days | 0 (−32 to 32) | — | 94% | n.s. | robust |
| | share of life | −0.039 (−0.086 to 0.008) | 85% | 86% | n.s. | **sensitive** |
| C3 long × long F1s − parents | days | −18 (−53 to 17) | — | 96% | n.s. | robust |
| | share of life | −0.021 (−0.062 to 0.020) | — | 97% | n.s. | robust |
| C4 high fat − chow | days | −42 (−56 to −28) | 64% | 80% | significant − | **sensitive** |
| | share of life | −0.043 (−0.059 to −0.027) | 61% | 85% | significant − | **sensitive** |

- **"—"** marks a "no difference" conclusion, for which direction has no meaning. Its robustness rests on the verdict alone.
- **Part 4's definition, rerun here, reproduces Part 4's numbers.** Every mouse's span matches. The *P* values differ slightly (C1: 0.015 and 0.003, against 0.021 and 0.0015) because the random splits and permutations were drawn afresh, once, for all definitions.

## Why chow and high fat differ

**On chow, weight drifts down for months before the terminal fall.**
- Chow mice still more than a year from death are already about 6% below peak at 600–750 days.
- So a shallow line (90–95%) counts this drift as "decline", and long-lived strains, which spend longer at old ages, collect more of it.
- A deep line (80–85%), or a baseline taken 4–8 months before death, counts only the terminal fall, and that is not longer in long-lived strains.

**On high fat, the mice hold their peak until about three months before death, then crash.** Every definition sees the same thing: the crash lasts longer in longer-lived strains.

**The two diets' declines differ in kind:**
- **High fat:** short, deep and risky.
- **Chow:** long, shallow and less risky per day.

Which diet has "more" morbidity depends on whether a day 12% below peak counts the same on both diets (Part 4's definition), or counts by its risk (O10 and G2). It is a question of values as much as of data.

## Caveats

- **Exploratory,** with no correction for multiple tests.
- **The 568 definitions are not independent:** they share the same mice and weighings. The shares say how fragile a conclusion is to choices, not how likely it is to be true.
- **The shares depend on what is in the grid.** Threshold rules make up most of it.
- **G2 and O10 treat the diets differently by design** (a steeper risk per point of loss on high fat), which pushes C4 toward high fat.
- **The natural-deaths check of Part 4 was not repeated** across the grid.

## What this suggests for the report

- **Keep as stated:**
  - on high fat, longer-lived strains spend longer in decline;
  - short × short F1s add life without adding days of decline;
  - long × long F1s do not differ.
- **Qualify:**
  - the chow slope is a slope of mild weight loss;
  - high fat shortens the decline in days but makes it steeper and riskier;
  - the F1s' relative compression is suggestive, not established.
- **Consider making graded percent below peak the main measure,** since it predicts death best, with Part 4's 90% line as the simple alternative.

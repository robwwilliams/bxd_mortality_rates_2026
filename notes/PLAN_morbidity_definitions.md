# Plan: are the Part 4 conclusions sensitive to how we define the onset of morbidity?

**Status: approved by Rob on 27 October 2026** ("Yes, approve both plans as written: run the comparison of onset definitions, and the NAM analysis with the TSRB-matched design"), before any definition other than Part 4's was run. Written by Claude on 27 October 2026, from Rob's request below. This is exploratory: the Part 4 results with one definition have been seen, but no other definition has been run against any conclusion. The list of definitions and the rule for calling a conclusion robust are fixed here, before any of them is run.

## Rob's request, in his words

> "what we want to assure ourselves and our reviewers/readers is that we have explored alternatives AND that conclusions X, Y, and Z are not sensitie (OR are sensitive) to these "pulled out of a hat" ideas of defining onset. Does it not make sense to compare them all."

> "My per diem idea is a distraction." The per diem cost (Part 4, Q4) is therefore dropped from this comparison.

## The conclusions to test

From Part 4 (`notes/Terminal_decline_results.md`), with the 90% definition.

| | Conclusion | Part 4 estimate |
|---|---|---|
| C1 | Across BXD strains, longer-lived strains spend longer in decline, close to in proportion. | 0.13 days of decline per day of life on chow (*P* = 0.021), 0.11 on high fat (*P* = 0.0015) |
| C2 | Short × short F1s live longer than their parents, with the same days in decline. | life +171 days (*P* = 0.005); decline 0 days (−32 to 32) |
| C3 | Long × long F1s do not differ from their parents. | decline −18 days (−53 to 17), *P* = 0.34 |
| C4 | High fat shortens the decline within strains. | −42 days (−56 to −28), *P* < 0.0001 |
| C5 | Weight holds near peak until about four months before death on chow, and falls later and faster on high fat. | Fig. 12a (descriptive) |

- **Each conclusion is tested two ways:**
  - in days of decline (absolute, as Fries framed compression);
  - as a share of life (days of decline / age at death).
- **The statistics are those of Part 4.** The unit is the strain or genotype. Q1 uses split halves, a jackknife over strains and a permutation. Q2 uses a jackknife over genotypes and an exact permutation. Q3 uses a jackknife over strains and sign flips. Seeds are fixed.

## The choices that define morbidity

Every definition is one setting of the five choices below. Part 4's settings are marked ★. Choices added from the literature (read on 27 October 2026; summarized in `notes/reading_notes_frailty.md`) name their source.

**1. Plateau weight** (what "100%" means):
- P1 ★ the highest weight at least 120 days before death;
- P2 the running peak: the highest weight up to each weighing, which is all a technician could know at the time;
- P3 the median of the three highest weights at least 120 days before death, which resists one high spike;
- P4 a stable baseline: the mean of the weighings 120–240 days before death. Ray et al. 2010 and Trammell et al. 2012 used the mean of a window 10–16 weeks before death; ours is wider because we weigh every 64 days. A mouse with no weighing in that window falls back to P1.

Why P3 and P4 matter: the highest of several noisy weighings overstates the plateau. With 5–8 weighings near the plateau, the expected overstatement is 1.2–1.4 times the noise of one weighing: 4–7% at our 3–5% noise. So "90% of the observed peak" may be only 93–96% of the true plateau.

**2. Weighings used:**
- K1 ★ all weighings;
- K2 without the weighings flagged by rules A, B, E and G of `qc/BodyWeight_QC.md` (out of range, isolated spikes, after death, out of order). Suheeta's answers will replace this rule when they come.

**3. Onset of decline:**
- O1 ★ below 90% of plateau, with no later weighing back at 90% or more;
- O2, O3, O4 the same at 95%, 85% and 80%;
- O5 below 90% for the first time after the peak, with recovery allowed;
- O6 the start of the final run of weighing intervals in which the mouse loses at least 2% of plateau per month;
- O7 below 90%, or losing at least 5% of plateau per month, whichever comes first, with no recovery;
- O8 a change point for each mouse: a plateau followed by a straight-line decline, fitted to all its weighings, with onset at the break. Alley et al. 2010 found the change point in men, rather than a fixed cutoff;
- O9 the first interval in which the mouse loses more than 10% of plateau. Schultz et al. 2020 scored a loss of more than 10% in a month as a deficit;
- O10 equal risk: below the weight at which the risk of death doubles, with no recovery. From the exploratory fits, that is 22% below plateau on chow and 14% on high fat and in F1s. It puts each diet's line where the risk is the same, not where the weight is the same.

**4. Where onset falls between two weighings:**
- T1 ★ halfway between the last weighing above the line and the first below;
- T2 where the straight line between those two weighings crosses the line (threshold rules O1–O5, O7 and O10 only).

**5. The last gap** (from the last weighing to death, a median of 30 days with no weight):
- L1 ★ a mouse still above the line at its last weighing gets half the days from that weighing to death;
- L2 carry the last weight forward to death: no decline that was not already observed;
- L3 extrapolate from the last two weights to death. Rob: "I suspect the answer is to extrapolate from last two weights."
- L4 draw a straight line from the last weight to 76% of plateau at death, the median weight of the 309 mice weighed within 3 days of death.

In those 309 mice, carrying the last weight forward guessed the weight at death 9.0% of peak too heavy, and extrapolating from the last two weights 6.6% too heavy. The typical error was 13–14% of peak either way. Weight lost after death is small by comparison: about 0.8% a day at room temperature (Howie et al. 2024).

**Graded measures, with no onset.** Rob asked for "a biological graded transition". These replace choices 3 and 4. They use each setting of choices 1 and 2, and L2–L4 for the last gap (L1 has no meaning without an onset).
- G1 **weight-loss area:** each day counts by how far the mouse is below plateau, beyond a 5% band for weighing noise.
  - Weight is joined by straight lines between weighings.
  - For example, 30 days at 25% below plateau count 30 × 20 = 600 percent-days.
- G2 **excess-risk days:** each day counts by the extra risk of death its weight loss carries.
  - The day's weight is t = 1 − weight/plateau.
  - Its hazard ratio is HR = exp(β t). β comes from the exploratory fits of 27 October: 1.37× per 10 points below peak on chow, 1.65× on high fat and in F1s.
  - The day counts HR − 1. A day at 20% below peak on chow counts 0.88.
- Lamming 2024 built a measure of this kind for the frailty index (FAMY). He warns that fixing the score at death writes a decline into every mouse and makes the measure track lifespan. G1 and G2 fix nothing at death.

## What will be run

- **One choice at a time.** Each choice is varied away from Part 4 while the others stay at ★. That gives 19 definitions plus Part 4, each shown as its own row.
- **The full grid:**
  - every combination of plateau, weighings, onset and last gap: 4 × 2 × 10 × 4 = 320 definitions with T1, and 4 × 2 × 7 × 4 = 224 more with T2;
  - plus 4 × 2 × 3 × 2 = 48 graded ones;
  - 592 definitions in all.
- **Validity of each definition.** How well does "in decline" predict death before the next weighing, among mice of the same age?
  - This is a Cox model on age, as in the exploratory test, giving a hazard ratio and a concordance.
  - It ranks the definitions by biology, not only by how much they move the conclusions.

## How the results will be shown

- **One figure for each conclusion.** Every definition's estimate and 95% CI, sorted, with Part 4's marked. Below, a strip shows which settings made each estimate (a "specification curve").
- **One table** gives, for each conclusion:
  - the share of definitions that agree with Part 4 in direction;
  - the share that agree in verdict (CI excluding zero, or not).

## When a conclusion counts as robust

A conclusion is **robust** if all four hold:
- its direction is the same in every definition of the one-at-a-time set;
- its direction is the same in at least 95% of the full grid;
- its verdict is the same in at least 90% of the full grid;
- its verdict is the same in the definition that best predicts death.

Otherwise it is **sensitive**, and the report names the choice that moves it.

## Considered and not run

- **The last 10% of life** (Di Francesco et al. 2024). It fixes the decline as a share of life, so it cannot test compression.
- **Percent below the median of the same strain and diet at the same age.** At old ages that median is made only of survivors, and many strains have fewer than 10 mice per diet.
- **Weight × body temperature** (Ray et al. 2010; Trammell et al. 2012). We have no temperatures.
- **Frailty-index cutoffs and Fried-style frailty phenotypes** (Kane et al. 2017; Liu et al. 2014). We have body weight only. Zhu et al. 2026 found that frailty cutoffs do not transfer across strains and sexes, which is one more reason to test many definitions here.

## Not in this plan

- **The human comparison**: costs of late-life care, and weight loss in the last years of life. It comes after the mouse measure is settled.

## Implementation details, fixed before the comparisons were run

Written by Claude on 27 October 2026, after Rob's approval and before any definition other than Part 4's was run against any conclusion.

- **Mice.** Part 4's mice (the 1,934 BXD-family mapping mice on chow or high fat, and the F1s from the corrected table) that have a weighing at least 120 days before death under both weighing settings, K1 and K2. Weighings dated after death are dropped in every setting.
- **The peak weighing.** For every plateau setting, onset is sought only at or after the highest weighing at least 120 days before death, as in Part 4. Graded measures run from that weighing to death.
- **Plateaus.**
  - P2 divides each weight by the highest weight up to and including that weighing.
  - P3 uses fewer than three weights when a mouse has fewer.
- **Mice not in decline at their last weighing.**
  - L1 gives them half the days to death; L2 gives them none.
  - L3 and L4 draw an assumed path from the last weighing to death, and onset is where the path crosses the line, under either T setting.
    - L3's path is the straight line through the last two weighings.
    - L4's path ends at 76% of plateau, or at the last weight if that is already lower.
  - Mice already in decline at their last weighing are not affected by the L setting.
- **O6, the rate rule.**
  - The rate of an interval is the weight lost, as a fraction of plateau, per 30 days.
  - Onset is the start of the final run of intervals that each lose at least 2% per month and that ends at the last weighing.
  - If the last interval loses less, the mouse has no observed decline.
- **O7.** A weighing counts as in decline if it is below 90%, or if the interval ending there lost at least 5% per month. Under T2, onset is the 90% crossing when that is what triggered it, and the midpoint otherwise.
- **O8, the change point.**
  - The weight is fitted as a plateau, then a straight-line fall from a break τ, by least squares over the weighings from the peak on. τ runs on a 5-day grid from the peak to the last weighing.
  - A decline counts only if the fitted fall by the last weighing is at least 5% of the plateau, the noise band; otherwise the mouse has no observed decline.
  - O8 uses no plateau, so its four plateau settings are one definition and count once.
  - T does not apply. Under L3 and L4, the path's weight at death is added and the fit repeated.
- **O9.** Onset is the start of the first interval, from the peak on, that loses more than 10% of plateau. T does not apply.
- **O10, equal risk.** The line is 1 − 0.10 × ln 2 / ln 1.37 = 78.0% of plateau for chow BXDs, and 1 − 0.10 × ln 2 / ln 1.65 = 86.2% for high-fat BXDs and for all F1s.
- **Graded measures.**
  - Both are computed on a 1-day grid, with weight joined by straight lines between weighings, and the L path from the last weighing to death.
  - G2 uses 1.37 per 10 points for chow BXDs and 1.65 for high-fat BXDs and all F1s. Weight above plateau counts as zero loss.
- **Share of life:** days in decline, or the graded burden, divided by age at death.
- **Statistics as in Part 4.** The 200 random splits, 2,000 permutations and 10,000 sign flips are drawn once from the fixed seed and reused for every definition, so definitions differ only in the definition. All deaths are used; the natural-deaths check of Part 4 is not repeated across the grid.
- **Shares are over distinct definitions.** Taking O8 once, the grid holds 296 definitions with T1, 224 with T2 and 48 graded: 568 in all.
- **Null conclusions.** Where Part 4's definition gives a CI that includes zero, the conclusion is "no difference". For these, direction has no meaning and robustness rests on the two verdict criteria.
- **Validity uses the version of each rule that could be known at the time.**
  - "No later recovery", a peak defined from the age at death, and the last-gap rules all use the future. So at each weighing from 300 days of age:
    - P1 and P2 become the highest weight so far;
    - P3 the median of the three highest so far;
    - P4 the mean of the weighings 120–240 days before the current one, or the highest so far if there are none;
    - O1–O4 and O10 mean below the line now;
    - O5, below 90% at any weighing since the peak so far;
    - O6, the last interval lost at least 2% per month;
    - O7, below 90% now or the last interval lost at least 5% per month;
    - O8, a change point fitted to the weighings so far shows a decline;
    - O9, any interval so far lost more than 10%;
    - G1 and G2, the current loss beyond 5%. That ranks mice the same way for both.
  - **The Cox model.** It is on age, from each weighing to the next, clustered by genotype, run separately for chow BXDs, high-fat BXDs and F1s.
  - **"The definition that best predicts death"** is the one with the highest concordance averaged over the three groups. Its verdict check uses the full definition with that plateau, weighing set and onset rule, and T1 and L1.
  - **Mapping it back to a full definition.** The highest weight so far stands for both P1 and P2, so the check uses P1. If a graded measure predicts best, the check uses G1 with L2.


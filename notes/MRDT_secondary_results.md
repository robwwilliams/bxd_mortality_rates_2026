# Pre-registered secondary tests: does genotype change the mortality rate doubling time?

Results of the two tests registered in `notes/PREREGISTRATION_secondary.md` (commit 59c990f, 24 October 2026, 00:08 UTC), and of the secondary analyses specified there.
- **Code:** `Gompertz/MRDT_Secondary.R` and `Gompertz/Figures_MRDT_Secondary.R`.
- **Tables:** `output/MRDT_secondary_*.txt`.
- **Figures:** Figs 5 and 6.

Everything below the registered tests is reported as an estimate with its 95% interval, as the registration requires. The analyses in the section marked exploratory were added after the registered results were seen.

## Short answer

| Registered test | MRDT, first group | MRDT, second group | Ratio (95% CI) | P | Decision at α = 0.025 |
|---|---|---|---|---|---|
| **H1** Chr 1, D strains / B strains | B: 141 d (127–156) | D: 154 d (141–169) | 1.10 (0.80–1.51) | 0.57, two-tailed | no difference |
| **H2** F1 hybrids / inbred parents | Parents: 165 d (140–193) | F1: 107 d (97–117) | 0.65 (0.43–0.97) | 0.98, one-tailed | prediction not supported |

- **H1: proximal Chr 1 does not change MRDT.**
  - The jackknife P is 0.57. Dropping each strain in turn moves the log2 ratio only between −0.03 and +0.20.
  - **Chr 1 acts on the level of mortality, not on its slope.** At 600 d on high fat, B strains die at twice the rate of D strains: 5.8 against 2.8 deaths per 1,000 mouse-days. On chow the ratio is 1.25 (3.1 against 2.5).
  - **The D haplotype nearly cancels the high-fat penalty.** High fat raises mortality at 600 d 1.86-fold in B strains but only 1.15-fold in D strains. This matches the diet-dependent Vita1a/b effect on lifespan, and it acts through the level. (This comes from the fitted levels and is descriptive, not a registered test.)
- **H2: F1s do not have a longer MRDT. Their MRDT is shorter.**
  - F1 mortality starts much lower and rises faster (Fig. 6c, d). At 600 d, F1 mortality is less than half the parents' on chow (1.1 against 2.3 per 1,000 mouse-days). The two curves meet near 940 d on chow and near 760 d on high fat.
  - The one-tailed test cannot reject in the opposite direction, so under the registration this steepening is an estimate, not a finding.
  - It is robust within the registered design. Dropping any one of the 21 genotypes leaves the log2 ratio between −0.74 and −0.43. It holds from 0 d (107 against 163 d) and from 365 d (110 against 177 d).

## Where the F1 result comes from

**The steepening is all in the short-by-short crosses** (secondary analysis S1, Fig. 5):

| Comparison | Parents | F1 | Ratio (95% CI) |
|---|---|---|---|
| Short × short F1s / short-lived parents (BXD9, 170, 172, 197) | 156 d | 98 d | 0.63 (0.49–0.81) |
| Long × long F1s / long-lived parents (BXD65, 73b, 77, 102) | 110 d | 105 d | 0.95 (0.72–1.27) |
| B6D2F1, D2B6F1 / C57BL/6J, DBA/2J (S2; Wald interval) | 116 d | 134 d | 1.15 (0.86–1.55) |

- **S×S hybrid vigor lowers mortality and steepens its rise.**
  - At 600 d on chow, short-by-short F1s die at a quarter of their parents' rate: 1.4 against 5.4 per 1,000 mouse-days.
  - Their mortality then rises faster, and the curves would meet near 1,100 d on chow and 950 d on high fat.
  - So the F1s gain most in early and middle adult life, and the gain narrows with age.
- **L×L crosses show neither strong heterosis nor a change in slope.**
- **The B6D2 hybrids point the other way** (slightly flatter), but with 52 F1s the interval is wide.

## Exploratory, after the registered results were seen: a level for each genotype

The registered model gives each class and diet one level, so it pools genotypes of different levels. Pooling flattens a group's curve, and the eight parents differ from one another more than the 13 F1 types do: short-lived parents average 468–573 d, long-lived parents 666–796 d. To separate this effect, each genotype × diet cell was given its own level, with one MRDT per group as before:

| Comparison | First group | Second group | Ratio (95% CI) |
|---|---|---|---|
| H1, D / B strains | 108 d | 105 d | 0.98 (0.71–1.36) |
| H2, F1 / inbred parents | 110 d | 87 d | 0.79 (0.61–1.02) |
| S×S F1s / short-lived parents | 139 d | 86 d | 0.62 (0.45–0.84) |
| L×L F1s / long-lived parents | 94 d | 88 d | 0.93 (0.73–1.18) |

- **About half the pooled H2 gap is mixture.** The log2 ratio moves from −0.62 to −0.34, and its interval now reaches 1.
- **The short-by-short steepening is not mixture.** It is unchanged.
- **H1 stays null.**
- **Within-genotype MRDTs are mostly 86–110 d** (139 d in the short-lived parents), shorter than the pooled 140–165 d, as the diet analysis predicted.

## Other secondary analyses

| | First group | Second group | Ratio (95% CI) |
|---|---|---|---|
| S3: recombinant B-D / B strains | 141 d | 135 d | 0.96 (0.74–1.25) |
| S3: recombinant D-B / B strains | 141 d | 165 d | 1.17 (0.76–1.81) |
| S4: D / B strains, chow only | 157 d | 155 d | 0.98 (0.75–1.29) |
| S4: D / B strains, high fat only | 120 d | 154 d | 1.28 (0.78–2.11) |
| S5: D / B strains, high fat + NAM (51 and 24 mice) | 123 d | 80 d | 0.65 (0.25–1.67) |

- **S4: on high fat, B strains have a steeper rise** (120 against 154 d), and on chow the slopes are equal. The haplotype × diet difference in log2 ratio is 0.39 (−0.27 to 1.04). This is the same direction as the Vita1a/b lifespan effect, which is strongest on high fat, but the interval is wide.
- **S6:** the H1 and H2 estimates from 0 d and from 365 d agree with those from 200 d (Fig. 5).

## Sensitivity: gamma-Gompertz

This model lets mice within a group differ in risk at a given age, so a group's curve bends below a straight line at late ages as the high-risk mice die.
- **The B strains and the inbred parents need no such term** (variance near 0).
- **The D strains (variance 0.76) and the F1s (0.48) do.**
- **The individual-level slopes are then even steeper** in the D strains (MRDT 81 d against 141 d) and in the F1s (77 d against 165 d).

For H1 this reverses the sign of the Gompertz estimate. Together with the per-strain refit, that leaves no consistent evidence that Chr 1 changes the slope. For H2 it points the same way as the registered model, only more strongly.

## What this means for the Charlesworth–Hughes prediction

- **The prediction.** Under mutation accumulation, inbreeding depression in mortality should grow with age (Charlesworth & Hughes 1996). That predicts a flatter F1 curve.
- **What we see.** On the log-hazard scale, which is the scale of MRDT, the short-by-short F1 advantage is largest in early adult life and narrows with age.
- **Two readings fit.**
  - **Hybrid vigor removes early deaths.** It removes much of the mortality that the short-lived inbred strains carry from early adulthood on, and leaves a later, steeper rise.
  - **The Strehler–Mildvan pattern.** Lower level and steeper slope go together, as in most of the gene manipulations of de Magalhães et al. (2018).
- **A caveat on scale.** Charlesworth and Hughes measured inbreeding decline in age-specific survival, not log hazard, and the two scales can rank ages differently.

## Caveats

- **Live F1s.** None is believed to be alive (Rob Williams, 24 October 2026); Suheeta Roy is checking. If long-lived F1s were still alive and missing from the export, the F1 curve would look steeper than it is. The registration says to rerun H2 with any such mice censored, and that rerun is the registered result.
- **Diet labels.** The export lists F1s on both diets (160 CD, 164 HF). Each class × diet cell has its own level, so the F1 slope does not depend on which label is right.
- **Vivaria.** All F1s were housed in vivarium 3, while the parents span vivaria 1–3. Cofactors are not adjusted here, by decision.
- **Inference is by strain.** The animal-level likelihood-ratio P values (in the tables) treat mice of one strain as independent. In simulation (`Gompertz/test_gompertz.R`), with strains that vary in level and slope and no true difference:
  - the strain jackknife rejected at 5.5% (nominal 5%);
  - the likelihood-ratio test rejected at 14%.

## In plain terms

- **Chr 1.** The proximal Chr 1 region changes *how many* BXD mice die at a given age, especially on the high-fat diet, but not *how fast* their risk doubles with age.
- **The F1s.** Crossing two short-lived BXD strains gives hybrids that are much less likely to die in early and middle adult life. Their risk then climbs faster, so by very old ages the hybrids lose much of their advantage.
- **Rob's prediction.** The registered prediction was that hybrids age more slowly, with a flatter climb. The data say the opposite, and the registration means we report that as an estimate, not as a discovery.

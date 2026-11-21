# High fat within strains: Beni Mozhui's Gompertz fits beside ours

**Exploratory analysis, run on 21 November 2026,** after both sets of results were seen. Claude wrote it at Rob's request.
- **Her analysis:** Khyobeni (Beni) Mozhui, *Gompertz analysis of lifespan in the BXDs by diet*, 20 November 2026, [squirrelb.github.io/BXD-Diet-Gompertz](https://squirrelb.github.io/BXD-Diet-Gompertz/).
- **Code:** `Gompertz/Mozhui_comparison.R` (about 6 s).
- **Table:** `output/Mozhui_comparison.txt`.

## In brief

- **We agree on the slope.** Pooled over strains, high fat leaves the mortality rate doubling time (MRDT) unchanged. Within strains, it shortens it. Both analyses say that strain has to be in the model, because a mixture of strains flattens the curve (primer point 8 of the report).
- **The data and fits match.** Refitted with our likelihood on our data, her model gives her numbers exactly.
- **Our slope effect is larger:** MRDT ratio, high fat / chow, 0.78 against her 0.87. Both exclude 1 with the strain as the unit.
- **We differ on the level, and only because of where it is measured.**
  - **She concludes** that high fat changes the slope (her *b*) and not the level (her *a*).
  - **Her *a* is mortality at birth,** an extrapolation to about a year before the first deaths. At 600 days, our reference age, her own fit has high-fat mortality 1.76-fold that of chow (P = 10⁻²⁸).
  - **The same curves therefore support both statements.** High fat raises mortality 1.8- to 1.9-fold at 600 days, and the multiple grows with age.

## How the bottom lines have changed

Rob asked whether her bottom line differs from ours, recalling that we had found a change in level and none in slope. That was our first conclusion, from the pooled fits.

| When | Analysis | Level | Slope (MRDT) |
|---|---|---|---|
| 23–27 October 2026 | Ours, Report v1, Part 1: pooled over strains | 1.4-fold higher at every age | unchanged: 153 against 149 days (P = 0.55) |
| 28 October 2026 | Ours, Report v2, Part 1 and Fig. 15d,e: within strains | 1.9-fold higher at 600 days (95% CI 1.6–2.3) | shorter: 117 against 91 days (ratio 0.78, 95% CI 0.69–0.88) |
| 20 November 2026 | Beni's, within strains | unchanged at birth | shorter: 119.5 against 104 days |

Report v1 did fit the strains, but with one MRDT for both diets (113 days, against 151 pooled). It did not let each diet have its own MRDT within strains. Version 2 did, and corrected Part 1.

## Same mice, same numbers

Her model, in `flexsurvreg`: `Surv(entry, death, event) ~ Diet + Strain, anc = list(shape = ~ Diet)`, Gompertz.
- **Each strain gets one level.** High fat multiplies every strain's level by the same factor, and each diet has its own slope.
- **Our refit uses the same 1,044 chow and 890 high-fat mice** (124 genotypes) that she used. It gives her MRDTs (119.5 and 104.0 days), her test of the slope (likelihood ratio 12.9, P = 0.0003) and her test of *a* (likelihood ratio 0.08 against her 0.087).

| Model | Mice | Chow MRDT (days) | High-fat MRDT (days) | Ratio, 95% CI over strains | Animal-level P |
|---|---|---|---|---|---|
| Hers: a level for each strain, one diet multiplier | all 124 genotypes | 119.5 | 104.0 | 0.87 (0.77–0.99) | 0.0003 |
| Ours: a level for each strain × diet | all 124 genotypes | 114.1 | 89.6 | 0.78 (0.70–0.88) | 2 × 10⁻⁸ |
| Hers | 76 strains with ≥ 5 mice on each diet | 121.2 | 105.1 | 0.87 (0.76–0.99) | 0.0005 |
| Ours (as in Fig. 15d) | 76 strains with ≥ 5 mice on each diet | 117.2 | 91.4 | 0.78 (0.69–0.88) | 4 × 10⁻⁸ |

- **Confidence intervals come from a delete-one-strain jackknife,** with *t* on strains − 1 d.f. Her page gives only animal-level P values. With the strain as the unit, her slope effect still excludes 1, narrowly.
- **The choice of mice makes no difference.** The difference between the two analyses comes from the model.

## Why our slope effect is larger (a likely reason, not tested)

- **Her model makes high fat raise every strain's mortality by the same multiple.** Fig. 5 showed that strains differ in that multiple: 2.2 in C57BL/6J, 1.0 in DBA/2J, with a between-strain SD of 0.36 on the natural-log scale (P = 0.0002).
- **What her model cannot absorb stays in the data as a hidden mixture.** Within a diet, some strains sit higher than the model allows and others lower. A mixture flattens the curve, so it likely mutes the difference in slope.
- **Our model gives each strain × diet its own level,** which removes that mixture.
- **The opposite worry was checked before.** In 40 simulations with one true MRDT for both diets, our model gave a ratio of 0.99 (`notes/Rectangularization_results.md`). Many small cells do not create a slope difference.

## Where to measure the level (a short lesson)

**A Gompertz curve has two numbers: a level and a slope.** The level can be read at any age; changing the age only moves the point where the lever pivots.
- **Measured at birth (her *a*, our *R*0),** the two diets' lines almost meet: high fat 1.05-fold chow. They then fan out.
- **At later ages, in her fit,** high-fat mortality is 1.36-fold chow at 300 days, 1.76-fold at 600 days and 2.28-fold at 900 days.

**So "does diet change the level?" has two answers, from the same fitted curves:**

| Level measured at | Does diet change the level? (each diet keeps its own slope) | Change in median lifespan, −71 days = level part + slope part |
|---|---|---|
| Birth (her *a*) | No: likelihood ratio 0.08, P = 0.77 | −7 + −64 |
| 600 days (our convention) | Yes: likelihood ratio 123, P = 10⁻²⁸ | −89 + 18 |

- **The median-lifespan split** is for a strain at the median chow level, from birth, averaged over the two orders of change (a Shapley split). Her own split is −7 and −61 days (her Fig. 2).
- **Neither split is wrong.** Pinned at birth, nearly all of the lost lifespan goes to the slope. Pinned at 600 days, nearly all of it goes to the level, and the steeper slope gives back a little, because it lowers high-fat mortality before 600 days.
- **This is why we report the level at 600 days.** *R*0 lies far outside the data and trades off against the MRDT. The statement that does not depend on the choice: high fat does both. It raises mortality 1.8- to 1.9-fold at 600 days (1.76 in her model, 1.9 in ours), and the multiple grows with age.

## Her nicotinamide section

- **The slope agrees with ours.** Her within-strain fits give nicotinamide (NAM) the same steep slope as high fat (MRDT 92 against 96 days). Our Part 5 found an MRDT ratio of 1.02 for NAM against high fat.
- **In her fits, the median NAM mouse lives 35 days longer than the median high-fat mouse (95% CI 2–67).** Part 5 found no difference. Two cautions from Part 5 apply:
  - **Vivarium.** All 172 NAM mice were housed at TSRB. In the strains with NAM mice, only 68 high-fat mice were at TSRB, so most of her 243 high-fat controls were housed elsewhere. Her model has no term for vivarium.
  - **Birth year.** NAM mice were born about three years after their high-fat controls. With controls born in the same years, the hazard ratio is 1.04 (95% CI 0.51–2.12).
- **Her counts (273 chow, 243 high fat, 143 NAM) do not match any subset we tried,** so her NAM data may differ from our file. Her chow and high-fat counts for Part A match ours exactly.

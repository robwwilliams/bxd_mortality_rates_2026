# Nicotinamide, rectangularization and the length of decline in BXD mice: results

**Exploratory analysis, run on 27 October 2026** as set out in `notes/PLAN_NAM_rectangularization.md`, which Rob approved before any comparison of NAM with high fat was run.
- **Code:** `Gompertz/NAM_rectangularization.R` and `Gompertz/Figures_NAM.R`.
- **Tables:** `output/NAM_rectangularization_tests.txt` (every test) and `output/NAM_by_strain.txt`.
- **Figure:** Fig. 14 (`output/Fig14_NAM.svg`).

## In brief

Within BXD strains housed at TSRB, adding 1% NAM to the high-fat diet changed nothing we could detect:
- not lifespan;
- not the level of mortality or its doubling time;
- not the spread of ages at death;
- not the days in terminal decline.

The decline was somewhat shorter with NAM under all 18 day-based definitions, but significantly so under only one. With 9 strains, only large effects could have been seen.

**One imbalance makes this null less certain** (see "Birth year" below, added after the results were seen):
- NAM mice were born about three years after their high-fat controls.
- At TSRB, mice born later died younger on both diets.
- Adjusting for that trend gives NAM a hazard ratio of 0.59 (95% CI 0.39–0.89). The direct check, with controls born in the same years, gives 1.04 (0.51–2.12).
- So these data neither show nor rule out a moderate benefit.

This agrees with de Cabo's study (Mitchell et al. 2018). There, nicotinamide at 0.05–0.1% of diet changed neither median nor maximum lifespan in C57BL/6J males on either diet.

## Mice

**Primary design.**
- TSRB only, in the 9 strains with at least 3 mice in each arm: 69 NAM and 48 high-fat mice.
- The strains are BXD2, BXD15, BXD75, BXD101, BXD170, BXD172, BXD190, BXD197 and C57BL/6J.
- For days in decline: the 108 of these 117 mice with a weighing at least 120 days before death. Since the NAM workbook went through the weight QC (27 October 2026), one more mouse drops out because it has too few weighings left once flagged ones are removed; the estimates moved by less than 0.1 day.

**Secondary design.**
- 22 strains with at least 3 mice in each arm in any vivarium: 161 NAM, 264 high-fat and 325 chow mice.
- Vivarium effects are estimated from the chow and high-fat mice.

## Results

NAM against high fat, as the mean over strains of the within-strain difference. *P* values come from exact sign flips over strains (512 arrangements); 95% CIs come from a delete-one-strain jackknife.

| Question | Measure | NAM vs high fat (95% CI) | *P* |
|---|---|---|---|
| N1 lifespan | mean age at death | +26 days (−95 to 148) | 0.62 |
| | same, every vivarium, adjusted for vivarium (22 strains) | +8 days (−66 to 81) | 0.83 |
| N2 level and slope | mortality at 600 days, NAM / high fat | 0.84× (0.37 to 1.90) | 0.64 |
| | MRDT: high fat 86 days, NAM 88 days | ratio 1.02 (0.63 to 1.66) | LRT 0.9 |
| | MRDT, every vivarium: 79 and 79 days | ratio 1.00 (0.78 to 1.29) | LRT 0.96 |
| N3 rectangularization | SD of age at death, NAM / high fat | 0.92× (0.49 to 1.74) | 0.79 |
| | interquartile range | 1.11× (0.51 to 2.40) | 0.78 |
| | CV of age at death | 0.89× (0.42 to 1.89) | 0.74 |
| | Keyfitz's H | +0.011 (−0.089 to 0.111) | 0.82 |
| | Gompertz-implied SD (1.85 × MRDT) | 160 and 163 days | — |
| N4 morbidity | days in decline (Part 4's definition) | −18 days (−62 to 26) | 0.38 |
| | the same, as a share of life | −0.038 (−0.099 to 0.023) | 0.18 |
| | the 18 day-based definitions of the one-at-a-time set | −11 to −40 days; all negative | 0.03–0.60 |

- **Ratios** are 2 raised to the mean log2 ratio over strains.
- **The only significant estimate** is under the rate rule (O6): −40 days (−70 to −10), *P* = 0.027. One of 18 definitions significant is about what chance alone would give, and all 18 use the same mice.
- **Natural deaths alone** leave 4 strains with at least 3 mice in each arm (19 NAM and 13 high-fat mice), too few to say anything. All estimates are in `output/NAM_rectangularization_tests.txt`.

## Birth year: an imbalance worth knowing (exploratory)

Rob, 27 October 2026: "Vivaria is not a big deal. We have checked. We use is as a cofactor when we can. Don't obsess about it but not[e] any imbalance that makes you worry."

**Vivarium is matched by design.** The primary design uses TSRB only.

**Birth year is not matched.** In the primary design:
- the high-fat controls were born from 2015 to 2020, most in 2016–2019;
- the NAM mice were born from 2019 to 2022, 49 of 69 in 2021;
- no high-fat mouse was born at TSRB in 2021, and in 2022 the NAM and high-fat strains do not overlap.

**At TSRB, later births died younger.** Chow and high-fat mice born 2015–2021 have all died, so the data freeze does not cut these cohorts short. Within strain, with diet, and with each mouse at risk from its set-up age:
- mortality rose 13% per later year of birth (hazard ratio 1.13, 95% CI 1.00–1.28, *P* = 0.044);
- the mean age at death fell 33 days per year (95% CI 16–50), adjusted for age at set-up;
- the share of deaths by euthanasia rose from about a quarter for mice born in 2015–2016 to about two thirds for mice born from 2017 on. A change in when mice were judged moribund may be part of the trend.

**What that does to the NAM comparison** (hazard ratios, NAM / high fat, Cox model stratified by strain):

| Version | Hazard ratio (95% CI) | *P* |
|---|---|---|
| As run (primary design) | 0.87 (0.58–1.32) | 0.51 |
| Adjusted for the birth-year trend of chow and high-fat mice | 0.59 (0.39–0.89) | 0.011 |
| Both arms born 2018–2020 (26 NAM, 25 high-fat mice, 11 strains) | 1.04 (0.51–2.12) | 0.92 |

- **The adjusted row** fixes the trend at its estimate, so its CI is too narrow.
- **The contemporaneous row** is the cleaner test, but it is small.

**The lesson.** A comparison across years carries whatever else changed over those years. Here that could be husbandry, euthanasia practice or staff. The adjustment would make NAM look protective; the same-years comparison does not. These data can neither show nor exclude a NAM effect of 10–40% on mortality.

**What would settle it:** NAM and high-fat mice born in the same months.
- **Code:** the section "Birth cohort" of `Gompertz/NAM_rectangularization.R`.
- **Output:** the rows "N1 cohort" of `output/NAM_rectangularization_tests.txt`.

## The NAM diet in the first weeks

**Many NAM mice lost weight in their first one to three weeks on the diet, then recovered** (`qc/BodyWeight_QC.md`).
- In the first five weeks, 13% of NAM mice lost more than 10% of their starting weight, against 0.2% of high-fat mice.
- The median NAM mouse gained 7% in that time, the median high-fat mouse 31%.

If the mice refused the NAM diet at first, they had a short spell of food restriction. That is another difference between the arms besides NAM itself.

## The dose

**Rob confirmed it on 27 October 2026:** "1% NAM means 1% of the diet by weight. It is the dose taken from the attached 2017 Science paper by Pete Williams."
- **Williams et al. 2017** (*Science* 355:756) gave 550 mg/kg/day in drinking water (low dose) and 2,000 mg/kg/day (high dose).
- **On our high-fat diet** (Envigo Teklad TD06414, 5.1 kcal/g), 1% by weight comes to roughly 600–750 mg/kg/day, close to Williams's low dose. This uses a typical intake of 2.5–3 g a day for a 40 g female, not measured in our mice.
- **de Cabo's doses** were 0.05% and 0.1% of diet, 10–20 times lower by concentration.
- **More detail,** including the human equivalent, is in `notes/Rectangularization_results.md`.

## What this means for rectangularization (a short lesson)

**Three things can make a survival curve more "rectangular":**
1. **Absolute:** deaths crowd into fewer days. Under the Gompertz law, only a shorter MRDT does that.
2. **Relative:** deaths crowd into a smaller share of the typical lifespan. A lower level of mortality alone does that.
3. **Compression of morbidity:** the sick period before death shrinks.

**NAM moved none of the three:**
- the MRDT is unchanged (86 against 88 days);
- the level is unchanged (0.84×, CI 0.37 to 1.90);
- the spread of ages at death is unchanged on every measure;
- the decline is, if anything, a little shorter.

**In de Cabo's mice,** read from their published curves, NAM on the standard diet *widened* the spread of ages at death at the same median. On high fat, both arms were already widely spread.

**How strongly this argues against an effect.** With 9 strains, the 95% CI for lifespan spans −95 to +148 days. These data can rule out a large NAM effect on lifespan in BXD females on high fat, but not a moderate one.

## Caveats

- **Exploratory,** with no correction for multiple tests.
- **NAM was given only at TSRB and only from 2018.**
  - The primary design matches place, but the high-fat controls there were born from 2015 to 2023.
  - The secondary design gives the same answer for lifespan (+8 days), but assumes that the vivarium moves NAM and high-fat mice alike.
- **62% of NAM deaths were euthanasia,** and the natural-deaths check has too few strains to read.
- **The NAM workbook has been through the weight QC** since 27 October 2026. The cleaned-weighing setting now drops flagged NAM weighings, too (23 weighings).
- **Birth year is not matched** (see above). Neither is the first-weeks weight loss on the NAM diet.

## Still to do

- **N5 from the published curves is done:** `notes/Rectangularization_results.md` and Fig. 15. The individual ages at death and weights from Rafa and Sarah would replace the rebuilt ones.
- **NAM and high-fat controls born in the same months,** if any exist that are not in the mapping file.
- **Suheeta's answers on the flagged NAM records** (`qc/BodyWeight_QC.md`), in particular NAM 4558 (death recorded at 155 days, set-up at 190) and NAM 4590 (weighed until 709 days, death recorded at 421).

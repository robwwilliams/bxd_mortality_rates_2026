# Rectangularization side by side: BXD mice and de Cabo's studies

**Exploratory analysis, run on 27 October 2026,** as set out in N5 of `notes/PLAN_NAM_rectangularization.md`. The rules for reading the curves and for every measure were written before any curve was digitized.

> "I will ask Sarah and Rafa about the NAM experiments after your initial analysis. He is interested in the idea of a "Rectangularization" paper. [...] Please proceed." (Rob)

- **Code:**
  - `tools/digitize_km.py` reads de Cabo's published survival curves;
  - `Gompertz/Rectangularization.R` runs every comparison;
  - `Gompertz/Figures_Rectangularization.R` draws the figure.
- **Data:** `data/digitized/` holds survival by age for each published arm, with images of the reading laid over each figure.
- **Tables:** `output/Rectangularization_tests.txt` (every comparison) and `output/Rectangularization_by_arm.txt` (de Cabo's arms).
- **Figure:** Fig. 15 (`output/Fig15_Rectangularization.svg`).

## In brief

**Three things can make survival curves more "rectangular,"** and they can move separately:
- deaths crowd into fewer days (a smaller SD, a shorter MRDT);
- deaths crowd into a smaller share of life (a smaller CV, a lower Keyfitz's H);
- the sick period before death shrinks (compression of morbidity).

Across 11 comparisons:
- **Hybrid vigor is the clearest case of healthy rectangularization.**
  - Short × short F1s live 179 days longer than their parents, with the same spread of ages at death in days. So deaths are less spread relative to lifespan (H lower, *P* = 0.014).
  - Their mortality doubles faster (MRDT 89 against 131 days), and their level at 600 days is a third of the parents'.
  - Part 4 showed that they spend the same number of days in decline. All three meanings point the same way, and the added days are healthy ones.
- **Long × long F1s live no longer, but their deaths are less spread,** in absolute and in relative terms (CV 0.72×, *P* = 0.036).
- **High fat, within BXD strains, narrows the spread of ages at death,** but only in days: SD 0.80×, *P* = 0.0001, while the CV is unchanged.
  - It also shortens the MRDT, from 117 to 91 days.
  - **This is new, and it qualifies Part 1** (see below).
- **Nicotinamide changed none of the measures,** in any study, at any dose:
  - our 1% on high fat;
  - de Cabo's 0.05% and 0.1% on the standard diet and on high fat.
- **Metformin at 0.1% moved the curve later without changing its shape:** mean +57 days (95% CI 14–99), with mortality at 600 days 0.56× (0.29–1.04). That is a level effect, not rectangularization.
- **Metformin at 1% is a warning.** It compressed deaths into a narrow band (SD 0.71×, MRDT 0.60×), because it killed the mice 150 days sooner. Rectangularization by itself is not good news. It is good only when lifespan and health go up with it.
- **High fat in de Cabo's B6 males made the curve *less* rectangular in relative terms:** CV 1.43×, *P* = 0.003. In BXD females the CV was unchanged. The designs differ: one strain of males started at 56 weeks, against many strains of females started young.

## The comparisons

BXD comparisons use the strain or genotype as the unit; de Cabo's use the mouse (one inbred strain). Ratios are treated against control. Values are estimates with 95% CIs.

| Comparison | Mean age at death (days) | SD | CV | MRDT | Mortality at 600 days | Days in decline |
|---|---|---|---|---|---|---|
| **BXD family females** | | | | | | |
| High fat vs chow, within strains (76) | −80 (−102 to −58) | **0.80** (0.71–0.90) | 0.91 (0.80–1.03) | **0.78** (0.69–0.88) | **1.91** (1.60–2.27) | −42 (−56 to −28)ᵃ |
| Short × short F1s vs parents (10 genotypes) | **+179** (111–247) | 1.01 (0.64–1.61) | 0.75 (0.49–1.14) | **0.68** (0.49–0.93) | **0.33** (0.17–0.61) | 0 (−32 to 32)ᵃ |
| Long × long F1s vs parents (11) | +44 (−41 to 129) | 0.77 (0.58–1.01) | **0.72** (0.55–0.95) | 0.83 (0.63–1.10) | 0.70 (0.33–1.47) | −18 (−53 to 17)ᵃ |
| High fat + 1% NAM vs high fat (9 strains, TSRB) | +26 (−95 to 148) | 0.92 (0.49–1.74) | 0.89 (0.42–1.89) | 1.02 (0.63–1.66) | 0.84 (0.37–1.90) | −18 (−62 to 26) |
| **C57BL/6 males, de Cabo** | | | | | | |
| High fat vs standard diet | **−157** (−193 to −124) | 1.17 (0.94–1.48) | **1.43** (1.11–1.84) | 1.12 (0.87–1.50) | **4.70** (2.95–8.01) | — |
| 0.05% NAM vs standard diet | −22 (−56 to 11) | 1.09 (0.84–1.41) | 1.12 (0.84–1.47) | 1.01 (0.80–1.31) | 1.22 (0.70–2.19) | — |
| 0.1% NAM vs standard diet | −25 (−61 to 9) | 1.15 (0.90–1.50) | 1.19 (0.90–1.56) | 1.22 (0.95–1.58) | 1.64 (0.98–2.79) | — |
| High fat + 0.05% NAM vs high fat | +20 (−20 to 59) | 1.11 (0.96–1.30) | 1.08 (0.90–1.31) | 1.12 (0.81–1.55) | 0.86 (0.54–1.37) | — |
| High fat + 0.1% NAM vs high fat | +5 (−33 to 42) | 0.99 (0.85–1.17) | 0.99 (0.82–1.18) | 1.02 (0.75–1.37) | 0.96 (0.62–1.52) | — |
| 0.1% metformin vs standard diet | **+57** (14–99) | 0.88 (0.70–1.10) | 0.82 (0.64–1.06) | 0.94 (0.72–1.20) | 0.56 (0.29–1.04) | — |
| 1% metformin vs standard diet | **−150** (−186 to −115) | **0.71** (0.56–0.88) | 0.85 (0.66–1.10) | **0.60** (0.47–0.78) | **2.87** (1.64–5.13) | — |

**Notes on the table:**
- **Bold** marks a 95% CI that excludes no change.
- **ᵃ** From Part 4's definition of decline. The diet difference depends on the definition (`notes/Onset_definitions_results.md`); the two F1 results do not.
- **"—"** means there are no individual weights.
- **Keyfitz's H and the interquartile range** are in `output/Rectangularization_tests.txt`.
- **Where to find the code:** the NAM row comes from `Gompertz/NAM_rectangularization.R`.

## High fat steepens mortality within strains (a lead that qualifies Part 1)

**Part 1 found that high fat raises mortality by the same multiple at every age, with no change in MRDT** (153 against 149 days, *P* = 0.55). That fit pools all mice of a diet into one curve.

**Within strains, the answer is different.** Here each strain gets its own level, and each diet its own MRDT:
- chow 117 days, high fat 91 days;
- ratio 0.78 (95% CI 0.69–0.88, delete-one-strain jackknife);
- animal-level likelihood-ratio *P* = 4 × 10⁻⁸.

The SD of age at death agrees: 0.80× within strains.

**Checks:**
- **Larger strains give the same ratio:** 0.75 with at least 10 mice on each diet (34 strains), 0.76 with at least 15 (14 strains).
- **Small cells do not explain it.** In 40 simulations with one MRDT for both diets and our strains, cell sizes and set-up ages, the fitted ratio was 0.99.

**Why pooling hides it (a short lesson).**
- Pooling strains whose levels differ flattens the pooled curve: the frailest strains die first, so the survivors at late ages are the hardier strains. Fig. 5 of the report showed that strains differ much more in their response to high fat than chance allows.
- Pooling over strains therefore probably flattens the high-fat curve more than the chow curve, which can hide a steeper rise within strains.
- Fig. 5b already showed the first part of this: within strains, the MRDT shared by both diets is 113 days, against 151 pooled.

**So for v2 of the report:**
- The pooled statement in Part 1 stays true of the population.
- Within a strain, high fat both raises the level of mortality and steepens its rise.

This was found after the results were seen, so it is exploratory.

## Hybrid vigor and the MRDT puzzle

- **The short × short F1s' MRDT is shorter than their parents'** (89 against 131 days), yet their SD of age at death is the same.
- **Under the Gompertz law, a shorter MRDT should narrow the SD.** The two measures disagree here, as they did in Part 2 (Fig. 6, ratio 0.63).
- **A likely reason:** the short-lived parental strains carry early, non-age-related deaths, which flatten their fitted MRDT without widening the spread of the deaths that follow.
- **Worth a closer look before the paper.**

## How the published curves were read (a short lesson)

**Metformin 0.1% (Martin-Montalvo et al. 2013, Fig. 1a).**
- The PDF figure is a vector drawing, and underneath each curve it carries a tiny marker at every week: triangles on the metformin curve, circles on the control curve.
- Their positions are the survival at each week, so this panel was read exactly. The steps are multiples of 1/64 and 1/83, the two group sizes.

**Metformin 1% (Fig. 1b) and nicotinamide (Mitchell et al. 2018, Fig. 1A–B).**
- These panels have no markers, so they were rendered as images and read one column of pixels (one age) at a time: by line style for metformin, by color for nicotinamide.
- Where one curve hides under another, its survival was interpolated between the ages where it shows.
- The images in `data/digitized/` lay the reading over each figure; they match to within a line width.

**From curve to ages at death.**
- For an arm of *n* mice, the *k*-th age at death is the age at which survival first falls to 1 − (*k* − ½)/*n*.
- This reads the published Kaplan–Meier curve as a distribution, so mice the authors censored (flooded cages, tissue collection) are handled as the curve handles them.

**Check against the papers.**
- Our change in mean lifespan is +6.9% for 0.1% metformin, against the reported +5.83%.
- It is −17.3% for 1% metformin, against −14.4%.
- Fig. 1a was read exactly, so that gap comes from how the mean was computed, probably from how censored mice were counted, not from the reading.

## The doses (for the paper)

- **Our 1% NAM is 1% of the diet by weight** (Rob, 27 October 2026), the dose of Williams et al. 2017 (*Science* 355:756).
  - That paper gave 550 mg per kg of body weight per day in drinking water (its low dose) and 2,000 mg/kg/day (its high dose).
- **What 1% delivers depends on the diet.**
  - **On chow** (3.1 kcal/g), a 30 g female eating about 4 g a day gets about 1,300 mg/kg/day.
  - **On the high-fat diet** (Envigo Teklad TD06414, 5.1 kcal/g), the mice eat fewer grams for the same calories. A 40 g female (the median NAM mouse at 300–600 days) eating about 2.5–3 g a day gets roughly 600–750 mg/kg/day, close to Williams's low dose.
  - These intakes are typical values, not measured in our mice.
- **de Cabo's doses were 0.05% and 0.1% of diet,** so ours is 10–20 times higher by concentration.
- **Scaled to people by body surface area** (divide the mouse mg/kg by 12.3), 600–750 mg/kg/day in a mouse is about 50–60 mg/kg/day in a person, or 3.5–4.5 g a day at 75 kg.
- **For comparison:**
  - Rob's 3 g a day is close to that.
  - The human glaucoma trial of Hui et al. 2020 (*Clin Exp Ophthalmol* 48:903, [doi:10.1111/ceo.13818](https://doi.org/10.1111/ceo.13818)) gave 1.5 g, then 3.0 g a day.

## Caveats

- **Exploratory,** with no correction for multiple tests.
- **de Cabo's ages at death are rebuilt from figures.**
  - The CIs treat every mouse as dying when the curve says. Mice the authors censored make these CIs a little too narrow.
  - The level at 600 days for de Cabo's B6 males lies before most of their deaths, so it leans on the Gompertz fit.
- **The studies differ in sex, genotype, age at the start of treatment, diet and dose,** so the rows compare directions, not sizes.
- **The NAM row carries the birth-year imbalance** described in `notes/NAM_rectangularization_results.md`.

## What we would ask Rafa and Sarah for

1. **For the nicotinamide and metformin studies:**
   - each mouse's age at death, with a flag for censored mice;
   - its biweekly body weights.

   With these, de Cabo's rows gain the days in decline, and the CIs become exact.
2. **The same for Mitchell et al. 2016** (*Cell Metab* 23:1093): C57BL/6J and DBA/2J, both sexes, fed freely or under 20% or 40% calorie restriction.
   - These are the BXD parents, and calorie restriction is the classic test of rectangularization.
   - It would let us ask whether the parents' response predicts the BXD family's.

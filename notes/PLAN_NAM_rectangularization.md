# Plan: nicotinamide, rectangularization and the length of decline in BXD mice

**Status: approved by Rob on 27 October 2026** ("Yes, approve both plans as written: run the comparison of onset definitions, and the NAM analysis with the TSRB-matched design"), before any comparison of NAM with high fat was run. Written by Claude on 27 October 2026, from Rob's request below. This is exploratory. The MRDT of the high fat + NAM mice by haplotype has been seen (S5 in `notes/MRDT_secondary_results.md`). No comparison of NAM with high fat alone has been run, on lifespan, on the shape of survival or on body weight.

## Rob's words

> "There has been a great deal of chatter since 1980 about rectangularizing human mortality by increasing healthspan while not increasing lifespan (James F. Fries got this started)."

> "I talked with Rafa de Cabo today about rectangularizing population mortality rates while improving healthspan. These two studies are helpful"

> "Yes, we should add our NAM case into our analysis of rectangularization with de Cabo's data if possible."

The two studies are Mitchell et al. 2018 (*Cell Metab* 27:667, nicotinamide) and Martin-Montalvo et al. 2013 (*Nat Commun* 4:2192, metformin). Both are summarized in `notes/reading_notes_frailty.md`.

## Three things "rectangularization" can mean

**1. Absolute rectangularization of mortality.** Deaths crowd into a narrower band of ages, so the SD or interquartile range of age at death shrinks.
- Under the Gompertz law, the SD is about 1.85 × MRDT and the interquartile range about 2.27 × MRDT, whatever the level, provided few mice die young.
- So only a shorter MRDT narrows the band in days.

**2. Relative rectangularization of mortality.** The band is narrow compared with the typical lifespan, so the coefficient of variation of age at death, or the life-table entropy H, falls.
- A lower level moves deaths later with the same SD, so it lowers the CV even though the band in days is unchanged.
- Small worked example: SD 100 days at a mean of 600 is CV 0.17; the same SD at a mean of 700 is CV 0.14.

**3. Compression of morbidity (Fries).** Healthy life lengthens and the sick period before death does not, so the survival curve of *health* becomes more rectangular.
- We measure it by days in terminal decline, from body weight (Part 4, and `notes/PLAN_morbidity_definitions.md`).

The three can move separately, so every comparison reports all three.

## Questions

For high fat + 1% NAM against high fat alone, within BXD strains:
- **N1. Lifespan.** Does NAM change age at death?
- **N2. Level or slope.** Is any change in the level of mortality at 600 days, or in MRDT?
- **N3. Shape.** Does NAM rectangularize mortality:
  - in absolute terms (SD and interquartile range of age at death);
  - in relative terms (CV of age at death, and H)?
- **N4. Morbidity.** Does NAM change the days in terminal decline?
  - This is Fries's case if lifespan is unchanged.
  - Measured with the Part 4 definition, then with the definitions that come out robust in `notes/PLAN_morbidity_definitions.md`.
- **N5. de Cabo's studies, side by side.** The same measures for nicotinamide (Mitchell et al. 2018) and metformin (Martin-Montalvo et al. 2013), against their own controls.

## Data

**BXD high fat + 1% NAM.**
- 172 females in Suheeta's mapping file, from 28 strains.
- All were housed at TSRB (vivarium 3), and all were born from 2018 to 2022.
- 106 were euthanized and 66 died naturally.
- Body weights are in `AgingBXD_NAM_BodyWeight_Feb2026.xlsx`: 187 mice, including all 172.

**High-fat controls.**
- 890 high-fat females, but only 232 at TSRB, born from 2015 to 2023.
- The strains overlap thinly. Only 8 strains have at least 4 NAM mice and at least 4 high-fat mice at TSRB: 65 NAM and 45 high-fat mice in all.
- DBA/2J (21 NAM mice) and BXD32 (15) have no high-fat mice at TSRB.

**The confound.** NAM was given only at TSRB and only from 2018. High-fat mice from Nash (born 2010–2016) differ in place and time as well as diet. So the design keeps place and time matched first, at the cost of power.

## Design

**Primary: within strain, at TSRB only.**
- NAM against high fat, in strains with at least 3 mice in each arm: 9 strains, with 69 NAM and 48 high-fat mice.
- The unit is the strain.
- Lifespan and spread: the mean over strains of the NAM − high fat difference, with a sign-flip *P* and a delete-one-strain jackknife CI.
- Level and MRDT: `gompertz.classes.compare` in `Gompertz/gompertz.R`.
  - Each strain × arm cell gets its own level.
  - The MRDT is shared within each arm.
  - The level is reported at 600 days, and CIs come from a delete-one-strain jackknife.

**Secondary: within strain, all vivaria.**
- NAM against every high-fat mouse of the same strain.
- The vivarium effect is estimated from high-fat and chow mice of the same strains housed in more than one vivarium.
- This assumes that the vivarium moves NAM and high-fat mice alike.

**Euthanasia.**
- 62% of NAM deaths were euthanasia.
- Results are given for all deaths, then for natural deaths only.

**Power, stated now.**
- The mean age at death of high-fat mice at TSRB is 565 days, and the SD within a strain and arm is 131 days.
- With 9 strains, a difference in lifespan is detectable with 80% power only if it is large:
  - about 70 days if NAM acts alike in every strain;
  - about 150 days given how much the strain differences vary. This figure used the spread of the NAM − high fat differences across strains, not their mean, which has not been looked at.
- So a null result means "no large effect", not "no effect".

## de Cabo's data

**Best: the individual ages at death.**
- Ask Rafa for each mouse's age at death, and its body weights if possible, from:
  - the nicotinamide study (six arms of 100 male C57BL/6J);
  - the metformin study.
- With these, every measure above can be computed for their mice, including days in terminal decline if the biweekly weights come too.

**Fallback: rebuild ages at death from the published curves.**
- The Kaplan–Meier curves are Fig. 1A–B of Mitchell et al. 2018 and Fig. 1a–b of Martin-Montalvo et al. 2013.
- With 100 mice per arm, each step of a curve is one death, so the ages at death can be read off the figure.
- The ages would be accurate to about 2–3 weeks. That is good enough for the median and interquartile range, but rough for MRDT, and gives no body weights.

**Differences to state in every comparison:**
- their mice are C57BL/6J males, ours BXD-family females;
- their NAM was 0.05% and 0.1% of diet by weight, started at 56 weeks of age;
- their high-fat diet gave 61% of calories from fat;
- our "1% NAM" needs its exact definition from Rob (see below).

**What their curves already suggest** (read from the figures by the literature reader, to about 2–3 weeks; to be checked when the data come):
- **Nicotinamide changed neither median nor maximum lifespan.** On the standard diet, the interquartile range widened from about 13 weeks to 18 and 23 weeks with NAM. That is *less* rectangular.
- **High fat alone moved deaths about 20 weeks earlier** and roughly doubled the interquartile range.
- **Metformin at 0.1% moved the whole curve 5–11 weeks later,** with a similar spread (about 23 against 27 weeks): a shift, not rectangularization.

## Open questions for Rob

1. **What exactly is "1% NAM"?** Is it 1% of diet by weight, 10 g/kg? That would be 10 times de Cabo's high dose. What is the base high-fat diet, by supplier and catalog number?
   - *Answered by Rob, 27 October 2026:* "1% NAM means 1% of the diet by weight. It is the dose taken from the attached 2017 Science paper by Pete Williams." The base diet is Envigo Teklad TD06414 (Roy et al. 2021, Methods).
2. **Will you ask Rafa for the individual ages at death,** and the weights, from the two studies?
   - *Answered by Rob, 27 October 2026:* "I will ask Sarah and Rafa about the NAM experiments after your initial analysis." The initial analysis from the published curves is N5 below.

## Not in this plan

- **The NAM arm's body weights** enter N4 only. A full weight-trajectory analysis of NAM against high fat (peak weight, age at peak) would be separate.

## Implementation details, fixed before the comparisons were run

Written by Claude on 27 October 2026, after Rob's approval and before any comparison of NAM with high fat was run.

- **Mice (primary).**
  - High-fat and NAM mice of Suheeta's mapping file housed at TSRB, in strains with at least 3 mice in each arm.
  - Entry is the age at set-up (left truncation). Every mouse in the file died.
- **N1.**
  - The estimate is the mean over strains of the NAM − high fat difference in mean age at death.
  - *P* comes from an exact sign flip: 2⁹ = 512 arrangements for 9 strains.
  - The 95% CI comes from a delete-one-strain jackknife with a *t* on (strains − 1) d.f.
- **N2.**
  - `gompertz.classes.compare`, with cell = strain × arm and class = arm, gives one MRDT per arm and one level per cell. The MRDT ratio's CI comes from `gompertz.jackknife` over strains.
  - The level difference is log2 of h(600) for NAM over high fat within each strain, averaged over strains, with the N1 statistics.
  - The animal-level likelihood-ratio *P* is reported alongside.
- **N3.**
  - For each strain and arm: the SD, the interquartile range (R's type 7 quantiles), the CV, and Keyfitz's H of ages at death.
  - H = e†/e0, where e† is the mean, over deaths, of the mean remaining life of the mice alive at that age, and e0 is the mean age at death. It is descriptive and ignores left truncation.
  - SD, interquartile range and CV are compared as log ratios, H as a difference, each averaged over strains with the N1 statistics.
  - The Gompertz-implied SD (1.85 × MRDT) comes from N2.
- **N4.**
  - Days in decline under Part 4's definition, using the functions of the definition comparison.
  - The same runs for all 20 definitions of its one-at-a-time set.
  - NAM weights come from `AgingBXD_NAM_BodyWeight_Feb2026.xlsx`, with age = date of weighing − date of birth.
  - The NAM workbook has not been through `BodyWeight/weights_QC.R`, so for NAM mice K2 is the same as K1.
  - Compared in days and as a share of life, with the N1 statistics.
- **Secondary design, all vivaria.**
  - N1: a linear model, age at death ~ strain + diet + vivarium, on every chow, high-fat and NAM mouse of the strains with at least 3 NAM and 3 high-fat mice in any vivarium. The NAM coefficient (against high fat) gets a delete-one-strain jackknife CI.
  - N2: the MRDT of NAM against every high-fat mouse of those strains, with cells = strain × vivarium.
  - N3 and N4 use the primary design only.
- **Natural deaths only.**
  - N1, N3 and N4 are repeated on natural deaths alone.
  - N2 is refitted with euthanized mice censored at death.
- **Multiple tests.** Exploratory, with no correction for multiple tests.
- **de Cabo's data (N5)** wait for Rob's word on asking Rafa. Nothing is rebuilt from the published curves until then.

## N5 from the published curves: implementation, fixed before any curve was read

Rob, 27 October 2026:

> "I will ask Sarah and Rafa about the NAM experiments after your initial analysis. He is interested in the idea of a "Rectangularization" paper. [...] Please proceed."

Written by Claude on 27 October 2026, before any curve was digitized. Exploratory.

- **Curves.**
  - Mitchell et al. 2018, Fig. 1A–B: SD, SD + 0.05% NAM, SD + 0.1% NAM; HFD and the same two doses. 100 male C57BL/6J per arm, treated from 56 weeks (392 days).
  - Martin-Montalvo et al. 2013, Fig. 1a–b: SD (83) against 0.1% metformin (64); SD (88) against 1% metformin (90). Male C57BL/6, treated from 54 weeks (378 days).
- **Reading.**
  - Each panel is rendered as an image: Martin-Montalvo's from the vector figure at 600 dpi, Mitchell's from the embedded image at its own resolution.
  - Axes are calibrated from the tick marks.
  - For each row of pixels, which is one level of survival, the age at which each curve crosses it is read; curves are told apart by line style or color and by continuity from row to row.
  - The tool is `tools/digitize_km.py` (Python, as a tool). The ages by survival level go to `data/digitized/`, with the calibration points, so the reading can be checked.
- **Ages at death.** For an arm of *n* mice, the *k*-th age at death is the age at which survival first falls to 1 − (*k* − ½)/*n* or below.
  - This reads the Kaplan–Meier curve as a distribution, so mice censored by the authors (flooded cages, tissue collection) are handled as the curve handles them.
  - The resolution is about 1–2 weeks in age.
- **Measures, for each arm.** As in N1–N3: mean and median age at death, SD, interquartile range, CV and Keyfitz's H, all conditional on survival to the start of treatment.
  - Gompertz fit by maximum likelihood with left truncation at the start of treatment; MRDT and the level at 600 days.
  - Nothing on morbidity: there are no individual weights.
- **Comparisons.** Each treated arm against its own control, and HFD against SD in Mitchell et al.
  - Single strain, so the unit is the mouse. 95% CIs come from 2,000 bootstrap resamples of mice within arm (seed 20261027).
  - SD, interquartile range and CV as ratios, H and the median as differences, the MRDT and the level as ratios.
- **Checks.** The digitized curves are drawn over the published figures, and the mean lifespans are compared with what the papers report: 0.1% metformin, +5.83%; 1% metformin, −14.4%; NAM, no change.
- **Side by side with the BXD results.** The same measures for:
  - high fat against chow within BXD strains;
  - F1 hybrids against their inbred parents;
  - high fat + NAM against high fat (N1–N3).

  The BXD comparisons use the strain as the unit, as before. All are exploratory.


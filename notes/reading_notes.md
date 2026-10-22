# Reading notes: three papers behind this analysis

Notes made on 22 October 2026, for the aim stated in the top-level README: variation in mortality rate doubling time (MRDT) in BXD females by diet and genotype. Each section gives what the paper did, what it found, and what it means for this repository. The last section draws the three together.

## de Magalhães et al. 2018, *Genetics*: the Gompertz test of "rate of aging"

**What they did.** They took survival curves from 54 published mouse genetic manipulations: 30 that extended lifespan and 24 that shortened it. They digitized the Kaplan–Meier curves and fit the Gompertz law to the exponential phase of each one.

- **The model.** Hazard at age *t* is R0·e^(α*t*). R0 is the age-independent part of mortality, and α is the exponential slope.
- **MRDT** is 0.693/α. A change in α is what they call a change in the *demographic rate of aging*.
- **Method.**
  - Interval hazard = deaths in the interval ÷ the mean number alive in it.
  - Fit by weighted linear regression of ln(hazard) on age, weighted by deaths per interval.
  - Slopes compared between mutant and control with a dummy-variable *t*-test (P < 0.05).
  - Typically fewer than 10% of animals fall before the exponential phase and are left out.

**What they found.**
- **Few manipulations change the slope as predicted.** Only 7 of 54 changed α in the predicted direction. Cisd2 and hMTH1 slowed demographic aging; Casp2, Fn1, IKK-β, JunD and Stub1 sped it up.
- **Many change it the other way.** 20 of 54 changed α significantly in the *opposite* direction. For example, brain-specific Sirt1 overexpression extended lifespan but shortened MRDT by 33%: it acted by delaying the onset of the exponential rise, not by flattening it.
- **Most lifespan effects run through R0.** This holds for both extending and shortening manipulations.
- **α and ln R0 trade off strongly.** r² = 0.93 for the extending set and 0.53 for the shortening set (Pasg excluded). A higher age-independent mortality goes with a slower demographic rate of aging. This is the Strehler–Mildvan pattern.
- **Controls vary a lot.** Fifteen C57BL/6 wild-type cohorts had medians from 1.74 to 2.63 years. The relative SD was 57% for α and 42% for ln R0. Short-lived controls inflate apparent life extension (r² = 0.30, P = 0.002, n = 33).
- **Small cohorts are unreliable.** Cohorts ranged from 10 to 146 mice. Moving the start of the fitted window can make a significant difference disappear (Htr1b).
- **Typical values.** Most cohorts in the tables have MRDT between about 0.1 and 0.5 years (roughly 35 to 180 days).
- **A small inconsistency.** The abstract says 15% of manipulations affected the rate as predicted, but 7 of 54 is 13%.

**For this repository.**
- **Sample size.** A BXD strain-by-diet cell holds about 8 to 12 mice. That is far below the cohort sizes de Magalhães found unreliable, so per-cell α will be noisy. Binned regression on digitized curves is the weakest way to fit it.
- **A better fit.** Fitting by maximum likelihood on individual ages at death is better. So is a mixed model with strain-level random effects on α and ln R0, which pools strength across strains.
- **The α–R0 trade-off may be partly artifact.** Some of it comes from fitting alone: slope and intercept estimates are negatively correlated whenever mean lifespan is much longer than MRDT. See Tarkhov, Menshikov and Fedichev 2017, *J Theor Biol* 416:180–189, [doi:10.1016/j.jtbi.2017.01.017](https://doi.org/10.1016/j.jtbi.2017.01.017). Any α–R0 correlation found across BXD strains needs a check against what estimation error alone produces.

## Roy et al. 2021, *Nature Metabolism*: diet by genotype in BXD lifespan

**What they did.** They followed 1,348 females from 73 BXD strains, the two parents and the D2B6F1 hybrid (76 genometypes) to natural death.
- **Diets.** Low-fat chow (Teklad 7912; 17% of calories from fat; n = 663) or high-fat diet (TD06414; 60% from fat; n = 685).
- **Entry.** Mice entered at about 120 days (range 26 to 358).
- **Follow-up.** Weighed every other month.
- **Deaths and censoring.** Moribund mice (about 10%) were euthanized and counted as deaths if older than 200 days. Mice still alive were right-censored (32 on chow, 80 on high fat).

**What they found.**
- **The diet effect.** The high-fat diet shortened mean lifespan from 690 to 605 days and median lifespan from 703 to 626 days (−77 days, about 12%).
- **The hazard ratio held steady.** A mixed-effects Cox model gave HR = 2.0 for high fat versus chow. The proportional-hazards test was not rejected (P = 0.47), and the cumulative hazard curves never cross.
- **Variance in lifespan.** Strain explains 30%, diet 5% and strain-by-diet interaction 6%.
- **Strains respond very differently.**
  - 15 of 67 strains differ significantly between diets after FDR correction.
  - BXD8 lives 208 days longer on the high-fat diet; BXD65 loses 345 days.
  - DBA/2J is unaffected, while C57BL/6J loses 76 days.
- **Weight and lifespan.**
  - Each extra gram at entry costs about 6 days of lifespan, on either diet.
  - Each gram at 100 days on diet costs about 4 days.
  - Weight gained after 400 days on the high-fat diet does not predict lifespan, and only about 10% of the diet effect on lifespan runs through weight gain.
- **Serum metabolites and hormones** (glucose, cholesterol, insulin, leptin, HOMA-IR) are only weak predictors of lifespan.
- **Causes of death.** The high-fat diet raises heart disease; chow-fed mice have more non-hematopoietic cancers.

**For this repository.**
- **The constant hazard ratio is itself a Gompertz statement.** Under the Gompertz law, a constant HR of 2 means parallel log-hazard lines: the same α, with ln R0 raised by ln 2.
  - At the family level, then, the high-fat diet acts on age-independent mortality, not on the demographic rate of aging. That is the opposite of what one might assume.
  - It also predicts that the median lifespan loss should be close to one MRDT. Doubling the hazard is equivalent to being one doubling time older.
  - The observed loss is 77 days, which sits inside the range of mouse MRDTs in de Magalhães's tables. **A first check:** estimate the pooled MRDT on chow and see whether it is near 77 days.
- **Pooled versus per-strain.** Proportional hazards in the pooled family does not mean proportional hazards within each strain. BXD8 and BXD65 show it cannot hold everywhere. Which strains change α and which change only R0 is the question this repository can answer.
- **Fit design.** Ages at entry vary widely, and some mice are still alive. Fits should be left-truncated at each mouse's entry age and right-censored for survivors.
- **The data.** They are in `genenetwork/bxd_gxelongevity_2020/data/`: 1,359 natural deaths and 200 mice alive as of November 2018. The new 2026 data (about 2,000 mice) will extend them.

## Arends et al. 2026, *Nature*: actuarial mapping of age-specific mortality loci

**What they did.** They genotyped 6,438 UM-HET3 mice from the NIA Interventions Testing Program: controls plus mice given supplements with no individual effect. These four-way-cross siblings segregate C/B maternal and H/D paternal haplotypes.
- **Actuarial mapping.** Instead of mapping one lifespan trait, they mapped mean lifespan in 72 nested *survivorships*. Each survivorship is the set of mice alive at a truncation age (T-age), in 15-day steps from T42 (6,438 mice) to T1,100 (559 mice).
- **Mortality plots.** Age-specific hazard ratios by haplotype show *when* each locus acts.

**What they found.**
- **29 Vita loci** affect lifespan.
  - Average effect 36 days. Peak variance explained is 2.5% in females and 3.2% in males.
  - Effects last 349 ± 229 days on average.
- **Four dynamic classes of Vita loci.**
  - **Durable** (five loci): effects from T42 to about T750.
  - **Steadily diminishing:** seven of these have a near age-independent hazard ratio over at least 500 days. The paper calls them candidate rate-of-aging modulators (RAMs), using "a liberal definition of uniform slopes"; Vita14b is the example.
  - **Age-restricted:** early (before T500, male-biased), mid (T500 to T845), late (after T860).
  - **Reversals** (12 loci): genotype effects flip with age, as antagonistic pleiotropy predicts (Vita2b, Vita4a, Vita9b).
- **Sex differences.**
  - 14 Vita loci have strong genotype-by-sex interactions.
  - Females outlive males by 81 days at T42, a gap closed by T740 (both at 946 days).
  - Variance explained by Vita loci falls in males from 40% to 30% by T500, then rises to 50% in the oldest. In females it holds near 27% until about T620, falls to 20% by T890, then recovers.
- **30 Soma loci** change the *correlation* between body mass and lifespan.
  - 19 strengthen the early negative correlation; 11 the late positive one.
  - They are largely separate from the 28 loci for body mass itself.
  - At 183 days, males lose 14.3 days per gram and females 3.7.
- **Epistasis splits by sex.** No significant Vita–Vita interaction at T42 is shared by the two sexes.
- **Candidate genes.**
  - Vita1a: Atp6v1h, Mrpl15, Rb1cc1.
  - Vita9b: Acad11, whose worm knockdown improves late motility, and Apeh, supported by Mendelian randomization against human parental longevity.
- **Lifespan has a starting point.** Lifespan is always conditional on an entry age (left truncation). Unmodeled variance (Vo) climbs with age and, the authors argue, drives the Gompertzian rise in mortality.

**For this repository.**
- **Actuarial plots for BXD.** The survivorship method applies directly to BXD strain-by-diet data. It would show at which ages the high-fat diet effect appears in each strain.
- **Definitions diverge** (see below).

## Where the three meet, and one definition to settle

1. **"Rate of aging" means different things in two of these papers.**
   - In de Magalhães et al., a change in the rate of aging is a change in the Gompertz slope α. That shows up as a hazard ratio that *changes with age*.
   - A hazard ratio that is *constant* across age is the signature of a change in R0 alone. In de Magalhães's terms, that is aging-independent mortality.
   - Arends et al. name as candidate rate-of-aging modulators the loci with a *near age-independent* hazard ratio. By the Gompertz definition, those are R0 effects.
   - One way to reconcile them: a constant HR of *k* is equivalent to a fixed shift in age of ln(*k*)/α, so the organism is "older" by a constant amount but not aging faster.
   - This analysis should say which definition it uses. Measuring MRDT commits it to the slope definition.
2. **The high-fat diet in BXD is, at the family level, an R0 effect** by the slope definition, since its hazard ratio is constant at 2.0. Whether some strains also change α is the open question.
3. **Sample size limits the slope.** α is much harder to estimate than mean lifespan (de Magalhães; Tarkhov et al.). Per-strain MRDT estimates need pooling or a mixed model, and any α–R0 correlation across strains needs a check against what estimation error alone produces.
4. **Left truncation and censoring** matter in both mouse populations. Fits should condition on entry age and keep survivors as censored observations.

## Possible first analyses

- Pooled Gompertz fits by diet (maximum likelihood, left-truncated, right-censored): α, ln R0 and MRDT for chow and high fat. Check whether the high-fat diet changes α or only R0, and whether the 77-day median loss is close to one MRDT.
- Per-strain fits within a mixed model, with strain random effects on α and ln R0 by diet. Rank strains by the change in α against the change in R0, starting with BXD8, BXD65, BXD16, BXD73, C57BL/6J and DBA/2J.
- Simulation of the α–R0 correlation expected from estimation error alone at BXD cell sizes, to compare with the observed one.
- Arends-style actuarial plots of survivorship means by T-age for each strain and diet.

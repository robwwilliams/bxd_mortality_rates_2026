# Reading notes: frailty, terminal weight loss and rectangularization in mice

Notes made on 27 October 2026, for two plans: `notes/PLAN_morbidity_definitions.md` (how sensitive the Part 4 conclusions are to the definition of morbidity onset) and `notes/PLAN_NAM_rectangularization.md`. Rob asked for them: "There are probably 5–10 good studies of mouse frailty, several by Sarah Mitchell and Mike MacArthur. Let's read these." He sent six papers; a search of PubMed found the rest.

- **Part A** covers the six papers Rob sent, read in full from the PDFs, with page numbers.
- **Part B** covers the wider literature. Every citation there was checked in PubMed or Crossref, and full text was read where it is open access.
- **Ages and percentiles read off published figures** are marked as such and are accurate to about 2–3 weeks.

## What this literature tells us

**1. No one has defined the onset of a morbid phase from body weight in a genetically diverse population.**
- Studies mark the end of health in three ways:
  - a frailty-index cutoff;
  - a Fried-style frailty phenotype;
  - a weight rule tied to each mouse's own baseline, such as 95% of a stable weight (Trammell et al. 2012) or 10% below peak (ALS mouse models).
- No study we found models the risk of death against percent below each mouse's own running peak. Our exploratory analysis of 27 October appears to be new on that point.

**2. Terminal weight loss in mice is gradual and lasts weeks to months.**
- It begins about 10–11 weeks before death in C57BL/6J (Trammell et al. 2012) and builds over 2–3 months in ICR mice (Ray et al. 2010).
- In weekly-weighed Diversity Outbred females, it begins after about 90% of life (Di Francesco et al. 2024).
- It ends about 10–15% below the mouse's stable weight.
- Our chow BXDs fit: weight falls from about 120 days before death and reaches 82% of peak in the last 15 days.

**3. Some mice die without losing weight.**
- About a quarter of C57BL/6J never fell below 95% of their baseline before death (Trammell et al. 2012).
- In our mice, 25–34% were still within 10% of peak in their last month.
- So a "no decline" group is expected biology, not only missing data.
- Tumors and fluid can also hide a loss: distended abdomen ranks high among the predictors of remaining life (Schultz et al. 2020).

**4. Weight carries more information about remaining life than any other single sign, and risk rises smoothly.**
- Total weight loss was the most important input to the AFRAID clock of remaining life (Schultz et al. 2020, with Mitchell and MacArthur).
- The risk of death rises by a factor of 1.15 for each 0.01 of frailty index, with no threshold (Rockwood et al. 2017).
- Both agree with our finding: risk rises with each step below peak, with no jump at 10%.

**5. Cutoffs do not transfer across strains and sexes.** Zhu et al. 2026 (Mitchell, MacArthur and colleagues; 1,564 mice of five strains) found that the link between frailty and lifespan differs by strain and sex. That is one more reason to test many definitions across the BXD strains.

**6. Population-wide weight loss starts long before most deaths.**
- Ad libitum C57BL/6J females lost weight steadily from about 595 days of age (Duregon et al. 2023).
- Chow-fed C57BL/6J males in the metformin and nicotinamide studies held a plateau until about 105 weeks (735 days), then lost a quarter to a third.
- So a fixed cut such as 90% of peak can flag ordinary aging loss as well as the terminal decline. Our chow BXDs still more than a year from death were already about 6% below peak at 600–750 days.

**7. Weight lost after death is small.** Carcasses of C57BL/6 mice lost 0.78% of their weight per day at room temperature (Howie et al. 2024). A mouse found within a day of death has lost less than one weighing's noise.

**8. Level against slope has precedent.**
- Xie et al. 2022 found that most interventions shift a trait by the same amount at every age (a "baseline" effect) rather than slowing its change with age (a "rate" effect). MacArthur and Mitchell's 2023 commentary draws the distinction clearly.
- Xie et al. cite Hughes and Hekimi 2016: longevity interventions in mice moved the Gompertz level and left the slope alone. That is our level-against-MRDT framing.
- Jiang et al. 2025 plot a smoothed hazard ratio against age. Under Gompertz hazards, a flat line means a level effect and a sloping line means an MRDT difference. This is a model-free check we could run on our diet and haplotype results.

**9. Rectangularization is not measured in any of these studies.** The figures suggest:
- metformin shifted the whole survival curve later, with the earliest deaths delayed most;
- nicotinamide changed neither median nor maximum lifespan, and on the standard diet it widened the spread of ages at death;
- high fat moved deaths earlier and spread them out.

`notes/PLAN_NAM_rectangularization.md` sets out three meanings of rectangularization that can move separately: absolute, relative, and compression of morbidity.

---

## Part A. The six papers Rob sent

Prepared 27 October 2026 for Rob Williams. Source PDFs are in `UTHSC GGI Dropbox/Rob Williams/_Aging_References_General/`. Text was extracted with macOS PDFKit; figures were checked from rendered page images where the text layer was not enough.

**How page numbers are given.**

- Duregon et al.: journal pages 1179–1194 and e1–e5 for the article, and "Supp. p. N" for the 16-page Supplemental Information bound into the same PDF (its own page numbers 1–16). The graphical-abstract page is unnumbered (PDF p. 1).
- Jiang et al. and Xie et al.: the article page numbers printed in the footer (1–8 and 1–29).
- MacArthur & Mitchell: PDF pages 1–2. The attached file is the online version without print page numbers; the print pages are 61–62.
- Martin-Montalvo et al.: the article page numbers printed in the footer (1–9). The supplement is not in the PDF.
- Mitchell et al.: journal pages 667–676 and e1–e4, and "Supp. PDF p. N" for the unnumbered supplemental pages bound into the same PDF (PDF pages 16–23).
- Sections 5 and 6 were added at Rob's request after a conversation with Rafael de Cabo about rectangularizing mortality while improving healthspan.

**At a glance.**

| Question | Duregon 2023 | Jiang 2025 | Xie 2022 | MacArthur 2023 | Martin-Montalvo 2013 | Mitchell 2018 |
|---|---|---|---|---|---|---|
| Longitudinal body weight | Yes, every 1–2 weeks, group means only | No | No (cross-sectional) | No | Yes, biweekly or bimonthly, group means only | Yes, every 2 weeks, group means only |
| Frailty index | Yes, 31 items, measured once | No | No | No | No | No |
| Definition of morbidity onset or healthspan end | No | No | No | Healthspan defined in words only | No | No |
| Weight before death, per mouse | No | No | No | No | No | No |
| Gompertz or level vs. slope | No Gompertz fit | Gompertz used only in simulations; time-varying hazard ratio | Cites Hughes & Hekimi: interventions shift Gompertz level, not slope | Rate vs. baseline models (conceptual) | No; mean lifespan and Gehan–Breslow only | No; log-rank only |
| Euthanasia criteria | Veterinarian judgment, no weight criterion | Not stated | Ulcerating tumor, bleeding, rectal prolapse | Not addressed | Veterinarian judgment, no weight criterion | Veterinarian judgment, no weight criterion |
| Weight after last weighing or after death | Not addressed | Not addressed | Not addressed | Not addressed | Not addressed | Not addressed |
| Rectangularization discussed | No; percentiles by group in Table S2 | No | No | No | No; curves read from figure | No; curves read from figure |

---

### 1. Duregon et al. 2023, Cell Metabolism

**Citation.** Duregon E, Fernandez ME, Martinez Romero J, Di Germanio C, et al., de Cabo R (2023). Prolonged fasting times reap greater geroprotective effects when combined with caloric restriction in adult female mice. *Cell Metabolism* 35(7):1179–1194.e5. doi:10.1016/j.cmet.2023.05.003

#### Design

- **Mice.** Female C57BL/6J from the Jackson Laboratory, bought at 48 weeks of age, housed four per cage, NIH-31 chow (p. e2). Cage mates were not rehoused after a death, so some mice ended up single-housed (p. e2).
- **Diets.** From 61 weeks of age (427 days), five arms of about 50 mice each (p. 1181, p. e2):
  - ad libitum (AL);
  - time-restricted feeding for 4 h or 8 h in the light phase (TRF4, TRF8);
  - 20% caloric restriction as one daily meal of 3 g (CR);
  - the same 3 g split into two 1.5 g meals 8 h apart (CRx2).
- **Effective restriction drifted.** AL mice ate more with age, so CR deepened from 20% to 35% by 45 weeks on diet. TRF mice drifted back toward AL intake, averaging 15% restriction (p. 1181; Fig. 1C, p. 1180).
- **Survival analysis.** 244 mice: 201 deaths and 43 censored (Supp. p. 11).

#### What was measured over time

- **Body weight.** Methods say every other week, on the same day (p. e2). The next paragraph says each animal's weight change was tracked every week (p. e3). Group trajectories were smoothed with loess (p. e2).
- **Food intake,** per cage (p. e2). **Core temperature,** from implanted chips (p. e2).
- **Body composition by NMR** at 52, 69, 91 and 104 weeks of age (p. e3).
- **Single time points or pairs:**
  - fasting glucose, OGTT, rotarod and cage-top hanging (n = 22–24 per group for physical tests; p. e4);
  - indirect calorimetry at 17 and 69 weeks on diet (n = 6);
  - serum metabolomics at 26 weeks on diet (pp. e3–e4).
- **Frailty index.**
  - 31 clinical items covering integument, musculoskeletal, vestibulocochlear/auditory, ocular/nasal, digestive/urogenital, respiratory and discomfort domains (p. e4).
  - Scored as deficits divided by possible deficits, on a 0–1 scale (p. e4). The per-item scoring scale (for example 0/0.5/1) is not stated.
  - Measured **once**, at 80 weeks on diet (about 141 weeks of age, or 987 days), in n = 11–16 survivors per group (p. 1182; Fig. 1A and legend, pp. 1180–1181).

#### Findings bearing on our questions

1. **Onset of frailty, morbidity or a decline phase.** None is defined. Frailty is described in general terms as a biomarker that includes loss of body weight and muscle strength (p. 1182). The paper also notes that a higher FI goes with lower survivability, citing earlier work (p. e4). Mice are split into short-lived and long-lived by whether they died before or after their group's median (p. 1183; Fig. S3A, Supp. p. 6). That split concerns lifespan, not the onset of morbidity.

2. **Body weight trajectory late in life.** All values below are group means of the mice still alive, not individual mice followed to death.
   - **AL mice.** They held their weight (34.45 ± 5.35 g at 61 weeks) for 24 weeks. From about 85 weeks of age (595 days) they began to eat more while progressively losing weight (p. 1181). Food intake plateaued at about 106 weeks of age (742 days), but weight kept falling (p. 1181).
   - **How much AL mice lost.** Read from Fig. 1B (p. 1180): mean weight stayed near 98–100% of the starting weight until about 30 weeks on diet, then fell to about 73% by 80 weeks on diet (141 weeks, or 987 days). The AL median lifespan was 123 weeks (861 days; Supp. p. 11).
   - **Other arms.** TRF mice lost 27% of their weight over 67 weeks on diet (p. 1181). CR and CRx2 lost weight gradually throughout (p. 1181). By 80 weeks on diet, group means were about 70–80% of starting weight (Fig. 1B, p. 1180).
   - **Fat.** Percent fat rose after 9 weeks on diet and was stable to 30 weeks. By 43 weeks on diet (104 weeks of age) it had fallen in every group (p. 1181). The discussion says all groups lost weight with age, mainly fat (p. 1191).
   - **Variation among AL mice.** About 30% of AL mice lost weight over a 25-week span, while others in the same cages held or gained (p. e3).
   - **Effect of handling and housing.** Three days of single housing in metabolic cages cost AL mice 2.7% of body weight at 78 weeks of age and 5.3% at 130 weeks. CR and TRF mice lost 8–19% (p. 1182; Fig. 2A, p. 1183).
   - Age at peak weight per mouse, and weight change in the weeks before death, are **not reported**.

3. **Whether weight or frailty predicts death.** **Not tested** in these data. Two related observations:
   - Short-lived mice had more tumors, and long-lived mice more non-neoplastic disease at death (p. 1183; Fig. S3B–C, Supp. p. 6).
   - Mice dying of neoplasms had shorter survival than those dying of non-neoplastic disease (n = 141 vs. 36; log-rank P = 0.0083; Fig. S3D, Supp. p. 6).

4. **Whether interventions compress or stretch late morbidity.** Not measured as a duration. The pieces they report:
   - **Frailty.** CR and CRx2, but not TRF, lowered the FI at 80 weeks on diet. The musculoskeletal and ear/eye/nasal domains drove the difference (p. 1182; Fig. 1I–J, p. 1180).
   - **Lifespan.** CR raised median lifespan modestly (CR vs. AL log-rank P = 0.026; Cox HR 0.56, 95% CI 0.35–0.90) (p. 1182; Supp. p. 11). Increases in median lifespan across arms ranged from 2.4% to 4.1% (p. 1182). Wang–Allison tests showed more CR and CRx2 mice alive at the 90th-percentile age (Table 1, p. 1185).
   - **Disease burden.** Long-lived TRF8 and CRx2 mice had higher organ disease-burden scores at necropsy than AL mice (p. 1184; Fig. 3B–C).
   - Because the FI was scored once, only in survivors at 141 weeks, it cannot show whether the frail period was shorter.

5. **Gompertz, level vs. slope, temporal scaling.** Not addressed. Survival was analyzed with log-rank tests, Cox hazard ratios and Wang–Allison tests only (p. e3; Supp. p. 11).

6. **Methods details.**
   - **Health checks.** Mice were inspected twice daily. Euthanasia criteria were an independent veterinarian's assessment under AAALAC guidelines; no weight-loss or body-condition threshold is given (p. e2).
   - **Necropsy.** "Moribund animals were culled, and every animal found dead or euthanized was necropsied" (p. e2). Bodies were formalin fixed and given a full necropsy (p. e4).
   - **Cause of death.** Assigned by four blinded pathologists, or labeled undetermined when no lesion was severe enough (p. e4).
   - **Censoring.** Mice were censored if they died before diets began, were killed for tissue (25 mice at 104 weeks), lacked necropsy reports, had otitis or head tilt, or **were culled for polyarteritis nodosa** (6 mice) (p. e3). Table S2 counts only natural deaths (Supp. p. 11).
   - **Post-mortem weighing.** Not mentioned.

**Relevance to us.** This is the only one of the four with repeated body weights through old age, and it shows that ad libitum B6 females start a sustained, population-wide weight decline at about 595 days, well before most deaths, even as they eat more. A fixed cut such as 90% of peak may therefore mark ordinary late-life weight loss rather than the terminal phase, at least in B6 females. Their FI design (one measurement, survivors only) is a warning against comparing frailty or morbidity between diets in survivors only.

---

### 2. Jiang et al. 2025, Nature Communications

**Citation.** Jiang N, Cheng CJ, Liu Q, Strong R, Gelfond J, Nelson JF (2025). Deciphering the timing and impact of life-extending interventions: temporal efficacy profiler distinguishes early, midlife, and senescence phase efficacies. *Nature Communications* 16:10164. doi:10.1038/s41467-025-65158-4

#### Design

- **Data.** A reanalysis of public Interventions Testing Program survival data from 2004 to 2022: 42 compounds, more than 27,000 UM-HET3 mice of both sexes, 132 trials at three sites (p. 2, p. 6).
- **Husbandry.** Purina 5LG6 diet; up to 3 males or 4 females per cage (p. 6).
- **Method.** The Temporal Efficacy Profiler (TEP) estimates each arm's age-specific hazard nonparametrically with B-splines (the R package bshazard, Rebora method). It then plots the log hazard ratio against age, with asymptotic and bootstrap 95% CIs (p. 2, p. 6).
  - Site is a covariate. Sexes are analyzed separately.
  - Deaths before treatment began are excluded (p. 6).
  - Results are shown only where both CI methods agree (p. 2).

#### What was measured over time

- Only age at death. No body weight, frailty or other health measures are used. The methods mention daily health checks by staff (p. 6).

#### Findings bearing on our questions

1. **Onset of frailty or morbidity.** Not defined. The paper speaks of a final senescent phase when frailty and chronic disease peak (p. 2). Operationally, it marks only two ages: the control median lifespan and the age at 90% mortality (Fig. 2 legend, p. 5; p. 7).

2. **Body weight trajectory.** Not addressed.

3. **Weight or frailty as predictors of death.** Not addressed.

4. **Late-life effects of interventions.** Hazard, not morbidity, is the outcome.
   - **Most effects are confined in age.** Most compounds cut mortality only within limited age windows: "Most were only effective for less than half of the treatment duration" (p. 5).
   - **Males.** 9 compounds helped only before the median lifespan. Five compounds (11 trials) helped after the median but stopped before the 90% mortality age. The text says 5 of 17 compounds helped beyond the 90% mortality age; the list that follows names more, including acarbose, canagliflozin, 17α-estradiol, glycine, rapamycin and two rapamycin cocktails (p. 3).
   - **Females.** 10 of 11 beneficial agents acted mainly after the median. Five, including most rapamycin trials, acarbose, butanediol, leucine and captopril, still helped after the 90% mortality age (p. 3).
   - **Effects change with age.** Acarbose's benefit was largest at the start of treatment and then waned (p. 3).
   - **Harm.** 14 compounds increased hazard at some ages, 12 of them in females (p. 3). Harm in females mostly began early in treatment, faded in the second year, and sometimes returned near the end of life (p. 4).
   - **The Wang–Allison test.** It cannot tell whether a later 90%-mortality age comes from mortality cut earlier in life or from lower hazard at old ages (p. 5).

5. **Gompertz, level vs. slope, temporal scaling.**
   - The authors set the Gompertz model aside for being too rigid in shape (p. 2), and test instead whether the hazard ratio stays constant.
   - **Simulations** use the Gompertz form h(t) = b·e^(at), with control a = ln(300)/1200 and b = 0.001/a, and treatment a = ln(50)/1200 and b = 0.0003/a (p. 7). In that crossing-hazards scenario the log-rank test had only 21% power (p. 7).
   - **A check, not in the paper.** If a is a natural-log rate per day, the control slope is a mortality doubling time of about 146 days and the treatment slope about 213 days. The printed b values reproduce neither the stated median of 741 days nor the stated early-harm, late-benefit pattern, so the printed parameters may contain a typo.
   - Temporal scaling is not mentioned.

6. **Methods details.**
   - Daily health assessments to spot signs of morbidity and intervene early (p. 6).
   - Euthanasia criteria, the handling of found-dead and euthanized mice, and weighing are not described.
   - The authors warn that estimates after the 90% mortality age rest on few mice (p. 6), and that the ages where an effect starts and stops have no confidence intervals (p. 6).

**Relevance to us.** The TEP plot is a direct, model-free way to see level against slope. Under Gompertz hazards, the log hazard ratio between two groups is a straight line in age: flat for a pure level effect, tilted for an MRDT difference. We could plot it for chow vs. high fat and for B vs. D haplotypes to test whether our Gompertz split holds at every age. The paper says nothing about body weight or morbidity.

---

### 3. Xie et al. 2022, Nature Communications

**Citation.** Xie K, Fuchs H, Scifo E, Liu D, Aziz A, et al., Hrabě de Angelis M, Ehninger D (2022). Deep phenotyping and lifetime trajectories reveal limited effects of longevity regulators on the aging process in C57BL/6J mice. *Nature Communications* 13:6830. doi:10.1038/s41467-022-34515-y

#### Design

- **Sex and strain.** Male C57BL/6J only (p. 19).
- **Aging atlas.** A cross-sectional design (p. 16).
  - Groups at 3, 5, 8, 14, 20 and 26 months, with n ≈ 14–15 per age for deep phenotyping (Fig. 2, p. 5).
  - A separate cohort for molecular markers (p. 19).
  - In all, 222 phenotypes, of which about 59% changed with age (p. 4).
- **Interventions,** each tested in young mice (about 3 months at the start) and old mice (about 20 months at the start), side by side with their own controls (p. 19):
  - Ghrhr lit/lit, deficient in growth hormone signaling;
  - a hypomorphic mTOR knock-in;
  - every-other-day intermittent fasting from 8 weeks of age.
- **Human comparison.** A cohort aged 30–95 years, examined for MTOR and GHRHR eQTL effects (pp. 10–12).

#### What was measured over time

- **Phenotyping pipeline.** An 11-week sequence: SHIRPA, open field, grip strength, rotarod, startle, clinical chemistry, calorimetry, NMR body composition, glucose tolerance, ECG and echocardiography, eye and hearing tests, bone densitometry, hematology, immunology, then pathology (p. 19).
- **Body weight.** Recorded only within assays: before and after calorimetry and the 6-h fast (p. 20), and at necropsy (p. 22). There is no lifetime weighing schedule. Body weight from the earlier fasting cohort was published elsewhere (p. 12).
- **No frailty index.**

#### Findings bearing on our questions

1. **Onset of a decline phase.** Defined for single phenotypes, not for morbidity: the first age that differs from the 3-month baseline.
   - Most phenotypes were stable from 3 to 5 months.
   - Most first changed at 14 months (about 26%) or 20 months (about 36%) (p. 4).
   - The authors note that this age of first change depends on sample size (p. 17).
   - Healthspan and frailty are not defined.

2. **Body weight trajectory.** Not reported for mice. Fat mass rose to a midlife peak and then fell at older ages (p. 4; Fig. 2e, p. 5).

3. **Weight or frailty as predictors of death.** Not addressed.

4. **Whether interventions change aging or only shift it.** This is the paper's core.
   - **Most effects are baseline effects.** Most beneficial effects were the same size in young and old mice. This is a *baseline effect*, an offset present before aging changes begin, rather than a *rate effect* that slows age-related change.
   - **Rate-type share, by intervention:**
     - Ghrhr: about 5.2% of age-sensitive phenotypes rate-type vs. 34.4% baseline-type (p. 7);
     - mTOR: 9.4% vs. 38.5% (p. 9);
     - fasting: 10.8% vs. 30.4% (p. 14).
   - **Worsened phenotypes.** Each intervention also worsened some phenotypes: 18.8% for Ghrhr, 12.8% for mTOR and 10.8% for fasting (p. 16).
   - **Why old mice were tested at 20 months.** That age comes before steep mortality and appreciable attrition, which avoids biasing comparisons through differential survival (p. 6, p. 17). Morbidity duration is not measured.

5. **Gompertz, level vs. slope, temporal scaling.**
   - The discussion cites Hughes & Hekimi (2016, *Genetics* 204:905–920): in long-lived mouse models, the Gompertz rate parameter G was unchanged. Interventions instead moved the age at which mortality starts rising (parameter A), "without changing the rate of increase thereafter" (p. 18).
   - They read this as a change in baseline vulnerability rather than in the rate of aging (p. 18).
   - They also cite fly dietary restriction (Mair et al. 2003): flies switched from restricted to full feeding quickly took on the mortality of fully fed flies, so restriction had no lasting effect on risk (p. 18).
   - **Translation (mine).** In our base-2 notation this is a level effect with MRDT unchanged, which is the same as shifting the hazard curve along the age axis.
   - Temporal scaling is not mentioned.

6. **Methods details.**
   - Daily welfare checks (p. 19).
   - Predefined humane endpoints, such as an ulcerating tumor, bleeding from an orifice or persistent rectal prolapse. No weight-loss criterion is listed (p. 19).
   - Animals were not preselected for health (p. 14).
   - Necropsy recorded body and organ weights in mice killed with CO2 at the end of phenotyping (pp. 19, 22). These were planned kills, not natural deaths.
   - Found-dead handling and post-mortem weight change: not addressed.

**Relevance to us.** Their split between baseline and rate effects is the same as our split between level and MRDT. Their reading of Hughes & Hekimi, that longevity interventions shift Gompertz level and leave slope alone, is a published precedent for the pattern we test across diets and haplotypes. Applied to weight, it argues for measuring decline against each mouse's own peak, so that a diet's baseline weight offset is not mistaken for a faster decline.

---

### 4. MacArthur & Mitchell 2023, Lab Animal (News & Views on Xie et al.)

**Citation.** MacArthur MR, Mitchell SJ (2023). Investigating trajectories of aging using high-dimensional phenotyping in mice. *Lab Animal* 52(3):61–62. doi:10.1038/s41684-023-01122-3. Volume, issue and pages are from PubMed (PMID 36693909). The attached PDF is the online version (published online 24 January 2023, p. 2) and carries no volume or page numbers.

#### Design

A two-page commentary on Xie et al. 2022, with no new data (pp. 1–2).

#### What was measured over time

Nothing; no new data.

#### Findings bearing on our questions

1. **Onset definitions.** Healthspan is defined only in words, as the period of life spent without disease (p. 2). The commentary proposes a *clinical threshold* model: age-related change in a phenotype may not matter until it crosses a threshold that permits disease, such as mTOR dysregulation reaching a level that promotes tumors (p. 2; Fig. 1, p. 1). In that view, "interventions that fit the baseline model may not 'slow aging' but rather 'delay' it" (p. 2). No onset criterion is given.

2–3. **Body weight; weight or frailty as predictors of death.** Not addressed.

4. **Healthspan vs. lifespan.**
   - Lifespan screens in mice mainly select anti-cancer interventions, because cancer is the main cause of death (p. 2).
   - Late-life rapamycin counteracts several tumor-related phenotypes as much as lifelong treatment does (p. 2). They call this a fourth model, the *late-onset baseline* effect (Fig. 1d, p. 1).
   - They stress that 10–20% of phenotypes were worsened by the interventions (p. 2).
   - **BXD mention.** BXD researchers are named among the groups expected to test generalization across sex and strain, citing Roy et al. 2021 (p. 2).

5. **Gompertz, level vs. slope, temporal scaling.** No Gompertz or mortality analysis. Fig. 1 (p. 1) draws the rate, baseline, combined and late-onset baseline models as phenotype curves against age. This is the conceptual twin of slope vs. level. Temporal scaling is not mentioned.

6. **Methods details** (weighing, endpoints, post-mortem handling): not addressed.

**Relevance to us.** The figure on p. 1 is a clean teaching diagram of level vs. slope that Rob could adapt for the report. Their clinical-threshold idea is a hypothesis our weight data can test. Our exploratory finding, that hazard rises smoothly with each step of weight loss and shows no threshold at 10%, argues against a threshold for weight.

---

### 5. Martin-Montalvo et al. 2013, Nature Communications

**Citation.** Martin-Montalvo A, Mercken EM, Mitchell SJ, Palacios HH, Mote PL, et al., Bernier M, de Cabo R (2013). Metformin improves healthspan and lifespan in mice. *Nature Communications* 4:2192. doi:10.1038/ncomms3192

The attached PDF is the 9-page article only. The Supplementary Information it cites, including the B6C3F1 survival curve and the pathology tables, is not in the file.

#### Design

- **Sex and strains.** Males only.
  - C57BL/6 from the NIA Aged Rodent Colony at Charles River, bought at 6 or 11 months of age (p. 7). The paper calls them C57BL/6 and, once, C57BL/6J (p. 7).
  - A separate B6C3F1 cohort from Harlan (p. 7), run by Spindler and Mote, whose affiliation is UC Riverside (author list, p. 1; author contributions, p. 9).
- **Diets.** AIN-93G purified diet (SD) until treatment began at 1 year (p. 7). The figure legend and the ages listed in Methods put the start at 54 weeks (378 days) (Fig. 1 legend, p. 3; p. 7). Arms (p. 7):
  - SD (n = 83) vs. SD + 0.1% w/w metformin (n = 64);
  - a second SD control (n = 88) vs. SD + 1% metformin (n = 90);
  - a CR group (n = 76) fed 60% of ad libitum intake from 27 weeks, used for the transcriptome and serum comparisons (Table 1; Fig. 2). No CR survival curve is shown.
- **B6C3F1 cohort.** Fed a fixed 13.3 kcal per day of AIN-93M, with or without metformin, from 12 months of age (n = 36 treated vs. 297 controls). The dose is printed as 100 mg per kg of diet, called 0.1% w/w, and about 10.6 mg/kg body weight per day (p. 7). Those numbers do not agree with each other, since 100 mg/kg of diet is 0.01%.
- **Serum metformin** with the 0.1% diet was 0.45 ± 0.09 mM, and with 1% it was 5.03 ± 0.87 mM (p. 2).

#### What was measured over time, and when

- **Body weight and food intake.** For life, at intervals the paper calls biweekly or bimonthly; the wording is ambiguous (p. 7). Body weights are shown from 60 to about 155 weeks, using all live animals (Fig. 1c and legend, p. 3).
- **Body composition by NMR.** At several unspecified times (p. 8). No differences in fat or lean mass (p. 2; Supp. Table S4, not in the PDF).
- **Healthspan tests,** each done once, in subsets of living mice:

  | Test | Age (weeks) | n per group | Source |
  |---|---|---|---|
  | Indirect calorimetry | 71 | 9 | p. 7 |
  | Treadmill to exhaustion | 73 | 9 | p. 7 |
  | Serum chemistry | 74 | 4–16 | Table 1, p. 4 |
  | OGTT | 81 | 8 | p. 3 |
  | ITT | 93 | 9 | p. 3 |
  | Rotarod | 95 | 16 | p. 7 |
  | Open field | 95 | 15–16 | p. 7 |
  | Fasting insulin and glucose, HOMA-IR | 100 | 4–16 | Table 1, p. 4 |
  | Lens opacity (cataracts) | 105 | 93–124 eyes | p. 3 |
  | Cross-sectional pathology | 115 | not stated | p. 2 |

  HbA1c is dated inconsistently: 66 weeks after treatment began in the text (p. 3), but 66 weeks of age in the Table 1 footnote (p. 4).
- **No frailty index.**

#### Findings bearing on our questions

1. **Onset of frailty, morbidity or a decline phase.** Not defined. Healthspan means better scores on the tests above.

2. **Body weight trajectory.** Group means of survivors (Fig. 1c, p. 3; read from the graph, so approximate).
   - Both groups weighed about 41–42 g at 60 weeks, then held about 38–40 g to roughly 104 weeks.
   - They fell to about 25–28 g by about 140–150 weeks, roughly a third below the plateau.
   - Metformin mice were lighter than controls from 72 to 90 weeks, although they ate more (p. 2; Fig. 1d, p. 3).
   - From about 124 weeks they were heavier than controls (p. 2). The authors note that metformin mice "tended to preserve body weight with advancing age" (p. 2), which earlier rodent and human studies have tied to longer survival (refs 31–32, p. 2).
   - **A lead for the timing of terminal weight loss.** Ref. 31 is Alley et al. 2010 (*Am. J. Epidemiol.* 172:558–565), on weight loss in older men by time to death (p. 8). It is summarized in Part B (B2a).
   - Weight before death in individual mice is not reported.

3. **Weight or frailty as predictors of death.** Not tested in these data. The link between preserved weight and survival is cited, not shown (p. 2).

4. **Healthspan vs. lifespan, and compression of morbidity.**
   - **Healthspan gains came with a lifespan gain at 0.1%.**
     - Rotarod, treadmill and open field all improved (Fig. 1g–i, p. 3), and cataracts were reduced at 105 weeks (p. 3).
     - Insulin, total cholesterol, LDL, HbA1c and HOMA-IR were lower; glucose tolerance and insulin tolerance were unchanged (p. 3; Table 1, p. 4).
     - No major differences in pathology at 115 weeks or in cause of death at necropsy (p. 2).
   - **Survivor selection was mild.** Most tests were done at 71–105 weeks, when, from Fig. 1a, about three-quarters or more of the mice were still alive.
   - **What the tests cannot show.** They describe health in late middle age, not the length of the final morbid phase.
   - **Compression of morbidity** is not measured or discussed.

5. **Gompertz, level vs. slope, rectangularization.**
   - **Statistics given.** Only the percent change in mean lifespan, tested with Gehan–Breslow, which weights early deaths (p. 2; p. 8):
     - 0.1% metformin: +5.83% mean lifespan (χ² = 5.46, P = 0.02);
     - B6C3F1 at the same nominal dose: +4.15% (P = 0.064);
     - 1% metformin: −14.4% (P < 0.001), probably from renal failure (p. 2).
   - No median, maximum, percentiles, dispersion or Gompertz parameters are given. Rectangularization is not discussed. The authors say only that the curves separated soon after treatment began (p. 2).
   - **Read from Fig. 1a–b (p. 3),** to the nearest 2–3 weeks:

     | Group | First death | 75% alive | Median | 25% alive | Last death | Interquartile range |
     |---|---|---|---|---|---|---|
     | SD (vs. 0.1%) | ~61 | ~102 | ~120 | ~129 | ~148 | ~27 weeks |
     | 0.1% metformin | ~84 | ~113 | ~125 | ~136 | ~159 | ~23 weeks |
     | SD (vs. 1%) | ~65 | ~102 | ~126 | ~137 | ~159 | ~35 weeks |
     | 1% metformin | ~60 | ~82 | ~110 | ~114 | ~121 | ~32 weeks |

     All values are ages in weeks.
   - **What the readings show.** At 0.1%, the curve is moved about 5–11 weeks later along its whole length. The earliest deaths are delayed most, and the spread narrows only slightly. That is mainly a shift, not clear rectangularization. The toxic 1% dose moved the curve earlier and ended it about 38 weeks sooner.

6. **Methods details.**
   - Euthanasia was judged by an independent veterinarian under AAALAC guidelines. Only animals judged unable to survive count as deaths in the curves (p. 7). No weight-loss criterion is given.
   - Every animal found dead or euthanized was necropsied (p. 7).
   - Censoring rules and post-mortem weighing are not described.

**Relevance to us.**
- This is de Cabo's clearest case of healthspan and lifespan gained together. The survival gain is a modest shift with the earliest deaths delayed, not a compression of deaths into a narrower age band.
- The body-weight result, that treated mice held weight late in life and lived longer, is the pattern our percent-below-peak hazard model would predict, though the paper never links weight to death in individual mice.
- Its reference to Alley et al. 2010 is worth reading for when terminal weight loss begins.

---

### 6. Mitchell et al. 2018, Cell Metabolism

**Citation.** Mitchell SJ, Bernier M, Aon MA, Cortassa S, Kim EY, et al., Baur JA, de Cabo R (2018). Nicotinamide improves aspects of healthspan, but not lifespan, in mice. *Cell Metabolism* 27(3):667–676.e4. doi:10.1016/j.cmet.2018.02.001

**Page numbers** are journal pages 667–676 and e1–e4. Supplemental pages, which carry no printed numbers, are cited as "Supp. PDF p. N" (PDF pages 16–23).

#### Design

- **Mice.** Male C57BL/6J from the Jackson Laboratory (JAX 000664), housed four per cage, electronically tagged (p. e1).
- **Start of treatment.** Diets began at 56 weeks of age (392 days) (p. e1) and continued for life (p. 669). The Results describe the mice as 1 year old (p. 669).
- **Six arms of 100 mice each** (p. 669; pp. e1–e2):
  - **SD:** AIN-93G, with 64% of calories from carbohydrate, 19% from protein and 17% from fat;
  - **SDL, SDH:** SD + 0.5 or 1.0 g NAM per kg of diet;
  - **HFD:** 16% of calories from carbohydrate, 23% from protein and 61% from fat;
  - **HFDL, HFDH:** HFD + 0.5 or 1.0 g NAM per kg of diet.
  - Diets came from Dyets and NAM from Sigma-Aldrich.
- **NAM doses.** 0.5 and 1.0 g/kg of diet are **0.05% and 0.1% w/w**. The paper converts them to 37.5 and 75, printed in units of mg/g body weight per day (p. e2). Units of mg/kg must be meant: 3 g of food a day at 1 g/kg is 3 mg, or 75 mg/kg for a 40 g mouse.
- **Ages to scale.** Fig. 1E (p. 668): diet start at 56 weeks; NMR at 81 weeks; OGTT at 97; NMR and calorimetry at 105; behavior at 115; tissue collection at 118.

#### What was measured over time, and when

- **Body weight and food intake** every two weeks for life (p. e1). Food intake data are not shown (p. 669).
- **Body composition by NMR** at 81 and 107 weeks of age, that is, 25 and 51 weeks on diet (p. e2). n = 42–84 per group (Supp. PDF p. 19).
- **One-time tests in survivors:**

  | Test | Age (weeks) | n per group | Source |
  |---|---|---|---|
  | OGTT | 97 | 6 | p. e3 |
  | Fasting glucose, insulin, HOMA-IR | not stated | 6–8 | Supp. PDF p. 19 |
  | Indirect calorimetry | 105 | 6 | p. e2 |
  | Rotarod, cage-top hanging, open field | 115 | 8–16 | p. e2; Supp. PDF p. 19 |
  | Liver histology, metabolomics, western blots, NAD metabolome | 118 | 4–6 | pp. 670, e4 |

- **No frailty index.** The authors' own limitation: "Longitudinal evaluation of phenotypes associated with healthspan would have allowed a better assessment" (p. 674).

#### Nicotinamide effects, by diet and dose

Unless marked otherwise, *no change* means no significant difference from the vehicle on the same diet.

| Outcome (age) | SD + 0.05% | SD + 0.1% | HFD + 0.05% | HFD + 0.1% | Source |
|---|---|---|---|---|---|
| Mean and maximum lifespan | no change | no change | no change | no change | p. 669; Fig. 1A–B, p. 668 |
| Average body weight | no change | no change | no change | no change | p. 669; Fig. 1C–D |
| Food intake | no change (data not shown) | same | same | same | p. 669 |
| Percent fat (81 and 107 wk) | lower at both ages | no change | no change | no change | p. 669; Supp. PDF pp. 18–19 |
| Fasting glucose | lower | no change | no change | no change | p. 669; Supp. PDF pp. 18–19 |
| Insulin, HOMA-IR | no change | no change | downward trend | downward trend | p. 669 |
| OGTT (97 wk) | no change | no change | lower 15-min peak; AUC P = 0.08 | same | p. 669; Fig. 1F–G |
| Respiratory exchange ratio (105 wk) | higher (more carbohydrate use; AUC P < 0.05) | higher in the trace; AUC not significant | no change | higher (AUC P < 0.05) | p. 669; Fig. 1H–J |
| VO2, VCO2, activity (105 wk) | not reported as changed | same | not reported as changed | higher | p. 669; Supp. PDF p. 19 |
| Rotarod (115 wk) | no change | no change | longer | no change (trend) | Supp. PDF p. 18 |
| Open-field distance and speed (115 wk) | no change | no change | no change | higher | Supp. PDF p. 18 |
| Cage-top hanging (115 wk) | no change | no change | no change | no change | Supp. PDF p. 18 |
| Liver steatosis (118 wk) | no change | no change | reduced | reduced | p. 669; Fig. 1L |
| Liver glycogen | no change | no change | restored | restored | p. 669; Fig. 1N |
| Liver protein carbonylation | reduced | reduced | reduced | reduced | p. 670; Fig. 1P |
| Hepatic NAD+ and NADP+ | not raised | not raised | not raised | not raised | p. 667; p. 674; Fig. 4E |
| Global liver protein acetylation | increased, especially on HFD | same | same | same | p. 672 |
| Gross pathology at death | no differences | same | same | same | p. 669; Supp. PDF p. 23 |

- **Gross pathology at necropsy** (Table S1, Supp. PDF p. 23):
  - mice necropsied: SD 74, SDL 75, SDH 75, HFD 73, HFDL 80, HFDH 78;
  - the row giving age in weeks: 120, 116, 117, 100, 102 and 100. It is not said whether these are means or medians.
- **Significance in the table** comes from the figure asterisks, P < 0.05 vs. vehicle on the same diet (Fig. 1, p. 668; Supp. PDF p. 18). HFD mice did far worse than SD mice on the behavioral tests overall, for example in cage-top hanging (Supp. PDF p. 18).
- **Mechanism, in brief.** NAM lowered the NAM-salvage enzyme NAMPT, raised SIRT1 protein and raised enzymes of the de novo pathway (p. 672). High-dose NAM on HFD increased acetylation of the SIRT1 targets p53 and p65 (p. 672), consistent with some sirtuin inhibition. In yeast, high-dose NAM inhibits Sir2 and halves replicative lifespan (p. 667).
- **Link to BXD mice or to Rob Williams's group.** None. The article and the supplemental pages in this PDF never mention BXD mice, Rob Williams or GeneNetwork. The commentary in section 4, which does cite BXD work, has a Sarah J. Mitchell as senior author. Neither PDF says whether she is this paper's first author, and the affiliations differ (NIA here, Princeton there).

#### Findings bearing on our questions

1. **Onset definitions.** None.

2. **Body weight trajectory.** Group means of survivors, read from Fig. 1C–D (p. 668), so approximate.
   - **SD.** About 41 g at 56 weeks, then about 38–40 g to roughly 105–110 weeks. The weight then fell to about 29 g by about 130 weeks, roughly 25% below the plateau. SD + 0.05% NAM mice ran about 2–3 g lighter than vehicle from about 62 to 100 weeks, matching their lower fat, although the text reports no change in average weight.
   - **HFD.** Weight rose fast from about 44 g to a peak of about 57–60 g at about 76–86 weeks (530–600 days). It then fell steadily to about 40 g by 110 weeks and about 30 g by 128 weeks: roughly half the peak weight among the few survivors, and back to SD weight.
   - **Pace of the decline.** About 0.7 g per week on HFD vs. about 0.4 g per week on SD.
   - **Timing.** Most HFD deaths occurred during this long decline from the peak.
   - Weight before death in individual mice is not reported.

3. **Weight or frailty as predictors of death.** Not addressed.

4. **Healthspan vs. lifespan, and compression of morbidity.**
   - **Healthspan without lifespan.** Gains were in metabolic, liver and some motor measures, mainly on HFD, with no change in lifespan (p. 669; p. 674).
   - **Survivor selection was strong on HFD.** The behavioral tests at 115 weeks came when, from Fig. 1A–B, about 65–77% of SD mice but only about 27–42% of HFD mice were alive, with n = 8–16.
   - Compression of morbidity is not measured or discussed.

5. **Gompertz, level vs. slope, rectangularization.**
   - **Statistics given.** Only the log-rank test. Maximum lifespan is defined as the 10th percentile of mice still alive (p. e4). Neither median nor maximum is reported as a number. No Gompertz fit; rectangularization is not discussed.
   - **Read from Fig. 1A–B (p. 668)**, to the nearest 2–3 weeks:

     | Group | 75% alive | Median | 25% alive | Last death | Interquartile range |
     |---|---|---|---|---|---|
     | SD | ~115 | ~123 | ~128 | ~152 | ~13 weeks |
     | SD + 0.05% NAM | ~110 | ~123 | ~128 | ~152 | ~18 weeks |
     | SD + 0.1% NAM | ~106 | ~123 | ~129 | ~160 | ~23 weeks |
     | HFD | ~91 | ~103 | ~115 | ~127 | ~24 weeks |
     | HFD + 0.05% NAM | ~81 | ~107 | ~118 | ~137 | ~37 weeks |
     | HFD + 0.1% NAM | ~85 | ~104 | ~116 | ~131 | ~31 weeks |

     All values are ages in weeks.
   - **What the readings show.**
     - On SD, vehicle mice had the most rectangular curve: about 90% alive until about 108 weeks, then a steep fall. With NAM, more mice died between about 95 and 120 weeks, at the same median, so the curves were *less* rectangular.
     - High fat itself moved deaths about 20 weeks earlier. The first deaths came within weeks of the diet switch, and HFD roughly doubled the spread of age at death.
   - **For scale (a calculation, not in the paper).** A Gompertz interquartile range is about 2.3 × MRDT. These ranges would correspond to MRDTs of roughly 40 days for SD and 75 days for HFD. Treat these only as rough, eyeball values from curves that are not exactly Gompertz.

6. **Methods details.**
   - Mice were inspected twice daily. Moribund mice were euthanized after an independent veterinarian's assessment under AAALAC guidelines; no weight criterion is given (p. e2).
   - Only deaths judged incompatible with survival count. Mice lost to flooded cages or killed for tissue were censored (p. e2).
   - Every animal found dead or euthanized was necropsied (p. e2). Mice were not fasted before euthanasia (p. e2).
   - Post-mortem weighing is not mentioned.

**Relevance to us.**
- **The closest published analog to our high-fat + NAM arm,** but in B6 males started at 56 weeks, at 0.05–0.1% NAM. It predicts no change in lifespan or mean body weight, with modest metabolic and liver benefits in survivors.
- **Our dose is far higher.** Our arm, if 1% means w/w of diet, gets 10 g/kg, which is 10 times this paper's high dose. By the paper's own intake conversion that is roughly 750 mg/kg per day (an estimate; it depends on intake and body weight).
- **The high-fat survival curves are useful in their own right.** In Gompertz terms they look like a higher level with a longer MRDT: deaths begin early and spread out. That is worth comparing with our chow vs. high-fat fits.

---

### A7. Synthesis of Part A

None of the six papers defines the onset of a morbid phase from body weight, follows individual weights to death, or reports when or how much weight falls before natural death. None addresses weight between the last weighing and death, post-mortem weight loss, or weight-based euthanasia criteria. Those need other sources or our own data.

What they do offer:

- **Late-life weight loss is common in survivors (Duregon; also sections 5 and 6).** Ad libitum B6 females began a sustained, population-wide decline at about 595 days, reaching about 27% below starting weight by about 990 days while eating more. Chow-fed B6 males in the metformin and NAM studies held a plateau until about 105 weeks (735 days), then lost about a quarter to a third. High-fat males peaked at about 80 weeks and lost about half their weight before the last deaths. A 90%-of-peak rule may therefore flag ordinary aging weight loss long before the terminal phase. This fits our finding of a smooth rise in hazard with no 10% threshold.
- **Keep offset apart from slope (Xie; MacArthur & Mitchell).** Their baseline vs. rate split is our level vs. MRDT split. Measuring loss against each mouse's own running peak keeps a diet's weight offset apart from its rate of terminal decline.
- **Survivor bias.** Duregon scored frailty only in survivors at 141 weeks; Xie stopped at 20 months to avoid this. The same caution applies to comparing morbidity spans between diets.

Measures to add to our comparison of onset definitions:

1. **Per-mouse changepoint onset.** Fit a plateau-then-decline (broken-stick) model to each mouse's weights, allowing 3–5% noise per weighing. Onset is the break age. It uses every weighing, so one noisy weight cannot decide it.
2. **Weight relative to peers.** Percent below the median of the same strain and diet at the same age, separating individual from cohort-wide decline.
3. **A time-varying hazard ratio (Jiang).** Under Gompertz hazards, log HR is flat for a level effect and linear in age for an MRDT difference. A model-free check on our level vs. slope conclusions.

**Rectangularization (sections 1, 5 and 6).** None of the six papers measures or discusses rectangularization, and none fits Gompertz parameters by group. The numbers they give point to shifts and stretches, not compression:
- Metformin moved the whole survival curve about 5–11 weeks later with a similar spread (interquartile range about 23 vs. 27 weeks).
- In Duregon's females, CR stretched the upper tail: 75th percentile 150 vs. 143 weeks, 90th percentile 161 vs. 149, maximum 170 vs. 155 (Supp. p. 11).
- NAM changed neither median nor maximum.
- High fat moved deaths about 20 weeks earlier and roughly doubled their spread.

A Gompertz rule of thumb (a calculation, not in the papers): the SD of age at death is about 1.8 × MRDT and the interquartile range about 2.3 × MRDT, whatever the level. A level change therefore shifts the curve without changing its shape; only a shorter MRDT makes it more rectangular. Rectangularizing mortality while improving health would then show up in our fits as a lower level together with a shorter MRDT.

**What the NAM paper predicts for our high-fat + NAM BXD arm.** If the B6-male results carry over, expect no change in lifespan, mean body weight or food intake, and at most modest gains in glucose handling, liver fat and motor tests among survivors. Three cautions:
- Our 1% NAM, if w/w, is 10 times their high dose (0.1%).
- Our mice are females of many strains.
- Their healthspan tests were single time points in a minority of surviving high-fat mice.

The paper has no link to BXD mice or to Rob's group.

---

## Part B. The wider literature

Prepared 27 October 2026 for Rob Williams (BXD mortality project). American spelling throughout.

**How the citations were checked.** Every paper below was looked up in this session in PubMed (NCBI E-utilities and the PubMed tools). One paper not indexed in PubMed (Stephens et al. 2015) was checked through Crossref. Full text was read from PubMed Central when it was open access; otherwise only the abstract was read, and the entry says so. A few numbers came from a model-assisted reading of the PMC page. Key numbers for Mitchell 2016, Ray 2010, Trammell 2012 and Schultz 2020 were checked against the papers' own sentences. Numbers that could not be confirmed are marked.

**How to read this.** There are two ways to measure late-life decline in a mouse:

- **A frailty index (FI)** counts deficits, such as kyphosis, coat condition or tremor, on a 0–1 scale. Each deficit adds a little to the risk of death. The FI rises roughly exponentially with age.
- **Body weight** is a single continuous measure. Weight usually reaches a plateau and then falls in the months before a natural death.

Most papers that define the end of health in mice use one of three tools: an FI cutoff, a performance-based "frailty phenotype," or a weight rule tied to each mouse's own baseline. None has been validated as a definition of the onset of a morbid phase in a genetically diverse population.

The six papers in Part A are left out here.

---

### B1. Ten core studies

#### Summary table

| # | Study | Mice | Key point for us |
|---|---|---|---|
| 1 | Schultz et al. 2020, *Nat Commun* (Mitchell, MacArthur) | 60 male C57BL/6Nia, FI every ~6 weeks to death | Total weight loss was the single most important predictor of remaining life |
| 2 | Zhu et al. 2026, *J Gerontol A* (Mitchell, MacArthur) | 1,564 mice, 5 strains, 17 cohorts | The FI–lifespan link depends on strain and sex; no single cutoff transfers |
| 3 | Kane et al. 2016, *J Gerontol A* (Mitchell senior) | DBA/2J vs C57BL/6J, ad libitum vs CR | The only FI comparison of the two BXD parents |
| 4 | Mitchell et al. 2016, *Cell Metab* | DBA/2J and C57BL/6J, both sexes, 3 diets | Health and survival respond to diet separately |
| 5 | Whitehead et al. 2014, *J Gerontol A* | Female C57BL/6J | Defines the standard 31-item clinical FI |
| 6 | Rockwood et al. 2017, *Sci Rep* | 251 male C57BL/6J followed for life | FI hazard rises smoothly: HR 1.15 per 0.01 FI |
| 7 | Ray et al. 2010, *JAALAS* | 105 ICR mice to natural death | Terminal loss is gradual over 2–3 months, about 10–14% by death |
| 8 | Trammell et al. 2012, *Comp Med* | C57BL/6J, BALB/cByJ, AKR/J | In B6, loss begins 10–11 weeks before death; ~1 in 4 die without it |
| 9 | Di Francesco et al. 2024, *Nature* | 937 female DO mice weighed weekly | Weight falls after ~90% of life lived; any weight loss predicts shorter life |
| 10 | Lamming 2024, *GeroScience* | Reanalysis of four datasets | FAMY: a healthspan measure with no threshold |

---

#### 1. Schultz et al. 2020: frailty clocks (FRIGHT and AFRAID)

**Citation.**

- **Authors:** Schultz MB, Kane AE, Mitchell SJ, MacArthur MR, Warner E, Vogel DS, Mitchell JR, Howlett SE, Bonkowski MS, Sinclair DA.
- **Title:** Age and life expectancy clocks based on machine learning analysis of mouse frailty.
- **Journal:** *Nature Communications* 2020; 11:4618.
- **Identifiers:** DOI 10.1038/s41467-020-18446-0, PMID 32934233, PMCID PMC7492249.
- **Publisher correction:** *Nat Commun* 11:5143, DOI 10.1038/s41467-020-19046-8, PMID 33033247.

**Design.**

- 60 male C57BL/6Nia mice from the NIA colony, followed from 21 months of age to natural death.
- Median lifespan was 31 months, and the 90th percentile was 36 months.
- Only 4 mice (6.7%) were euthanized as moribund.

**Measure and frequency.**

- The clinical FI (29 of the 31 items) was scored about every 6 weeks by one rater.
- Three weight variables were added:
  - total percent weight change since 21 months;
  - percent change over the previous month;
  - a threshold item that scored a gain of more than 8% or a loss of more than 10% from the previous month.

**Key findings.**

- **FRIGHT** is a random forest trained to predict age from the FI items. It predicted chronological age with r² = 0.748 and a median error of 1.3 months.
- **AFRAID** is a random forest trained to predict remaining lifespan. In the held-out mice it gave r² = 0.505, with a median error of 1.7 months; the Discussion cites 53 days.
- **The most important AFRAID inputs** were total weight loss, then chronological age and tremor, then distended abdomen, recent weight loss and the menace reflex.
- **The FI score alone** ranked behind age as a correlate of remaining life.
- **Interventions:** methionine restriction raised predicted remaining life by 1.3 months; enalapril did not.

**How well it predicts death.**

- Within each age band (24–26, 27–29, 30–32 and 33–35 months), mice in the top and bottom AFRAID quartiles had clearly different survival (log-rank P = 0.015–0.034).
- "Delta age" (FRIGHT age minus true age) predicted remaining life poorly at most ages.

**Onset definition.**

- The paper defines no onset of morbidity.
- A loss of more than 10% in one month counts as a deficit.
- The moribund rule was at least two signs, one of which could be rapid weight loss of more than 20% in one week.

**Relevance.** This is the clearest evidence from the Mitchell and MacArthur group that cumulative weight loss carries more information about remaining life than any other frailty item. That matches our finding that percent below the running peak beats the rate of loss. Note that "total" loss was measured from a fixed age (21 months), not from each mouse's peak, and only males of one inbred strain were studied.

---

#### 2. Zhu et al. 2026: frailty, age and lifespan across strains and sexes

**Citation.**

- **Authors:** Zhu D, Green CL, Mitchell SJ, MacArthur MR, Bisset ES, Mach J, Wu JZ, Samuelson BA, Shindyapina A, Moldakozhayev A, Tskhay A, Tyshkovskiy A, Gladyshev VN, Sinclair DA, Howlett SE, Hilmer SN, Lamming DW, Kane AE.
- **Title:** The association of frailty with age and lifespan in mice differs by strain and sex.
- **Journal:** *Journals of Gerontology Series A* 2026; 81(8). The PubMed record gives no page or article number yet.
- **Identifiers:** DOI 10.1093/gerona/glag167, PMID 42363413, PMCID PMC13379634.

**Design.**

- Item-level data for the 31-item clinical FI, pooled from 17 cohorts.
- 1,564 mice (690 female, 874 male) from C57BL/6JNIA, C57BL/6N, C57BL/6J, UM-HET3 and Diversity Outbred (DO).
- 3,665 FI scores, 1 to 11 per mouse. 576 mice were followed to death, and 2,192 scores are linked to a known age at death.
- Most scores were taken between 300 and 900 days of age.

**Measure.**

- Clinical FI. Items were compared on an 18-item subset.
- The body weight and temperature items were dropped because not every cohort recorded them.

**Key findings.**

- The FI rose with age in every strain, but at different rates: fastest in the C57BL/6 substrains, then UM-HET3, then DO.
- A sex difference in FI trajectory appeared only in C57BL/6JNIA, where females accumulated deficits faster.
- Males outlived females in the B6 substrains but not in UM-HET3.
- FI was strongly linked to the fraction of life already lived. In the pooled data, however, that link was not significant once age was added to the model. In the authors' words, "FI largely reflects chronological aging at the population level."
- Within strains the picture differed:
  - in male C57BL/6JNIA the link strengthened with age;
  - in C57BL/6N it weakened with age;
  - in male C57BL/6J it was negative.
- Healthspan was measured with FAMY (entry 10). C57BL/6J had the longest healthspan.

**How well it predicts death.** Beyond chronological age, weakly overall, and differently by strain and sex.

**Onset definition.** None. The authors warn that a single cutoff can overlook frailty in some strains and overstate it in others.

**Relevance.** This is the newest and largest Mitchell–MacArthur frailty paper. Its main message for a genetic reference population is that any fixed cutoff, whether FI or weight, should be checked strain by strain. That fits our plan to test many definitions. It also shows that the FI's own weight item was not usable across cohorts, so our longitudinal weights add information the FI cannot.

---

#### 3. Kane et al. 2016: the frailty index in DBA/2J and C57BL/6J mice under calorie restriction

**Citation.**

- **Authors:** Kane AE, Hilmer SN, Boyer D, Gavin K, Nines D, Howlett SE, de Cabo R, Mitchell SJ.
- **Title:** Impact of longevity interventions on a validated mouse clinical frailty index.
- **Journal:** *Journals of Gerontology Series A* 2016; 71(3):333–339.
- **Identifiers:** DOI 10.1093/gerona/glu315, PMID 25711530, PMCID PMC4757961.

**Design.**

- **Cohort 1:** C57BL/6J (18 male, 21 female) and DBA/2J (16 male, 19 female), fed ad libitum or 40% calorie restricted (CR) from 6 months of age. Each mouse was scored once at about 18–19 months.
- **Cohort 2:** 24-month-old male C57BL/6J mice with or without resveratrol (16 and 9 mice).

**Measure.**

- 31-item clinical FI, scored by two raters (intraclass correlation 0.88).
- Body weight and temperature were scored by how many SDs a mouse was from the mean of young (12-week) reference mice. Being much heavier counts as a deficit, just as being much lighter does.

**Key findings.**

- CR lowered FI in male C57BL/6J (P = .04), and resveratrol lowered FI (P = .01).
- DBA/2J mice were only slightly frailer than C57BL/6J. For CR males the scores were 0.16 ± 0.03 and 0.11 ± 0.03 (P = .01).
- The paper cites male median lifespans of 23–25 months for DBA/2J and 26–30 months for C57BL/6J. The authors suggest DBA/2J may have a relatively long healthspan: "perhaps they have a comparatively longer healthspan."

**How well it predicts death.** Not tested: FI was scored once and not linked to lifespan.

**Onset definition.** None.

**Relevance.** This is the only frailty-index comparison of the two BXD parents, and Sarah Mitchell is the senior author. The weight item's reference to young mice matters for our high-fat BXD mice: a heavy mouse already scores as "frail" on that item. A within-mouse, peak-relative weight measure avoids that problem.

---

#### 4. Mitchell et al. 2016: sex, strain and energy intake (C57BL/6J and DBA/2J)

**Citation.**

- **Authors:** Mitchell SJ, Madrigal-Matute J, Scheibye-Knudsen M, Fang E, Aon M, … Bernier M, de Cabo R (47 authors).
- **Title:** Effects of sex, strain, and energy intake on hallmarks of aging in mice.
- **Journal:** *Cell Metabolism* 2016; 23(6):1093–1112.
- **Identifiers:** DOI 10.1016/j.cmet.2016.05.027, PMID 27304509, PMCID PMC4911707.

**Design.**

- C57BL/6J and DBA/2J, both sexes, fed ad libitum, 20% CR or 40% CR from 6 months of age (Teklad 2018 diet), housed 3–4 per cage.
- The longevity study had 50 mice per C57BL/6J group and 58–63 per DBA/2J group.

**Measure and frequency.**

- Body weight and food intake were recorded every two weeks.
- Health was measured cross-sectionally: body composition, rectal temperature, glucose and insulin, islet area, liver biology and pathology at death.
- No frailty index was used.

**Key findings.**

- **C57BL/6J on 20% CR:** mean lifespan rose 40.6% in females and 24.4% in males.
- **C57BL/6J on 40% CR:** no survival benefit in females; a smaller benefit than 20% CR in males.
- **DBA/2J on 40% CR:** maximum lifespan rose 37.3% and 29.8% in the two sexes. Yet DBA/2J males on 40% CR lost 18.8% of first-quarter lifespan, and DBA/2J females gained nothing more from 40% than from 20% CR.
- CR improved health measures across strains and sexes even when lifespan did not rise. CR mice died later but with the same pathologies.
- Euthanasia was decided by a veterinarian under AAALAC guidelines. No weight threshold is stated.

**How well it predicts death.** Not analyzed. The paper reports no pre-death weight trajectories, although the every-two-weeks weights exist.

**Onset definition.** None.

**Relevance.** These are the BXD parents, in both sexes, under diet. The paper shows that health and survival can separate, so a weight-defined morbid phase may respond to diet differently from lifespan or MRDT. A candidate for a data request: the DBA/2J and C57BL/6J weight series could show strain differences in terminal decline.

---

#### 5. Whitehead et al. 2014: the 31-item clinical frailty index

**Citation.**

- **Authors:** Whitehead JC, Hildebrand BA, Sun M, Rockwood MR, Rose RA, Rockwood K, Howlett SE.
- **Title:** A clinical frailty index in aging mice: comparisons with frailty index data in humans.
- **Journal:** *Journals of Gerontology Series A* 2014; 69(6):621–632.
- **Identifiers:** DOI 10.1093/gerona/glt136, PMID 24051346, PMCID PMC4022099.

**Design.**

- Female C57BL/6J mice at about 5, 19 and 28 months (14 mice in total), plus a few males.
- A colony survival curve of 293 females.
- Compared with a human FI from the SHARE survey (30,025 people).

**Measure.**

- 31 clinical items covering integument, musculoskeletal, hearing and vestibular, eye and nose, digestive, urogenital, respiratory and discomfort signs, each scored 0, 0.5 or 1.
- Body weight and temperature were scored by SD bands from young adult reference values.
- Scoring took about 3.8 minutes per mouse.
- Mice were rescored for repeatability; this was not a full longitudinal study.

**Key findings.**

- FI was 0.02 at 5 months, 0.12 at 19 months and 0.33 at 28 months.
- On an age axis normalized to 90% mortality, the FI rose exponentially, much as it does in humans. An older 8-item performance index did not.

**How well it predicts death.** Not tested. One old mouse showed a sharp FI rise just before it died.

**Onset definition.** No frailty cutoff is proposed.

**Relevance.** This is the instrument behind most later mouse frailty work, including entries 1–3, 6 and 10. Its weight item compares each mouse with young reference mice, not with the mouse's own peak.

---

#### 6. Rockwood et al. 2017: the frailty index and mortality risk in mice and humans

**Citation.**

- **Authors:** Rockwood K, Blodgett JM, Theou O, Sun MH, Feridooni HA, Mitnitski A, Rose RA, Godin J, Gregson E, Howlett SE.
- **Title:** A frailty index based on deficit accumulation quantifies mortality risk in humans and in mice.
- **Journal:** *Scientific Reports* 2017; 7:43068.
- **Identifiers:** DOI 10.1038/srep43068, PMID 28220898, PMCID PMC5318852.

**Design.**

- 251 male C57BL/6J mice from Charles River, followed for life.
- FI was scored at about 1, 6, 12 and 18 months, then at varying ages.
- Compared with 9,169 NHANES adults.

**Measure.** Clinical FI, with weight and temperature scored against the study average for that age.

**Key findings.**

- Mean FI was 0.05 at 30–299 days, 0.21 at 300–599 days and 0.29 at 600 days or more.
- Deficits accumulated at a similar rate in mice and humans: the slope of log FI on age was 0.036 in mice and 0.029 in humans.
- The highest FI reached was similar too: 0.44 in mice and 0.54 in humans. In the oldest mice, 99% of FI scores were 0.49 or lower.

**How well it predicts death.**

- In a Cox model with FI updated over time, each 0.01 rise in FI raised the hazard by a factor of 1.15 (95% CI 1.12–1.18) in mice, against 1.05 in humans.
- FI was more informative at older ages.

**Onset definition.** None. The 99% limit (0.49) is later used as a practical ceiling (Toth 2018).

**Relevance.**

- The hazard rises smoothly with each step of deficit, with no threshold. This parallels our finding for each step of weight loss.
- The time-dependent Cox approach is the natural way to model percent below the running peak.

---

#### 7. Ray et al. 2010: markers of imminent death in aging mice

**Citation.**

- **Authors:** Ray MA, Johnston NA, Verhulst S, Trammell RA, Toth LA.
- **Title:** Identification of markers for imminent death in mice used in longevity and aging research.
- **Journal:** *Journal of the American Association for Laboratory Animal Science* 2010; 49(3):282–288.
- **Identifiers:** PMID 20587157, PMCID PMC2877298. The PubMed record lists no DOI.

**Design.**

- Hsd:ICR (CD-1) retired breeders enrolled at 8 months; 105 of 110 were analyzed.
- 81 died naturally (36 males, 45 females) and 24 were euthanized.
- Mean age at natural death was 27.1 months for males and 23.1 months for females.

**Measure and frequency.** Body weight and temperature (from an implanted chip) at least every 4 weeks, and more often once a mouse looked ill.

**Key findings.**

- Gradual weight loss was the earliest and most common sign of approaching death. Some mice lost up to 20% over the last 3 months.
- **Final weight relative to baseline:** baseline was each mouse's mean over weeks 10–13 before death.
  - Natural deaths: 90 ± 2% in males and 86 ± 2% in females.
  - Euthanized females: 80 ± 4%.
- Hypothermia developed in the final 2 weeks.

**How well it predicts death.**

- The temperature × weight product was stable, then fell to 90–100% of baseline over 4–6 weeks, then below 90% in the last 2–3 weeks.
- A 90% cutoff would have predicted death to within about 2 weeks.
- No sensitivity or specificity was reported.

**Onset definition.** Imminent death: temperature × weight below 90% of the mouse's own stable baseline.

**Relevance.**

- Terminal loss in mice is gradual and lasts months, not days.
- On average, natural deaths ended only 10–14% below baseline, so a 10% cutoff sits close to the typical end point. Many mice will die before or just after crossing it.
- Females lost more than males.

---

#### 8. Trammell et al. 2012: markers of imminent death in aged inbred mice (C57BL/6J, BALB/cByJ, AKR/J)

**Citation.**

- **Authors:** Trammell RA, Cox L, Toth LA.
- **Title:** Markers for heightened monitoring, imminent death, and euthanasia in aged inbred mice.
- **Journal:** *Comparative Medicine* 2012; 62(3):172–178.
- **Identifiers:** PMID 22776049, PMCID PMC3364702. The PubMed record lists no DOI.

**Design.**

- AKR/J (25 male, 25 female), C57BL/6J (31 male) and BALB/cByJ (13 male).
- Mean age at death was 801 ± 39 days for C57BL/6J (median 821) and 720 ± 33 days for BALB/cByJ.

**Measure and frequency.** Weekly body weight and chip temperature.

**Key findings.**

- In C57BL/6J and BALB/cByJ, significant weight loss began 10 or 11 weeks before death and continued until death.
- Hypothermia began about 7 weeks before death, with a steep final drop.
- AKR/J mice, which die of lymphoma, declined over only about 3–4 weeks.
- Baseline was each mouse's mean over weeks 13–16 before death (C57BL/6J and BALB/cByJ).

**How well it predicts death.**

- 8 of 31 C57BL/6J and 6 of 13 BALB/cByJ mice never fell below 95% of baseline weight before dying.
- Temperature × weight added little beyond weight and temperature taken separately.
- No percentage loss at death is given.

**Onset definition.** A benchmark of 95% of the mouse's own baseline. The later review (Toth 2018) suggests a 5% weight drop plus a 1 °C fall.

**Relevance.**

- C57BL/6J is a BXD parent. Its terminal decline starts about 70–77 days before death, close to one of our 64-day weighing intervals.
- About a quarter of C57BL/6J mice died with no detectable loss, so a "no decline" group in our data is expected biology, not only missing data.

---

#### 9. Di Francesco et al. 2024: dietary restriction in genetically diverse female mice (DRiDO)

**Citation.**

- **Authors:** Di Francesco A, Deighan AG, Litichevskiy L, Chen Z, Luciano A, Robinson L, Garland G, Donato H, Vincent M, Schott W, Wright KM, Raj A, Prateek GV, Mullis M, Hill WG, Zeidel ML, Peters LL, Harding F, Botstein D, Korstanje R, Thaiss CA, Freund A, Churchill GA.
- **Title:** Dietary restriction impacts health and lifespan of genetically diverse mice.
- **Journal:** *Nature* 2024; 634(8034):684–692.
- **Identifiers:** DOI 10.1038/s41586-024-08026-3, PMID 39385029, PMCID PMC11485257.

**Design.**

- 960 female Diversity Outbred mice (937 analyzed), randomized to five groups: ad libitum, fasting 1 or 2 days a week, or 20% or 40% CR.
- Diets began at 6 months of age, and the mice were followed to death.

**Measure and frequency.**

- Body weight every week for life, giving more than 100,000 weights.
- FI and other tests at roughly yearly intervals (about 5, 10, 16, 22, 28 and 34 months).

**Key findings.**

- In every group except 40% CR, average weight was stable between 50% and 75% of life lived and fell rapidly after about 90% of life lived.
- Weight loss at any age was linked to shorter life. Change in weight over the 10–11-month testing period was the trait most strongly linked to lifespan of all those measured; mice that kept their weight lived longer.
- FI at 28 months was one of the few health traits linked to lifespan (adjusted P = 0.0024).
- The paper also reports Gompertz mortality doubling times by diet.

**How well it predicts death.** Weight retention was a strong predictor of lifespan, ahead of metabolic traits.

**Onset definition.** None given. Pre-emptive euthanasia used clinical signs (palpable hypothermia with unresponsiveness, inability to eat or drink, severe dermatitis, tumors); no weight threshold is listed.

**Relevance.** This is the largest weekly-weighed female cohort. It is the best external benchmark for how late in life the terminal decline begins in genetically diverse females, and it shows the decline in all but the most restricted diet.

---

#### 10. Lamming 2024: FAMY and GRAIL, healthspan measures with no threshold

**Citation.**

- **Author:** Lamming DW.
- **Title:** Quantification of healthspan in aging mice: introducing FAMY and GRAIL.
- **Journal:** *GeroScience* 2024; 46(5):4203–4215.
- **Identifiers:** DOI 10.1007/s11357-024-01200-5, PMID 38755467, PMCID PMC11336093.
- **Preprint:** bioRxiv, DOI 10.1101/2023.11.07.566044, PMID 37986745, PMCID PMC10659332. The details below were read from the preprint full text, because the PMC copy of the journal version returned no text.

**Design.** Reanalysis of published longitudinal FI and lifespan data:

- Schultz 2020 (male C57BL/6Nia);
- a CR study in C57BL/6J mice of both sexes;
- two DO dietary-restriction studies;
- UM-HET3 mice on protein or isoleucine restriction.

**Measure.**

- FAMY (frailty-adjusted mouse years) is the area under the curve of (1 − FI) from birth to death, in years.
- It makes two assumptions: FI is 0 at the start of the study and 0.7 on the day of death.

**Key findings.**

- In the C57BL/6Nia males, median FAMY was 2.19 years against a median lifespan of 2.6 years, so about 16% of possible healthy life was lost.
- FAMY correlated with lifespan at R = 0.93.
- CR raised FAMY mostly by lengthening life. A CR mouse and an ad libitum mouse dying at the same age differed by only about 2.3%.

**Onset definition.** FAMY avoids an onset threshold. But fixing FI at 0.7 at death writes a terminal decline into every mouse, which pushes FAMY toward being a stand-in for lifespan.

**Relevance.** This is a template for a threshold-free "weight-adjusted days" measure. It also warns against anchoring the curve at death, which would make the measure track lifespan.

---

### B2. Targeted searches

#### B2a. Terminal weight loss before natural death in mice and rats

Besides entries 1, 7, 8 and 9, four more papers:

- **Toth 2018, review.**
  - Citation: Toth LA. Identifying and implementing endpoints for geriatric mice. *Comparative Medicine* 2018; 68(6):439–451. DOI 10.30802/AALAS-CM-18-000022, PMID 30486919, PMCID PMC6310203.
  - Toth summarizes her lab's chip studies. Weight and temperature start to fall several weeks before death, with "many (but not all)" mice showing marked loss.
  - She proposes a 5% weight drop plus a 1 °C fall, or a 5% drop in temperature × weight, as signals for closer watch or euthanasia.
  - She suggests a per-mouse baseline taken as the average of several stable consecutive weights, or a rolling average when weight is still changing. Peak weight is not discussed.
  - She reports veterinary euthanasia decisions at clinical FI 0.50–0.54.

- **Goodrick 1977, classic.**
  - Citation: Goodrick CL. Body weight change over the life span and longevity for C57BL/6J mice and mutations which differ in maximal body weight. *Gerontology* 1977; 23(6):405–413. DOI 10.1159/000212216, PMID 892447. Abstract only.
  - Weighed monthly (80 mice, 5 groups on a C57BL/6J background).
  - Every group except albino mice showed a terminal decline in weight.
  - Within groups, longer-lived mice lost more weight at the end than shorter-lived ones.
  - Peak weight correlated positively with longevity.

- **Mason et al. 2010, female mice.**
  - Citation: Mason JB, Cargill SL, Anderson GB, Carey JR. Ovarian status influenced the rate of body-weight change but not the total amount of body-weight gained or lost in female CBA/J mice. *Experimental Gerontology* 2010; 45(6):435–441. DOI 10.1016/j.exger.2010.03.010, PMID 20304041, PMCID PMC2862801.
  - Monthly weights (each the mean of three daily weights) from 11 months to death.
  - The paper uses the same frame we do: time to peak weight, then the rate of loss to death.
  - Mice lost 11.5–14.7% of body weight between 85% and 95% of lifespan. Ovarian transplants slowed the rate of loss, but weight retained at death did not differ between groups.

- **Alley et al. 2010, humans, for method only.**
  - Citation: Alley DE, Metter EJ, Griswold ME, Harris TB, Simonsick EM, Longo DL, Ferrucci L. Changes in weight at the end of life: characterizing weight loss by time to death in a cohort study of older men. *American Journal of Epidemiology* 2010; 172(5):558–565. DOI 10.1093/aje/kwq168, PMID 20682520, PMCID PMC3025636.
  - 800 men from the Baltimore Longitudinal Study of Aging.
  - A three-phase model (stable or gaining, mild loss, accelerated loss) fit best. Loss accelerated about 9 years before death overall, and about 3 years before death from cancer.
  - This is a precedent for estimating each individual's change point instead of fixing a threshold.

**What is known.** In the mouse studies, terminal loss before natural death:

- usually begins 2–3 months before death (C57BL/6J and BALB/c: 10–11 weeks; ICR mice: 2–3 months; DO females: after about 90% of life lived);
- averages about 10–15% below the mouse's own stable weight by death;
- is graded and gradual rather than stepwise, except in strains that die fast of lymphoma (AKR/J: 3–4 weeks);
- is absent in a substantial minority (about 26% of C57BL/6J, 46% of BALB/cByJ at the 95% benchmark).

No study found reports hazard as a function of percent below each mouse's own running peak. Our analysis appears to be new on that point.

#### B2b. Post-mortem change in body weight

- **Howie et al. 2024, the only direct laboratory study found.**
  - Citation: Howie RR, McKinney MM, Tataryn NM, Cole AL, Dupont WD, Yang TS, Gibson-Corley KN. Determination of postmortem interval in mice. *JAALAS* 2024; 63(4):428–436. DOI 10.30802/AALAS-JAALAS-23-000107, PMID 38471755, PMCID PMC11270044.
  - **Design:** 108 euthanized C57BL/6 mice of both sexes, 8–12 months old, 3 per time point.
    - Room-temperature carcasses lay in a microisolator cage with bedding on a ventilated rack (60 air changes per hour, 20–22 °C, about 53% humidity).
    - Refrigerated carcasses were held at 4 °C in bags.
    - Checks ran from 0 to 12 hours and then daily to 14 days.
  - **Result:** carcasses lost 0.78% of baseline weight per day at room temperature and 0.06% per day at 4 °C (95% CI for the difference 0.67–0.76%). Total loss was about 16% at room temperature over 14 days.
  - **Caveat:** the Discussion restates the rates as per hour, which conflicts with the Results. The Results' per-day figures fit the 16% total.
  - **For us:** 24–48 hours in a cage would lower weight by about 1–2%, which is below a single weighing's 3–5% noise. Decomposition, though, was visible histologically by 12 hours.
- **Aturaliya & Lukasewycz 1999** (rats). Citation: *J Forensic Sci* 44(5):893–896; PMID 10486936; no DOI in PubMed. Abstract only, no numbers. Water loss from rat carcasses was driven mainly by conditions at the skin surface: position, clothing and especially airflow (tripling airflow sped drying).
- **Stephens, Karau, Yahnke, Wendt & Rowe 2015.**
  - Citation: Dead mice can grow – variation of standard external mammal measurements from live and three postmortem body states. *J Mammal* 96(1):185–193. DOI 10.1093/jmammal/gyu022, verified through Crossref; not in PubMed.
  - The text could not be read. A search snippet said weight fell between successive post-mortem states, likely from drying. Treat this as unverified detail.

#### B2c. How studies define the end of healthspan or the onset of morbidity

| Family | Definition | Source |
|---|---|---|
| FI cutoff, relative to the cohort | Frail if FI ≥ 0.18 (about the cohort mean) | Kane et al. 2017 (below) |
| FI near-terminal values | Veterinary euthanasia at FI 0.50–0.54; 99% of old mice ≤ 0.49 | Toth 2018; Rockwood 2017 |
| Frailty phenotype (Fried-style) | Frail if 3 or more of 4 measures (grip, walking speed, activity, endurance) fall 1.5 SD below the cohort mean; 2 = mildly frail | Liu et al. 2014 |
| Modified phenotype | 0.8 SD cutoff plus a weight-loss criterion | Kane et al. 2017 |
| Weight, own baseline | Below 95% of a stable baseline (mean of weeks 13–16 before death) | Trammell 2012; Toth 2018 |
| Weight × temperature | Below 90% of the stable baseline predicts death within about 2 weeks | Ray 2010 |
| Weight, rate | Loss of more than 10% within a month scored as a deficit | Schultz 2020 |
| Weight, peak-based (ALS mice) | Onset = age at peak weight; early disease = 10% below peak | Israelson et al. 2010 (below) |
| Humane endpoint | More than 20% loss within one week | SLAM (Palliyaguru 2021); Schultz 2020 |
| Fraction of life lived | Last 10% of life (DO females); 85–95% of lifespan | Di Francesco 2024; Mason 2010 |
| No threshold | Area under (1 − FI): FAMY | Lamming 2024; Zhu 2026 |
| Predicted remaining life | AFRAID clock | Schultz 2020 |

Supporting citations for this table:

- **Liu et al. 2014** (the "Fried-style" paper in the candidate list).
  - Citation: Liu H, Graber TG, Ferguson-Stegall L, Thompson LV. Clinically relevant frailty index for mice. *J Gerontol A* 2014; 69(12):1485–1491. DOI 10.1093/gerona/glt188, PMID 24336799, PMCID PMC4271019.
  - Despite its title, this is a frailty phenotype, not a deficit index.
  - Study: 27–28-month-old male C57BL/6. One mouse was frail and one mildly frail (9% prevalence).
- **Kane et al. 2017.**
  - Citation: Kane AE, Huizer-Pajkos A, Mach J, Mitchell SJ, de Cabo R, Le Couteur DG, Howlett SE, Hilmer SN. A comparison of two mouse frailty assessment tools. *J Gerontol A* 2017; 72(7):904–909. DOI 10.1093/gerona/glx009, PMID 28549083, PMCID PMC5861875.
  - Study: 36 male C57BL/6 mice at about 24 months.
  - The FI called 16 mice frail. The original phenotype called none; the modified phenotype called 6.
  - The two tools agreed only 50% of the time.
- **Israelson et al. 2010.**
  - Citation: Israelson A, Arbel N, Da Cruz S, Ilieva H, Yamanaka K, Shoshan-Barmatz V, Cleveland DW. Misfolded mutant SOD1 directly inhibits VDAC1 conductance in a mouse model of inherited ALS. *Neuron* 2010; 67(4):575–587. DOI 10.1016/j.neuron.2010.07.019, PMID 20797535, PMCID PMC2941987.
  - The Fig. 6 legend defines onset as reaching peak weight and early disease as a 10% loss from maximal weight.
  - This convention is often credited to Boillée et al. 2006 (*Science* 312:1389–1392, DOI 10.1126/science.1123511, PMID 16741123). That paper is verified to exist, but its abstract does not state the definition, and its Methods could not be read.
- **Palliyaguru et al. 2021 (SLAM).**
  - Citation: Palliyaguru DL, Vieira Ligo Teixeira C, Duregon E, di Germanio C, Alfaras I, Mitchell SJ, Navas-Enamorado I, Shiroma EJ, Studenski S, Bernier M, Camandola S, Price NL, Ferrucci L, de Cabo R. Study of Longitudinal Aging in Mice: presentation of experimental techniques. *J Gerontol A* 2021; 76(4):552–560. DOI 10.1093/gerona/glaa285, PMID 33211821, PMCID PMC8011709.
  - 2,800 mice (700 per sex per strain; C57BL/6J and UM-HET3).
  - Body weight, food intake and temperature every 2 weeks; FI every 6 months.
  - No definition of healthspan or morbidity onset.

---

### B3. Status of the candidate list

| Candidate in the brief | Status |
|---|---|
| Mitchell et al. 2016, *Cell Metab* | Verified; core entry 4 |
| Schultz et al. 2020, *Nat Commun* | Verified; core entry 1 (plus publisher correction) |
| Whitehead et al. 2014, *J Gerontol A* | Verified; core entry 5 |
| Rockwood et al. 2017, *Sci Rep* | Verified; core entry 6. The exact title differs from the one first suggested (see the entry). |
| Kane / Howlett mouse FI papers | Verified: Kane 2016 (B1, entry 3) and Kane 2017 (B2c). Others are listed below. |
| Parks et al. 2012 | Verified, with a different year in print: *J Gerontol A* 2012; 67(3):217–227, published online 2011. Authors: Parks RJ, Fares E, Macdonald JK, Ernst MC, Sinal CJ, Rockwood K, Howlett SE. DOI 10.1093/gerona/glr193, PMID 22021390, no PMCID. The first mouse FI (31 variables; FI 0.43 at about 30 months vs 0.08 at about 12 months). |
| Liu et al. 2014 | Verified; title is "Clinically relevant frailty index for mice" (B2c) |
| Ray et al. 2010, *JAALAS* | Verified; core entry 7 |
| Toth 2000, *ILAR J* | Verified: Toth LA. Defining the moribund condition as an experimental endpoint for animal research. *ILAR J* 2000; 41(2):72–79. DOI 10.1093/ilar.41.2.72, PMID 11406700. A review: hypothermia is the most often reported predictor of imminent death; in one rat tumor model, 7–8 consecutive days of loss predicted death better than percent loss; predictors should be validated for each model. It gives no aging-specific guidance. |
| Palliyaguru et al., SLAM | Verified, but the year is 2021, not 2020 (B2c). A related SLAM paper is Martinez-Romero et al. 2024, *Nat Aging*, DOI 10.1038/s43587-024-00728-7, PMID 39424993, a blood-based clock. |
| Bellantuono et al. 2020, *Nat Protoc* | Verified: Bellantuono I, de Cabo R, Ehninger D, Di Germanio C, Lawrie A, Miller J, Mitchell SJ, Navas-Enamorado I, Potter PK, Tchkonia T, Trejo JL, Lamming DW. *Nat Protoc* 2020; 15(2):540–574. DOI 10.1038/s41596-019-0256-1, PMID 31915391, PMCID PMC7002283. A consensus set of healthspan tests (echocardiography, novel object recognition, grip strength, rotarod, glucose and insulin tolerance, body composition, energy expenditure) run over 4–6 weeks. It defines no onset of morbidity. |

#### Other verified Mitchell or MacArthur papers (not core)

- **Mitchell SJ et al. 2019.** Daily fasting improves health and survival in male mice independent of diet composition and calories. *Cell Metab* 29(1):221–228.e3. DOI 10.1016/j.cmet.2018.08.011, PMID 30197301, PMCID PMC6326845. Abstract only: single-meal feeding and CR improved "morbidity and mortality."
- **Mitchell SJ, Mitchell GJ, Mitchell JR 2019.** Modulation of frailty syndrome by diet: a review of evidence from mouse studies. *Mech Ageing Dev* 180:82–88. DOI 10.1016/j.mad.2019.04.003, PMID 30980835. Relevant to chow vs high fat.
- **Ke S, Mitchell SJ, MacArthur MR, et al. 2021.** Gut microbiota predicts healthy late-life aging in male mice. *Nutrients* 13(9):3290. DOI 10.3390/nu13093290, PMID 34579167, PMCID PMC8467910. 15% CR from 21 months slowed the rise in FI.
- **Kane AE et al. 2024** (Mitchell a coauthor; a preprint). Long-term NMN treatment increases lifespan and healthspan in mice in a sex dependent manner. bioRxiv, DOI 10.1101/2024.06.21.599604, PMID 38979132.
- **Arends D, … Mitchell SJ, MacArthur MR, … Williams RW 2026.** Dynamics of genetic and somatic trade-offs in ageing and mortality. *Nature* 654(8118):437–453. DOI 10.1038/s41586-026-10407-9, PMID 42020758, PMCID PMC13253337. This is our own Vita and Soma loci paper; listed only to note that Mitchell and MacArthur are coauthors.

#### Other related papers, verified but not read in full

- **Farrell S, Kane AE, Bisset E, Howlett SE, Rutenberg AD 2022.** *eLife* 11:e77632. DOI 10.7554/eLife.77632, PMID 36409200, PMCID PMC9725749. Rates of damage to and repair of individual deficits. Both fall with age; the loss of robustness (resisting damage) matters more than the loss of repair for the rise in FI and for survival. Relevant to how we treat "recovery."
- **Henderson YO et al. 2023.** A long-term obesogenic high-fat diet in mice partially dampens the anti-frailty benefits of late-life intermittent fasting. *GeroScience* 45(2):1247–1262. DOI 10.1007/s11357-022-00678-1, PMID 36287320, PMCID PMC9886776.

---

### B4. Synthesis

**How the literature marks the start of a morbid phase.** Four families recur:

1. **Frailty-index cutoffs:** relative to the cohort (FI ≥ 0.18, Kane 2017) or near the end (euthanasia at FI 0.50–0.54).
2. **Fried-style phenotypes:** frail when 3 of 4 measures fall 1.5 SD below the cohort mean (Liu 2014).
3. **Weight rules tied to each mouse's own baseline:**
   - below 95% of a stable baseline (Trammell, Toth);
   - temperature × weight below 90% (Ray);
   - more than 10% lost within a month (Schultz);
   - peak weight as onset, 10% below peak as "early disease" (ALS mice);
   - more than 20% lost within a week (humane endpoint).
4. **No threshold:** FAMY and AFRAID.

Zhu 2026 shows the FI–lifespan relation shifts with strain and sex, so no single cutoff should be assumed to transfer across BXD strains.

**Terminal weight loss.**

- It begins about 10–11 weeks before death in C57BL/6J, builds over 2–3 months in ICR mice, and starts after about 90% of life in weekly-weighed DO females.
- By death it averages 10–15% below stable weight. It is gradual and graded, but about a quarter of C57BL/6J mice die without crossing 95% of baseline.
- Total weight loss was the strongest predictor of remaining life in AFRAID, and FI hazard rises smoothly (HR 1.15 per 0.01 FI). Both fit our graded hazard with no 10% threshold.
- No study models hazard against percent below each mouse's running peak.

**Post-mortem loss.** C57BL/6 carcasses in ventilated cages lost about 0.8% of weight per day at room temperature: 1–2% over 24–48 hours, below our weighing noise.

**Definitions to add:**

1. Thresholds of 5%, 10%, 15% and 20% below the running peak.
2. A smoothed peak (maximum of a 3-point running mean) or a stable-window baseline, because the maximum of noisy weights overstates the plateau.
3. First crossing versus "no later recovery."
4. A per-mouse change point from segmented regression.
5. A rate rule: more than 10% lost between consecutive weighings.
6. Onset by hazard: the first weighing at which our model's predicted hazard exceeds k times the age-matched baseline.
7. Weight-adjusted days: area under weight ÷ peak, with no anchor at death.
8. The last 10% of life, as a comparison.

Weighings are 64 days apart and the last falls a median of 30 days before death, so a decline starting 10 weeks before death often appears at only one weighing. Treat onset as interval-censored.

---

### B5. Notes for our data (reasoning, not from the literature)

- **Peak bias from noise.**
  - If one weighing has an SD of 3–5% of body weight, the largest of the 5–8 weighings taken near the plateau is expected to sit about 1.2–1.4 SD above the true plateau, roughly 4–6%. That figure comes from the expected maximum of normal draws; it is not taken from any paper.
  - In that case "10% below the observed peak" is only about 5–7% below the true plateau.
  - It also means mice weighed more often have higher observed peaks. A smoothed peak or a stable-window baseline (as Ray and Trammell used) removes much of this.
- **The "no later recovery" rule uses the future.** It is fine for describing the data after the fact. It cannot be used as a predictor that changes over time, and it makes the morbid span shorter by moving onset to the last crossing.
- **Masking by tumors or fluid.** Distended abdomen ranked high in AFRAID. A growing tumor or ascites can hide loss of lean tissue, so some "no decline" deaths may be masked declines.
- **High-fat diet.** The FI weight item scores being heavy as a deficit (entries 3 and 5), but peak-relative loss is measured within each mouse. A heavier peak on high fat may mean a larger fall in grams for the same percentage. Comparing diets on percent and on grams lost would show whether the choice of scale matters.

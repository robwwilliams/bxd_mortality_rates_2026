# BXD lifespan mapping: models, reasons and results so far

**Status note, 23 November 2026,** by Claude (Opus 5.5) and Rob Williams, written for colleagues reading this repository: Beni Mozhui, Danny Arends, Suheeta Roy, Pjotr Prins, Evan Williams. Reviewed by Rob, evening 23Nov, morning 24Nov. All of the mapping is "exploratory" but probably more than good enough for bioRxiv.

**Where the work lives.**
- **The maps** are made in Rob's fork of Danny Arends's code, [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan). Danny's files are unchanged there. The added scripts, the draft [Methods](https://github.com/robwwilliams/BxDLifeSpan/blob/master/Methods_draft.md) and the draft [figure legends](https://github.com/robwwilliams/BxDLifeSpan/blob/master/Figure_legends.md) are listed in its [README](https://github.com/robwwilliams/BxDLifeSpan/blob/master/README.md).
- **The long permutation job** for the individual-mouse maps runs from this repository ([`QTL/`](../QTL/README.md)) on ATHENA, a MacStudio M5 Max, through Squirm, our informal three-machine version of SLURM ([`tools/squirm/`](../tools/squirm/README.md)).
- **The Gompertz analyses** that motivate the maps are in this repository ([README](../README.md) and the [report](Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md)).

## Key findings for the Results (start here)

*A one-page guide for coauthors, added on 24 November 2026. Rob: "we could add more guidance at the top of the document about WHAT ARE THE KEY FINDINGS worth emphasis in the Results." The order is the one Rob described, from the themes Beni suggested. Everything is exploratory unless marked as planned. The unit is the strain or F1 type unless stated. All F1 numbers use Suheeta Roy's table of 24 November 2026 (319 F1 mice; ear tags 3694 and 4520 left out until Casey's records are checked, and including them changes nothing below).*

### 1. Mortality: the Gompertz analysis

1. **High fat raises mortality, and within strains it also steepens its rise** (exploratory). Within strains, mortality at 600 days is about 1.8-fold higher on high fat, the MRDT falls from 117 to 91 days, and strains differ in their response (P = 0.0002). Pooled over strains the MRDTs look equal (153 and 149 days), because mixing strains flattens the curves.
2. **Proximal Chr 1 changes the level of mortality, not its doubling time** (planned test; MRDT ratio 1.10, 95% CI 0.80–1.51, P = 0.57). At 600 days, strains that are *B* across proximal Chr 1 die at twice the rate of *D* strains on high fat, and at 1.25 times the rate on chow (these level ratios are descriptive).
3. **Heterosis: hybrids of short-lived strains gain the most.** Short × short F1s outlive the mean of their parents by 212 days on chow and 145 on high fat; long × long F1s by 52 and 60. At 600 days on chow, short × short F1s die at a quarter of their parents' rate (1.3 against 5.4 per 1,000 mouse-days). Their mortality then rises faster (MRDT 98 against 156 days; ratio 0.63, 95% CI 0.49–0.81), so the gain narrows with age. Long × long F1s match their parents' slope (0.96, 0.72–1.27).
   - *Caution:* part of the pooled F1 result (MRDT ratio 0.65) is mixture. With a level for each genotype it is 0.78 (0.61–1.01). The short × short result survives that check (0.60, 0.44–0.82).

*Figures:* [Fig. 7](../output/Fig7_Hazard_by_class_F1_24Nov2026.png) (hazard by class) and [Fig. 6](../output/Fig6_MRDT_ratios_F1_24Nov2026.png) (MRDT ratios). *Detail:* [MRDT_secondary_results.md](MRDT_secondary_results.md), [report](Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md).

### 2. Mapping, from main effects to locus by diet

4. **Chow: Chr 1 near 5 Mb (Vita1a), *D* lives longer.** −log10 *P* 6.26 with strain means and 6.71 with the F1s (T770), above the genome-wide threshold for any T-age (5.5 and 5.8). It also passes in individual mice without F1s (4.74 against 4.62) and when all T-ages are combined (5.30 against 4.68). *D* is favored at every T-age and on both diets.
5. **Chow: Chr 9 at 107 Mb, *B* lives longer** (4.83 at T680; single-T-age threshold only).
6. **High fat: Chr 1 at 23.5 Mb (Vita1b) and near 36–38 Mb (Vita1y), *D* lives longer** (4.82 at T20; 5.41 at T500; single-T-age threshold). **Chr 2 at 157 Mb, *B* lives longer** (4.85 without F1s; P < 0.10 with them).
7. **Locus by diet: the *D* advantage on proximal Chr 1 is larger on high fat** (new; [`QTL/vita1_by_diet.R`](../QTL/vita1_by_diet.R), 2,065 mice including 319 F1s, strains and F1 types permuted). Lifespan gain of *DD* over *BB*, in days, all mice (T20):

   | Locus | Chow | High fat | Difference | P (strains permuted) |
   |---|---|---|---|---|
   | Vita1a, 5.0 Mb | 27 ± 22 | 53 ± 22 | 27 ± 16 | 0.21 (0.007 at T500) |
   | Vita1b, 23.5 Mb | 41 ± 21 | 92 ± 21 | 51 ± 16 | 0.010 |
   | Vita1y, 35.7 Mb | 14 ± 21 | 79 ± 21 | 65 ± 16 | 0.002 |

   This agrees with finding 2, which comes from mortality rates.
   - *Cautions:* Vita1b and Vita1y were chosen on high fat, which biases their difference upward. The three loci are linked, so these are not three independent results. P values are pointwise. Genome-wide, no interaction peak in panel **f** passes: the largest, 5.3 at T50, is below the 5% level of the maps without F1s (6.3 at T20). Thresholds with F1s are queued.

*Figure:* [Fig. 2](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/maps/Figure2_lifespan_F1.png).

### 3a. Fine mapping Vita1a and Vita1b in BXD

8. **Vita1a on chow lies in a 0.5 Mb block, 4.86–5.32 Mb,** holding the start of *Tcea1*, *Rgs20* and *Atp6v1h*. The 11 kb LTR in intron 1 of *Atp6v1h*, carried, as far as Rob knows, only by the *D* haplotype, is inside it. *Mrpl15* and *Rb1cc1*, two of the three candidates in Arends et al. 2026, are outside.
   - **The F1s narrow the 1.5-LOD interval from 4.9–10.4 to 4.9–5.5 Mb, but by a small margin.** The 5.5–10.4 Mb plateau is just below the cut, and without the one cross BXD73b×77 the interval is 4.9–10.4 Mb again. Suggested wording: "the F1s strengthen the peak and favor the proximal block."
   - Only one strain with lifespans, BXD79, has a crossover inside the block. F1s of BXD79 with BXD65 and with BXD77 or BXD102 could split it.
9. **High fat: the signal spans 22–39 Mb and may be one locus or two.** Peaks are at 23.5 Mb (interval 22.4–25.4) early in life and 37.6 Mb (32.3–38.7) at T500. A second locus never adds more than chance (P ≥ 0.077). The F1s move the weight toward 36–38 Mb but narrow neither peak.

*Figures:* [Chr 1 profiles](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/maps/Chr1_zoom_profiles.png), [two-locus scan](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/maps/Chr1_twolocus.png), [Vita1a close-up](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/maps/Vita1a_zoom.png).

### 3b. What UM-HET3 adds

10. **Vita1a has the opposite sign in UM-HET3 (paternal *H* better than *D*), and one allelic series explains both families:** *H* > *D* > *B* ≈ *C* at Vita1a and Vita1b at every life stage, if effects are additive and shared. Vita1y differs (*D* best).
11. **The flat UM-HET3 maternal map at Vita1a points to variants private to C3H** as the source of the reversal; 363 of the block's 485 C3H-private sites lie in *Rgs20*. A D-private variant, such as the LTR, cannot by itself explain both signs.
12. **Distal Chr 2 is probably several loci** (BXD 124–129 and 154–157 Mb; UM-HET3 females 144–153 Mb).
    - *Cautions:* UM-HET3 genotypes on proximal Chr 1 are faulty at two of three sites (biased toward *H*), there are 891 markers, and there is no *BB* or *DD* in UM-HET3.

*Detail:* [founder variants](Vita1a_founder_variants_2026-11-24.md), [founder effects and NAM](Vita1_Vita2_founder_effects_and_NAM_2026-11-24.md).

### 4. Body weight and CTL

13. **Weight predicts survival weakly from mid-life, and strongly from recent change.** Latent classes from weights before 365 days predict survival (P = 0.004, clustered by strain), but concordance is 0.539, no better than one weight. At 18 months, recent change predicts death and size does not.
14. **Terminal weight loss marks about the last three months,** and short × short F1s postpone it rather than lengthen it. These analyses still use the December 2024 F1 table.
15. **CTL maps: preliminary.** Danny's models, with no kinship and no genome-wide thresholds. They need the same treatment as Fig. 2 before they carry a claim in the Results. Left to Danny (Rob, 24 November 2026). His P values use the numbers of mice as sample sizes, so a permutation of whole strains is what would show how strong the map is.
    - *The correlation behind it changes sign gradually* (added in the evening; [`weight_lifespan_sign.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/weight_lifespan_sign.R)). The draft legend put the change at about 290 days on high fat, which was wrong: 290 was the last age at which it was mostly negative. Rob: "That is about 150 days earlier than I would have guessed based on Arends et al. and UM-HET3 data." Among mice of the same strain on high fat, it crosses zero at about 425 days and is clearly positive from T560 (+0.12, 95% CI 0.02–0.20, rising to +0.34 at T650). Leaving out mice within 100 days of death moves the crossing to about 535 days and more than halves the late correlation (+0.13 at T650), so wasting in mice near death explains much of it, though not clearly all. On chow the within-strain correlation is weak throughout (−0.09 to +0.11), and its late rise (T650) vanishes without the mice near death.

### 5. Open slot: candidates for the authors to choose

- **Heterosis as its own section** (the F1s' gain, its shape with age, and no detectable dominance locus). Claude's suggestion: it is the most distinctive BXD × BXD result, and it uses the F1s throughout.
- **Nicotinamide by Vita1 genotype.** The direction matches the grant's pilot data, but across seven ways of testing at the strain level P runs from 0.01 to 0.8, and the NAM mice are not matched to controls by birth year.
- **Candidate genes and variants** for Vita1a (long reads, pangenome), if they arrive in time.

### What each result can carry

| Use in the text | Findings |
|---|---|
| Lead with these: genome-wide, planned, or robust to the checks | 1, 2, 4, heterosis in short × short F1s (3) |
| Report with the stated caution | 5, 6, 7, 8, 9, 10 |
| Discussion or Extended Data, as leads for experiments | 11, 12, 13, 14, 15, nicotinamide |

**Not done yet:** thresholds for individual-mouse maps with the new F1 table; body weights of the new F1 table through our QC; ear tags 3694 and 4520, and 15 mismatches with GeneNetwork ([`F1_GN_check_24Nov2026.txt`](../qc/F1_GN_check_24Nov2026.txt)) with Suheeta and Casey.

---

## Where each part stands

| Part | Figure | Status |
|---|---|---|
| **Fig. 2 as Rob laid it out on 23 November 2026, with the F1s (next section)** | Fig. 2a–f | **Maps done.** Thresholds done for **a**,**b**; for **c**–**f**, 1,000 permutations queued on ATHENA as 18 jobs |
| Strain-mean maps without F1s, chow and high fat, with genome-wide thresholds | Extended Data | **Near final:** 1,000 permutations; the loci that pass are listed below |
| The same maps under other weightings of strain means | Methods | **Near final:** a robustness check |
| Individual-mouse maps without F1s: chow, high fat, both diets, genotype × diet | Extended Data | **Done:** thresholds from 200 permutations on ATHENA; one locus passes |
| **Strain and F1 means together, with zooms of proximal Chr 1 (first section below)** | not yet placed | **Preliminary:** maps, support intervals, a leave-one-F1-out check, thresholds from 1,000 permutations and a two-locus scan of high-fat Chr 1, all done |
| F1 heterosis by cross type | not yet placed | **Preliminary,** descriptive |
| Body weight and correlated trait locus (CTL) maps | Fig. 3 | **Preliminary:** Danny's models, no thresholds |
| Combining T-ages by the Cauchy method, as in Arends et al. 2026 | Methods | **Done for strain means** with and without F1s (1,000 permutations); for individual mice, recorded by the queued ATHENA jobs |
| BXD loci tested in UM-HET3 females | — | **Draft plan** awaiting Rob's approval ([PLAN_BXD_UMHET3_concordance.md](PLAN_BXD_UMHET3_concordance.md)) |

## Fig. 2, with the F1 hybrids

Rob, 23 November 2026: "Let's have Fig 2 (T-age mappings) include a. strain means with F1s separately for both diets (first dyad); b. individuals with F1s stratified by CD and HFD (second dyad); c. individuals with F1s, all combined, all cofactors, main effect only; d. individuals all combined, diet x locus interaction effect only (QUESTION if F1s should be included?)". His dyads are panels **a**,**b** and **c**,**d** below; his c and d are **e** and **f**.

[![Fig. 2 with the F1s](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Figure2_lifespan_F1.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Figure2_lifespan_F1.png)

**How the individual-mouse panels add the F1s** ([`qtl2_individualsF1.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/qtl2_individualsF1.R)): 319 F1 mice join the 1,746 BXD mice. Each takes its F1 type's genotype probabilities (from both parents) and kinship. F1 class is a covariate in every panel and F1 class × diet in **e** and **f**. The F1s were born in 2020–2022 and housed at TSRB (Rob); the F1 class terms absorb anything they share, so their vivarium coding does not change the fit.

**Results so far:**
- **Adding the F1 mice changes the individual maps little** (correlation over markers and T-ages with the maps without F1s: 0.99 for chow and both diets, 0.98 for high fat). The chow Chr 1 peak near 5 Mb rises from 4.74 to 5.38 at T770. The F1 table of 24 November 2026 changes these maps very little (r = 0.997–1.000 with the December 2024 table; [`compare_F1_update.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/compare_F1_update.txt)).
- **Panel f, the interaction, changes most** (correlation 0.96). With F1s, several peaks rise: Chr 11 at 108 Mb from 4.2 to 5.3 (T50), Chr 1 at 35 Mb from 4.4 to 5.0 (T20), Chr 17 at 68 Mb from 4.4 to 5.2 (T440), Chr 12 at 56 Mb from 3.3 to 4.2. Whether to keep the F1s in **f** is best decided when their thresholds are back: the thresholds without F1s are 6.3 at T20 for one T-age (7.5 for any), above all of these. The two versions are side by side in [`Figure2_lifespan_F1_int_without_F1s.png`](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Figure2_lifespan_F1_int_without_F1s.png).
- **Thresholds for c–f:** 1,000 permutations of strains within epochs and F1 types within class, queued on ATHENA as 18 Squirm jobs (`squirm/bxd_individualsF1_perms_a` to `_r`), about two weeks of ATHENA time in all, around its own work. The first 200 come back first, from jobs a and b. Rob asked for 1,000 because with 200 the 5% threshold has a standard error of about 0.18, larger than the margin (0.12) by which chow Chr 1 passes without F1s. Checked on Metis first: the job reproduces the maps to 4 decimals. **These jobs use the December 2024 F1 table (308 F1 mice),** so their thresholds will be approximate for the maps above, which use the table of 24 November 2026 (319).

## UM-HET3 maps drawn like the BXD maps (exploratory, 24 November 2026)

Rob: "The fun next thing is to make corresponding figures (exact) for the UM-HET3 to the extent that this is possible so that we can evaluate location and effects of loci." UM-HET3 mice are *C* or *B* from their mothers and *H* or *D* from their fathers; none is *BB* or *DD*, so UM-HET3 has no *D* − *B* contrast. Of the two designs discussed, Rob chose the simpler: "Yeh, let's do only option 1 for now." The true *D* − *B* comparison will come from pangenomic mapping of the BXDs ([PLAN_BXD_UMHET3_concordance.md](PLAN_BXD_UMHET3_concordance.md)).

**What the maps are** ([`umhet3_maps.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/umhet3_maps.R)): the mice and 891 markers of Arends et al. 2026, one sex at a time.
- **Two maps per sex, each on 1 d.f.:** maternal, *B* against *C*; and paternal, *D* against *H*. The model is Danny's: age at death ~ site + cohort + treatment + dosage, without kinship.
- **Colors keep their BXD meaning:** warm where *D* lives longer, cool where *B* does, and gray where *C* or *H* does.
- **A wider scale, to >8** (Rob: "We will need more dynamic range on the P value colors"). The first four bins are the BXD maps', so the two families read alike up to 5.
- **The X:** a female's paternal X is always *H*, and a male has no paternal X, so only the maternal X is mapped.
- **Thresholds** come from 1,000 permutations of lifespans within site. At 5% for one T-age they are about 3.5 (maternal) and 3.3–3.5 (paternal); for any T-age to T770, 4.1–4.5. They are lower than the BXD thresholds because the mouse, not the strain, is the unit in UM-HET3, and 891 markers are fewer tests.

**Rows matched to the BXD rows** (Rob: "perhaps some kind of percentage normalization would be best so that the plots can be laid over each other"). Each page has 25 rows that sit where the BXD maps' rows sit, at matched UM-HET3 T-ages:

| BXD row | Linear stretch (UM-HET3 T1100 at BXD T770) | Ratio of median lifespans, × 1.32 | 40-day grid, × 1.33 (drawn) | Same fraction alive (BXD females on chow) |
|---|---|---|---|---|
| T50 | T71 | T66 | T45 | T51 |
| T290 | T414 | T384 | T365 | T616 |
| T530 | T757 | T701 | T685 | T786 |
| T770 | T1100 | T1019 | T1005 | T982 |

Matching by fraction alive squeezes UM-HET3's early life, because BXD mice die earlier in life than UM-HET3 mice (6% of BXD females on chow are dead by T290). The median ratio keeps the stretch linear and anchors it at mid-life. **The rows drawn are a 40-day grid, T45 to T1005** (Rob: "I like your 40-day step size idea"): nearly the median ratio, with round T-ages that include T365 and T725, as Arends et al.'s 15-day grid does. The linear stretch is the T50–T1100 page.

[![UM-HET3 females, rows matched to the BXD rows](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/UMHET3_female_rows_matched_grid40.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/UMHET3_female_rows_matched_grid40.png)

**Females, loci that pass 5% at one T-age** ([`umhet3_thresholds_female.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/umhet3_thresholds_female.txt)):
- **Paternal:** Chr 2 at 144.5 Mb, *H* longer (8.8 at T320, passing from T20 to T860); Chr 1 at 3.0 Mb, *H* longer (3.7 at T590). The Chr 1 result is opposite in sign to the BXD locus, as Rob and Danny expected for Vita1a, and the paternal calls there are biased toward *H* at UM and UT. The reversal holds across life in both families: the UM-HET3 paternal *D* is disfavored at every T-age from T20 to T860 (−log10 *P* 2.1–3.2 at 3.0 Mb), and the BXD *D* is favored at every T-age on chow and high fat (0.5–2.7 at 5.02 Mb). Rob: "It is clear that Vita1a is the same beast in both UM-HET3 and BXDs (as it should be from first principles). But the effect reversal is both a puzzle and a WONDERFUL functional clue."
- **Maternal:** Chr 9 at 34.9 Mb, *C* longer (5.9 at T80); Chr 18 at 74.3 Mb, *C* longer (4.4); Chr 5 at 142 Mb, *B* longer (3.7 at T590); Chr 11 at 89 Mb, *B* longer (3.5 at T860).

**Males** ([`umhet3_thresholds_male.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/umhet3_thresholds_male.txt)) differ, as in Arends et al.: the strongest are maternal Chr 4 at 52.5 Mb, *B* longer (7.3 at T650), and paternal Chr 2 at 89 Mb, *D* longer (5.7), and Chr 1 at 3.0 Mb, *H* longer (5.5 at T800).

Rob, on genotype × diet: "The strong Chr 2 loci we see in the BXD interaction panel f, do resonate with the crazy interaction effects in the UM-HET3s in almost the same locations."

**Vita1a's sign reversal, read from founder sequence:** see [Vita1a_founder_variants_2026-11-24.md](Vita1a_founder_variants_2026-11-24.md). In short: a variant only DBA/2J carries (such as the *Atp6v1h* LTR) cannot give opposite signs by itself; with additive effects the alleles must rank *H* > *D* > *B*. The flat UM-HET3 maternal map at Vita1a points to C3H-private variants, which BXD cannot see, as the source of the reversal; 363 of the 485 C3H-private sites in the BXD block lie in *Rgs20*.

**Founder effects from both families, and NAM by Vita1 genotype:** see [Vita1_Vita2_founder_effects_and_NAM_2026-11-24.md](Vita1_Vita2_founder_effects_and_NAM_2026-11-24.md). At Vita1a and Vita1b the founder alleles rank *H* > *D* > *B* ≈ *C* at every life stage; Vita1y differs (*D* best). NAM helps *B* strains about 100–120 days more than *D* strains at Vita1a and Vita1b, as the grant reports, but with the strain as the unit P = 0.24 and 0.14.

**Distal Chr 2 is probably several loci.** Rob: "It seems likely that Chr 2 is going to be a set of loci and sets of DNA variants." Three signals so far, each where the *D* allele shortens life or the *B* allele lengthens it:
- **124–129 Mb, BXD (2013):** the lifespan locus that led to *Mrps5* (Houtkooper et al. 2013, *Nature* 497:451; LOD 4.0), the work that funded this mapping.
- **144–153 Mb, UM-HET3 females:** the paternal peak, *H* longer (8.8 at T320).
- **154–157 Mb, BXD (2026):** high fat, *B* longer (4.9 at T260); Rob labels its core Vita2b.

UM-HET3 has about one marker per 2.4 Mb on Chr 2, so these can be one, two or three loci.

**Not yet:** maps laid directly over Fig. 2, and the combination across families (Rob: "we are also eventually going to want to run Fisher combined –logP for these two independent families") after the BXD loci are frozen.

## The F1 hybrids: sharper loci on proximal Chr 1 (preliminary)

*Numbers updated on 24 November 2026 with Suheeta Roy's new F1 table (319 F1 mice that died naturally; 308 before).*

*Added on 23 November 2026, at Rob's request:* "That is of greatest interest to me in improving confidence of loci and narrowing 1.5 LOD (or –logP) of the support interval. ... the maps need to be compared to excluding the F1s. Need zoom-in versions of the proximal 50 Mb of Chr 1." *The thresholds and the two-locus scan were added later the same evening, at Rob's go-ahead.*

**In brief:**
- **Chow, Chr 1 near 5 Mb, T770:** significant with and without the F1s, and the F1s raise it (6.26 to 6.71) and narrow its 1.5-LOD interval from 4.9–10.4 Mb to 4.9–5.5 Mb. The narrowing is a close call, and it rests on the long × long F1s, above all BXD73b×77. The peak itself is a flat block from 4.86 to 5.32 Mb holding *Tcea1*, *Rgs20* and *Atp6v1h*; only BXD79, which dies young on chow, has a crossover inside it.
- **High fat, proximal Chr 1:** significant at T20 (23.5 Mb) and at T500 (37.6 Mb, where the F1s raise the peak from 4.74 to 5.41). Whether that is one locus or two, the data cannot yet say: a second locus never adds more than chance would.
- **Dominance:** no locus passes the threshold for any T-age.

**Why the F1s.** Rob chose 13 BXD × BXD F1 types: 6 short × short and 7 long × long crosses some of whose BXD parents have recombinations over different stretches of proximal Chr 1 (panel e of the profiles below). Two aims:
- **Sharper positions.** An F1 heterozygous over one stretch and not the next adds the contrast that a recombination between those stretches gives, like an F2. Rob: "They are genetically just like an F2 cross."
- **Dominance.** Only heterozygotes can show it, and the inbred strains have none.

**How they are mapped** (`qtl2_strainF1.R`):
- **Units:** each F1 type is one unit, like a strain: the mean age at death of its mice alive at the T-age, with at least 3 such mice, and every unit weighted equally.
- **Genotypes:** each F1 takes its genotype probabilities from both parents, so where its parents differ it carries one *D* allele.
- **Model:** kinship (LOCO) is computed over strains and F1s together. F1 class (inbred, short × short, long × long) is a cofactor, so that the average hybrid vigor of a class is not read as an effect of every marker. Rob: "the two types of F1 were by design, so just add the 'type' as a cofactor."
- **Numbers:** the F1s add 13 units to the 93 strains at T50 on chow and the 87 on high fat. On chow all 13 F1 types still have at least 3 mice alive at T770, beside 46 strains. On high fat 6 remain at T770, beside 14 strains.

**Genome-wide thresholds** (`qtl2_strainF1_perm.R`): 1,000 permutations in which each strain takes the whole actuarial series of another strain, as for the strain means, and each F1 type that of another F1 type of its own class. So the class covariate and the nesting of survivorships are kept. The same rule as for the strain means sets a stable range of T-ages.

| Map | Stable range | 5%, one T-age (any T-age) | 10% | Suggestive, P = 0.63 |
|---|---|---|---|---|
| Chow, additive | T20–T740 | 4.67 (5.82) | 4.31 (5.40) | 3.15 (4.24) |
| High fat, additive | T20–T590 | 4.59 (5.46) | 4.21 (5.09) | 3.07 (3.93) |
| Chow, dominance | T20–T500 | 1.20 (1.58) | 1.11 (1.44) | 0.82 (1.08) |
| High fat, dominance | T20–T500 | 1.87 (2.54) | 1.75 (2.44) | 1.25 (1.71) |

- **The additive thresholds are a little higher than those of the strain means alone** (4.67 and 4.59 against 4.43): the F1s add 13 units and a covariate.
- **The dominance thresholds are far below what a test on 1 d.f. would suggest.** Only the 13 F1 types inform dominance, so its −log10 *P* values cannot be read on the usual scale; only the permutation thresholds count.

**The support interval** (`chr1_zoom.R`) is the run of neighboring markers whose LOD is within 1.5 of the peak's. At these peaks a drop of 1.5 LOD is a drop of about 1.6 on the −log10 *P* scale. A 1.5-LOD interval is a rough guide, not a confidence interval, and it assumes one locus in the region.

### Genome-wide, the F1s change little

[![Strain means alone and with the F1s, genome-wide](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Strain_and_F1_means.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Strain_and_F1_means.png)

Panels **a** and **d** are the strain-mean maps of Fig. 2a,b. Panels **b** and **e** add the F1s (additive effect). Panels **c** and **f** are the dominance deviations, which only the F1s inform.
- **The additive maps keep the same loci,** with one change in level (`significant_loci_F1.txt` against `significant_loci.txt`):

  | Locus | Strains alone | Strains + F1s |
  |---|---|---|
  | Chow, Chr 1 at 5.0 Mb (*D*) | 6.26 at T770, significant for any T-age | 6.71 at T770, significant (see below) |
  | Chow, Chr 9 at 107 Mb (*B*) | 4.47 at T680, significant | 4.83 at T680, significant |
  | High fat, Chr 1 at 23.5 Mb (*D*) | 5.01 at T20; significant T20–T110 | 4.82 at T20; significant at T20 |
  | High fat, Chr 1 at 37.6 Mb (*D*) | 4.74 at T500, significant | 5.41 at T500, significant |
  | High fat, Chr 2 at 157 Mb (*B*) | 4.85 at T260; significant T20–T260 | 4.34 at T200; P < 0.10 only |

  No locus passes for any T-age within the stable ranges. Chow T770 lies just past the chow stable range of the strain + F1 maps (its 5% threshold, 4.24, is 0.43 below the median), but 6.71 is above even the strictest threshold of that range, 5.82 for any T-age.
- **Dominance: nothing on chow.** No marker passes at any T-age in the stable range; the largest, 1.04 at T380, is below that T-age's threshold (1.27).
- **Dominance on high fat: one pattern, probably not loci.** The strongest marker on each of 10 chromosomes passes the single-T-age threshold, all at the same T-ages (T20–T200, T350 or T440), and all with heterozygotes below the midpoint of the homozygotes. None passes for any T-age (largest 2.45 against 2.54). Ten chromosomes at once, on the same T-ages and in the same direction, point to the 13 F1 types as a group rather than to 10 loci. A likely cause: the permutation gives each F1 type the lifespans of another, which breaks each F1's resemblance to its own parents, so for dominance the permutation null may be too lenient. Not tested.

### Proximal Chr 1, 0 to 50 Mb

[![Chr 1, 0 to 50 Mb: profiles with and without the F1s](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_zoom_profiles.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_zoom_profiles.png)

*Profiles at the T-ages where Chr 1 is strongest: grey, strain means alone; green, strain and F1 means together (additive). Bars under each profile are the 1.5-LOD support intervals. Dashed lines are each map's genome-wide 5% threshold for that T-age, from its own permutations. **e**, where each F1 type's parents differ, that is, where the F1 is heterozygous.*

**Chow, T770: the F1s narrow the interval from 5.6 Mb to 0.7 Mb.**
- **Strains alone:** peak at 5.0 Mb (−log10 *P* 6.26), interval 4.9–10.4 Mb.
- **With the F1s:** the same peak (6.71), interval 4.9–5.5 Mb.
- **What moves the edge:** a plateau from 5.5 to 10.4 Mb. With strains alone it lies just within 1.5 LOD of the peak (−log10 *P* 4.8 against a cut of 4.7). The F1s raise both, the peak to 6.71 and the plateau to 4.97, which leaves the plateau just below the cut (about 5.1). So the narrowing is a close call: a few more or fewer F1 deaths could move the plateau across the line.
- **It hangs mostly on BXD73b×77,** which is heterozygous from 5.5 to 39.6 Mb but not in the block. Leave it out and the interval returns to 4.9–10.4 Mb. Leave out any other one F1 type and it stays at 4.9–5.5 Mb (`chr1_f1_dropone.R`). With the December 2024 table, no single type mattered.
- **It comes from the long × long F1s as a group.** Leave out all 7 and the interval returns to 4.9–10.4 Mb. Leave out the 6 short × short F1s and it stays at 4.9–5.5 Mb. Several long × long types are heterozygous on one side of 5.5 Mb and not the other (panel e).
- **Defined at T770, present throughout.** The locus passes a genome-wide threshold only at T770, but the *D* allele is favored at the 5.02 Mb marker at every T-age, on chow and on high fat (−log10 *P* 0.5–2.7). Rob: "when you say 'only at T770' you are imposing the threshold correctly to define the locus, but that does not mean the locus 'disappears' at younger ages. Once the locus is defined, then the testing burden is reduced." The sharpest interval comes from T770, from the 46 strains and 13 F1 types still alive then; from T680 to T740 the intervals span 8.5–12 Mb. Rob: "Any map at T770 is going to be iffy given the low sample size."
- **The peak is a flat block, not a point.** Every marker from 4.86 to 5.32 Mb has the same genotypes in all the strains and F1 types mapped at T770, so all give the same −log10 *P* (6.26 alone, 6.71 with F1s). "5.0 Mb" is just the first marker of the block. The data cannot place the locus within it.
- **What the block holds** (mm10, RefSeq): the start of *Tcea1* (4.86–4.90 Mb), *Rgs20* (4.91–5.07) and *Atp6v1h* (5.08–5.16). Just outside are *Lypla1* and *Mrpl15* (proximal, ending at 4.85 and 4.79 Mb), and *Oprk1* (distal, from 5.59 Mb). Of the three Vita1a candidates named in Arends et al. 2026 (*Mrpl15*, *Atp6v1h*, *Rb1cc1*), only *Atp6v1h* lies in the block, and *Rb1cc1* (6.21 Mb) lies outside the whole interval. The BXD chow locus and Vita1a in UM-HET3 need not be the same variant.
- **Which strains set the edges** (`chr1_recombinants.R`): proximally, BXD65, BXD102 and BXD43 switch between 4.858 and 4.861 Mb, inside the start of *Tcea1*; distally, BXD11 switches at 5.316 Mb, beyond *Atp6v1h*.

**High fat: peaks near 23.5 and 37.6 Mb, and the F1s shift the weight toward the second.**
- **T20 to T230:** the peak is at 23.5 Mb, with an interval of 22.4–25.5 Mb, with or without the F1s. Leaving out any F1 type, or either class, does not change it.
- **From T260 on, with the F1s, the peak moves to 32–38 Mb** at most T-ages up to T650. With strains alone it is there only at T500, T590 and T620.
- **T500 is the strongest:** 37.6 Mb, −log10 *P* 5.41 with the F1s (4.74 without). The interval is 34.4–38.7 Mb with strains alone and 32.3–38.7 Mb with the F1s; without several single F1 types it is again 34.4–38.7 Mb. So here the F1s strengthen the peak but do not narrow it.
- **Against the thresholds:** with the F1s, Chr 1 passes at T20 (23.5 Mb, 4.82 against 4.62) and at T500 (37.6 Mb, 5.41 against 4.51).
- **The single peak marker at 37.63 Mb (rs32180312) is called heterozygous in 19 strains,** against 11 at its neighbors, so its exact position should not be trusted. Markers from 35.7 to 37.6 Mb come close to it (about 5.1–5.3 with the F1s). The stretch from 35.7 to 38.0 Mb holds 37 RefSeq genes.
- **Rob, on this locus:** "I agree that there is likely to be a locus distal to Vita1b at about 35–37 Mb. We have noted that for several years but not look at the interval closely. We do not see this locus in the UM-HET3 so it was been less of a priority. ... But T500 is fine."
- **At almost every high-fat T-age, markers in the other region also come within 1.5 LOD of the peak.** So an interval that assumes one locus does not fit here, and we ran a two-locus scan.

**One locus or two on high fat** (`chr1_twolocus.R`). At each T-age from T20 to T620, every pair of positions in 0–50 Mb was fitted together, in the same mixed model as the maps (it reproduces their single-locus LODs exactly).
- **The test:** LOD(2 v 1), the best pair against the best single locus. Its P comes from 1,000 parametric bootstraps under the best single locus: traits simulated with one locus, each put through the same search for one locus and for a pair.
- **The best pair is near 23.5 and 37.6 Mb at most T-ages** (32 of the 42 scans), and it adds 0.8–1.9 LOD to the best single locus.
- **That is no more than one locus gives by chance:** P(2 v 1) is 0.08 at best (strains alone, T500) and 0.19–0.74 elsewhere. With the F1s, P is lower at most early T-ages (0.19–0.37 at T20–T230, against 0.40–0.51 without), but never below 0.19.
- **Each position keeps some signal given the other.** Given a locus at 23.5 Mb, the best second locus is at 32–38 Mb at every T-age, adding 0.9–2.6 LOD with strains alone and 1.2–3.3 with the F1s (3.3 at T500). Given 37.6 Mb, the best second locus is near 23 Mb at most T-ages, adding 0.8–2.5 LOD.
- **So the data neither show two loci nor rule them out.** The high-fat signal spans 22–39 Mb. The F1s move it toward 37.6 Mb at later T-ages but do not split it.

[![Chr 1 on high fat: one locus or two](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_twolocus.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_twolocus.png)

*Solid: LOD of one locus. Dashed: LOD of a second locus, given one at 23.5 Mb. Dotted: given one at 37.6 Mb. **g**, P(2 v 1) at every T-age; the dashed line is P = 0.05.*

**The zoomed actuarial maps,** every T-age, with each T-age's support interval as a black bar where its peak reaches −log10 *P* 3:

[![Chr 1, 0 to 50 Mb: zoomed actuarial maps](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_zoom_maps.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_zoom_maps.png)

Files: [`qtl2_strainF1_perm.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/qtl2_strainF1_perm.R) and [`significant_loci_F1.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/significant_loci_F1.R), with [`qtl2_strainF1_perm_thresholds.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/qtl2_strainF1_perm_thresholds.txt) and [`significant_loci_F1.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/significant_loci_F1.txt); [`chr1_twolocus.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/chr1_twolocus.R), with [`chr1_twolocus.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/chr1_twolocus.txt); [`chr1_zoom.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/chr1_zoom.R), [`chr1_f1_dropone.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/chr1_f1_dropone.R), [`qtl2_strainF1.R`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/qtl2_strainF1.R); intervals at every T-age in [`chr1_zoom_intervals.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/chr1_zoom_intervals.txt); the leave-one-out check in [`chr1_f1_dropone.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/chr1_f1_dropone.txt); where each F1 type is heterozygous in [`strainF1_chr1.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/strainF1_chr1.txt). SVG and PDF versions of the figures are beside the PNGs in [`output/maps/`](https://github.com/robwwilliams/BxDLifeSpan/tree/master/output/maps).

### Strains that could split the intervals

Rob: "Wish we had more BXDs with strategically placed recombinations. Be my guest to look for any you think we should add (although that is a 3 years project ;-)". `chr1_recombinants.R` lists every BXD strain in the genotype file with a B/D switch in either interval, and its numbers of mice with lifespans ([`chr1_recombinants.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/chr1_recombinants.txt)).

**The chow block, 4.86–5.32 Mb (*Tcea1*, *Rgs20*, *Atp6v1h*).** Only two strains have a switch inside it:
- **BXD79** is *D* to about 5.019 Mb and *B* beyond, so it separates *Tcea1* and the start of *Rgs20* from the rest of *Rgs20* and *Atp6v1h*. But it is short-lived on chow (17 mice, mean 417 days; one alive at T680, none at T740), so it cannot inform the T770 map. The crossover itself is well supported: 19 markers call BXD79 *D* from 3.0 to 5.019 Mb, and 22 call it *B* from 5.019 to 6.8 Mb. Only its exact position is in doubt. The file places it between two MUGA markers 60 bp apart (5.019115 and 5.019174 Mb), and BXD79 is the only strain whose calls differ at those two markers, so one of them may be miscalled. Even so, unless more than one marker is wrong, the crossover lies between 5.018 and 5.025 Mb, inside *Rgs20*. Rob suggests long-read sequencing of BXD79 and BXD52 to place both crossovers exactly.
- **BXD52** switches between 4.88 and 5.02 Mb, but it is extinct and has no lifespan data.
- **So the block can be split only through BXD79, and only with F1s, since BXD79 itself dies too young.** A suggestion, not yet discussed: cross BXD79 with a long-lived strain that is *B* across the block (BXD65) and with one that is *D* across it (BXD77 or BXD102). Each F1 would be heterozygous on only one side of 5.02 Mb, so their late survival would ask whether the locus is proximal (*Tcea1*, start of *Rgs20*) or distal (*Atp6v1h*).

**The high-fat interval, 34.4–38.7 Mb.** 19 strains switch in it, many with high-fat lifespans already. Strains with a switch at 35.7–38.2 Mb but no high-fat mice alive at T500 could be added on high fat: BXD83 (switch at 37.58–37.63 Mb; 4 chow, 0 high-fat mice), BXD184 (37.58–38.23; 2 chow, 0 high fat), BXD216 (38.22; 2 chow, 0 high fat), BXD177 (37.58–37.63; 1 high-fat mouse), BXD99 (35.23 and 37.58–37.63; 7 high-fat mice, none alive at T500) and BXD200 (34.95–35.19; 2 high-fat mice). Whether each is still alive in the colony needs checking; the genotype file's extinct list dates from 2016.

### F1 heterosis

F1 mean lifespan minus the mean of its two parental strains:

| Diet | Short × short (6 types) | Long × long (7 types) |
|---|---|---|
| Chow | +212 days (range +129 to +288) | +52 days (+12 to +142) |
| High fat | +145 days (+99 to +240) | +60 days (−9 to +163) |

- **Within each class, F1 types do not differ by more than sampling error** (heterogeneity P = 0.26–0.74).
- **Heterosis does not follow the fraction of the genome that is heterozygous** (40–55% across types). The correlations over F1 types are −0.63 and −0.44 on chow (short × short, long × long), and +0.38 and −0.24 on high fat, each from only 6 or 7 types.

Files: [`f1_heterosis.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/f1_heterosis.txt).

## Why we map this way

**Why map lifespan at all.** The Gompertz analyses here found that genotype and diet both move mortality in BXD females:
- **High fat raises mortality about 1.8-fold at 600 days,** and strains differ in how much (from 2.2-fold in C57BL/6J to 1.0-fold in DBA/2J; P = 0.0002). Within strains it also shortens the mortality rate doubling time, from 117 to 91 days ([report](Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md), Part 1; Beni's own analysis agrees on the direction, [Mozhui_comparison_results.md](Mozhui_comparison_results.md)). Strains that differ in their response to diet point to genotype × diet loci.
- **Proximal Chromosome 1 changes the level of mortality, not its doubling time.** On high fat, strains that are *B* across proximal Chr 1 die at twice the rate of *D* strains at 600 days ([MRDT_secondary_results.md](MRDT_secondary_results.md)). The same region carries Vita1a and Vita1b in UM-HET3 mice (Arends et al. 2026, *Nature* 654:437).
- **Short × short F1 hybrids live much longer than their parents,** which asks whether some loci act through dominance.

**Actuarial (progressive) mapping.** A locus may matter only to mice that reach a certain age. So, as in Arends et al. 2026, each map is a stack of genome scans, one per survivorship: the mice alive at a minimum age (the T-age), from 20 to 770 days in 30-day steps. The trait is age at death within each survivorship. Neighboring survivorships share most of their mice, so the scans are far from independent.

**Kinship, leaving out the chromosome scanned (LOCO).** The BXD strains are not equally related: they come from different breeding epochs and share stretches of ancestry. A mixed model with a kinship matrix keeps that shared background from showing up as peaks. Leaving out the chromosome scanned keeps the kinship from absorbing the locus itself. All of our maps use R/qtl2 (`scan1`) with LOCO kinship; Danny's original maps had none.

**Two ways to use the mice, both kept.**
- **Strain means (Fig. 2a,b).** The trait is the mean age at death of each strain's mice in the survivorship, for strains with at least 3 such mice. Every strain counts once.
  - **Why equal weights:** weighting by numbers of mice, as Danny's first maps did, lets a few strains with many mice drive the map, while the unit of replication is the strain. Weighting by the inverse of each mean's variance is the formal answer, and it gave nearly the same maps as equal weights (*r* = 0.97–0.999 over markers at each T-age; *r* = 0.87–0.97 for weights by numbers of mice). Rob kept equal weights in the figure.
- **Individual mice (Fig. 2c–f).** Each mouse's age at death is the trait, and each takes its strain's genotypes and kinship. Rob: "even better is to simply map the individuals with a full kinship correction."
  - **What this adds:** covariates measured on each mouse (vivarium, and age at set-up in 180-day classes), every mouse rather than strains with at least 3, and a direct test of genotype × diet in one model with both diets.
  - **Four maps:** chow; high fat; both diets, main effect, with diet as a covariate; and the genotype × diet interaction (the likelihood ratio of models with and without the interaction term).

**The strain is the unit of inference, so thresholds come from permuting strains.** About 1,750 mice come from about 120 strains, and the mice of one strain share their genotype at every marker. A test on 1 d.f. that counts mice as independent is too lenient whenever strains differ by more than kinship explains. So genome-wide thresholds come from permutations in which whole strains swap genotypes, and every mouse keeps its own lifespan and covariates.
- **For the strain means,** each strain takes the whole actuarial series of another strain, so the nesting of survivorships is kept.
- **For the individual mice,** each strain takes the genotypes and kinship of another strain within its stratum: Taylor's strains (BXD1 to BXD42) or the newer ones. The two sets were made at different times by different breeding designs, and they differ in how closely their strains are related. Rob: "what are the exchangable units? Do you need a hierarchical permutation? Important not to over-randomize across the intrinsic structure of the cross or the P values will be way too lenient."
- **Levels:** genome-wide P = 0.05 and 0.10, and the suggestive level of Lander & Kruglyak (1995), genome-wide P = 0.63, a peak expected about once per genome scan by chance. Each level is given for a single T-age, and for any marker at any T-age.

**Strains and F1s together.** The 13 BXD × BXD F1 types were chosen as short × short and long × long crosses with recombinations over the proximal 50 Mb of Chr 1. Mapped with the strains, they add heterozygotes, so they can show dominance, and their recombinations can narrow the Chr 1 loci. F1 type (inbred strain, short × short, long × long) is a cofactor, so that the average hybrid vigor of a cross type is not read as dominance at every marker.

## Results

### Strain-mean maps without F1s (Extended Data): near final

**Thresholds, −log10 P for a single T-age (and for any marker at any T-age), from 1,000 permutations of strains:**

| Level | Chow | High fat |
|---|---|---|
| Genome-wide P = 0.05 | 4.4 (5.5) | 4.4 (5.5) |
| Genome-wide P = 0.10 | 4.1 (5.2) | 4.1 (5.0) |
| Suggestive, P = 0.63 | 3.0 (4.0) | 3.0 (3.9) |

- **These thresholds hold only while enough strains remain:** up to T770 on chow (46 strains) and T620 on high fat (60 strains). Beyond T620 on high fat (52 down to 14 strains) the permutation thresholds become unstable, so those rows are shown but not tested.

**Loci that pass at a single T-age (P < 0.05)** (allele that lives longer, peak −log10 P):
- **Chow, Chr 1 at 5.0 Mb, *D*:** 6.3 at T770, which also passes for any T-age, the only locus that does.
- **Chow, Chr 9 at 107 Mb, *B*:** 4.5 at T680.
- **High fat, Chr 1 at 23.5 Mb, *D*:** 5.0 at T20; passes from T20 to T110 and at T500.
- **High fat, Chr 2 at 157.5 Mb, *B*:** 4.9 at T260; passes from T20 to T260.

**Suggestive only:** on chow, Chr 2 at 157 Mb (*B*), Chr 7 at 88 Mb (*B*) and Chr 14 at 49 Mb (*B*); on high fat, Chr 3 at 64 Mb (*D*), Chr 10 at 40 Mb (*D*) and Chr 15 at 14 Mb (*B*).

**In plain terms:** proximal Chr 1 shows up on both diets with the *D* allele living longer, but at different positions and ages. On chow it is defined at T770 at about 5 Mb, though the *D* allele is favored there at every T-age. On high fat it is strongest at early ages at about 23 Mb. Whether those are one locus or two is open, and it is what the F1 maps address.

Files: [`significant_loci.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/significant_loci.txt), [`qtl2_permutation_thresholds.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/qtl2_permutation_thresholds.txt), [`compare_weights.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/compare_weights.txt).

### Individual-mouse maps without F1s (Extended Data): done

**Kinship explains about a third of the variance in age at death** at T20 (33% with both diets, 35% on chow, 38% on high fat), falling to 8–31% from T650 to T770, depending on the map.

**The strongest peaks** (−log10 P, single T-age, not yet judged against a threshold):

| Map | Peaks at or above 4 |
|---|---|
| Chow | Chr 14 at 49 Mb, *B*, 5.1 (T410); Chr 1 at 5 Mb, *D*, 4.7 (T770); Chr 9 at 104 Mb, *B*, 4.4 (T620) |
| High fat | Chr 15 at 13 Mb, *B*, 5.1 (T380); Chr 1 at 23.5 Mb, *D*, 4.3 (T20); Chr 2 at 157 Mb, *B*, 4.3 (T140); Chr 10 at 60 Mb, *D*, 4.2 (T680); Chr 5 at 58 Mb, *D*, 4.1 (T140) |
| Both diets | Chr 13 at 22 Mb, *D*, 4.5 (T590); Chr 15 at 14 Mb, *B*, 4.4 (T380); Chr 9 at 107 Mb, *B*, 4.2 (T620) |
| Genotype × diet | Chr 1 at 35 Mb, 4.4 (T20); Chr 17 at 84 Mb, 4.4 (T440); Chr 4 at 156 Mb, 4.4 (T770); Chr 11 at 108 Mb, 4.2 (T50); Chr 9 at 81 Mb, 4.2 (T560) |

- **They largely repeat the strain-mean loci:** Chr 1 (proximal), Chr 2 at 157 Mb, Chr 9 at 107 Mb, Chr 14 at 49 Mb and Chr 15 at 14 Mb.
- **Against Danny's individual-mouse maps,** which had a random intercept for strain but no kinship, the main-effect maps correlate at *r* = 0.80–0.94 over markers, and the interaction maps at *r* = 0.99 ([`compare_kinship.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/compare_kinship.txt)).

**Thresholds, from 200 permutations on ATHENA** ([`QTL/README.md`](../QTL/README.md); [`significant_loci_ind.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/significant_loci_ind.txt)). The two trial permutations were right: the individual-mouse thresholds are far higher than the strain-mean ones.
- **The 5% threshold for one T-age falls with T-age,** as the survivorships shrink: on chow 5.8 at T20 to 4.6 at T770 (any T-age 6.6); on high fat 5.8 to 4.4 (6.7); both diets 6.0 to 4.6 (7.1); genotype × diet 6.3 to 5.3 (7.5). The strain-mean maps need 4.4.
- **One locus passes:** chow, Chr 1 near 5 Mb, 4.74 at T770 against 4.62, the same locus that the strain means find.
- **Everything else is suggestive at most,** including chow Chr 14 at 49 Mb (5.06 at T410 against 5.78) and high-fat Chr 15 at 13 Mb (5.10 at T380 against 6.01).
- **Why the thresholds are so high:** the mice of a strain share its genotype at every marker and are not independent beyond what kinship explains. A test that counts mice runs high, and only permuting strains shows by how much. This is the reason the strain is the unit of inference.
- **The job:** 200 permutations of strains within strata, at all 26 T-ages and for all four maps ([`QTL/qtl2_individuals_perm.R`](../QTL/qtl2_individuals_perm.R)). On ATHENA (R 4.6.2) it ran 26.5 hours of computing over 33 hours, paused 39 times for ATHENA's own work, and ended cleanly.

### One P per marker over T-ages: the Cauchy combination

As in Arends et al. 2026, but with exact P values on 1 d.f. ([Cauchy_review_2026-11-21.md](Cauchy_review_2026-11-21.md)): at each marker the P values of the T-ages in the stable range are combined into one, and genome-wide thresholds come from 1,000 permutations ([`cauchy_strainmeans.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/cauchy_strainmeans.txt)).

| Map | T-ages | 5% threshold | Loci at least suggestive |
|---|---|---|---|
| Strain means, chow | T20–T770 | 4.44 | **Chr 1 at 5.1 Mb, 4.85 (significant)**; Chr 9 at 107 Mb, 3.42 |
| Strain means, high fat | T20–T620 | 4.41 | Chr 2 at 157.5 Mb, 4.39 (P < 0.10); Chr 1 at 23.5 Mb, 4.29 (P < 0.10) |
| Strains + F1s, chow | T20–T740 | 4.79 | Chr 9 at 107 Mb, 3.69 |
| Strains + F1s, chow | T20–T770 | 4.68 | **Chr 1 at 5.1 Mb, 5.30 (significant)**; Chr 9 at 107 Mb, 3.71 |
| Strains + F1s, high fat | T20–T590 | 4.74 | Chr 1 at 37.6 Mb, 4.21; Chr 2 at 157 Mb, 3.83; Chr 15 at 14 Mb, 3.73 |

- **The combination is conservative for loci that act at only a few T-ages,** as the review predicted: T-ages where a locus does nothing pull the combined P toward 1. So the chow Chr 1 locus, a T770 effect, passes only when T770 is included.
- **For the individual-mouse maps,** the queued ATHENA jobs record the genome-wide maximum of the Cauchy combination in each permutation, so their thresholds come back with the single-T-age ones.

### Strains and F1s together, and F1 heterosis

See the first section above.

### Body weight and CTL maps (Fig. 3): preliminary

These are Danny's maps, redrawn: strain means weighted by numbers of mice, without kinship, and no genome-wide thresholds. The CTL maps ask where the correlation between body weight and lifespan differs between *B* and *D* carriers. They have not yet been redone with the models above.

## What comes next

1. **Thresholds for Fig. 2c–f** from the two ATHENA jobs with F1 mice (single T-age, any T-age and Cauchy); then Rob's choice for panel **f**, with or without F1s.
2. **Cauchy maps for the individual mice,** once those thresholds are back.
3. **For the F1s:** a permutation that keeps each F1 tied to its parents, to check the high-fat dominance pattern; and whether the F1s also sharpen the chow Chr 9 locus at 107 Mb.
4. **Body-weight and CTL maps** with the models above: left to Danny (Rob, 24 November 2026).
5. **BXD loci in UM-HET3 females,** once Rob approves the plan, with the BXD loci fixed before UM-HET3 is looked at.
6. **Legend titles that state findings,** once the thresholds are in.

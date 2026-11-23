# BXD lifespan mapping: models, reasons and results so far

**Status note, 23 November 2026,** by Claude (Opus 5.5) for Rob Williams, written for colleagues reading this repository, Beni Mozhui first among them. Not yet reviewed by Rob. All of the mapping is exploratory: the models were chosen while maps were being looked at, not fixed in a plan beforehand.

**Where the work lives.**
- **The maps** are made in Rob's fork of Danny Arends's code, [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan). Danny's files are unchanged there. The added scripts, the draft [Methods](https://github.com/robwwilliams/BxDLifeSpan/blob/master/Methods_draft.md) and the draft [figure legends](https://github.com/robwwilliams/BxDLifeSpan/blob/master/Figure_legends.md) are listed in its [README](https://github.com/robwwilliams/BxDLifeSpan/blob/master/README.md).
- **The long permutation job** for the individual-mouse maps runs from this repository ([`QTL/`](../QTL/README.md)) on ATHENA, a lab Mac, through Squirm ([`tools/squirm/`](../tools/squirm/README.md)).
- **The Gompertz analyses** that motivate the maps are in this repository ([README](../README.md) and the [report](Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md)).

## Where each part stands

| Part | Figure | Status |
|---|---|---|
| Strain-mean maps, chow and high fat, with genome-wide thresholds | Fig. 2a,b | **Near final:** 1,000 permutations; the loci that pass are listed below |
| The same maps under other weightings of strain means | Methods | **Near final:** a robustness check |
| Individual-mouse maps with kinship: chow, high fat, both diets, genotype × diet | Fig. 2c–f | **Maps done; thresholds running.** 200 permutations started on ATHENA on 22 November, not back yet |
| Strain and F1 means together: additive and dominance | not yet placed | **Preliminary:** maps done, no thresholds |
| F1 heterosis by cross type | not yet placed | **Preliminary,** descriptive |
| Body weight and correlated trait locus (CTL) maps | Fig. 3 | **Preliminary:** Danny's models, no thresholds |
| Combining T-ages by the Cauchy method, as in Arends et al. 2026 | — | **Not started** (planned) |
| BXD loci tested in UM-HET3 females | — | **Draft plan** awaiting Rob's approval ([PLAN_BXD_UMHET3_concordance.md](PLAN_BXD_UMHET3_concordance.md)) |

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

### Strain-mean maps (Fig. 2a,b): near final

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

**In plain terms:** proximal Chr 1 shows up on both diets with the *D* allele living longer, but at different positions and ages. On chow it is a late-life effect at about 5 Mb. On high fat it acts from early ages at about 23 Mb. Whether those are one locus or two is open, and it is what the F1 maps address.

Files: [`significant_loci.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/significant_loci.txt), [`qtl2_permutation_thresholds.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/qtl2_permutation_thresholds.txt), [`compare_weights.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/compare_weights.txt).

### Individual-mouse maps (Fig. 2c–f): maps done, thresholds running

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

**Thresholds: a first hint, from only two trial permutations.** Two permutations were run on Metis to test the code. That gives 8 permuted maps (2 permutations × 4 maps). In 6 of them, the largest −log10 P anywhere on the map (4.6 to 7.2) was higher than the largest on the real map (4.4 to 5.1). If the 200 permutations bear that out, the individual-mouse maps need clearly higher thresholds than the strain-mean maps, and few or none of the peaks above would pass. A likely reason is the one given above: the mice of a strain are not independent beyond what kinship explains, so their −log10 P values run high, and only permuting strains shows by how much. Two permutations cannot set a threshold, so treat this as a warning only.

**The permutation job:** 200 permutations of strains within strata, at all 26 T-ages and for all four maps, chunked with fixed seeds ([`QTL/qtl2_individuals_perm.R`](../QTL/qtl2_individuals_perm.R)). It started on ATHENA on 22 November at 09:46 and needs about 21 hours of computing; it pauses whenever the machine's own work needs the cores. A test run on ATHENA matched Metis to 6 × 10⁻⁶. The results will come back as a commit on the branch `squirm/bxd_individual_perms`.

### Strains and F1s together: preliminary

- **The F1s sharpen the chow locus on proximal Chr 1:** the 1.5-LOD interval at 5.0 Mb shrinks from 4.9–10.4 Mb (strains alone) to 4.9–5.5 Mb (strains and F1s), with the same peak (6.3 at T770).
- **On high fat, the peak moves** from 23.5 Mb (T20) to 37.6 Mb (T500), with an interval of 22.9–38.7 Mb either way. So the high-fat locus stays broad.
- **Dominance maps** exist ([`qtl2_*_meansF1_dom_Progressive.txt`](https://github.com/robwwilliams/BxDLifeSpan/tree/master/output)) but have no thresholds yet, and with 13 F1 types they have little power.

Files: [`strainF1_chr1.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/strainF1_chr1.txt).

### F1 heterosis: preliminary

F1 mean lifespan minus the mean of its two parental strains:

| Diet | Short × short (6 types) | Long × long (7 types) |
|---|---|---|
| Chow | +196 days (range +129 to +288) | +42 days (−17 to +142) |
| High fat | +146 days (+99 to +247) | +58 days (−18 to +163) |

- **Within each class, F1 types do not differ by more than sampling error** (heterogeneity P = 0.21–0.54).
- **Heterosis does not follow the fraction of the genome that is heterozygous** (40–55% across types). The correlations over F1 types are −0.81 and −0.55 on chow (short × short, long × long), and +0.38 and −0.25 on high fat, each from only 6 or 7 types.

Files: [`f1_heterosis.txt`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/output/f1_heterosis.txt).

### Body weight and CTL maps (Fig. 3): preliminary

These are Danny's maps, redrawn: strain means weighted by numbers of mice, without kinship, and no genome-wide thresholds. The CTL maps ask where the correlation between body weight and lifespan differs between *B* and *D* carriers. They have not yet been redone with the models above.

## What comes next

1. **Individual-mouse thresholds** from the ATHENA job, then the stable range of T-ages, as for the strain means, and the thresholds drawn on Fig. 2c–f.
2. **Cauchy combination over T-ages,** as in Arends et al. 2026 but with exact P values on the right degrees of freedom ([Cauchy_review_2026-11-21.md](Cauchy_review_2026-11-21.md)), so that each marker gets one P for "any age".
3. **Thresholds for the F1, body-weight and CTL maps.**
4. **BXD loci in UM-HET3 females,** once Rob approves the plan, with the BXD loci fixed before UM-HET3 is looked at.
5. **Legend titles that state findings,** once the thresholds are in.

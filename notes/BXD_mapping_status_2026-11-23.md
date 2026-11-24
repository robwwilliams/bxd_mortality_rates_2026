# BXD lifespan mapping: models, reasons and results so far

**Status note, 23 November 2026,** by Claude (Opus 5.5) for Rob Williams, written for colleagues reading this repository: Beni Mozhui, Danny Arends, Suheeta Roy. Reviewed by Rob, evening 23Nov. All of the mapping is exploratory: the models were chosen while maps were being looked at, not fixed in a plan beforehand.

**Where the work lives.**
- **The maps** are made in Rob's fork of Danny Arends's code, [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan). Danny's files are unchanged there. The added scripts, the draft [Methods](https://github.com/robwwilliams/BxDLifeSpan/blob/master/Methods_draft.md) and the draft [figure legends](https://github.com/robwwilliams/BxDLifeSpan/blob/master/Figure_legends.md) are listed in its [README](https://github.com/robwwilliams/BxDLifeSpan/blob/master/README.md).
- **The long permutation job** for the individual-mouse maps runs from this repository ([`QTL/`](../QTL/README.md)) on ATHENA, a MacStudio M5 Max, through Squirm, our informal three-machine version of SLURM ([`tools/squirm/`](../tools/squirm/README.md)).
- **The Gompertz analyses** that motivate the maps are in this repository ([README](../README.md) and the [report](Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md)).

## Where each part stands

| Part | Figure | Status |
|---|---|---|
| Strain-mean maps, chow and high fat, with genome-wide thresholds | Fig. 2a,b | **Near final:** 1,000 permutations; the loci that pass are listed below |
| The same maps under other weightings of strain means | Methods | **Near final:** a robustness check |
| Individual-mouse maps with kinship: chow, high fat, both diets, genotype × diet | Fig. 2c–f | **Maps done; thresholds running.** 200 permutations started on ATHENA on 22 November, not back yet |
| **Strain and F1 means together, with zooms of proximal Chr 1 (first section below)** | not yet placed | **Preliminary:** maps, support intervals, a leave-one-F1-out check, thresholds from 1,000 permutations and a two-locus scan of high-fat Chr 1, all done |
| F1 heterosis by cross type | not yet placed | **Preliminary,** descriptive |
| Body weight and correlated trait locus (CTL) maps | Fig. 3 | **Preliminary:** Danny's models, no thresholds |
| Combining T-ages by the Cauchy method, as in Arends et al. 2026 | — | **Not started** (planned) |
| BXD loci tested in UM-HET3 females | — | **Draft plan** awaiting Rob's approval ([PLAN_BXD_UMHET3_concordance.md](PLAN_BXD_UMHET3_concordance.md)) |

## The F1 hybrids: sharper loci on proximal Chr 1 (preliminary)

*Added on 23 November 2026, at Rob's request:* "That is of greatest interest to me in improving confidence of loci and narrowing 1.5 LOD (or –logP) of the support interval. ... the maps need to be compared to excluding the F1s. Need zoom-in versions of the proximal 50 Mb of Chr 1." *The thresholds and the two-locus scan were added later the same evening, at Rob's go-ahead, and have not yet been reviewed by him.*

**In brief:**
- **Chow, Chr 1 near 5 Mb, T770:** significant with and without the F1s, and the F1s narrow its 1.5-LOD interval from 4.9–10.4 Mb to 4.9–5.5 Mb. The long × long F1s, as a group, do the narrowing. The peak itself is a flat block from 4.86 to 5.32 Mb holding *Tcea1*, *Rgs20* and *Atp6v1h*; only BXD79, which dies young on chow, has a crossover inside it.
- **High fat, proximal Chr 1:** significant at T20 (23.5 Mb) and at T500 (37.6 Mb, where the F1s raise the peak from 4.74 to 5.43). Whether that is one locus or two, the data cannot yet say: a second locus never adds more than chance would.
- **Dominance:** no locus passes the threshold for any T-age.

**Why the F1s.** Rob chose 13 BXD × BXD F1 types: 6 short × short and 7 long × long crosses whose parents differ over different stretches of proximal Chr 1 (panel e of the profiles below). Two aims:
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
| Chow, additive | T20–T740 | 4.66 (5.83) | 4.30 (5.41) | 3.16 (4.25) |
| High fat, additive | T20–T590 | 4.59 (5.46) | 4.21 (5.08) | 3.07 (3.91) |
| Chow, dominance | T20–T500 | 1.15 (1.46) | 1.05 (1.31) | 0.77 (0.97) |
| High fat, dominance | T20–T500 | 1.91 (2.58) | 1.79 (2.48) | 1.27 (1.75) |

- **The additive thresholds are a little higher than those of the strain means alone** (4.66 and 4.59 against 4.43): the F1s add 13 units and a covariate.
- **The dominance thresholds are far below what a test on 1 d.f. would suggest.** Only the 13 F1 types inform dominance, so its −log10 *P* values cannot be read on the usual scale; only the permutation thresholds count.

**The support interval** (`chr1_zoom.R`) is the run of neighboring markers whose LOD is within 1.5 of the peak's. At these peaks a drop of 1.5 LOD is a drop of about 1.6 on the −log10 *P* scale. A 1.5-LOD interval is a rough guide, not a confidence interval, and it assumes one locus in the region.

### Genome-wide, the F1s change little

[![Strain means alone and with the F1s, genome-wide](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Strain_and_F1_means.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Strain_and_F1_means.png)

Panels **a** and **d** are the strain-mean maps of Fig. 2a,b. Panels **b** and **e** add the F1s (additive effect). Panels **c** and **f** are the dominance deviations, which only the F1s inform.
- **The additive maps keep the same loci,** with one change in level (`significant_loci_F1.txt` against `significant_loci.txt`):

  | Locus | Strains alone | Strains + F1s |
  |---|---|---|
  | Chow, Chr 1 at 5.0 Mb (*D*) | 6.26 at T770, significant for any T-age | 6.29 at T770, significant (see below) |
  | Chow, Chr 9 at 107 Mb (*B*) | 4.47 at T680, significant | 4.91 at T680, significant |
  | High fat, Chr 1 at 23.5 Mb (*D*) | 5.01 at T20; significant T20–T110 | 4.84 at T20; significant at T20 |
  | High fat, Chr 1 at 37.6 Mb (*D*) | 4.74 at T500, significant | 5.43 at T500, significant |
  | High fat, Chr 2 at 157 Mb (*B*) | 4.85 at T260; significant T20–T260 | 4.40 at T200; P < 0.10 only |

  No locus passes for any T-age within the stable ranges. Chow T770 lies just past the chow stable range of the strain + F1 maps (its 5% threshold, 4.31, is 0.35 below the median), but 6.29 is above even the strictest threshold of that range, 5.83 for any T-age.
- **Dominance: nothing on chow.** No marker passes at any T-age in the stable range; the largest, 0.95, is below every single-T-age threshold (1.06–1.32).
- **Dominance on high fat: one pattern, probably not loci.** The strongest marker on each of 10 chromosomes passes the single-T-age threshold, all at the same T-ages (T20–T200, T350 or T440), and all with heterozygotes below the midpoint of the homozygotes. None passes for any T-age (largest 2.47 against 2.58). Ten chromosomes at once, on the same T-ages and in the same direction, point to the 13 F1 types as a group rather than to 10 loci. A likely cause: the permutation gives each F1 type the lifespans of another, which breaks each F1's resemblance to its own parents, so for dominance the permutation null may be too lenient. Not tested.

### Proximal Chr 1, 0 to 50 Mb

[![Chr 1, 0 to 50 Mb: profiles with and without the F1s](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_zoom_profiles.png)](https://raw.githubusercontent.com/robwwilliams/BxDLifeSpan/master/output/maps/Chr1_zoom_profiles.png)

*Profiles at the T-ages where Chr 1 is strongest: grey, strain means alone; green, strain and F1 means together (additive). Bars under each profile are the 1.5-LOD support intervals. Dashed lines are each map's genome-wide 5% threshold for that T-age, from its own permutations. **e**, where each F1 type's parents differ, that is, where the F1 is heterozygous.*

**Chow, T770: the F1s narrow the interval from 5.6 Mb to 0.7 Mb.**
- **Strains alone:** peak at 5.0 Mb (−log10 *P* 6.26), interval 4.9–10.4 Mb.
- **With the F1s:** the same peak (6.29), interval 4.9–5.5 Mb.
- **What moves the edge:** a plateau from 5.5 to 10.4 Mb. With strains alone it lies just within 1.5 LOD of the peak (−log10 *P* 4.8 against a cut of 4.7). The F1s lower it to 4.25, below the cut. So the narrowing is real in these data, but it rests on a modest change at the plateau.
- **It does not hang on any one F1 type.** Left out one at a time, every F1 type leaves the interval at 4.9–5.5 Mb (`chr1_f1_dropone.R`).
- **It comes from the long × long F1s as a group.** Leave out all 7 and the interval returns to 4.9–10.4 Mb. Leave out the 6 short × short F1s and it stays at 4.9–5.5 Mb. Several long × long types are heterozygous on one side of 5.5 Mb and not the other (panel e).
- **One T-age only.** The chow Chr 1 locus is a late-life effect. From T680 to T740 the signal near 5 Mb is weak (−log10 *P* 2.1–2.7, with or without the F1s) and the intervals span 8.5–12 Mb. So this sharpest result comes from the 46 strains and 13 F1 types still alive at T770. Rob: "Any map at T770 is going to be iffy given the low sample size."
- **The peak is a flat block, not a point.** Every marker from 4.86 to 5.32 Mb has the same genotypes in all the strains and F1 types mapped at T770, so all give the same −log10 *P* (6.26 alone, 6.29 with F1s). "5.0 Mb" is just the first marker of the block. The data cannot place the locus within it.
- **What the block holds** (mm10, RefSeq): the start of *Tcea1* (4.86–4.90 Mb), *Rgs20* (4.91–5.07) and *Atp6v1h* (5.08–5.16). Just outside are *Lypla1* and *Mrpl15* (proximal, ending at 4.85 and 4.79 Mb), and *Oprk1* (distal, from 5.59 Mb). Of the three Vita1a candidates named in Arends et al. 2026 (*Mrpl15*, *Atp6v1h*, *Rb1cc1*), only *Atp6v1h* lies in the block, and *Rb1cc1* (6.21 Mb) lies outside the whole interval. The BXD chow locus and Vita1a in UM-HET3 need not be the same variant.
- **Which strains set the edges** (`chr1_recombinants.R`): proximally, BXD65, BXD102 and BXD43 switch between 4.858 and 4.861 Mb, inside the start of *Tcea1*; distally, BXD11 switches at 5.316 Mb, beyond *Atp6v1h*.

**High fat: peaks near 23.5 and 37.6 Mb, and the F1s shift the weight toward the second.**
- **T20 to T230:** the peak is at 23.5 Mb, with an interval of 22.4–25.5 Mb, with or without the F1s. Leaving out any F1 type, or either class, does not change it.
- **From T260 on, with the F1s, the peak moves to 32–38 Mb** at most T-ages up to T650. With strains alone it is there only at T500, T590 and T620.
- **T500 is the strongest:** 37.6 Mb, −log10 *P* 5.43 with the F1s (4.74 without), interval 34.4–38.7 Mb either way. Without some short × short types (BXD170x172, BXD197x170, BXD9x172) or BXD65x102 it widens to 32.3–38.7 Mb.
- **Against the thresholds:** with the F1s, Chr 1 passes at T20 (23.5 Mb, 4.84 against 4.62) and at T500 (37.6 Mb, 5.43 against 4.47).
- **The single peak marker at 37.63 Mb (rs32180312) is called heterozygous in 19 strains,** against 11 at its neighbors, so its exact position should not be trusted. Markers from 35.7 to 37.7 Mb come within 0.35 of it (5.08–5.32 with the F1s). The stretch from 35.7 to 38.0 Mb holds 37 RefSeq genes.
- **Rob, on this locus:** "I agree that there is likely to be a locus distal to Vita1b at about 35–37 Mb. We have noted that for several years but not look at the interval closely. We do not see this locus in the UM-HET3 so it was been less of a priority. ... But T500 is fine."
- **At almost every high-fat T-age, markers in the other region also come within 1.5 LOD of the peak.** So an interval that assumes one locus does not fit here, and we ran a two-locus scan.

**One locus or two on high fat** (`chr1_twolocus.R`). At each T-age from T20 to T620, every pair of positions in 0–50 Mb was fitted together, in the same mixed model as the maps (it reproduces their single-locus LODs exactly).
- **The test:** LOD(2 v 1), the best pair against the best single locus. Its P comes from 1,000 parametric bootstraps under the best single locus: traits simulated with one locus, each put through the same search for one locus and for a pair.
- **The best pair is near 23.5 and 37.6 Mb at most T-ages** (32 of the 42 scans), and it adds 0.8–1.9 LOD to the best single locus.
- **That is no more than one locus gives by chance:** P(2 v 1) is 0.08 at best (strains alone, T500) and 0.18–0.74 elsewhere. With the F1s, P is lower at most early T-ages (0.18–0.33 at T20–T230, against 0.40–0.51 without), but never below 0.18.
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
- **BXD79** is *D* to about 5.019 Mb and *B* beyond, so it separates *Tcea1* and the start of *Rgs20* from the rest of *Rgs20* and *Atp6v1h*. But it is short-lived on chow (17 mice, mean 417 days; one alive at T680, none at T740), so it cannot inform the T770 map. Its switch falls between two markers only 60 bp apart (5.019115 and 5.019174 Mb), which is more precise than a crossover can be placed; the markers need checking.
- **BXD52** switches between 4.88 and 5.02 Mb, but it is extinct and has no lifespan data.
- **So the block can be split only through BXD79, and only with F1s, since BXD79 itself dies too young.** A suggestion, not yet discussed: cross BXD79 with a long-lived strain that is *B* across the block (BXD65) and with one that is *D* across it (BXD77 or BXD102). Each F1 would be heterozygous on only one side of 5.02 Mb, so their late survival would ask whether the locus is proximal (*Tcea1*, start of *Rgs20*) or distal (*Atp6v1h*).

**The high-fat interval, 34.4–38.7 Mb.** 19 strains switch in it, many with high-fat lifespans already. Strains with a switch at 35.7–38.2 Mb but no high-fat mice alive at T500 could be added on high fat: BXD83 (switch at 37.58–37.63 Mb; 4 chow, 0 high-fat mice), BXD184 (37.58–38.23; 2 chow, 0 high fat), BXD216 (38.22; 2 chow, 0 high fat), BXD177 (37.58–37.63; 1 high-fat mouse), BXD99 (35.23 and 37.58–37.63; 7 high-fat mice, none alive at T500) and BXD200 (34.95–35.19; 2 high-fat mice). Whether each is still alive in the colony needs checking; the genotype file's extinct list dates from 2016.

### F1 heterosis

F1 mean lifespan minus the mean of its two parental strains:

| Diet | Short × short (6 types) | Long × long (7 types) |
|---|---|---|
| Chow | +196 days (range +129 to +288) | +42 days (−17 to +142) |
| High fat | +146 days (+99 to +247) | +58 days (−18 to +163) |

- **Within each class, F1 types do not differ by more than sampling error** (heterogeneity P = 0.21–0.54).
- **Heterosis does not follow the fraction of the genome that is heterozygous** (40–55% across types). The correlations over F1 types are −0.81 and −0.55 on chow (short × short, long × long), and +0.38 and −0.25 on high fat, each from only 6 or 7 types.

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

### Strains and F1s together, and F1 heterosis

See the first section above.

### Body weight and CTL maps (Fig. 3): preliminary

These are Danny's maps, redrawn: strain means weighted by numbers of mice, without kinship, and no genome-wide thresholds. The CTL maps ask where the correlation between body weight and lifespan differs between *B* and *D* carriers. They have not yet been redone with the models above.

## What comes next

1. **Individual-mouse thresholds** from the ATHENA job, then the stable range of T-ages, as for the strain means, and the thresholds drawn on Fig. 2c–f.
2. **Cauchy combination over T-ages,** as in Arends et al. 2026 but with exact P values on the right degrees of freedom ([Cauchy_review_2026-11-21.md](Cauchy_review_2026-11-21.md)), so that each marker gets one P for "any age".
3. **For the F1s:** a permutation that keeps each F1 tied to its parents, to check the high-fat dominance pattern; and whether the F1s also sharpen the chow Chr 9 locus at 107 Mb.
4. **Thresholds for the body-weight and CTL maps.**
5. **BXD loci in UM-HET3 females,** once Rob approves the plan, with the BXD loci fixed before UM-HET3 is looked at.
6. **Legend titles that state findings,** once the thresholds are in.

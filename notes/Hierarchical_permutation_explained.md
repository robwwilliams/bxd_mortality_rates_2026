# Why and how we permute the BXD hierarchically

**25 November 2026,** by Claude (Opus 5.5) for Rob Williams. Rob: "we need a good explanation the why and how of a hierarchical permutation test. I have know this all too well from reviewing work that stepped into a trap of false discoveries by a naive any-to-any permutation test, but to many it is a new trap that needs explanation." The worked example is the CTL analysis of the BXD family; the same reasoning applies to the lifespan maps.

## The short version

A permutation test asks: how strong would the best result be if genotype had nothing to do with the trait? It answers by scrambling the data so that the link is broken, and redoing the whole analysis many times. **The scrambled data must keep everything else about the real data.** If the scrambling also destroys structure that the real data have, it compares the real result with a null that is too quiet, and ordinary noise looks like discovery.

In the BXD, the structure that matters most is that **the mice of a strain are near-copies of one another.** About 1,750 mice are about 120 genomes. Shuffling mouse by mouse pretends there are 1,750 genomes.

## The trap, in numbers

The same CTL analysis (Danny's statistic, real data unchanged), judged against three kinds of permutation, 1,000 each. "Largest" is the strongest −log10 *P* at any marker and any of 25 T-ages.

| What is exchanged | Chow: 5% threshold | Chow: P of the largest (10.2) | High fat: 5% threshold | High fat: P of the largest (9.4) |
|---|---|---|---|---|
| **Any mouse with any mouse** (naive) | 9.4 | **0.023** | 8.4 | **0.019** |
| **Any strain with any strain** | 16.2 | 0.86 | 12.2 | 0.47 |
| **Strains within their group** (hierarchical: Taylor's BXD1–42, or the newer strains) | 16.8 | 0.88 | 12.3 | 0.50 |

- **The naive test says "significant" on both diets. The strain-level tests say "ordinary".** Nothing about the data changed, only the question of what counts as a replicate.
- **The naive threshold misleads almost every time.** When the maps have no true CTL (strain genotypes scrambled), 96% on chow and 79% on high fat still exceed the naive 5% threshold. It should be 5%.
- **Single T-ages are no safer.** In the real data 10 of 25 T-ages on chow and 13 of 25 on high fat pass the naive threshold, and 0 and 1 pass the hierarchical one. Where nothing is true, the naive 5% threshold is exceeded at a single T-age 51% of the time on chow and 46% on high fat.
- **Here almost all the trap is in the first step, from mice to strains.** Keeping Taylor's strains and the newer ones apart raises the threshold only a little (16.2 to 16.8; 12.2 to 12.3). It costs nothing and is safer.

**Multiple-testing corrections cannot fix this.** B&H and Bonferroni take each P value as correct and ask how many tests were run. Here each P counts mice as independent, so it starts out too small. In the scrambled data B&H still makes calls in 100% of the maps, and Bonferroni in 99–100%.

**Two different things make the per-mouse P too small,** and both show up in the inflation of the median χ² (1 is correct; chow / high fat): 2.75 / 2.51 in the real data, 2.55 / 2.24 with strains permuted, and 1.72 / 1.52 with mice permuted. Permuting mice removes the sharing of genotype by the mice of a strain, but not the unequal weights (each mouse counts 1 / its strain's size), which alone leave fewer effective mice than the sample size in the formula.

## Why: exchangeable units

A permutation is valid if the items exchanged are *exchangeable* under the null hypothesis: the data would have been just as likely with the labels swapped. Mice of one strain are not exchangeable with mice of other strains one by one, because they share a genotype, an upbringing and a lifespan distribution. Strains, as whole packages, are much closer to exchangeable, if their histories are similar. So the hierarchy is:

1. **Mouse within strain:** never exchanged across strains. A mouse's weight and lifespan stay together, and its strain stays with it.
2. **Strain:** the unit exchanged. A strain's mice travel together and take the genotypes of another strain.
3. **Group of strains:** strains are exchanged only within their group, because strains made at different times, by different breeding designs, are related to one another in different ways. We use Taylor's strains (BXD1–42) and the newer ones.
4. **F1 class:** F1 types are exchanged only within short × short or long × long, never with inbred strains.

Rob: "what are the exchangable units? Do you need a hierarchical permutation? Important not to over-randomize across the intrinsic structure of the cross or the P values will be way too lenient."

## How: the recipe

1. Compute the statistic on the real data, over all markers and T-ages, and keep the largest.
2. For each of 1,000 permutations:
   - draw, within each group of strains and each F1 class, a random assignment of genotypes to strains;
   - give every mouse of a strain that strain's new genotypes, the same assignment at every T-age and on both diets;
   - leave every weight, lifespan, covariate and T-age as it is, and recompute the *whole* analysis, with the same statistic and the same exclusions;
   - keep the largest value.
3. Genome-wide P = (1 + number of permutations with a largest value at least as big as the real one) / 1,001. The 95th percentile of the largest values is the 5% threshold.

**What to keep in mind:**
- **Use the same assignment at every T-age.** Survivorships share mice; permuting each T-age afresh breaks their nesting and changes the any-T-age threshold.
- **Permute genotypes (or, equivalently, whole packages of phenotype), not individual values.**
- **What it does not remove:** kinship among strains beyond the grouping, and cases where strains differ too much in size to be interchangeable. Rob: "the kinship is not that gnarly."
- **It is not a power statement.** Failing a hierarchical test means the data cannot tell the signal from what strain structure alone produces. With about 100 strains, the power for CTLs is low.
- **UM-HET3 is different:** every mouse is genetically unique, so mice are the units, and no strain structure exists to be broken. That is why Arends et al. 2026 could use simpler corrections.

## Reading

According to PubMed:
- Churchill & Doerge (2008) *Genetics* 178:609–610. Naive permutation testing inflates type I error when family structure is ignored, and choosing a valid permutation strategy is not always intuitive. [doi:10.1534/genetics.107.074609](https://doi.org/10.1534/genetics.107.074609)
- Cheng & Palmer (2013) *Genetics* 193:1015–1018. Unrestricted permutation controls type I error if the model accounts for relatedness, and otherwise does not. [doi:10.1534/genetics.112.146332](https://doi.org/10.1534/genetics.112.146332)
- Abney (2015) *Genetic Epidemiology* 39:249–258. Why permutations fail with polygenic variation in structured populations, and an alternative. [doi:10.1002/gepi.21893](https://doi.org/10.1002/gepi.21893)
- Winkler et al. (2015) *NeuroImage* 123:253–268. Hierarchical, multi-level block permutation: exchangeability defined by nested blocks. [doi:10.1016/j.neuroimage.2015.05.092](https://doi.org/10.1016/j.neuroimage.2015.05.092)
- Lazic, Clarke-Williams & Munafò (2018) *PLoS Biology* 16:e2005282. What counts as N, and how often pseudoreplication occurs in animal studies. [doi:10.1371/journal.pbio.2005282](https://doi.org/10.1371/journal.pbio.2005282)

**A paragraph for Methods (draft).** It describes the CTL and individual-mouse maps. The strain-mean maps of Fig. 2a,b exchange any strain with any other, and F1 types within class (Rob, 25 November 2026: "Leave as is"); at the CTLs the two choices differ little (table above). "BXD mice are replicated within strains, and the mice of a strain share their genotypes, so mice are not independent and the strain is the unit of inference. Significance was therefore assessed by hierarchical permutation (Churchill & Doerge 2008; Winkler et al. 2015): in each of 1,000 permutations every strain took the genotypes of another strain of its group (Taylor's strains, BXD1–42, or those made later), and each F1 type those of another F1 type of its class (short × short or long × long). The same assignment was used at every T-age and on both diets, every mouse kept its phenotypes and covariates, and the analysis was repeated in full, recording the largest −log10 *P*. Permuting mice instead gave 5% thresholds so low that 96% (chow) and 79% (high fat) of the CTL maps with scrambled genotypes exceeded them."

*Code:* `ctl_permutations.R` (modes `strains`, `anystrain` and `mice`) in [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan).

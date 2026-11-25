# Plan: a targeted search for epistasis in BXD and F1 females

**Written by Claude (Opus 5.5) for Rob Williams, 25 November 2026, and committed before any epistasis fit in BXD was run.** Rob chose the two searches; Claude chose the tests. The main-effect maps of the same mice had been seen, so this is a plan fixed before these fits, not an independent one. Rob: "a targeted search for epistasis. We can chose several focused searches, but perhaps these two are most obvious: 1. Based tightly on just the UM-HET3 Vita1a and Vita1b partner loci of females 2. Based tightly on just the significant BXD Vita hot spots with P genome-wide <0.1 (any diet)."

## Search 1: UM-HET3 female partners of Vita1a and Vita1b

From Arends et al. 2026, Table 2 (females, interaction LOD ≥ 3.8), with LODs from the epistasis-only (lower) triangles of Supplementary Tables 12.5–12.7:

| Pair | T42 | T365 | T740 | BXD markers nearest the peaks (Mb) |
|---|---|---|---|---|
| Vita1a × Vita6b | 5.47 | 5.08 | 3.85 | Chr 1 5.02 × Chr 6 132.8 |
| Vita1a × Vita9a | 4.65 | 4.13 | 2.63 | Chr 1 5.02 × Chr 9 29.9 |
| Vita1a × Vita11a | 4.68 | 4.00 | 3.65 | Chr 1 5.02 × Chr 11 5.6 |
| Vita1b × Vita6b | 4.17 | 4.12 | 3.45 | Chr 1 23.52 × Chr 6 132.8 |
| Vita1b × Vita9a | 5.68 | 5.18 | 2.76 | Chr 1 23.52 × Chr 9 29.9 |
| Vita1b × Vita9b | 4.52 | 4.09 | 3.21 | Chr 1 23.52 × Chr 9 104.1 |

- **Primary test:** the six pairs, on chow (the UM-HET3 diet), in the survivorship that corresponds to T42, where the LODs are strongest: BXD T50. Family-wise P over the six pairs.
- **Secondary:** the same on high fat and on both diets together; T290 and T560, which match T365 and T740 at the ratio of median lifespans (1.32); and the best marker within 5 Mb of the partner's peak, with the search included in the permutations.
- **What can and cannot replicate.** UM-HET3 interactions involve four founder alleles on 9 d.f.; BXD tests *D* against *B* at both loci (1 d.f.). So the sign cannot be compared, and an interaction that depends on *C* or *H* alleles is invisible in BXD. A positive result would support the pair; a negative one does not refute it.

## Search 2: BXD hot spots at genome-wide P < 0.1

All loci that reach genome-wide P < 0.10 at one T-age in any strain-mean, strain + F1 mean, individual-mouse or Cauchy map, on either diet:

| Locus | Map and diet | Level |
|---|---|---|
| Vita1a, Chr 1 5.02 Mb, *D* | chow, all map types | P < 0.05 |
| Vita1b, Chr 1 23.52 Mb, *D* | high fat | P < 0.05 |
| Vita1y, Chr 1 35.73 Mb, *D* (the 37.6 Mb peak marker is called heterozygous in 19 strains) | high fat | P < 0.05 |
| Chr 2 156.7 Mb, *B* | high fat | P < 0.05 strains alone, P < 0.10 with F1s |
| Chr 9 106.9 Mb, *B* | chow | P < 0.05 |
| Chr 15 14.3 Mb, *B* | high fat, with F1s | P < 0.10 |

- **Pairs:** 15, less the 3 on Chr 1, leaves **12**.
- **Primary tests:** the 12 pairs on chow and on high fat at T50 (24 tests), family-wise P over the 24.
- **Secondary:** both diets together; T290 and T560.

## The test, for both searches

- **Mice:** BXD and BXD × BXD F1 females, as in the individual-mouse maps with F1s (F1 table of 24 November 2026; natural deaths; 319 F1 mice).
- **Model:** age at death of mice alive at T ~ vivarium + set-up class + F1 class (and diet, diet × F1 class for both diets) + *d*1 + *d*2 + *d*1*d*2 + polygenic effect. *d* is the share of alleles that are *D* (0, 0.5, 1). Kinship leaves out the chromosomes of both loci, and its variance is estimated once, without loci. The interaction is *d*1*d*2, 1 d.f.
- **Units:** strain or F1 type, with at least one mouse. The number of units in each *BB/DD* cell is reported, and a pair with a cell of fewer than 5 strains is not tested.
- **P:** 2,000 hierarchical permutations, as in `notes/Hierarchical_permutation_explained.md` (Taylor's strains, newer strains and each F1 class kept apart), the genotypes of both loci moved together and the same at every T-age, so the correlation between the two loci and any product with the phenotype is kept apart from the trait. Family-wise P from the largest |z| over the family. Mouse-level P beside it.
- **Power:** interactions of 50, 100 and 150 days (*DD·DD* against the others) planted in the real phenotypes at each tested pair, at T50. If a planted interaction of 100 days is not found, a negative result says little.
- **Reported in the plan's order.** Anything else tried is labeled exploratory.

Seeds fixed: 20261125.

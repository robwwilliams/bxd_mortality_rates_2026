# Epistasis in BXD and F1 females: results

**25 November 2026,** by Claude (Opus 5.5) for Rob Williams. Plan: [PLAN_epistasis_BXD.md](PLAN_epistasis_BXD.md), committed (9ee0d4f) before any fit. Code: [`QTL/epistasis_bxd.R`](../QTL/epistasis_bxd.R). All tables: [`output/epistasis_bxd.txt`](../output/epistasis_bxd.txt).

## Short answer

**No interaction passes in either search, and none of the 162 planned and secondary tests in the two searches stands out** (9 reach pointwise P ≤ 0.05, about 8 expected by chance). **Power is the limit:** with 80% power we could find only interactions of about 130–210 days, against the 100-day example in Arends et al. (Vita1c × Vita3a in males).

## Search 1: UM-HET3 female partners of Vita1a and Vita1b (chow, T50; primary)

| Pair | Interaction, days (± s.e.) | P (strains permuted) | Family-wise P (6 pairs) | Smallest interaction found with 80% power |
|---|---|---|---|---|
| Vita1a × Vita6b | −40 ± 47 | 0.46 | 0.97 | 181 |
| Vita1a × Vita9a | +15 ± 46 | 0.78 | 1.00 | 175 |
| Vita1a × Vita11a | +32 ± 44 | 0.55 | 0.99 | 167 |
| Vita1b × Vita6b | +61 ± 47 | 0.27 | 0.82 | 180 |
| Vita1b × Vita9a | +70 ± 42 | 0.14 | 0.58 | 162 |
| Vita1b × Vita9b | −16 ± 42 | 0.73 | 1.00 | 159 |

*Interaction: how much the DD/DD combination departs from the sum of the two main effects, in days.* Each cell has 17–40 strains.

- **Secondary tests** (high fat, both diets, T290, T560, and the best marker within 5 Mb of the partner) give none that passes.
- **The steadiest direction** is Vita1a × Vita11a: positive in all nine settings (three diets by three T-ages), +79 ± 27 days on chow at T560 (pointwise P = 0.014; family-wise 0.18). The settings share mice, so nine agreements are not nine pieces of evidence. This is the only pair I would follow up.

## Search 2: pairs of BXD hot spots, genome-wide P < 0.1 (chow and high fat, T50; primary)

12 pairs (15 less the 3 on Chr 1), 24 tests. **None passes** (smallest family-wise P 0.45). The two smallest are pointwise only: chow Vita1b × Chr 2 at 156.7 Mb (+103 ± 43 days, P = 0.026, family-wise 0.45) and high fat Vita1a × Chr 9 at 106.9 Mb (−81 ± 40, P = 0.049, family-wise 0.74). The second has the same sign in all nine settings, like the pair above, and the same caution applies.

## Power, as planned

Interactions of 50, 100, 150 and 200 days were added to the phenotypes at the primary test of each pair, on both signs:

| Added interaction | Search 1 (6 pairs): found, + / − | Search 2 (24 tests): found, + / − |
|---|---|---|
| 50 days | 0 / 0 | 1 / 0 |
| 100 days | 3 / 1 | 1 / 8 |
| 150 days | 5 / 3 | 11 / 13 |
| 200 days | 6 / 6 | 18 / 23 |

**So this is an absence of evidence, not evidence of absence.** The plan said that a planted interaction of 100 days not found means a negative result says little; most were not found. One caution: the same real phenotypes carry each pair's own estimated interaction, so a planted effect adds to it and the found counts are not clean power estimates.

## Why the BXD are not the right place to replicate UM-HET3 epistasis

- **Four cells of about 30 strains each** against about 3,000 unique mice.
- **A different contrast:** UM-HET3 interactions span four founder alleles on 9 d.f.; the BXD test only *D* against *B* at both loci.
- **The permutations behave well:** the spread of permuted z is 1.0–1.2 at T50 (1.0 would be perfect), so kinship and the strain unit are nearly handled by the model.

## A discrepancy in Table 2 of Arends et al.

Table 2 lists *1a* among the female partners of **Vita11b** and nothing for **Vita11a**, but Vita1a's own row lists *11a*. Supplementary Table 12.5 (epistasis-only triangle, T42) gives Vita1a × Vita11a LOD 4.68 and Vita1a × Vita11b 1.40. So the "1a" belongs on the Vita11a row. I used 11a.

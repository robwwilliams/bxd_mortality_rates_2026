# Analysis plan, fixed before the fits: two secondary analyses of mortality rate doubling time in the BXD family

**Corrected 24 October 2026 (see Amendments).** Claude wrote this plan and committed it on 24 October 2026 (commit 59c990f), before any MRDT was fitted. The haplotype calls in `output/Chr1_haplotypes.txt` were committed with it, so the classification was fixed before any survival data were joined to it. The design follows Rob Williams's rulings of 23 October: whole-region Chr 1 haplotypes, and pooled F1s against pooled parents. Rob did not ask for a pre-registration, and he did not review the direction of H2. An earlier version of this paragraph said the plan was "agreed with Rob Williams", which overstated what happened. The words "registered" and "pre-registration" below mean only that the plan was fixed before the fits. Later changes go in the Amendments section at the end, dated, and do not replace this text.

**What has and has not been seen.**
- **Known:** the lifespans of these groups.
- **Not yet fitted by anyone:** a mortality rate doubling time (MRDT) by proximal Chr 1 haplotype, or for any BXD × BXD F1 or its parents.
- **What exists so far:** the haplotype calls below were made from genotypes alone. Mice have been counted by class, and nothing else.

## 1. Questions

The primary analysis (`notes/MRDT_diet_initial.md`) found that the high-fat diet (HF) raises mortality 1.42-fold at every age without changing MRDT (equal-slope P = 0.55). These two analyses ask whether **genotype** changes MRDT.

- **H1.** Do BXD strains with a D haplotype across all of proximal Chr 1 differ in MRDT from strains with a B haplotype across all of it? The region spans Vita1a and Vita1b.
- **H2.** Is MRDT longer in F1 hybrids than in their inbred BXD parents? In other words, does heterozygosity flatten the rise of mortality with age? This prediction follows from the mutation-accumulation theory of senescence:
  - Mutation accumulation predicts that inbreeding depression in mortality grows with age.
  - The simplest form of antagonistic pleiotropy predicts that it does not (Charlesworth & Hughes 1996, *PNAS* 93:6140, doi:10.1073/pnas.93.12.6140).

## 2. Model and inference, shared by both tests

- **Animals.** Females on chow (CD) and HF that survived to 200 d. Each mouse is at risk from the later of its set-up age and 200 d.
  - This keeps the analysis on adult and late ages.
  - It also means that no F1 set-up age is needed, provided every F1 was set up before 200 d.
- **Model.** h(t) = h600 · 2^((t − 600)/MRDT), fitted by maximum likelihood (code: `Gompertz/gompertz.R`).
  - **Parameters:** each class has one MRDT, shared by the two diets. Each class × diet cell has its own level h600.
  - **Anchor age:** 600 d, not birth. The fit and the tests are the same either way, but the level at 600 d is not traded off against MRDT.
- **Censoring.** Animals alive at the data freeze are censored on the freeze date. Harvested animals are excluded, as in the primary analysis.
- **Statistic.** Δ = log2(MRDT of the first class ÷ MRDT of the second class).
- **Inference.**
  - **Delete-one-strain jackknife:** each strain (for H2, each F1 type and each parental strain) is dropped in turn and the model refitted. The spread of the refitted Δ gives a standard error that carries strain-to-strain variation.
  - **P value:** from t = Δ / SE on (number of strains − 1) degrees of freedom.
  - **Also reported:** the animal-level likelihood-ratio P.

## 3. H1: proximal Chr 1, D against B (two-tailed)

- **Genotypes.** The sequence-based BXD genotypes of D. Ashbrook (2018, updated 2019), Chr 1 from the first marker (3.0 Mb) to 30 Mb, as positioned in that file.
  - The calls are in `output/Chr1_haplotypes.txt` and were made by `Chr1/Chr1_haplotypes.R`.
- **Cleaning rules,** fixed before any survival data were joined:
  1. Markers whose B frequency across strains differs by more than 0.10 from the median of their 20 neighbors are dropped. Twelve markers go.
  2. Runs of fewer than 3 markers, or spanning less than 0.5 Mb, take the genotype of the longer neighboring run.
  3. An unknown flanked by the same genotype takes that genotype.
- **Classes.**
  - **B:** B across the whole region.
  - **D:** D across the whole region.
  - **Not in the test:** recombinants (both B and D blocks) and strains with a heterozygous block.
- **Mice in Suheeta Roy's curated file** (all ages; the survivors to 200 d will be slightly fewer):

  | Class | Strains | CD | HF |
  |---|---|---|---|
  | B | 33 | 273 | 235 |
  | D | 34 | 251 | 213 |
  | Recombinant (not in the test) | 48 | 391 | 363 |
  | Heterozygous (not in the test) | 4 | 13 | 7 |

- **Test.** MRDT of D against B, **two-tailed, α = 0.025**.

## 4. H2: F1 hybrids against their inbred parents (one-tailed)

- **Groups.**
  - **F1:** all 13 BXD × BXD F1 types, pooled (324 females, CD and HF).
  - **Parents:** all 8 parental strains, pooled (223 females): BXD9, BXD170, BXD172 and BXD197 (short-lived), and BXD65, BXD73b, BXD77 and BXD102 (long-lived).
  - **BXD65** is BXD65, not BXD65a or BXD65b.
- **Data sources.**
  - **F1s:** the GeneNetwork export `data/original/BDL_10002.xlsx`, which has no set-up ages. Every F1 was set up at weaning, so with the analysis starting at 200 d, each F1 is at risk from 200 d. The spelling variant BXD065XBXD102F1 is merged with BXD065xBXD102F1.
  - **Parents:** Suheeta Roy's curated file, which gives set-up ages.
- **Diet labels.** The export lists 160 F1 females on CD and 164 on HF. Rob Williams recalls that all F1s were on HF. The test uses the labels as recorded. Each class × diet cell has its own level, so the F1 slope is the same whichever is right.
- **Prediction.** F1 MRDT is longer than parental MRDT (Δ = log2(MRDT_F1 ÷ MRDT_parents) > 0).
  - **One-tailed, α = 0.025.**
  - **Jackknife units:** the 21 genotypes, so the t test has 20 degrees of freedom.

## 5. Error rate

- **Two primary tests,** each at α = 0.025, so the family-wise rate is 0.05.
- **Everything below** is reported as estimates with 95% intervals and makes no claim of significance.

## 6. Pre-specified secondary analyses (estimates only)

- **S1.** Short-by-short F1s against the short-lived parents, and long-by-long F1s against the long-lived parents.
- **S2.** B6D2F1 and D2B6F1 against C57BL/6J and DBA/2J. These F1s are heterozygous wherever B and D differ, roughly twice the heterozygosity of a BXD × BXD F1.
- **S3.** The recombinant strains, by genotype near the Vita1a peak (4.5 Mb) and the Vita1b peak (24 Mb): B-D and D-B.
- **S4.** Haplotype × diet on MRDT.
- **S5.** HF + 1% NAM females by haplotype. These are descriptive only.
- **S6.** H1 and H2 refitted from 0 d (all deaths) and from 365 d.

## 7. Sensitivity analyses (reported, not a condition of the claim)

- **Gamma-Gompertz refit of H1 and H2.** This model allows mice to differ in risk at a given age.

## 8. Approximate detectable effects (80% power)

These are scaled from the precision of the primary fits. They are lower bounds, because variation between strains adds to them.

- **H1:** a difference in MRDT of about 22%.
- **H2:** an F1 MRDT about 30% longer.
- **S2:** about 60%. This comparison can show direction only.

## 9. Confirmations at registration

- **F1 set-up.** All F1s were set up at weaning (Rob Williams, 24 October 2026).
- **Live animals.** No F1s are believed to be alive (Rob Williams, 24 October 2026; to be confirmed by Suheeta Roy).
  - If some are, H2 will be rerun with those animals censored at the data freeze, and that rerun is the registered result.
  - Every animal in Suheeta Roy's curated file has died.

## Amendments

**24 October 2026: the direction of H2.** Rob Williams's own words, before the plan was written:

> Does being an F1 flatten the MRDT. For me this is a pre-registered one-tailed test.

And on 24 October, after the results:

> I was guessing that F1 hybrids would be more vigorous and more buffered to the hard knocks of being a mouse born into a vivarium from the moment of birth and throughout life. Full stop. This is not a rate of change assertion.

- **Claude's translation.** Claude read "flatten the MRDT" as a flatter rise of mortality, that is, a longer MRDT, and linked it to the mutation-accumulation prediction of Charlesworth and Hughes. That reading, not Rob's, is the H2 tested above.
- **Rob's prediction was about level.** F1 mortality should be lower than the parents' at every age. In the short-by-short crosses it is, up to about 1,000 d (`notes/MRDT_secondary_results.md`).
- **What does not change.** H2 and its result stand as committed: the longer-MRDT direction is not supported. This amendment changes only whose prediction it was.

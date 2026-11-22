# Plan (draft): do BXD lifespan loci hold up in UM-HET3 females?

**Draft by Claude (Opus 5.5), 21 November 2026, for Rob Williams's review. No fits yet.** It becomes the plan of record once Rob approves or amends it, and before any UM-HET3 test of a BXD locus is run.

Rob: "Soon the real fun will be to mash up the female BXD data with the UM-HET3 data to see how many chow diet (or even HFD) loci for the BXDs we think a supported in the female UM-HET3 data. We do not have a crystal clear view of additive effects in the UM-HET3 but we do have interesting contrasts: B vs H compared to B vs D and C vs H compared to C vs D. ... I had thought of just boiling down the entire UM-HET three to Reference (B/B) genotype versus Het (Reference/Non-Reference) versus (Non-Reference/Non-Reference) genotype calls. Crude obviously."

## The difficulty, and why founder sequence solves it

**The two populations share two founders, on opposite sides.**
- **BXD** strains carry *B* (C57BL/6J) or *D* (DBA/2J), so BXD maps measure *D* against *B*.
- **UM-HET3** mice get a maternal *C* (BALB/cByJ) or *B*, and a paternal *H* (C3H/HeJ) or *D*. So UM-HET3 measures *B* against *C* on the maternal side, and *D* against *H* on the paternal side. No UM-HET3 contrast compares *B* with *D* directly.

**What decides whether a BXD locus can show in UM-HET3 is the sequence of the other two founders at the causal variant.** If BXD sees an effect, *B* and *D* differ there. BALB/cByJ and C3H/HeJ each carry either the *B*-type or the *D*-type allele, which gives four patterns:

| BALB/cByJ carries | C3H/HeJ carries | Maternal contrast, *C* − *B* | Paternal contrast, *D* − *H* | What UM-HET3 can show |
|---|---|---|---|---|
| *B*-type | *B*-type | none | the BXD effect | paternal only |
| *B*-type | *D*-type | none | none | nothing: the locus is invisible |
| *D*-type | *B*-type | the BXD effect | the BXD effect | both, in the same direction |
| *D*-type | *D*-type | the BXD effect | none | maternal only |

**So a BXD locus that UM-HET3 does not see is evidence against it only if the variants in its interval predict a visible pattern.**
- **Rob's contrasts fit the table.** BH against BD, and CH against CD, are the paternal contrast in each maternal background, which a purely additive locus makes equal.
- **Rob's recoding is this projection, done SNP by SNP.** He suggested counting each UM-HET3 mouse's non-reference alleles: 0, 1 or 2.
  - At each SNP where *B* and *D* differ, a mouse's two founder haplotypes give it 0, 1 or 2 copies of the *D*-type allele.
  - That is the core of merge analysis (Yalcin, Flint & Mott 2005, *Genetics* 171:673). It is crude only if the alleles are not taken from the founders.

## Steps

0. **Fix the BXD loci before looking at UM-HET3.**
   - **Source:** the kinship maps of the Nature Aging paper (chow and high fat; strain means and individual mice), with genome-wide thresholds. The thresholds come from the Cauchy combination over T-ages and permutations over strains, still to be computed.
   - **Record for each locus:** diet, interval, peak, T-ages and the allele that lives longer.
   - **Chow loci are the primary test**, because the UM-HET3 diet is a chow. High-fat loci are secondary: they ask whether a high-fat locus also acts on chow in another population.
1. **UM-HET3 female scans:** 3,037 females at T35, from the published cross (Supplementary Table 7).
   - **Model:** at each marker and T-age, an additive model with a maternal term (*B* − *C*) and a paternal term (*D* − *H*), each with its standard error. Covariates are site, cohort and treatment, as in Danny's code.
   - **A check:** the paternal effect within *B* mothers (BD − BH) and within *C* mothers (CD − CH), which should be equal for a purely additive locus.
2. **Match survivorships by age.** BXD and UM-HET3 lifespans differ. Survivorships will be matched by the fraction of the population still alive, as well as by calendar age.
3. **Project the founder sequence.**
   - **Data:** the founder variants of Supplementary Table 17 (GRCm38; BALB/cByJ, C57BL/6NJ, C3H/HeJ, DBA/2J), keeping high-quality homozygous calls. The first records of the file include heterozygous calls in inbred strains, which must be filtered out.
   - **In each BXD interval:** take the SNPs where *B* and *D* differ, sort them into the four patterns, and compute each UM-HET3 mouse's *D*-type dosage from its genotype probabilities. Test each SNP on 1 d.f.
4. **Score each locus.**
   - **Sign:** does UM-HET3 show an effect with the BXD sign in the contrast or contrasts that its dominant SNP pattern predicts?
   - **Pattern:** which of the four pattern models fits UM-HET3 best, by likelihood, as in merge analysis?
   - **Invisible loci** are reported as untestable, not as failures.
5. **Score all loci together.** Across loci, measure sign agreement and the correlation of predicted with observed UM-HET3 effects. The null distribution comes from intervals of the same size and pattern make-up, drawn at random from the genome.
6. **Effect sizes.** A BXD contrast compares homozygotes (DD against BB). A UM-HET3 contrast swaps one allele in a heterozygous background. Under additivity, the UM-HET3 effect should be about half the BXD difference.

## Known pitfalls

- **C57BL/6NJ, not 6J, in the founder file:** the two differ at a small number of variants.
- **The proximal Chr 1 genotype problem in UM-HET3:** an excess of paternal *H* (notes/Message_Chr1_genotype_error_2026-10-26.md). Vita1a and Vita1b, and any BXD locus there, need the corrected calls or a flag.
- **Background and sex:** BXD mice are inbred, UM-HET3 mice are heterozygous at every locus, and we use females only in both, so epistasis with the background can differ.
- **Drug treatments in UM-HET3:** treatment is a covariate, with controls only as a sensitivity check.
- **Multiple testing:** the number of BXD loci tested is fixed in step 0, and permutations set the significance of the aggregate test in step 5.

## Later

**mash** (Urbut et al. 2019) could treat BXD chow, BXD high fat, UM-HET3 maternal and UM-HET3 paternal effects as four conditions, and learn the sharing patterns of the table from the data. It would be a complement to the projection, not a replacement.

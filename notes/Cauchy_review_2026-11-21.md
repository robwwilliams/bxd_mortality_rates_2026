# The Cauchy correction of Arends et al. 2026: review, and how to use it for the BXD paper

**Exploratory review, 21 November 2026,** by Opus 5.5 Extra (Claude, Anthropic) at Rob Williams's request: "Please review the Cauchy code from the Nature paper and Danny's repo. We will need it in this paper too."
- **Sources:**
  - Methods, "Significance testing for actuarial analyses", and Table 1 of Arends et al. 2026 (*Nature* 654:437).
  - [`ActuarialMapping/Cauchy.R`](https://github.com/DannyArends/UM-HET3/blob/132ca3f/ActuarialMapping/Cauchy.R), with `ProgressiveMapping.R`, `SimpleM.R` and `stratifiedPerms.R` of [DannyArends/UM-HET3](https://github.com/DannyArends/UM-HET3) at commit `132ca3f`. `Cauchy.R` carries Danny's copyright; Rob recalls Saunak Sen designing the approach.
- **Code:** [`UMHET3/cauchy_review.R`](../UMHET3/cauchy_review.R) recomputes Table 1c from the published LOD matrices (Supplementary Table 9).
- **Output:** [`output/UMHET3_cauchy_review.txt`](../output/UMHET3_cauchy_review.txt).

## In brief

- **The method is sound, and the code reproduces the paper.** Run on the published LOD matrices, Danny's function gives every Cauchy −log*P* of Table 1c to within 0.05.
- **The code turns LODs into P values as 10^−LOD.** That is right only for a test on 1 d.f. on the −log10 *P* scale, and these LODs are on 3 d.f. (four genotypes).
  - **The correct P values lower the Cauchy −log*P* of every Vita locus at or above 1.5 by 0.45 to 0.72.**
  - **Loci at or above 1.5 fall from 25 to 22 (combined), 25 to 22 (male) and 9 to 5 (female).**
- **The same mix-up affects the paper's LOD thresholds.**
  - **LOD 3.95 on 3 d.f. is −log10 *P* = 3.40,** so with 442 tests its genome-wide *P* is about 0.18, not 0.05.
  - **The 10%, 5% and 1% thresholds would be LODs of 4.21, 4.53 and 5.26,** not 3.65, 3.95 and 4.65.
- **LODs rounded to 0.00 force a locus's Cauchy *P* to 1.**
  - **Male Vita14a and Vita18a are published at 0.00** but score 3.08 and 2.34 with those values left out (2.48 and 1.81 on 3 d.f.).
- **For the BXD paper:** use exact *P* values (ours are on the right d.f. already), keep the Cauchy combination over T-ages, and set the threshold over markers by permuting strains.

## A short lesson: what the Cauchy combination does

At each marker we have one scan per survivorship: 72 in the UM-HET3 paper (T35 to T1100 in 15-day steps), and 26 in ours. A locus may act only at some ages, so we want one *P* per marker that asks: "does this marker affect lifespan in any survivorship?"

**The difficulty is that the 72 scans are not independent.** Each survivorship is a subset of the one before it, so neighbouring scans share most of their mice.
- **Bonferroni over 72 scans would be far too strict,** because the scans are nearly copies of one another.
- **Taking the best scan without any correction would be too lenient.**

**The Cauchy combination test** (Liu & Xie 2020, *J. Am. Stat. Assoc.* 115:393) solves this without our having to know how correlated the scans are.
- **Each *P* is turned into a Cauchy variable,** tan[(0.5 − *P*)π]. A small *P* becomes a large positive number: *P* = 10⁻⁴ gives 3,183.
- **The values are averaged, and the average is turned back into a *P*.**
- **Because the Cauchy distribution has such heavy tails, the average behaves like a single Cauchy variable** whatever the correlation between the scans. The combined *P* is therefore close to correct for small *P*.
- **It adapts to the correlation by itself.** If all 72 scans were identical, the combined *P* would equal the single *P*. If they were independent, it would be close to Bonferroni over 72.

**This is what Rob describes** as evaluating "the dynamics of change of mapping with truncation age": the combination works out from the scans themselves how much the T-ages overlap.

**The paper then adjusts the Cauchy *P* values over the 891 markers** with Benjamini–Hochberg, a false discovery rate, and calls a Cauchy −log*P* of 1.5 or more significant.

## What the code does, and five problems

`Cauchy.R` defines:

```r
cauchycombination <- function(p) {
   qc <- qcauchy(p, lower.tail=FALSE)      # tan((0.5 - p) * pi)
   pc <- pcauchy(mean(qc), lower.tail=FALSE)
   pc
}
```

**This is the Liu–Xie statistic with equal weights, and it is correct.** The problems are in what goes into it and what comes out.

**1. LOD is not −log10 *P* for these scans.**
- **`Cauchy.R` calls `cauchycombination(10 ^ -lods)`.** The LODs come from `ProgressiveMapping.R` as (*n*/2)·log10(RSS₀/RSS₁).
- **They are for four genotype probabilities,** which add 3 d.f. to the model. The *P* value of such a LOD is Pr(χ²₃ > 2 ln(10)·LOD).
- **10^−LOD is smaller than that *P* at every LOD,** by a factor that grows from 1.4 at LOD 0.3 to 3.6 at LOD 4. For example, LOD 2 gives *P* = 0.010 by 10^−LOD, but 0.027 on 3 d.f.
- **So the code overstates significance.** Recomputed on 3 d.f., every Vita locus at or above 1.5 drops by 0.45 to 0.72 (table in the output file). These loci fall below 1.5:
  - **Combined:** Vita11a, Vita11c and Vita15b.
  - **Male:** Vita2c, Vita3a and Vita9a.
  - **Female:** Vita1a, Vita9b, Vita11b and Vita12a.

**2. The paper's LOD thresholds have the same mix-up.**
- **Methods says:** "The threshold at a genome-wide type 1 Bonferroni error rate of 10% is 3.65 LOD (–log10(0.1/442) at 5% it is 3.95, and at 1% it is 4.65."
- **Those are −log10 *P* values, applied as LODs.** On 3 d.f. they need LODs of 4.21, 4.53 and 5.26.
- **The maternal and paternal maps (1 d.f.) err the other way.** There the thresholds are conservative, and LOD 3.24 would already give 5%.
- **`stratifiedPerms.R` would settle this directly on the LOD scale.** It permutes lifespans within sex and site and records the largest LOD of each permutation, but its results are not in the paper.

**3. A LOD of 0.00 forces the combined *P* to 1.**
- **The LOD tables are rounded to two decimals.** A LOD under 0.005 becomes 0.00, then *P* = 1. The Cauchy transform of 1 is minus infinity, so the combined *P* is 1 whatever the other 71 survivorships show.
- **This affects 26 markers in the combined maps, 43 in males and 26 in females.**
- **It matters for two loci.** Male Vita14a has a male LOD of 5.36 at T65 and male Vita18a one of 3.73 at T110, yet Table 1c gives both a male Cauchy −log*P* of 0.00. With the single 0.00 left out, they score 3.08 and 2.34 (2.48 and 1.81 on 3 d.f.).
- **The female 0.00s** (Vita6b, VitaXa, VitaXb) **are genuine:** their female LODs never exceed 1.04.

**4. Large *P* values pull the combination down.**
- **This is a property of the method, not a bug.** Survivorships in which a locus has no effect give *P* near 1, and their Cauchy values are large and negative: *P* = 0.999 gives −318.
- **So the test is conservative for loci that act only at some ages,** which are just the loci actuarial mapping is meant to find.
- **The remedies:** use exact (unrounded) *P* values, and check results against a permutation threshold. The harmonic mean *P* (Wilson 2019, *PNAS* 116:1195) is also valid under dependence and is not pulled down by large *P* values.

**5. Smaller points.**
- **The cut-off.** A Benjamini–Hochberg −log*P* of 1.5 is a false discovery rate of about 3%; 5% would be 1.30. Either way it controls the false discovery rate over markers, not genome-wide type 1 error, although the text calls it "*P* of less than 5%".
- **`SimpleM.R` correlates the four-way genotype codes 1–4 as if they were numbers.** It then takes the smallest *M*eff over 50 block lengths. Both choices lean toward too few independent tests.
- **The current `ProgressiveMapping.R` keeps only `sex == 1` (males) in its "combined" scan.** It did not affect the paper: the published combined LODs (Supplementary Table 9.1) differ from the male ones (*r* = 0.70) and start at T35, not T20, so they came from another version of the code. The line should be fixed before anyone reruns it.
- **`grep(marker, ...)` picks a marker's genotype columns without anchoring the name.** A marker whose name is contained in another's would take extra columns.

## Using it in the BXD paper

- **Input *P* values.** Our R/qtl2 maps already give −log10 *P* on the right d.f.: 1 d.f. for B against D, and 1 d.f. for the interaction. They are stored unrounded, so *P* = 10^−|value| is correct for them.
- **Cauchy over T-ages, at each marker and map.** That means 26 survivorships (T20 to T770) for chow, high fat, both diets and the interaction. Use Danny's function unchanged, but never pass *P* = 1: leave out exact zeros, or use the unrounded *P*.
- **Over markers.** The BXD.8 panel has 21,056 markers in far fewer independent blocks.
  - **Simplest:** `simpleM` on the strains' B/D genotypes, which suit it better than four-way codes, then Bonferroni over *M*eff.
  - **Better, and in keeping with our rule that the strain is the unit:** permute the genotypes among strains, keeping each strain's mice together. Rerun the whole actuarial stack, and take the largest Cauchy −log*P* over markers in each permutation. That gives one genome-wide threshold for markers and T-ages together, with no asymptotic assumption.
  - **Cost:** the kinship scans take about 30 minutes per full stack, so 1,000 permutations need a faster route. Options are strain-level scans, a fixed heritability, or fewer permutations on a cluster.
- **Flags on the maps.** Once there is a threshold, the T-ages at which a locus passes can be marked on the maps, as Rob suggested.
- **mash** (Urbut et al. 2019) is complementary. It would sort loci into shared and diet-specific, using the same scans with their effects and standard errors.

## For Danny and Saunak

Points 1 to 3 change numbers in Table 1 and the thresholds of Fig. 1 and Methods. They are worth a check with Danny and Saunak before the BXD paper reuses the method. A rerun of `stratifiedPerms.R` on the published cross (Supplementary Table 7) would give LOD thresholds by permutation and show which of points 1 and 2 matters in practice. It needs R/qtl, which is not installed here.

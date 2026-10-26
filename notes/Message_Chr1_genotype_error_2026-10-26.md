# UM-HET3 Chr 1: a genotyping-set artifact behind the paternal H excess

**To:** Danny Arends, Rob Williams\
**From:** Claude (Opus 5.5), working with Rob in `robwwilliams/bxd_mortality_rates_2026`\
**Date:** 26 October 2026

Dear Danny and Rob,

At Vita1a and Vita1b, paternal H outnumbers paternal D about 2:1. The cause is a genotyping artifact, not distorted transmission. A few MonsterPlex SNPs lose heterozygous calls in one of the two marker sets in Supplementary Table 5. The calls looked confounded with site only because the sites were genotyped with different sets. Everything below can be rerun from the repository in under a minute.

## Summary

1. **There are two genotyping sets, not one.**
   - Supplementary Table 5 has 912 marker rows named by position (`1_3010274`), which I call set A, and 253 named by rsID (`rs31443144`), which I call set B.
   - Nearly every mouse has calls in only one set:

     | Site | Set A | Set B |
     |---|---|---|
     | JL | 2,236 | 0 |
     | UM | 1,245 | 1,497 |
     | UT | 0 | 1,883 |

   - One mouse (UM17843) has calls in both sets, and 10 in neither.
   - UM mice are split between the sets in seven of the nine UM cohorts; 2011 is all set B and 2013 all set A. So within UM, set and site can be separated.
   - **JL looks clean because every JL mouse was genotyped with set A.**
2. **Set B loses heterozygotes at a few "incidental" SNPs.**
   - At any SNP where one founder strain is odd, half of the calls should be heterozygous.
   - 168 autosomal SNPs were called in at least 200 mice by both sets. The heterozygous fraction of set B minus set A has a median of −0.02.
   - The two sets differ by more than 0.10 at 12 of these SNPs, and every one is an incidental (secondary) SNP in Supplementary Table 4.1.
     - At 11 of the 12, set B has too few heterozygotes. At three of those, it has almost none.
     - At the twelfth, 12_65049772, set A at UM has too many heterozygotes.
3. **Most of the bad set-B calls were dropped from the R/qtl file, but not all.**
   - Of the 11 SNPs where set B loses heterozygotes, the call counts in Table 7 match set A alone at seven. So your QC seems to have removed those set-B calls.
   - The set-B calls stayed in at the other four, and at one SNP genotyped only in set B. Four of these five lie at Vita loci on Chr 1:

| SNP in Table 7 | Set B name | Locus | Set A, JL | Set A, UM | Set B, UM | Set B, UT |
|---|---|---|---|---|---|---|
| 1_3010274 | rs31443144 | Vita1a peak amplicon | 0.48 (399) | 0.70 (371) | 0.06 (932) | 0.30 (915) |
| 1_31062737 | rs230225148 | Vita1b, distal flank | 0.49 (1,613) | 0.41 (17) | 0.27 (1,443) | 0.25 (1,852) |
| 1_132295971 | rs33889206 | inside Vita1c | 0.50 (1,313) | 0.50 (768) | 0.22 (1,360) | 0.47 (1,847) |
| 1_167148678 | rs32557046 | Vita1d peak | not typed | not typed | 0.16 (1,310) | 0.20 (1,029) |
| 17_83900092 | rs29762406 | none | 0.49 (1,863) | 0.48 (1,058) | 0.05 (953) | 0.36 (739) |

   - The values are heterozygous fractions, with the number of mice called in parentheses. All five SNPs are DBA/2J-specific, so a heterozygote means the father gave D, and the expected fraction is 0.50.
   - A lost heterozygote is read as paternal H. These SNPs explain the H : D excess in Supplementary Table 2:

     | Locus | Paternal H : D |
     |---|---|
     | Vita1a | 2.02 |
     | Vita1b | 1.91 |
     | Vita1d | 1.39 |
     | Vita1c | 1.15 |
     | 25 loci off Chr 1 | 0.91–1.11 |
4. **At 31.06 Mb, set B misses the D allele only when the mother is B.**
   - The mother's haplotype is read at 24.04 Mb, where C57BL/6J is the odd strain: 0/1 means mother B and 1/1 means mother C.
   - Heterozygous (paternal D) fraction at 31.06 Mb:

     | | Mother B | Mother C |
     |---|---|---|
     | Set A, JL | 0.48 (526) | 0.48 (544) |
     | Set B, UM | **0.05** (711) | 0.48 (730) |
     | Set B, UT | **0.01** (935) | 0.49 (913) |

   - So set B calls true BD mice BH. That is the whole BD deficit at Vita1b.
   - Set B at UM also makes 25 impossible 1/1 calls at this DBA/2J-specific SNP, 23 of them in mice with a C mother.
   - My guess is allele-specific amplification in this amplicon in set B, but only the read depths can settle it.
5. **The 3.01 Mb amplicon (Vita1a) is unreliable outside JL, in both directions.**
   - Set B loses heterozygotes whatever the mother: UM 0.06, UT 0.30.
   - Set A at UM has too many heterozygotes (0.70).
   - Call rates at this amplicon are low even in set A: 399 of 2,236 JL mice.
   - Set B reports only rs31443144 (= 1_3010274), so 1_3010272 holds set-A calls only. This explains why two SNPs 2 bp apart showed 42% and 71% paternal H in Table 7 yet agreed in every mouse called at both.
   - At the 31.06 Mb amplicon, set B likewise drops the two SNPs that set A reports beside the one it keeps, 1_31062758 and 1_31062759.
6. **Between 0 and 34 Mb, set-B mice have no reliable paternal marker.**
   - The nearest good one is 1_34173196 (0.48 at UM, 0.50 at UT).
   - The paternal genotype at the Vita1a and Vita1b peaks is therefore inferred from faulty SNPs in about 3,400 mice.

## What this means for Vita1a to Vita1d

- **The LOD scores at Vita1a, Vita1b and Vita1d (and perhaps Vita1c) need a rescan** after the faulty calls are removed. I can't predict the direction of the change.
- **The level effect of paternal D at Vita1a probably survives.**
  - A set-B heterozygous call is probably real, so the dropout mostly moves true D mice into the H class. That should dilute a real D effect, not create one.
  - In my fits from 200 d with a level for each site × cohort, paternal D raises mortality at 600 d about 1.2-fold at UM + UT in both sexes. At JL, where the calls are clean, the ratio is 1.29 in females and 0.97 in males.
  - Its effect on MRDT does not survive (P = 0.22, 2 df).
- **Correction to Part 3 of Rob's report:** I described the bias as a site effect. It is a set effect that looks like a site effect, because JL is all set A and UT is all set B.

## How to replicate

**Code:** `https://github.com/robwwilliams/bxd_mortality_rates_2026`, branch `main`, commit `________`. Rob fills this in once the check is pushed.

**Inputs:** your Supplementary Tables, from `Arends_Supplementary_Tables_10Apr2026.zip`. They are not in git. Any folder works, because the scripts take paths.

| File | SHA-256 |
|---|---|
| `S_Table_4_Primers_MonsterPlex_Mouse_20Aug2025.xlsx` | `caa6c47490034f43cb0b21753c1aed22aa57bb7031e108bf852eb498c1811918` |
| `S_Table_5_VCF_coded_genotypes_metadata_18Aug2025.xlsx` | `f8e82b6c4f319b4f893479370566e76a36ee9244cc3c2b086aaf280b7ed18404` |
| `S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr` | `2e1c5eb322561b40790d8c63a13a5ef745620a58204d68f8bfdd792eaa73d8f3` |

**Software:** R 4.6.1 with readxl 1.6.0 and survival 3.8.12. Run from the repository root:

```bash
export LC_ALL=C.UTF-8
D=data/local/Arends_Supplementary_Tables_10Apr2026
X="$D/S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr"
Rscript UMHET3/vcf_set_check.R "$D/S_Table_5_VCF_coded_genotypes_metadata_18Aug2025.xlsx" "$D/S_Table_4_Primers_MonsterPlex_Mouse_20Aug2025.xlsx" "$X" > output/UMHET3_VCF_sets_check.log
Rscript UMHET3/chr1_marker_check.R "$X" > output/UMHET3_markers_chr1_check.log
Rscript UMHET3/vita1_site_check.R "$X" > output/UMHET3_Vita1_site_check.log
git diff --stat output/    # empty if your numbers match ours
```

Each script takes a few seconds. I reran all three today, and the tracked outputs came back identical.

**What each script does:**

- **`UMHET3/vcf_set_check.R`** works on the raw calls (Table 5).
  - Set A is the rows named `chr_position`; set B is the rows named by rsID. rsIDs are mapped to positions with Table 4.1 (columns `SNP rsID`, `Chr`, `Position (Bp)`).
  - A mouse belongs to the set whose rows hold any of its calls.
  - For each SNP it gives the heterozygous fraction (0/1 among called) by set and site. VCF codes: 0 = C57BL/6J reference, 1 = any other strain.
  - It compares the two sets at shared autosomal SNPs and tabulates 31.06 Mb and 3.01 Mb against the mother's haplotype.
  - Writes:
    - `output/UMHET3_VCF_sets_by_marker.txt`: every row of Table 5, with the number called and the heterozygous fraction in each set and site;
    - `output/UMHET3_VCF_set_by_mouse.txt`: GenoID, site and set;
    - `output/UMHET3_VCF_sets_check.log`.
- **`UMHET3/chr1_marker_check.R`** works on the R/qtl file (Table 7).
  - It counts calls that name the father (H: codes 1, 2, 7; D: codes 3, 4, 8) and the mother (C: 1, 3, 5; B: 2, 4, 6) at every marker, and by site on Chr 1 below 60 Mb.
  - Codes: 1 = CH, 2 = BH, 3 = CD, 4 = BD; 5 / 6 = mother C / B; 7 / 8 = father H / D. They are confirmed on X, where daughters carry only codes 1 and 2.
  - Sites 1.0, 2.0 and 3.0 are JL, UM and UT.
  - Writes `output/UMHET3_markers_genome.txt`, `UMHET3_markers_chr1_by_site.txt`, `UMHET3_31Mb_father_by_mother.txt` and the log.
- **`UMHET3/vita1_site_check.R`** fits individual ages at death by maximum likelihood (`Gompertz/gompertz.R`), from 200 d.
  - Each site × cohort gets its own level, and each genotype class one slope per sex.
  - Vita1a's paternal call is the agreement of 1_3010272, 1_3010274 and 1_4344820. Set-B mice have only 1_3010274, so their call rests on the faulty SNP.
  - Writes `output/UMHET3_Vita1_site_check.txt`.

## Suggested next steps (Danny)

1. **Check the allele depths (AD) in the original VCFs** at the 12 SNPs, by set. VCF codes can't tell amplification bias from a caller threshold.
   - Were sets A and B different primer pools, sequencing runs or calling pipelines? Set B reports only the rsID'd SNP in each amplicon.
2. **Rescan without the faulty calls.**
   - Drop the set-B calls at the five SNPs in the table above, or at any SNP where the two sets differ by more than 0.10.
   - Recompute the genotype probabilities and rescan Vita1a to Vita1d.
   - A quick bound: rescan with set-A mice only (JL and 1,245 UM).
3. **Make the same check a standard QC for the Ultima low-pass genotypes:**
   - the heterozygous fraction per SNP by batch, which should be 0.5;
   - impossible genotypes, such as 1/1 at a SNP specific to one paternal strain;
   - the paternal call split by the maternal haplotype.

**Other markers worth a look.** Their biases are in set A, not set B:

| SNP | Odd strain | Heterozygous fraction (set A) | Table 7 paternal H |
|---|---|---|---|
| 1_37893993 | DBA/2J | 0.35 at JL, 0.39 at UM | 0.63 |
| 17_34460076 | C3H/HeJ | 0.41 at JL, 0.33 at UM | 0.38 |
| 10_100488594 | C3H/HeJ | 0.60 at JL, 0.58 at UM | 0.58 |
| 12_65049772 | DBA/2J | 0.53 at JL, 0.78 at UM | 0.42 |

The full genome-wide list is in `output/UMHET3_markers_chr1_check.log`.

Best wishes,
Claude, for Rob

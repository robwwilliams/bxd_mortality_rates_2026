# Vita1a: why the sign flips between BXD and UM-HET3, read from founder sequence

**Exploratory, 24 November 2026,** by Claude (Opus 5.5) for Rob Williams, after the signs were seen. Code: [`UMHET3/vita1a_founder_variants.R`](../UMHET3/vita1a_founder_variants.R). Results: [`output/Vita1a_founder_variants.txt`](../output/Vita1a_founder_variants.txt), with every site in [`output/Vita1a_founder_variants_sites.txt`](../output/Vita1a_founder_variants_sites.txt).

Rob: "It is clear that Vita1a is the same beast in both UM-HET3 and BXDs (as it should be from first principles). But the effect reversal is both a puzzle and a WONDERFUL functional clue if we just use our little gray cells."

## The puzzle

- **In BXD, the *D* allele lives longer:** *D* − *B* > 0 at the 5.02 Mb marker at every T-age, on chow and high fat. The locus is defined (genome-wide) at T770 on chow, in a block from 4.86 to 5.32 Mb holding *Tcea1*, *Rgs20* and *Atp6v1h*.
- **In UM-HET3, the paternal *D* allele lives shorter:** *D* − *H* < 0 at every T-age from T20 to T860, in both sexes (−log10 *P* about 2–5.5). The UM-HET3 markers (3.0, 4.3, 6.2 and 8.0 Mb) cannot place it within 3–8 Mb.
- **The UM-HET3 maternal map is flat there:** *B* against *C*, median −log10 *P* about 0 from 3 to 8 Mb, in both sexes.

## A short lesson: what each contrast can see

A variant affects a contrast only if the two alleles compared differ at it. Four founders, C (BALB/cByJ), B (C57BL/6), H (C3H/HeJ) and D (DBA/2J):
- **BXD sees** variants where B and D differ.
- **UM-HET3 paternal** sees variants where D and H differ.
- **UM-HET3 maternal** sees variants where B and C differ.

**So a variant that only DBA/2J carries (D-private) moves BXD and the paternal contrast the same way.** It cannot, by itself, make *D* better than *B* but worse than *H*. That includes the 11 kb LTR in *Atp6v1h*, which to Rob's knowledge only the D haplotype carries.

**With additive effects, the two signs together mean the alleles rank *H* > *D* > *B*.** That calls for a variant at which C3H carries a long-life allele that DBA/2J lacks.

## What the founder sequence shows

Supplementary Table 17 of Arends et al. 2026: short-read calls (SNPs and short indels; **no structural variants**, so not the LTR) for the four founders, with C57BL/6NJ standing in for B6. Kept: every founder called and homozygous, depth at least 5, QUAL at least 30. 24,885 variable sites from 3 to 7 Mb.

| Pattern (C B H D) | Proximal flank, 3.0–4.86 Mb | BXD block, 4.86–5.32 Mb | Distal flank, 5.32–7.0 Mb | Contrasts it touches |
|---|---|---|---|---|
| D-private | 7,533 | 428 | 2,362 | BXD and paternal, same sign |
| C3H-private | 2,979 | 485 | 3,672 | paternal only |
| H = D against C = B | 2,568 | 284 | 1,604 | BXD only |
| B = H against C = D | 6 | 354 | 918 | BXD, paternal, maternal |
| B6-private | 56 | 170 | 1,091 | BXD and maternal |
| BALB/c-private | 55 | 135 | 74 | maternal only |
| B = D against C = H | 4 | 27 | 5 | paternal and maternal |
| three or more alleles | 36 | 6 | 33 | all |

**The flat maternal map is the key.** It argues that patterns touching the maternal contrast carry no large effect here: B6-private, BALB/c-private, B = H against C = D, B = D against C = H, and the multi-allelic sites. That leaves a simple additive account:
- **BXD's *D* advantage** from D-private sites (the LTR is one candidate) or H = D against C = B sites.
- **The UM-HET3 reversal** from C3H-private sites, which BXD cannot see, where the C3H allele lives longer by more than the D-private allele does.

**C3H's haplotype is distinct in *Rgs20*:** 363 of the block's 485 C3H-private sites lie in it.

**Coding sites in the block** (RefSeq coding exons, mm10):

| Position | Gene | Pattern | Contrasts | Note |
|---|---|---|---|---|
| 4,867,496 and 4,878,056 | *Tcea1* | H = D against C = B | BXD only | |
| 4,912,461 | *Rgs20* | C3H-private | paternal only | a candidate for the reversal |
| 4,923,964 | *Rgs20* | B = D against C = H | paternal and maternal | in the start codon of isoform NM_001290372 (Supplementary Table 1's start_lost); argued against by the flat maternal map |
| 5,070,062 | *Rgs20* | D-private | BXD and paternal | |
| 5,095,686 | *Atp6v1h* | B6-private | BXD and maternal | argued against by the flat maternal map |
| 5,124,338 | *Atp6v1h* | B = D against C = H | paternal and maternal | argued against by the flat maternal map |
| 5,150,035 | *Atp6v1h* | C3H-private | paternal only | a candidate for the reversal |

## Cautions

- **Additivity is an assumption.** BXD compares homozygotes; UM-HET3 compares heterozygotes on segregating backgrounds, and Vita1a interacts with Vita6b, Vita9a and Vita11a in UM-HET3 females. Dominance or epistasis could flip a sign without a third allele.
- **The C3H-private variants need not lie in the BXD block.** BXD cannot see them, and UM-HET3 cannot place its signal within 3–8 Mb; 7,136 C3H-private sites lie between 3 and 7 Mb.
- **The UM-HET3 paternal calls on proximal Chr 1 are biased toward *H* at UM and UT** (notes/Message_Chr1_genotype_error_2026-10-26.md).
- **A flat maternal map is weak evidence of no effect,** not proof.
- **Structural variants are missing.** Rob has asked David Ashbrook and Flavia Villani to focus their long-read analysis on Vita1a and Vita1b, looking for "weird stuff"; the LTR and anything like it will come from there.

## What would test it

- **Long reads (David Ashbrook, Flavia Villani):** whether C3H/HeJ carries its own structural variant in *Rgs20* or *Atp6v1h*, and the LTR's state in all four founders.
- **The pangenome (Flavia Villani, Andrea Guarracino) with Pjotr Prins's mapping:** the BXD *D* − *B* effect and the UM-HET3 paternal effect fitted to the same variants.
- **Expression:** if the C3H allele of *Rgs20* or *Atp6v1h* acts through expression, a cis difference between C3H and DBA/2 in an F1 would show it.

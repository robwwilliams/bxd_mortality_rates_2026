# UM-HET3 deaths per 15 days by Vita genotype (clean copy of Arends et al. Supplementary Table 2)

These 87 files are Supplementary Data Table 2 of Arends et al. 2026 (*Nature* 654:437), made by `UMHET3/clean_table2.R` from the published ZIP in `data/original/`. The numbers are unchanged.

## What was fixed

- **The first column is named `T-age`.** As published, no file names it, so the header is one name short.
- **Window labels use plain hyphens** (`5-20`).

## Checks, all passed in every file

- **The marginal columns add up:** C = CH + CD, B = BH + BD, D = CD + BD, H = CH + BH.
- **Numbers alive fall by exactly the deaths,** so there is no censoring.
  - Every genotyped mouse dies within the table.
  - nGenotyped is the sum of the four alive columns.
- **Female + male = combined** for every column.

## Files and columns

`<locus>_deathsIn15Dwindows_<female|male|combined>.txt`, for the 29 loci Vita1a to VitaXa.

| Column | Content |
|---|---|
| T-age | The 15-day window, in days of age (`35-50` is ages 35 to 50) |
| CH, CD, BH, BD | Deaths in the window by genotype. The first letter is the maternal haplotype (C = BALB/cByJ, B = C57BL/6J), the second the paternal (H = C3H/HeJ, D = DBA/2J) |
| C, B, D, H | Deaths by one haplotype, summed over the other parent's two |
| CH_alive … BD_alive | Mice of each genotype alive at the start of the window |
| nGenotyped | Mice alive with a genotype call at this locus |
| nTotal | All mice alive, called or not (6,438 that passed genotype QC) |

- **The first two rows are buffers.** Per the Supplementary Information Guide, they do not differ from the `35-50` row, because no mouse entered the study before its tail was docked for DNA.
- **Arends et al. used T-ages from T42 to T1100.**

## Caution: genotype calls on proximal Chr 1

Paternal H outnumbers paternal D about 2:1 at Vita1a and Vita1b, but not at any locus off Chr 1:

| Locus | Paternal H : D | Maternal C : B | Mice called, of 6,438 |
|---|---|---|---|
| Vita1a | 2.02 | 0.96 | 3,133 |
| Vita1b | 1.91 | 0.95 | 5,174 |
| Vita1d | 1.39 | 0.98 | 4,764 |
| Vita1c | 1.15 | 1.04 | 5,485 |
| 25 loci off Chr 1 | 0.91–1.11 | 0.88–1.07 | 2,753–6,319 |

- **At Vita1b the D deficit depends on the mother's haplotype:** BH : BD is 3.1 but CH : CD only 1.2. A distortion in the fathers' transmission could not depend on the mother's allele.
- **Nor can BD itself be lethal:** B6D2F1 hybrids are B/D at every locus and live long.
- **The raw MonsterPlex calls confirm it** (`UMHET3/vcf_set_check.R`).
  - One of the two marker sets loses heterozygous calls at a few SNPs, among them 1_3010274 (Vita1a), 1_31062737 (Vita1b) and 1_167148678 (Vita1d). That set typed half of the UM mice and all of the UT mice.
  - See `notes/Message_Chr1_genotype_error_2026-10-26.md`.
- **So the excess is most likely a genotyping problem.** Use the Chr 1 loci with care until the low-pass whole-genome sequencing redoes these calls. See Part 3 of the report in `notes/`.

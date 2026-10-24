# Genotypes

## BXD_genotypes_Chr1_0to35Mb.txt

Proximal Chr 1 (first marker at 3.0 Mb, through 35 Mb) from the sequence-based BXD genotypes of David Ashbrook: 518 markers by 207 BXD strains, coded B, D, H (heterozygous) and U (unknown).
- **Source.** The workbook `BXD_Sequence_based_updated_genos_edit_for_Rob_to_Play_With.xlsx` (sheet `BXD_updated_genos_25_10_18_edit`, started 22 October 2018, updated 23 September 2019). Rob Williams supplied it on 23 October 2026, because GeneNetwork was offline.
  - **SHA-256 of the workbook:** `20ed77f308e4eb98c0bee0410e5d55d6891a3b7149473277eb2e917b0543bcc2`
  - The workbook itself is not stored here (24 MB).
- **Extraction.** Made by `tools/extract_chr1_genotypes.py`, with one change: marker DA0000048.1 has its position in bp (4858261) rather than Mb, and it is converted to 4.858261. Everything else is as in the workbook.
- **SHA-256 of this file:** `1bc1d63300527c528e64c983bc953cd86c2e99e7a53db7370a528fe5df89f682`
- **Notes in the workbook header** list strains whose sequence and array genotypes disagree, among them BXD36, BXD53, BXD54, BXD83, BXD88, BXD151 and BXD162. The header also records that BXD65b carries the BXD65 genotype. Positions are as given in the workbook.

`Genotypes/Chr1_haplotypes.R` classifies each strain from this file. Its calls are in `output/Chr1_haplotypes.txt`.

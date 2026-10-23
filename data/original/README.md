# Original data

Files here are kept exactly as received. Corrections go into derived files elsewhere, never into these.

## BDL_10002.xlsx

The GeneNetwork export of trait BDL_10002, natural lifespan in days.
- **Source:** dataset BXD-LongevityPublish, http://genenetwork.org/show_trait?trait_id=10002&dataset=BXD-LongevityPublish
- **Exported:** 22 October 2026 at 17:49 GMT.
- **SHA-256:** `1beefc524123c885ff173defbb74804826e4676b9595d8a5a42570584f988717`

**Layout.** Rows 1–10 are GeneNetwork metadata; the column headers are on row 11. There are 3,281 animals:
- **2,594 natural deaths.** IDs start L (longevity colony), F (BXD×BXD F1 hybrids) or N (high-fat diet with 1% NAM).
- **687 harvested animals.** IDs start H, with Value `x`.

The groups include females and males, the parental strains and F1 hybrids, and three diets: `CD`, `HF` and `NAM`.

**Columns.**

| Column | Content |
|---|---|
| Name | Animal ID: letter prefix plus ear tag |
| Value | Age at natural death in days, or `x` if harvested |
| Sex, Strain, Tx | Sex, strain, diet (`CD` chow, `HF` high fat, `NAM` high fat with 1% NAM) |
| Age | Age at death or harvest in days |
| EarTag | Ear tag number |
| Longevity | Should equal Value |
| RRID, Epoch | Strain identifier and BXD breeding epoch |
| KM20, SR21, EW21, KM21 | Membership flags for earlier studies |

**Known problems.** See `qc/BDL_10002_QC.md`. Value and Longevity differ in 128 rows, all listed in `qc/BDL_10002_value_vs_longevity.csv`:
- **126 natural deaths** have Longevity blank.
- **H0004** (harvested) has Longevity blank instead of `x`.
- **L0852** has Value 663, but Age and Longevity are 845, which also matches the November 2018 record.

## BXD_Mortality_for_Mapping_Arends.xlsx

Suheeta Roy's curated file of BXD family females used for actuarial mapping by Danny Arends. Received from Rob Williams on 23 October 2026 and kept unchanged.
- **SHA-256:** `7f4b373ea9da132b6dbd7608d77c871a9f208b081f6869942272ab339dfa4457`

**Layout.** Rows 1–9 are notes on sample sizes; the column headers are on row 10. There are 2,106 females:
- CD 1,044
- HF 890
- HF + 1% NAM 172

**Columns.** Index, Ear tag, Diet, Strain, Age at death (days), Age at set up (days), Vivarium (1 = Nash, 2 = Nash then TSRB, 3 = TSRB).

**Compared with the GeneNetwork export of 22 October 2026:**
- **Same animals.** Every animal here is a natural death in that export.
- **Fewer animals.** This file leaves out males, BXD × BXD F1s, and the 2018 "Other" exclusions (same-day culls). It keeps the 2018 LowOutliers.
- **Ages.** Where the two disagree on age at death, this file agrees with the November 2018 records.

The Gompertz analysis in `Gompertz/` uses this file.

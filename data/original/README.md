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

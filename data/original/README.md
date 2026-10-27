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

## Arends_2026_Supplementary_Table_2.zip

Supplementary Data Table 2 of Arends et al. 2026 (*Nature* 654:437), as published (file `S_Table_2_Vita_mortality_by_age_and_genotype_text_files.zip` in `Arends_Supplementary_Tables_10Apr2026`).
- **SHA-256:** `90ce5c43097d4d9e1e7a5dbe52b27a0771a8b6d73fdbb9fb569b9d8526428a9f`

**Layout.** 87 tab-separated text files, one per Vita locus (29) and sex (female, male, combined): deaths per 15-day window by genotype, and numbers alive at the start of each window. The ZIP also holds macOS `__MACOSX` folders, which are not data.

**Known problems.**
- **No file names its first column** (the window, `5-20` to `1475-1490` days), so the header is one name short and R reads that column as row names.
- **The 2:1 excess of paternal H over paternal D** at Vita1a and Vita1b (and less at Vita1c and Vita1d) is in the files as published. It is most likely a genotyping problem on proximal Chr 1; see `data/umhet3/Table2/README.md`.

Clean copies, with the header fixed and every file checked, are in `data/umhet3/Table2/`.

## Body weights of the BXD aging colony: three workbooks

Suheeta Roy's body-weight workbooks, from `Roy_RawData_To_Danny.zip` (SHA-256 `1381de76cb404a2765c6f862c8bf04a54af1e8ab259439c22d44ab160b929f42`), which Rob Williams shared from Dropbox on 26 October 2026. Copied out of the ZIP unchanged; the file names, including " copy", are as received. The rest of the ZIP is in `data/local/`.

| File | SHA-256 | Content |
|---|---|---|
| `AgingBXD_BodyWeightData_updated31Dec2024.xlsx` | `bcb13f305ba998cb5fd64a463d6109d76fcac0dcba149555e4bdb1fa06189271` | BXD family females (128 genotypes) on CD and HF |
| `AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx` | `63e28dc6c81b7bbc8884c867a818d2a1594160b2101ae9af64eb6d6709670149` | BXD × BXD F1 females (18 F1 types) |
| `AgingBXD_NAM_BodyWeight_Feb2026.xlsx` | `bb83c2f10915445c25060d2e59c9317db5714c28eb8fb8ce7a52177853218b08` | Females on high fat with 1% NAM (187 mice) |

**Layout of `AgingBXD_BodyWeightData_updated31Dec2024.xlsx`.** The sheet `BXD_Females` has one row per mouse (2,621 rows):
- ear tag (current and original), strain, diet, sex and status (Natural, Euthanized, Harvest, LowOutlier, Other);
- age, date of birth, diet start and death;
- `Weight00 Baseline` at set-up, then up to 20 weighings (`Weight01`–`Weight20`, grams), each with `AgeAtWeightNN`, `DateWeightNN` and `DaysOnDietAtWeightNN`.

Weighings are about every 66 days. The other sheets are subsets of `BXD_Females` for single ages (baseline, 2, 6, 12, 18 and 24 months).

**Layout of the F1 workbook.** The sheet `NaturalDeath` has 310 F1 mice that died (Natural 141, Euthanized 168, Other 1), with up to 18 weighings in the same layout; `CauseOfDeath` holds the status. The other sheets are subsets for single ages.

**Linkage.** All 1,934 mice of `BXD_Mortality_for_Mapping_Arends.xlsx` are in `BXD_Females` by ear tag, with the same strain and diet. Age at death agrees for 1,933 of them.

**Corrections.** Six F1s are labeled BXD73 rather than BXD73b, and euthanized F1s count as natural deaths in our analyses (Rob, 27 October 2026). Both corrections are in `data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt` (see `data/corrected/README.md`); the workbook here is unchanged.

**Used by** `BodyWeight/terminal_decline.R` (`notes/PLAN_terminal_decline.md`), through the corrected F1 table.

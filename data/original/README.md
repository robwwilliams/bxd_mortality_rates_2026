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

## BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv

A newer version of `BXD_Mortality_for_Mapping_Arends.xlsx`, as a CSV, from Beni Mozhui's public repository [github.com/squirrelB/BXD-Diet-Gompertz](https://github.com/squirrelB/BXD-Diet-Gompertz) (commit `ae85d295b905`, 21 November 2026). Downloaded on 21 November 2026 and kept unchanged.
- **SHA-256:** `fd43d919853b058c5ff3873d53773545a21f4828470a22464cc3bc810c6f98e7`

**Layout.** Rows 1–15 are notes on sample sizes; the column headers are on row 16. The first seven columns are as in the workbook. Columns 8–9 hold the Vita1a and Vita1b genotypes, and the rest hold body weights joined from `BXD_BodyWeight_AllDiets_Dataset_Mapping_Arends.xlsx` (not in this repository). There are 2,077 females:
- CD 1,044
- HF 890
- HF + 1% NAM 143

**Compared with the workbook** (`notes/Mozhui_comparison_results.md`):
- **The 1,934 chow and high-fat rows are the same** in all seven columns.
- **The 29 NAM mice of C57BL/6J (8) and DBA/2J (21) are left out,** as parental strains not used for mapping.
- **Four NAM mice die later:** ear tags 3527 (730 days, against 638), 4558 (229, against 155), 4590 (786, against 421) and 5026 (620, against 483). All four are flagged in `qc/BodyWeight_QC.md` as weighed after their recorded death, and each later age falls after the mouse's last weighing or set-up. Where the corrections came from is not yet known.

**Used by** `Gompertz/NAM_rectangularization.R mozhui`, which reruns Part 5's nicotinamide analysis with these four ages.

## Arends_Data_05Nov2026/

The two files Danny Arends mapped from in November 2026, from the folder `Data_05Nov2026` of `Arends_Figures_09Nov2026.zip`, which Rob Williams received on 21 November 2026. Copied out unchanged; the zip's result workbooks and figure drafts are not copied here.

| File | Dated | SHA-256 | Content |
|---|---|---|---|
| `BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.xlsx` | 4 November 2026 | `9376a9bb2833e71a897fe51aab06b0198244403c65e0ab4718f64e24b9312916` | 2,077 females: CD 1,044, HF 890, NAM 143 |
| `BXD_BodyWeight_AllDiets_Dataset_Mapping_Arends.xlsx` | 4 November 2026 | `78582bd0137813b6f13b003e1259071ec509d7d163d29e0257529c084cfb9425` | 1,765 females with body weights: CD 854, HF 778, NAM 133 |

**Layout of the lifespan file.** Rows 1–9 are notes on sample sizes; the column headers are on row 10, with the seven columns of `BXD_Mortality_for_Mapping_Arends.xlsx`. One cell of column 8 holds a note on NAM 4558.

**Layout of the body-weight file.** Rows 1–3 are notes; the column headers are on row 5. One row per mouse: ear tag, diet, strain, status, age at death, dates, `Weight00 Baseline` at set-up, then `Weight01`–`Weight20`, each followed by `AgeAtWeightNN`. Missing values are `x`.

**Compared with the other files** (`qc/Mapping_files_QC.md`):
- **The lifespan file is Beni Mozhui's CSV at an earlier stage.** It has the same mice and the same chow and high-fat rows, and the corrected age of NAM 4558, but not those of NAM 3527, 4590 and 5026.
- **In the body-weight file, 6 NAM mice have a slipped row** from `Weight13` on (15 weighings). Every other weighing matches Suheeta's workbooks.

**Used by** `qc/mapping_files_QC.R`.

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

# The files Danny mapped from, against Beni's corrected file

Rob, 21 November 2026: "Before we get started we should look at the files Danny used for mapping which may not included this small number of fixes that you requested Suheeta to make. Beni's file has these correction. So do a QC and comparison of what Danny used first."

**Exploratory.** The checks were chosen after the four NAM corrections in Beni's file were known. Nothing is changed.
- **Code:** [`qc/mapping_files_QC.R`](mapping_files_QC.R) (under 1 s).
- **Every difference and flagged mouse:** [`qc/mapping_files_QC.txt`](mapping_files_QC.txt).

## In brief

- **Chow and high fat: the same mice and ages in every file.** All 1,934 chow and high-fat mice in Danny's file match ours and Beni's in strain, age at death, set-up age and vivarium. His sample sizes recompute exactly: 929 mapped on chow, 818 on high fat, 143 on NAM.
- **NAM: one fix of four.** Danny's file has the corrected age of NAM 4558, but the old ages of 3527, 4590 and 5026. Beni's later file has all four.
- **The NAM ages do not touch Danny's Fig. 2.** It maps lifespan and body weight on chow and high fat only.
- **No chow or high-fat age has been corrected in any file.** 22 BXD mice that Danny mapped were weighed after their recorded death, 17 of them by 23 days or more. Three strain means could move by 4 to 10 months.
- **Danny's body-weight file has a slipped row in 6 NAM mice.** In each, one weighing is missing, and every later cell has moved one column left. Weights of 534–924 g therefore sit beside ages of 32–50 days. Beni's file carries the same slip; her analysis does not use the weights.
- **GeneNetwork's lifespan trait (BDL_10002, exported 22 October) still has all the old ages.** This matters for the GN4AI test drive.

## The files

| File | Date | Mice | Used for |
|---|---|---|---|
| Ours: `data/original/BXD_Mortality_for_Mapping_Arends.xlsx` | received 23 October 2026 | 2,106: CD 1,044, HF 890, NAM 172 | Parts 1–5 of our report |
| **Danny's lifespan file:** `data/original/Arends_Data_05Nov2026/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.xlsx` | 4 November 2026 | 2,077: CD 1,044, HF 890, NAM 143 | his lifespan maps (`QTL_Lifespan_05Nov2026.xlsx`; Fig. 2, top four rows) |
| **Danny's body-weight file:** `data/original/Arends_Data_05Nov2026/BXD_BodyWeight_AllDiets_Dataset_Mapping_Arends.xlsx` | 4 November 2026 | 1,765: CD 854, HF 778, NAM 133 | his body-weight maps (`QTL_BW_5Nov.xlsx`; Fig. 2, rows 5–6) |
| Beni's: `data/original/BXD_Lifespan_AllDiets_Dataset_Mapping_Arends.csv` | from her repository, 21 November 2026 | 2,077, as Danny's | her Gompertz fits |

- **Danny's files come from `Arends_Figures_09Nov2026.zip`,** which Rob received on 21 November 2026. The zip also holds his result workbooks and the Fig. 2 drafts (not copied here).
- **Danny's lifespan maps** are actuarial: one map per T-age from 20 to 770 days, in 30-day steps. His body-weight maps run from 80 to 740 days.

## 1. Lifespan: four NAM mice

| Mouse | Strain | Ours (23 Oct) | Danny's (4 Nov) | Beni's (21 Nov) | GeneNetwork (22 Oct) |
|---|---|---|---|---|---|
| NAM 4558 | BXD15 | 155 | **229** | **229** | 155 |
| NAM 3527 | BXD172 | 638 | 638 | **730** | 638 |
| NAM 4590 | BXD32 | 421 | 421 | **786** | 421 |
| NAM 5026 | BXD62 | 483 | 483 | **620** | 483 |

- **NAM 4558** carries Danny's note: "wrong DOD of 155 days has been corrected".
- **Nothing else differs.** Danny's file, like Beni's, leaves out the 29 NAM mice of C57BL/6J (8) and DBA/2J (21).

## 2. Mice weighed after their recorded death

These are the mice of rule E in [`qc/BodyWeight_QC.md`](BodyWeight_QC.md). Rob sent the chow and high-fat cases to Suheeta on 27 October.
- **Danny mapped 28 of them:** 22 BXD mice on chow or high fat and 6 on NAM. Four more are parental or F1 mice, which he did not map.
- **In all three mapping files and in GeneNetwork,** every chow and high-fat age is as before. Only the NAM ages above have changed.
- **The excess is often small.** Five mice were weighed only 1 to 7 days after their recorded death, which a weighing at euthanasia with a slipped date could explain. Seventeen were weighed 23 to 632 days after it.

**Strain means that could move.** If each flagged mouse lived at least to its last weighing, these chow and high-fat strain means would rise by 20 days or more:

| Strain, diet | Mice in Danny's set | Flagged mouse: recorded death, last weighing (days) | Mean age at death as recorded | At least |
|---|---|---|---|---|
| BXD218, chow | 2 | 3276: 631, 1,263 | 631 | 947 |
| BXD81, high fat | 1 | 5925: 299, 482 | 299 | 482 |
| BXD125, chow | 2 | 4834: 640, 903 | 722 | 854 |
| BXD160, chow | 3 | 3152: 691, 784 | 740 | 771 |
| BXD21, high fat | 3 | 4990: 307, 382 | 470 | 495 |
| BXD197, high fat | 4 | 2786: 453, 547 | 527 | 551 |
| BXD5, chow | 9 | 2847: 196, 403 | 607 | 630 |

- **The top three cells have one or two mice,** so one wrong age carries the whole strain mean.
- **BXD 3276 may hold another mouse's date of death.** Both BXD218 chow mice, 3275 and 3276, died at 631 days by the record, and 3276 was weighed 10 more times. Its weight falls to 18.2 g at 771 days, then jumps to 29.0 g at 833.
- **The full list of 32 mice,** with each file's age, is under Check 3 in `qc/mapping_files_QC.txt`.
- **GeneNetwork has one more difference:** BXD 2325 (BXD170, chow) died at 342 days in all three files, but at 333 days in BDL_10002.

## 3. Body weights

- **1,765 mice and 14,082 weighings in Danny's file.** All but 15 weighings match Suheeta's workbooks exactly, in weight and age. Strain, status and age at death match for every mouse.
- **The 15 are a slipped row in 6 NAM mice.** From `Weight13` on, one weight is missing and each later cell holds the value of the cell to its right in the workbook:

| Mouse | Strain | Danny's `Weight13`, `AgeAtWeight13` | Workbook `Weight13`, `AgeAtWeight13` | Weighings affected |
|---|---|---|---|---|
| NAM 2882 | BXD32 | 535, 33.2 | 35.2 g, 535 days | 2 |
| NAM 2883 | BXD32 | 535, 34.1 | 37.4 g, 535 days | 3 |
| NAM 2884 | BXD32 | 535, 40.3 | 45.2 g, 535 days | 4 |
| NAM 2889 | BXD44 | 534, 50.5 | 49.4 g, 534 days | 4 |
| NAM 2995 | BXD218 | 890, blank | 27.1 g, 890 days | 1 |
| NAM 3038 | BXD218 | 924, blank | 21.1 g, 924 days | 1 |

  - **The NAM workbook lists all the weights first and then all the ages.** Danny's file interleaves them. The slip probably happened in that reshaping.
  - **Its effect on Danny's NAM body-weight maps** depends on how his code reads the cells. It cannot touch Fig. 2, which has no NAM panels.
- **31 weighings in 23 mice fall after the age at death in Danny's lifespan file.** These are the mice of section 2 that have body weights. Three of the worst, BXD 3276, 4834 and 5925, are not in his body-weight file.
- **125 mice that Danny mapped for lifespan have no body weights in his file:** 75 on chow, 40 on high fat and 10 on NAM.

## What this means

- **Danny's Fig. 2 stands on the same chow and high-fat ages as Parts 1–4 of our report and as Beni's analysis.** The NAM corrections do not change it.
- **The open question is the 22 chow and high-fat mice.** Suheeta has corrected NAM ages, but none of these. Her answers on BXD 3276, 4834 and 5925 matter most, because each is half or all of its strain mean.
- **For any NAM mapping:** use Beni's four ages, and fix the slipped row of the 6 NAM mice.
- **For the GN4AI test drive:** GeneNetwork's lifespan values carry the old NAM ages, and BXD 2325 differs by 9 days. Chow and high-fat mapping from GeneNetwork should match Danny's input; NAM mapping would not.

**For Danny, a small point about his results:** in each sheet of `QTL_Lifespan_05Nov2026.xlsx`, the last two columns are both headed 770, and the second is empty. In `QTL_BW_5Nov.xlsx`, the last two are both headed 740, and the second is empty. (Corrected on 21 November 2026: this note first said the two columns hold different values. Both readers, readxl and openpyxl, find no values in the second.)

# Corrected data

Tables here carry our corrections to files in `data/original/`, which stay exactly as received. Each table keeps the recorded values in its own columns, so every change can be traced.

## AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt

The sheet `NaturalDeath` of `data/original/AgingBXD_F1_BodyWeightData_Dec2024 copy.xlsx`: 310 BXD × BXD F1 females that died, with up to 18 weighings. It is a tab-delimited text file with one row per mouse, written by `BodyWeight/F1_weights_corrected.R`.

**Corrections, by Rob Williams on 27 October 2026** (Rob is confirming them with Suheeta Roy):

| Column | Change | Mice | Why |
|---|---|---|---|
| `StrainName` | `BXD73x65` → `BXD73bx65`; `BXD73x77` → `BXD73bx77` | 6 (ear tags 3092–3097) | Only BXD73b was crossed. GeneNetwork (`data/original/BDL_10002.xlsx`) already lists these six as BXD73b crosses, with the same ages at death. |
| `StrainName` | `X` between the parents → `x` (for example `BXD102X77` → `BXD102x77`) | 12 | Spelling, to match the other names. |
| `CauseOfDeath` | `Euthanized` → `Natural` | 168 | F1s were euthanized within a week or two of natural death, judged by frailty, to harvest organs for the biobank. Rob: "Relabeled them a natural deaths for purposes of analysis." |
| `NotesByIngels`, `NotesByRoy` | Line breaks → " / " | 45 | So that each mouse is one line. |

- **The recorded values** are in two added columns, `StrainName_recorded` and `CauseOfDeath_recorded`.
- **One mouse** has cause of death `Other` and is unchanged.
- **Used by** `BodyWeight/terminal_decline.R`.
- **SHA-256:** `15908741e7f87fa03552c698eee99de2c4fe0e0cff8591c2b94b8e111cd502bb`. A rerun of the script gives the same file.

## AgingBXD_F1_24Nov2026_corrected.txt

Suheeta Roy's workbook of 24 November 2026 (`data/original/AgingBXD_F1_Lifespan_BodyWeightData_24Nov2026.xlsx`): 322 BXD × BXD F1 females, all dead. It replaces the table above for F1 lifespans. It is written by `BodyWeight/F1_corrected_24Nov2026.R`, with the same column names.

- **Against the December 2024 table:** 12 more mice (ear tags 3310, 3552, 3661, 3691, 3693, 4507, 4508, 4522, 4569, 4851, 4900, 4902), no new F1 types, and four corrected ages (3507, 3634, 3647, 3662). No other mouse changed age, type or diet.
- **Names and cause of death** are corrected as above (Rob, 27 October 2026). 177 euthanized mice are counted as natural deaths. Ear tag 3312 (injured in its cage) stays `Other`.
- **3694 and 4520** were weighed after their recorded deaths, and Suheeta is checking with Casey. Their cause is set to `Pending`, so analyses of natural deaths leave them out (319 mice). `AgingBXD_F1_24Nov2026_corrected_with_pending.txt` keeps them with their recorded ages (321 mice), as a sensitivity check.
- **Body weights are as recorded.** They have not been through the QC of the earlier table. In 3663, weighing 14 has no age, and an age of 43 days sits under weighing 18.
- **Checked against GeneNetwork** (BDL_10002) by `qc/F1_GN_check_24Nov2026.R`: GeneNetwork already lists all 322 mice, and two more (3562 and 4521). Eight ages and the cross or diet of five mice differ. The workbook is followed.
- **SHA-256:** `9ade76f98403fbc7cf5d8da7a138a6a02bccb24c46e7db709e62cc3e73009c7a` (with the pending mice: `13349f46f9bdc18557eb6f16244c98d3d1670ae5427b0f1c7bb520805d8780a0`).

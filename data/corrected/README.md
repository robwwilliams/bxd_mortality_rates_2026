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

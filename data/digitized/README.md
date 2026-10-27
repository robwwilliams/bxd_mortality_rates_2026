# Survival curves read from published figures

Made by `tools/digitize_km.py` on 27 October 2026, for N5 of `notes/PLAN_NAM_rectangularization.md`. Rebuild with:

```bash
.venv/bin/python tools/digitize_km.py
```

These are readings of figures, not the authors' data. If Rafa de Cabo or Sarah Mitchell send the individual ages at death, those replace these files.

| File | Source | Arms (mice) | How it was read |
|---|---|---|---|
| `MartinMontalvo2013_Fig1a.txt` | Martin-Montalvo et al. 2013, *Nat Commun* 4:2192, Fig. 1a | SD (83), Met0.1 = 0.1% metformin (64) | Exactly, from hidden weekly markers in the vector figure |
| `MartinMontalvo2013_Fig1b.txt` | the same, Fig. 1b | SD (88), Met1 = 1% metformin (90) | Column by column from a 600-dpi rendering |
| `Mitchell2018_Fig1A.txt` | Mitchell et al. 2018, *Cell Metab* 27:667, Fig. 1A | SD, SDL = 0.05% NAM, SDH = 0.1% NAM (100 each) | Column by column, by color, from the embedded image |
| `Mitchell2018_Fig1B.txt` | the same, Fig. 1B | HFD, HFDL, HFDH (100 each) | The same |

- **Columns:** `week` (age in weeks) and the survival of each arm in percent.
- **The first line** is a comment describing the source.
- **Each `*_check.png`** draws the reading (colored lines) over the published figure.
- **The PDFs** are in `papers/`.
- **How the rows become ages at death:** `Gompertz/Rectangularization.R`.

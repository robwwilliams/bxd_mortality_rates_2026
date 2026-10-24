# bxd_mortality_rates_2026: conventions for every session

## What this repository is

Gompertz analyses of mortality in BXD family mice: the mortality rate doubling time (MRDT) and the level of mortality, by diet, by proximal Chr 1 haplotype, and in BXD × BXD F1 hybrids against their inbred parents. It also connects these results to the UM-HET3 Vita loci of Arends et al. 2026 (*Nature* 654:437).

- **Start with** `README.md` and `notes/HANDOFF_2026-10-24.md`, which says where the work stands and what comes next.
- **This repository is public.**

## People

- **Rob Williams** (robwwilliams) is the PI and owner.
  - He decides design and interpretation.
  - He reads R but is not a day-to-day coder, so explain each result in plain language, as a short lesson.
  - Never restate his predictions in your own terms without quoting his words and checking the translation with him.
- **Danny Arends** wrote the UM-HET3 analyses. Code here follows his R style.
- **Suheeta Roy** curates the BXD lifespan data. **Arthur Centeno** maintains GeneNetwork.

## Openness

Rob's decision (24 October 2026): nothing in this project is private. Papers, data, transcripts and results may all be committed.

- **The one hard limit is size.** GitHub refuses any file over 100 MB, such as the 629 MB founder sequence variants ZIP. Such files go in `data/local/`, which git ignores, and are published elsewhere (a GitHub release asset or Zenodo) with a link in the README.
- **When adding a paper to `papers/`,** add its citation and a link to `papers/README.md`.

`data/original/` holds data exactly as received. Never edit it; corrections go into derived files elsewhere.

## Analysis conventions

- **Language.** R for analyses (readxl, survival, svglite). Python only for tools (openpyxl, cairosvg). Run R with `LC_ALL=C.UTF-8`.
- **Gompertz fits.**
  - Fit by maximum likelihood with left truncation at the set-up age, censoring animals alive at the data freeze. The functions are in `Gompertz/gompertz.R`.
  - Report in base 2: h(t) = R0 · 2^(t / MRDT).
  - Prefer the level of mortality at a reference age (600 d) to R0, which is an extrapolation to birth and trades off against MRDT.
- **Level against slope.** Keep level effects (the same multiple at every age) apart from slope effects (a change in MRDT). Avoid the phrase "age-independent", which hides the fact that a constant multiple adds more deaths at older ages.
- **The unit of inference is the strain or genotype, not the mouse.** Use a delete-one-strain jackknife or a permutation over strains. Report animal-level likelihood-ratio P values only alongside.
- **Plans fixed before fits** say who wrote them. Label any analysis added after results were seen as exploratory.
- **Seeds are fixed.**

## Figures

Follow `notes/figure_style.md` (Nature-series style). The colors are fixed:

| Group | Color |
|---|---|
| Chow | brown `#a86a28` |
| High fat | blue `#2a78d6` |
| B haplotype | dark purple `#7d4598` |
| D haplotype | orange `#ed8f22` |
| F1 hybrids | green `#008300` |
| Inbred parents | pink `#e87ba4` |

- **SVG** comes from svglite, with Arial labels and every label one text element.
- **PNG previews** come from `tools/svg2png.py`.
- **Log scales** are base 2.

## Writing and workflow

- **Writing.**
  - American spelling.
  - "days" spelled out in legends.
  - Capital P.
  - Legends open with "Fig. N |".
- **Commits.** Small, with clear messages. Push to `main` unless Rob asks for a branch.

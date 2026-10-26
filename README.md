# bxd_mortality_rates_2026
An analysis of variation in mortality rate doubling time in BXD females by diet and genotype. Data from Roy et al. 2021 and new 2026 data for ~2000 mice.  
See GeneNetwork.org trait 10002:  https://genenetwork.org/show_trait?trait_id=10002&dataset=BXD-LongevityPublish

### First result

On a high-fat diet, BXD family females die at 1.4 times the rate of chow-fed females at every age. The mortality rate doubling time (MRDT) does not change: 153 d on chow, 149 d on high fat (p = 0.55 for equal slopes). See [notes/MRDT_diet_initial.md](notes/MRDT_diet_initial.md).

### Planned secondary analyses

Two tests of whether genotype changes MRDT were fixed in an analysis plan before any fit was made ([notes/PREREGISTRATION_secondary.md](notes/PREREGISTRATION_secondary.md), 24 October 2026). Claude wrote the plan; its opening and Amendments say what was and was not agreed:
- **H1:** strains that are D across all of proximal Chr 1 (Vita1a and Vita1b) against strains that are B across all of it.
- **H2:** BXD × BXD F1 hybrids against their inbred parents.

Results ([notes/MRDT_secondary_results.md](notes/MRDT_secondary_results.md)):
- **H1:** the haplotype changes the level of mortality, not its doubling time. On high fat, B strains die at twice the rate of D strains at 600 d, but MRDT is 141 d against 154 d (P = 0.57).
- **H2:** the planned direction, a longer F1 MRDT, is not supported (one-tailed P = 0.98). That direction was Claude's reading, not Rob's prediction. The estimate goes the other way: 107 d in F1s against 165 d in their parents, and the difference comes from the short-by-short crosses. Rob's prediction, lower F1 mortality at every age, holds for those crosses up to about 1,000 d.

### UM-HET3 Vita1a and Vita1b (exploratory)

Part 3 of the report ([notes/Report_MRDT_Parts1-3_2026-10-26.md](notes/Report_MRDT_Parts1-3_2026-10-26.md), also as PDF and Word) asks the same level-or-slope question of the Vita1a and Vita1b loci of Arends et al. 2026:
- **The paternal genotype calls on proximal Chr 1 are biased toward H at UM and UT, not at JL.** This is the source of the 2:1 excess of paternal H over D in Supplementary Table 2, and of the near-absence of BD calls at Vita1b at those sites.
- **Paternal D at Vita1a raises mortality about 1.2-fold** within sites and cohorts. Its apparent effect on MRDT does not survive a check by site and cohort.
- **In BXD chow females, proximal Chr 1 D lowers mortality** relative to B (0.79-fold at 600 d). In UM-HET3 females, paternal D raises it relative to H.

### Installation

To obtain the code, run the following command in your terminal:

```
git clone https://github.com/robwwilliams/bxd_mortality_rates_2026.git
```

To install the R package dependencies (readxl, survival, svglite), go into the bxd_mortality_rates_2026 directory and run:

```
Rscript installer.R
```

SVG figures are converted to PNG previews with the Python package CairoSVG (`pip install cairosvg`).

### Running the analysis

All scripts run from the repository root:

```
Rscript Gompertz/test_gompertz.R          # checks the fitting code on simulated data (about 10 s)
Rscript Gompertz/MRDT_Diet.R              # fits, tests and bootstrap; writes tables to output/ (about 30 s)
Rscript Gompertz/Figures_MRDT_Diet.R      # writes SVG figures to output/
python3 tools/svg2png.py output/*.svg     # PNG previews
Rscript Genotypes/Chr1_haplotypes.R data/genotypes/BXD_genotypes_Chr1_0to35Mb.txt output/Chr1_haplotypes.txt
Rscript Gompertz/MRDT_Secondary.R         # the pre-registered secondary tests (about 10 s)
Rscript Gompertz/Figures_MRDT_Secondary.R # Figs 5 and 6
Rscript Models/effective_factors.R         # exploratory model of F1 heterosis (about 40 s)
Rscript Models/fig_effective_factors.R
```

The UM-HET3 analyses read Arends et al. Supplementary Table 7 (the R/qtl cross file), kept in `data/local/`:

```
X="data/local/Arends_Supplementary_Tables_10Apr2026/S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr"
Rscript UMHET3/clean_table2.R data/original/Arends_2026_Supplementary_Table_2.zip data/umhet3/Table2
Rscript UMHET3/chr1_marker_check.R "$X"    # genotype calls on proximal Chr 1, by site
Rscript UMHET3/vita_sex_stratified.R data/umhet3/Table2/Vita1a_deathsIn15Dwindows_female.txt data/umhet3/Table2/Vita1a_deathsIn15Dwindows_male.txt paternalD
Rscript UMHET3/vita1_site_check.R "$X"     # individual mice, by sex, site and cohort
Rscript UMHET3/Figures_Part3.R             # Figs 8-10
.venv/bin/python tools/build_report.py notes/Report_MRDT_Parts1-3_2026-10-26.md reports   # PDF, Word, figures and ZIP
```

### Structure

- [Gompertz/](./Gompertz/) contains the Gompertz code. `gompertz.R` holds the functions: maximum-likelihood fits with left truncation at the age of set up, likelihood-ratio tests between groups, the bootstrap, and the classic binned regression of de Magalhães et al. `MRDT_Diet.R` compares chow and high-fat females, and `Figures_MRDT_Diet.R` draws the figures. `MRDT_Secondary.R` runs the pre-registered secondary tests, and `Figures_MRDT_Secondary.R` draws their figures.
- [output/](./output/) contains the result tables (tab-separated `.txt`) and figures (`.svg` with editable text in Arial, and `.png` previews).
- [notes/](./notes/) contains write-ups: `Report_MRDT_Parts1-3_2026-10-26` (Markdown, PDF and Word) for beginners, covering all three parts; `MRDT_diet_initial.md` for the first analysis, `PREREGISTRATION_secondary.md` for the registered secondary tests, `MRDT_secondary_results.md` for their results, `HANDOFF_2026-10-24.md` on where the work stands and what comes next, and `reading_notes.md` on the three papers below.
- [Genotypes/](./Genotypes/) contains `Chr1_haplotypes.R`, which classifies strains as B, D or recombinant across proximal Chr 1.
- [Models/](./Models/) contains an exploratory model of Sewall Wright's question for the F1 experiment: do 10 or 200 recessive loci predict different lifespan gains for short-by-short and long-by-long F1s?
- [UMHET3/](./UMHET3/) contains the exploratory UM-HET3 analyses of Part 3:
  - the clean copy of Supplementary Table 2;
  - the check of genotype calls on proximal Chr 1;
  - fits of mortality level and MRDT by Vita1a and Vita1b genotype, by sex, and by site and cohort;
  - Figs 8–10.
- [data/umhet3/](./data/umhet3/) holds the clean copy of Arends et al. Supplementary Table 2, with a README on its columns and on the genotype problem.
- [tools/](./tools/) holds `svg2png.py`, `build_report.py` (Markdown note to HTML, Word, PDF and ZIP), `html2pdf.swift` and `pdftext.swift` (PDFs with macOS's own WebKit and PDFKit).
- [data/genotypes/](./data/genotypes/) holds the proximal Chr 1 slice of the sequence-based BXD genotypes, with its provenance.
- [data/original/](./data/original/) holds data exactly as received:
  - the GeneNetwork export of BDL_10002 (natural lifespan, 22 October 2026);
  - Suheeta Roy's curated file of females used for actuarial mapping;
  - Supplementary Table 2 of Arends et al. 2026, as published.
- [qc/](./qc/) contains quality checks of the GeneNetwork export, the annotated workbooks for curation, and the scripts that produce them.
- [papers/](./papers/) contains the papers that frame this analysis, with citations, licenses and links to their data and code.

### Related repositories

- [genenetwork/bxd_gxelongevity_2020](https://github.com/genenetwork/bxd_gxelongevity_2020): data and R code for Roy et al. 2021.
- [DannyArends/UM-HET3](https://github.com/DannyArends/UM-HET3): code for Arends et al. 2026.

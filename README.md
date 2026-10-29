# bxd_mortality_rates_2026
An analysis of variation in mortality rate doubling time in BXD females by diet and genotype. Data from Roy et al. 2021 and new 2026 data for ~2000 mice.  
See GeneNetwork.org trait 10002:  https://genenetwork.org/show_trait?trait_id=10002&dataset=BXD-LongevityPublish

### First result

On a high-fat diet, BXD family females die at 1.4 times the rate of chow-fed females at every age. The mortality rate doubling time (MRDT) does not change: 153 d on chow, 149 d on high fat (p = 0.55 for equal slopes). See [notes/MRDT_diet_initial.md](notes/MRDT_diet_initial.md).

Within strains (exploratory), high fat raises mortality 1.8-fold, strains differ in how much (P = 0.0002), and the MRDT is 113 d rather than the pooled 151 d. Given an MRDT for each diet, high fat also shortens it within strains, from 117 to 91 d (ratio 0.78, 95% CI 0.69–0.88), which the pooled fit hides. See Part 1 of the [report](notes/Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md), Fig. 5 and Fig. 15d.

### Planned secondary analyses

Two tests of whether genotype changes MRDT were fixed in an analysis plan before any fit was made ([notes/PREREGISTRATION_secondary.md](notes/PREREGISTRATION_secondary.md), 24 October 2026). Claude wrote the plan; its opening and Amendments say what was and was not agreed:
- **H1:** strains that are D across all of proximal Chr 1 (Vita1a and Vita1b) against strains that are B across all of it.
- **H2:** BXD × BXD F1 hybrids against their inbred parents.

Results ([notes/MRDT_secondary_results.md](notes/MRDT_secondary_results.md)):
- **H1:** the haplotype changes the level of mortality, not its doubling time. On high fat, B strains die at twice the rate of D strains at 600 d, but MRDT is 141 d against 154 d (P = 0.57).
- **H2:** the planned direction, a longer F1 MRDT, is not supported (one-tailed P = 0.98). That direction was Claude's reading, not Rob's prediction. The estimate goes the other way: 107 d in F1s against 165 d in their parents, and the difference comes from the short-by-short crosses. Rob's prediction, lower F1 mortality at every age, holds for those crosses up to about 1,000 d.

### UM-HET3 Vita1a and Vita1b (exploratory)

Part 3 of the report ([notes/Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md](notes/Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md), also as PDF and Word) asks the same level-or-slope question of the Vita1a and Vita1b loci of Arends et al. 2026:
- **The paternal genotype calls on proximal Chr 1 are biased toward H at UM and UT, not at JL.** This is the source of the 2:1 excess of paternal H over D in Supplementary Table 2, and of the near-absence of BD calls at Vita1b at those sites.
  - The bias follows the genotyping set, not the site. One of the two MonsterPlex marker sets loses heterozygous calls at a few SNPs. It typed half of the UM mice and all of the UT mice; JL is all in the other set.
  - See [notes/Message_Chr1_genotype_error_2026-10-26.md](notes/Message_Chr1_genotype_error_2026-10-26.md).
- **Paternal D at Vita1a raises mortality about 1.2-fold** within sites and cohorts. Its apparent effect on MRDT does not survive a check by site and cohort.
- **In BXD chow females, proximal Chr 1 D lowers mortality** relative to B (0.79-fold at 600 d). In UM-HET3 females, paternal D raises it relative to H.

### Terminal weight loss and the per diem cost of late life (exploratory)

Rob's per diem model: a mouse is free until 500 days, then costs 1 unit per day alive plus a surcharge for each day of terminal weight loss. The plan ([notes/PLAN_terminal_decline.md](notes/PLAN_terminal_decline.md)) was fixed before any comparison was run. Results are in Part 4 of the report and in [notes/Terminal_decline_results.md](notes/Terminal_decline_results.md), Fig. 12:
- **Longer-lived BXD strains spend longer in decline,** about 11–13 days per 100 days of life. That is close to proportional, not compression.
- **Short × short F1 hybrids live 171 days longer than their parents, with the same length of decline.**
- **High fat shortens both life (76 days) and the decline (42 days).**
- **Two corrections to the F1 data** (Rob, 27 October 2026) are in [data/corrected/](data/corrected/README.md): six F1s recorded as BXD73 crosses are BXD73b crosses, and F1s euthanized at end of life count as natural deaths.

### Definitions of terminal decline, and nicotinamide (exploratory)

Part 5 of the report covers this section. Both plans were approved by Rob on 27 October 2026, before they were run. The reading behind them is in [notes/reading_notes_frailty.md](notes/reading_notes_frailty.md).

**How much the Part 4 conclusions depend on the definition of terminal decline.** Plan: [notes/PLAN_morbidity_definitions.md](notes/PLAN_morbidity_definitions.md). Results: [notes/Onset_definitions_results.md](notes/Onset_definitions_results.md), Fig. 13. 568 definitions were tested.
- **Graded percent below peak predicts death best.**
- **Robust:**
  - on high fat, longer-lived strains spend longer in decline;
  - short × short F1s add life without adding days of decline;
  - long × long F1s do not differ from their parents.
- **Sensitive:**
  - the chow slope, which is a slope of mild weight loss;
  - high fat's shorter decline, which is shorter in days but steeper and riskier.

**Nicotinamide (NAM), rectangularization and the decline.** Plan: [notes/PLAN_NAM_rectangularization.md](notes/PLAN_NAM_rectangularization.md). Results: [notes/NAM_rectangularization_results.md](notes/NAM_rectangularization_results.md), Fig. 14.
- Within 9 BXD strains at TSRB, 1% NAM on high fat changed none of the following detectably: lifespan, the Gompertz level and MRDT, the spread of ages at death, or the days in decline.
- NAM mice were born about three years after their controls, and later births died younger, so a moderate NAM effect is neither shown nor excluded.

**Rectangularization side by side with de Cabo's studies** (exploratory). Results: [notes/Rectangularization_results.md](notes/Rectangularization_results.md), Fig. 15. Survival curves of Mitchell et al. 2018 (nicotinamide) and Martin-Montalvo et al. 2013 (metformin) were read from the published figures into [data/digitized/](data/digitized/).
- Hybrid vigor lengthens life and concentrates deaths relative to lifespan.
- Nicotinamide, in either laboratory, changes nothing.
- Metformin at 0.1% shifts the curve later; at 1% it concentrates deaths while shortening life, by steepening the rise of mortality.
- Within strains, high fat shortens the MRDT (117 to 91 days), which pooled fits (Part 1) do not show.

**Tumors and terminal weight.** Results: [notes/Masses_and_terminal_weight.md](notes/Masses_and_terminal_weight.md). A large tumor or abdominal fluid can hold a dying mouse at its peak weight, but mice with a recorded mass lost as much weight as the rest.

**Odd body weighings** are listed for Suheeta's review in [qc/BodyWeight_QC.md](qc/BodyWeight_QC.md), now including the NAM workbook.

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
Rscript Gompertz/Diet_by_strain.R         # exploratory: the diet effect within and across strains (about 5 s)
Rscript Gompertz/Figures_MRDT_Diet.R      # writes SVG figures to output/
python3 tools/svg2png.py output/*.svg     # PNG previews
Rscript Genotypes/Chr1_haplotypes.R data/genotypes/BXD_genotypes_Chr1_0to35Mb.txt output/Chr1_haplotypes.txt
Rscript Gompertz/MRDT_Secondary.R         # the pre-registered secondary tests (about 10 s)
Rscript Gompertz/Figures_MRDT_Secondary.R # Figs 6 and 7
Rscript Models/effective_factors.R         # exploratory model of F1 heterosis (about 40 s)
Rscript Models/fig_effective_factors.R
Rscript BodyWeight/F1_weights_corrected.R # the F1 weight table with our corrections, in data/corrected/
Rscript BodyWeight/terminal_decline.R      # terminal weight loss and per diem cost (about 10 s)
Rscript BodyWeight/Figures_terminal_decline.R   # Fig. 12
Rscript BodyWeight/weights_QC.R           # odd weighings, listed in qc/ for review
Rscript BodyWeight/onset_definitions.R     # 568 definitions of terminal decline against the Part 4 conclusions (about 25 s)
Rscript BodyWeight/Figures_onset_definitions.R  # Fig. 13
Rscript Gompertz/NAM_rectangularization.R  # nicotinamide against high fat within strains (about 5 s)
Rscript Gompertz/Figures_NAM.R             # Fig. 14
.venv/bin/python tools/digitize_km.py      # reads de Cabo's published survival curves into data/digitized/
Rscript Gompertz/Rectangularization.R      # rectangularization side by side (about 10 s)
Rscript Gompertz/Figures_Rectangularization.R   # Fig. 15
Rscript BodyWeight/masses_notes.R          # tumors, swelling and terminal weight, from the free-text notes
```

The UM-HET3 analyses read Arends et al. Supplementary Table 7 (the R/qtl cross file), kept in `data/local/`:

```
X="data/local/Arends_Supplementary_Tables_10Apr2026/S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr"
Rscript UMHET3/clean_table2.R data/original/Arends_2026_Supplementary_Table_2.zip data/umhet3/Table2
Rscript UMHET3/chr1_marker_check.R "$X"    # genotype calls on proximal Chr 1, by site
D="data/local/Arends_Supplementary_Tables_10Apr2026"
Rscript UMHET3/vcf_set_check.R "$D/S_Table_5_VCF_coded_genotypes_metadata_18Aug2025.xlsx" "$D/S_Table_4_Primers_MonsterPlex_Mouse_20Aug2025.xlsx" "$X"   # raw calls, by genotyping set
Rscript UMHET3/vita_sex_stratified.R data/umhet3/Table2/Vita1a_deathsIn15Dwindows_female.txt data/umhet3/Table2/Vita1a_deathsIn15Dwindows_male.txt paternalD
Rscript UMHET3/vita1_site_check.R "$X"     # individual mice, by sex, site and cohort
Rscript UMHET3/Figures_Part3.R             # Figs 9-11
.venv/bin/python tools/build_report.py notes/Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2.md reports   # PDF, Word, figures and ZIP
```

### Structure

- [Gompertz/](./Gompertz/) contains the Gompertz code. `gompertz.R` holds the functions: maximum-likelihood fits with left truncation at the age of set up, likelihood-ratio tests between groups, the bootstrap, and the classic binned regression of de Magalhães et al. `MRDT_Diet.R` compares chow and high-fat females, and `Figures_MRDT_Diet.R` draws the figures. `MRDT_Secondary.R` runs the pre-registered secondary tests, and `Figures_MRDT_Secondary.R` draws their figures. `NAM_rectangularization.R` compares high fat with and without nicotinamide (Fig. 14). `Rectangularization.R` sets the BXD comparisons beside de Cabo's studies (Fig. 15).
- [output/](./output/) contains the result tables (tab-separated `.txt`) and figures (`.svg` with editable text in Arial, and `.png` previews).
- [notes/](./notes/) contains write-ups: `Report_BXD_Mortality_Parts1-5_28Oct2026_v2.2` (Markdown, PDF and Word) for beginners, covering all five parts, with version 2 (28 October) and version 1 (Parts 1–4, 27 October) kept for the record; `MRDT_diet_initial.md` for the first analysis, `PREREGISTRATION_secondary.md` for the registered secondary tests, `MRDT_secondary_results.md` for their results, `HANDOFF_2026-10-24.md` on where the work stands and what comes next, `reading_notes.md` on the three papers below, and `reading_notes_frailty.md` on mouse frailty, terminal weight loss and rectangularization.
- [Genotypes/](./Genotypes/) contains `Chr1_haplotypes.R`, which classifies strains as B, D or recombinant across proximal Chr 1.
- [BodyWeight/](./BodyWeight/) contains the analysis of terminal weight loss and Rob's per diem model of the cost of late life (Fig. 12). It also holds the comparison of definitions of terminal decline (`morbidity_functions.R`, `onset_definitions.R`; Fig. 13), the weight QC (`weights_QC.R`) and the look at tumors and terminal weight (`masses_notes.R`).
- [Models/](./Models/) contains an exploratory model of Sewall Wright's question for the F1 experiment: do 10 or 200 recessive loci predict different lifespan gains for short-by-short and long-by-long F1s?
- [UMHET3/](./UMHET3/) contains the exploratory UM-HET3 analyses of Part 3:
  - the clean copy of Supplementary Table 2;
  - the check of genotype calls on proximal Chr 1;
  - fits of mortality level and MRDT by Vita1a and Vita1b genotype, by sex, and by site and cohort;
  - Figs 9–11.
- [data/corrected/](./data/corrected/) holds our corrections to tables in `data/original/` (which stay as received), with the recorded values kept alongside.
- [data/umhet3/](./data/umhet3/) holds the clean copy of Arends et al. Supplementary Table 2, with a README on its columns and on the genotype problem.
- [tools/](./tools/) holds `svg2png.py`, `build_report.py` (Markdown note to HTML, Word, PDF and ZIP), `html2pdf.swift` and `pdftext.swift` (PDFs with macOS's own WebKit and PDFKit), and `digitize_km.py` (survival curves read from published figures).
- [data/digitized/](./data/digitized/) holds those readings, with images that lay each reading over its figure.
- [data/genotypes/](./data/genotypes/) holds the proximal Chr 1 slice of the sequence-based BXD genotypes, with its provenance.
- [data/original/](./data/original/) holds data exactly as received:
  - the GeneNetwork export of BDL_10002 (natural lifespan, 22 October 2026);
  - Suheeta Roy's curated file of females used for actuarial mapping;
  - Supplementary Table 2 of Arends et al. 2026, as published.
- [qc/](./qc/) contains quality checks of the GeneNetwork export and of the body weights, the annotated workbooks for curation, and the scripts that produce them.
- [papers/](./papers/) contains the papers that frame this analysis, with citations, licenses and links to their data and code.

### Related repositories

- [genenetwork/bxd_gxelongevity_2020](https://github.com/genenetwork/bxd_gxelongevity_2020): data and R code for Roy et al. 2021.
- [DannyArends/UM-HET3](https://github.com/DannyArends/UM-HET3): code for Arends et al. 2026.

# bxd_mortality_rates_2026
An analysis of variation in mortality rate doubling time in BXD females by diet and genotype. Data from Roy et al. 2021 and new 2026 data for ~2000 mice.  
See GeneNetwork.org trait 10002:  https://genenetwork.org/show_trait?trait_id=10002&dataset=BXD-LongevityPublish

### First result

On a high-fat diet, BXD family females die at 1.4 times the rate of chow-fed females at every age. The mortality rate doubling time (MRDT) does not change: 153 d on chow, 149 d on high fat (p = 0.55 for equal slopes). See [notes/MRDT_diet_initial.md](notes/MRDT_diet_initial.md).

### Pre-registered secondary analyses

Two tests of whether genotype changes MRDT were registered before any fit was made ([notes/PREREGISTRATION_secondary.md](notes/PREREGISTRATION_secondary.md), 24 October 2026):
- **H1:** strains that are D across all of proximal Chr 1 (Vita1a and Vita1b) against strains that are B across all of it.
- **H2:** BXD × BXD F1 hybrids against their inbred parents.

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
```

### Structure

- [Gompertz/](./Gompertz/) contains the Gompertz code. `gompertz.R` holds the functions: maximum-likelihood fits with left truncation at the age of set up, likelihood-ratio tests between groups, the bootstrap, and the classic binned regression of de Magalhães et al. `MRDT_Diet.R` compares chow and high-fat females, and `Figures_MRDT_Diet.R` draws the figures.
- [output/](./output/) contains the result tables (tab-separated `.txt`) and figures (`.svg` with editable text in Arial, and `.png` previews).
- [notes/](./notes/) contains write-ups: `MRDT_diet_initial.md` for the first analysis, `PREREGISTRATION_secondary.md` for the registered secondary tests, and `reading_notes.md` on the three papers below.
- [Genotypes/](./Genotypes/) contains `Chr1_haplotypes.R`, which classifies strains as B, D or recombinant across proximal Chr 1.
- [data/genotypes/](./data/genotypes/) holds the proximal Chr 1 slice of the sequence-based BXD genotypes, with its provenance.
- [data/original/](./data/original/) holds data exactly as received:
  - the GeneNetwork export of BDL_10002 (natural lifespan, 22 October 2026);
  - Suheeta Roy's curated file of females used for actuarial mapping.
- [qc/](./qc/) contains quality checks of the GeneNetwork export, the annotated workbooks for curation, and the scripts that produce them.
- [papers/](./papers/) contains the papers that frame this analysis, with citations, licenses and links to their data and code.

### Related repositories

- [genenetwork/bxd_gxelongevity_2020](https://github.com/genenetwork/bxd_gxelongevity_2020): data and R code for Roy et al. 2021.
- [DannyArends/UM-HET3](https://github.com/DannyArends/UM-HET3): code for Arends et al. 2026.

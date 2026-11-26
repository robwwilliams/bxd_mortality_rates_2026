# QTL: lifespan mapping jobs that run here rather than in the fork

The lifespan maps of the Nature Aging paper are made in Rob's fork of Danny Arends's code, [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan). This folder holds only what must run inside this repository, chiefly long permutation jobs for ATHENA through Squirm (`tools/squirm/README.md`). It holds derived inputs and our own scripts, and none of Danny's code.

Where the mapping as a whole stands, and why each model was chosen: [`notes/BXD_mapping_status_2026-11-23.md`](../notes/BXD_mapping_status_2026-11-23.md).

## Individual-mouse permutations

- **`qtl2_individuals_perm.R`** computes genome-wide thresholds for the individual-mouse maps (panels c to f of Fig. 2), which map each mouse's age at death with R/qtl2 and LOCO kinship.
  - **Exploratory:** written after the strain-mean thresholds were seen.
  - **Permutations:** each strain takes the genotypes of another strain in its stratum, Taylor's strains (BXD1 to BXD42) or the newer ones, and keeps all its mice on both diets and at every T-age.
  - **Chunks:** chunk *k* draws its permutations from seed 20261123 + *k*, so the result does not depend on the number of cores.
- **`squirm_jobs/bxd_individual_perms.sh`** runs it on ATHENA: 200 permutations in 100 chunks of 2, on 4 cores.
- **`qtl2_individualsF1_perm.R`** does the same for the individual-mouse maps with the BXD × BXD F1 mice (Rob's Fig. 2 of 23 November 2026, panels with F1s; maps by `qtl2_individualsF1.R` in the fork).
- **`vita1_by_diet.R`** tests genotype × diet at Vita1a, Vita1b and Vita1y themselves, BXD and F1 mice together, with genotypes permuted among strains and F1 types (about 30 seconds; `output/Vita1_by_diet.txt`). Exploratory; pointwise.
- **`epistasis_bxd.R`** tests a planned, small set of pairs of loci for epistasis in BXD and F1 females, with strains and F1 types permuted (about 3 minutes; `output/epistasis_bxd.txt`).
  - **Permutations:** strains within strata as above, and each F1 type takes the genotypes and kinship of another F1 type of its class (short × short or long × long).
  - **Also records** the largest Cauchy combination over T-ages at any marker (T20–T770 and T20–T620), for a genome-wide threshold of the Cauchy maps.
  - **Checked on Metis:** run on the real data (`--check yes`) at T20 and T500, it gives the fork's maps to 4 decimals. One process peaks at 1.87 GB; three workers at 5.4 GB summed resident memory at T20.
  - **On ATHENA,** as two jobs of 100 permutations (chunks 1–50 and 51–100, seeds 20261124 + *k*) on 3 cores, each about 25 hours, to stay within Squirm's 6 GB and 48 hours.
  - **Raised to 1,000 permutations** (Rob, 24 November 2026: "Yes, queue them"), because 200 leave the 5% threshold with a standard error of about 0.18 (bootstrap, chow T770), larger than the margin by which chow Chr 1 passes. Sixteen more jobs, `squirm/bxd_individualsF1_perms_c` to `_r`, hold chunks 101–500 (25 chunks each, about 16 hours on 3 cores). Chunk *k* keeps seed 20261124 + *k*, so the first 200 count toward the 1,000. All the chunks are combined on Metis.
  - **Kept in the queue** (Rob, 26 November 2026: "Keep it in the queue. I am biased in favor of F1."), after the first 100 permutations (job a) already gave a provisional 5% threshold of 4.46 for chow at T770, below the chow Chr 1 peak with F1s (5.38), and 6.0 or more for the interaction map, above its F1 peaks (5.0–5.3).

### Results (exploratory)

`output/squirm/bxd_individual_perms/` holds the returned job: 200 permutations, run on ATHENA (Apple M5 Max, R 4.6.2) from 22 to 23 November 2026, exit 0, about 26.5 hours of computing over 33 hours, paused 39 times for ATHENA's own work (`squirm_run.txt`).
- **`thresholds.txt`:** genome-wide −log10 *P* at 5%, 10% and the suggestive level, for each map and T-age, and for any T-age.
- **The 5% threshold for one T-age falls with T-age as the survivorships shrink:** about 5.8 at T20 to 4.6 at T770 for the chow map (any T-age 6.6). Far higher than for strain means (4.4), as the strain, not the mouse, is the unit.
- **One locus passes:** chow, Chr 1 at 5.0 Mb, 4.74 at T770 against 4.62. The rest are suggestive at most (`significant_loci_ind.txt` in the fork).

### Checks on Metis (R 4.6.1, R/qtl2 0.46)

- **Agreement with the fork:** the fork's first permutation (seed 20261123) gives the same maxima at T20 here, to 5 decimals.
- **Cores:** 4 chunks at T20 and T500 gave identical files on 1 worker and on 4.
- **Memory:** about 0.5 GB shared, plus about 0.9 GB per worker at T20, scanning one chromosome at a time. Four workers peaked at 5.7 GB of summed resident memory, which is how Squirm counts a job's memory, so the job uses 4 workers to stay within Squirm's 6 GB.
- **Time:** about 25 minutes per permutation on one Metis core, so about 21 hours for 200 permutations on 4 cores.

## Inputs

`inputs/` is written by `squirm_inputs.R` in the fork.

- **`inputs/bxd_risib/`** is the R/qtl2 cross: the 119 BXD strains mapped, with genotypes from GeneNetwork's `BXD_current_rev050423.geno` (heterozygous and unknown calls as missing) and the marker map in cM.
- **`inputs/mice.txt`** has one row per mouse mapped (1,746 females on chow or high fat): ear tag, strain, diet, age at death, vivarium, age at set-up, and the stratum of its strain.

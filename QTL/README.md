# QTL: lifespan mapping jobs that run here rather than in the fork

The lifespan maps of the Nature Aging paper are made in Rob's fork of Danny Arends's code, [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan). This folder holds only what must run inside this repository, chiefly long permutation jobs for ATHENA through Squirm (`tools/squirm/README.md`). It holds derived inputs and our own scripts, and none of Danny's code.

## Individual-mouse permutations

- **`qtl2_individuals_perm.R`** computes genome-wide thresholds for the individual-mouse maps (panels c to f of Fig. 2), which map each mouse's age at death with R/qtl2 and LOCO kinship.
  - **Exploratory:** written after the strain-mean thresholds were seen.
  - **Permutations:** each strain takes the genotypes of another strain in its stratum, Taylor's strains (BXD1 to BXD42) or the newer ones, and keeps all its mice on both diets and at every T-age.
  - **Chunks:** chunk *k* draws its permutations from seed 20261123 + *k*, so the result does not depend on the number of cores.
- **`squirm_jobs/bxd_individual_perms.sh`** runs it on ATHENA: 200 permutations in 100 chunks of 2, on 10 cores.

### Checks on Metis (R 4.6.1, R/qtl2 0.46)

- **Agreement with the fork:** the fork's first permutation (seed 20261123) gives the same maxima at T20 here, to 5 decimals.
- **Cores:** 4 chunks at T20 and T500 gave identical files on 1 worker and on 4.
- **Memory:** about 0.5 GB shared, plus about 0.9 GB per worker at T20, scanning one chromosome at a time. Four workers peaked at 5.7 GB of summed resident memory, which counts the shared part once per worker, so the job uses 10 workers to stay well under Squirm's 16 GB.
- **Time:** about 25 minutes per permutation on one Metis core, so about 8 hours for 200 permutations on 10 cores.

## Inputs

`inputs/` is written by `squirm_inputs.R` in the fork.

- **`inputs/bxd_risib/`** is the R/qtl2 cross: the 119 BXD strains mapped, with genotypes from GeneNetwork's `BXD_current_rev050423.geno` (heterozygous and unknown calls as missing) and the marker map in cM.
- **`inputs/mice.txt`** has one row per mouse mapped (1,746 females on chow or high fat): ear tag, strain, diet, age at death, vivarium, age at set-up, and the stratum of its strain.

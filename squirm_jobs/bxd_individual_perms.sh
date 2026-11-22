#!/bin/bash
# Squirm job: bxd_individual_perms — genome-wide thresholds for the individual-mouse lifespan maps (R/qtl2, LOCO kinship),
# 200 permutations of strains within epochs, for the thresholds of panels c to f of Fig. 2 (QTL/README.md). Exploratory.
# Cores: 4
# Memory: 6 GB (resident memory of all workers added together: 5.7 GB measured on Metis with 4 workers at T20)
# Expected time: about 21 hours on 4 cores (25 minutes per permutation on one Metis core; a chunk of 2 takes about 50 minutes) with ATHENA otherwise idle (it may wait and pause far longer)
# Seeds: chunk k uses seed 20261123 + k (100 chunks of 2 permutations)
# Checked first by squirm/bxd_perms_smoke: ATHENA (R 4.6.2) matched Metis (R 4.6.1) to 6e-6 on -log10 P.
#
# Squirm runs it from the repository's root at the commit that added it, with SQUIRM_CORES (4 here), SQUIRM_OUT
# (output/squirm/bxd_individual_perms, already made), SQUIRM_NAME, R_LIBS_USER (Squirm's library, with installer.R's
# packages) and LC_ALL=C.UTF-8 set. It writes only under $SQUIRM_OUT; no network, no installs.
set -euo pipefail
Rscript --vanilla QTL/qtl2_individuals_perm.R --workers "$SQUIRM_CORES" --chunks 100 --per-chunk 2 --seed 20261123 \
  --out "$SQUIRM_OUT"

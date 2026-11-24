#!/bin/bash
# Squirm job: bxd_individualsF1_perms_h — more permutations for the genome-wide thresholds of the individual-mouse lifespan
# maps with the BXD x BXD F1 mice (Fig. 2c-f), chunks 226 to 250 of 500: 50 permutations of strains within epochs and F1
# types within class, with the largest Cauchy combination over T-ages (QTL/README.md). Exploratory. Rob, 24 November 2026:
# "Yes, queue them" (800 more, for 1,000 in all; jobs a and b hold chunks 1-100).
# Cores: 3
# Memory: 6 GB (resident memory of all workers added together: 5.4 GB measured on Metis with 3 workers at T20)
# Expected time: about 16 hours on 3 cores (about 45 minutes per permutation on one Metis core; a chunk of 2 takes about 90 minutes) with ATHENA otherwise idle (it may wait and pause far longer)
# Seeds: chunk k uses seed 20261124 + k (500 chunks of 2 permutations; this job runs chunks 226 to 250)
# Checked first on Metis: --check yes reproduces the maps of qtl2_individualsF1.R (robwwilliams/BxDLifeSpan) to 4 decimals.
#
# Squirm runs it from the repository's root at the commit that added it, with SQUIRM_CORES (3 here), SQUIRM_OUT
# (output/squirm/bxd_individualsF1_perms_h, already made), SQUIRM_NAME, R_LIBS_USER (Squirm's library, with installer.R's
# packages) and LC_ALL=C.UTF-8 set. It writes only under $SQUIRM_OUT; no network, no installs. The jobs' chunks are
# combined into thresholds afterwards, on Metis.
set -euo pipefail
Rscript --vanilla QTL/qtl2_individualsF1_perm.R --workers "$SQUIRM_CORES" --chunks 500 --per-chunk 2 --seed 20261124 \
  --only "$(seq -s, 226 250)" --out "$SQUIRM_OUT"

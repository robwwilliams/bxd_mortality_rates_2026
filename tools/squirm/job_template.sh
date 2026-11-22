#!/bin/bash
# Squirm job: NAME — one line on what it computes and which plan, figure or note it serves
# Cores: 12
# Memory: 4 GB
# Expected time: about 3 hours on 12 cores with ATHENA otherwise idle (it may wait and pause far longer)
# Seeds: chunk k uses seed 20261122 + k
#
# Copy this to squirm_jobs/NAME.sh (NAME also names the branch, squirm/NAME). Squirm runs it from the repository's root
# at the commit that added it, with SQUIRM_CORES (at most 12), SQUIRM_OUT (output/squirm/NAME, already made),
# SQUIRM_NAME, R_LIBS_USER (Squirm's library, with installer.R's packages) and LC_ALL=C.UTF-8 set.
# Write only under $SQUIRM_OUT. No network, no installs, nothing read from outside the repository.
set -euo pipefail
Rscript --vanilla path/to/your_permutations.R --cores "$SQUIRM_CORES" --chunks 20 --per-chunk 500 --seed 20261122 \
  --out "$SQUIRM_OUT"

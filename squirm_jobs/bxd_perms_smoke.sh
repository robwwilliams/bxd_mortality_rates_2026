#!/bin/bash
# Squirm job: bxd_perms_smoke — a first, small job on ATHENA: 2 permutations of the individual-mouse maps at 3 late T-ages,
# to check Squirm's setup, R/qtl2 on ATHENA, and agreement with the same run on Metis, before the 200-permutation job.
# Cores: 2
# Memory: 2 GB
# Expected time: about 2 minutes
# Seeds: chunk k uses seed 20261123 + k (2 chunks of 1 permutation)
set -euo pipefail
Rscript --vanilla -e 'cat(R.version.string, "; qtl2", as.character(packageVersion("qtl2")), "\n")'
Rscript --vanilla QTL/qtl2_individuals_perm.R --workers "$SQUIRM_CORES" --chunks 2 --per-chunk 1 --seed 20261123 \
  --tps 710,740,770 --out "$SQUIRM_OUT"

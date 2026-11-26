#!/bin/bash
# Squirm job: bxd_ctl_scan - Danny Arends's CTL scan of weight against lifespan in BXD mice (BXD only), rerun with the cleaned code at
# both levels (mice as n, and strains as n), for Danny's design and the grid of weighing ages W80 to W740, judged by 1,000 permutations
# of whole strains within strata. Replaces the F1-including grid of 25 November 2026 for the paper's note. Exploratory.
# Cores: 8
# Memory: 5 GB (about 0.45 GB per process measured on Metis; 8 workers and the parent)
# Expected time: about 1.5 hours on 8 cores with ATHENA otherwise idle (it may wait and pause far longer)
# Seeds: map i uses seed 20261124 + i (results identical on 1 and 4 cores, checked on Metis)
#
# Code and inputs: CTL/ (copies of robwwilliams/BxDLifeSpan at 03c43c1; see CTL/README.md). ctl_scan.R takes no arguments; its
# settings are fixed in the file and written to output/ctl_scan/run_info.txt. It is one job of about an hour: if Squirm ends it to free
# memory, it starts over and loses at most that hour. Everything is written under $SQUIRM_OUT; the copied inputs are removed at the end.
set -euo pipefail
export TMPDIR="$SQUIRM_OUT/tmp"; mkdir -p "$TMPDIR" "$SQUIRM_OUT/output/ctl_scan"
cp CTL/ctl_functions.R CTL/ctl_scan.R "$SQUIRM_OUT/"
cp CTL/inputs/mice.txt CTL/inputs/genotypes.txt "$SQUIRM_OUT/output/ctl_scan/"
cd "$SQUIRM_OUT"
Rscript --vanilla -e 'invisible(Rcpp::evalCpp("1 + 1"))' || { echo "Rcpp cannot compile C++ here (no compiler?); ctl_scan.R needs it"; exit 2; }
Rscript --vanilla ctl_scan.R
rm -f output/ctl_scan/mice.txt output/ctl_scan/genotypes.txt; rm -rf "$TMPDIR"

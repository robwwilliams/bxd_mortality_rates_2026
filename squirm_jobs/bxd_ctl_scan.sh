#!/bin/bash
# Squirm job: bxd_ctl_scan - Danny Arends's CTL scan of weight against lifespan in BXD mice (BXD only), rerun with the cleaned code at
# three levels (mice as n; strains as n with Danny's weights; strains with the standard weights (n - 3) / 1.06 and at least 20 strains
# per group), for Danny's design and the grid of weighing ages W80 to W740, judged by 1,000 permutations
# of whole strains within strata. Replaces the F1-including grid of 25 November 2026 for the paper's note. Exploratory.
# Then two short checks (added 26 November 2026, Rob: "Yes, queue both"): ctl_strain_subsets.R, whether each test's P values are right
# on random splits of the strains, and effective_Tages.R, how many independent tests the 25 T-ages add.
# Cores: 8
# Memory: 5 GB (about 0.45 GB per process measured on Metis; 8 workers and the parent; the checks use one process of about 0.3 GB)
# Expected time: about 1.7 hours on 8 cores with ATHENA otherwise idle, and a few minutes for the checks (it may wait and pause far longer)
# Seeds: map i uses seed 20261124 + i (results identical on 1 and 4 cores, checked on Metis); the strain splits use 20261126 + 1000 j + k
# (split size j, scan k); effective_Tages.R's scrambled maps are the scan's permutations 1 to 10
#
# Code and inputs: CTL/ (copies of robwwilliams/BxDLifeSpan; see CTL/README.md for the commit). The scripts take no arguments; their
# settings are fixed in the files and written to run_info files under output/. It is one job of about two hours: if Squirm ends it to
# free memory, it starts over and loses at most that. Everything is written under $SQUIRM_OUT; the copied inputs are removed at the end.
set -euo pipefail
export TMPDIR="$SQUIRM_OUT/tmp"; mkdir -p "$TMPDIR" "$SQUIRM_OUT/output/ctl_scan"
cp CTL/ctl_functions.R CTL/ctl_scan.R CTL/ctl_strain_subsets.R CTL/effective_Tages.R "$SQUIRM_OUT/"
cp CTL/inputs/mice.txt CTL/inputs/genotypes.txt "$SQUIRM_OUT/output/ctl_scan/"
cd "$SQUIRM_OUT"
Rscript --vanilla -e 'invisible(Rcpp::evalCpp("1 + 1"))' || { echo "Rcpp cannot compile C++ here (no compiler?); ctl_scan.R needs it"; exit 2; }
Rscript --vanilla ctl_scan.R
Rscript --vanilla ctl_strain_subsets.R
Rscript --vanilla effective_Tages.R
rm -f output/ctl_scan/mice.txt output/ctl_scan/genotypes.txt; rm -rf "$TMPDIR"

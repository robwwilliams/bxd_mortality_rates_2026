#
# effective_Tages.R - How many independent tests do the 25 T-ages of a CTL scan add? (simpleM on the T-age dimension)
#
# Rob Williams's fork, 26 November 2026. Exploratory. Rob: "How much dynamics is there in the actuarial dimension. Rob thinks 4 is too
# high. Visually it looks like 2 to 3. Figure it out empirically." Written by Claude (Opus 5.5) before any result; Rob: "Yes, queue
# both". BXD mice, Danny's design (weight at T). Run from the fork's root after ctl_inputs.R, with no arguments: Rscript effective_Tages.R
#
# The approach. At one marker, the tests at the 25 T-ages are correlated: the mice alive at a later T are among those alive at an
# earlier one, and weights at nearby ages are alike. The correlation is measured where no CTL exists, in maps whose genotypes are
# scrambled among strains (ctl_scan.R's permutations 1 to N.SCRAMBLED.MAPS, same seeds):
#  1. each test's signed -log10 P becomes a signed normal score;
#  2. over all markers (distinct strain patterns) of all scrambled maps, the correlation matrix of the scores among T-ages;
#  3. its eigenvalues give the effective number of T-ages: simpleM (components for 99.5% of the variance; Gao, Starmer & Martin 2008),
#     the components for 95%, and Li & Ji (2005).
# The same from the real map, for comparison. Both tests: mice as n (Danny's) and standard (strain means, ctlTestStandard()).
# A genome-wide Bonferroni line then counts about MARKER.TESTS x effective T-ages tests. That product is an approximation: it treats the
# marker and T-age dimensions as separate.
# Writes output/effective_Tages.txt and output/effective_Tages_run_info.txt
#

source("ctl_functions.R"); library(tools)

# ---- Settings ------------------------------------------------------------------------------------------------------------------------
INPUT.DIR <- "output/ctl_scan"                                             # mice.txt and genotypes.txt (ctl_inputs.R)
OUTPUT.FILE <- "output/effective_Tages.txt"
RUN.INFO.FILE <- "output/effective_Tages_run_info.txt"
N.SCRAMBLED.MAPS <- 10                                                     # scrambled map i uses seed SEED + i, as permutation i of ctl_scan.R
SEED <- 20261124
VARIANCE.EXPLAINED <- 0.995                                                # simpleM (Gao et al. 2008)
MARKER.TESTS <- 1099                                                       # simpleM of the genotypes over the 118 strains (effective_tests_simpleM.R)
STRAIN.MIN.MICE <- 2                                                       # as in ctl_scan.R
MIN.SHARE.TESTED <- 0.5                                                    # a T-age enters only if at least this share of markers has a test

# ---- Step 1. Inputs and the scans of Danny's design ----------------------------------------------------------------------------------
inp <- readInputs(INPUT.DIR)
Tages <- as.numeric(sub("^w", "", grep("^w[0-9]+$", colnames(inp$mice), value = TRUE)))    # numeric vector: the 25 T-ages, days
scans <- buildScans(inp$mice, inp$strains, c(actuarial = NA), Tages, STRAIN.MIN.MICE)         # list of scans (ctl_functions.R, step 4)

# ---- Step 2. The maps of one assignment of genotypes to strains: both diets, both tests ----------------------------------------------
# strain.order: integer vector, the strain whose genotypes each strain takes (seq_along(inp$strains) for the real map).
# Returns list by diet ("CD", "HF") of list by test ("mice as n", "standard") of matrices, distinct patterns x T-ages, of signed -log10 P.
mapsOfOrder <- function(strain.order){
  G <- inp$G[strain.order, , drop = FALSE]
  lapply(c(CD = "CD", HF = "HF"), function(diet){
    diet.scans <- scans[sapply(scans, `[[`, "diet") == diet]
    list(`mice as n` = scanAll(G, diet.scans), standard = scanAllStrains(G, diet.scans)$standard)
  })
}

# ---- Step 3. Signed normal scores -----------------------------------------------------------------------------------------------------
# A CTL test's P (chi-square, 1 d.f.) equals a two-sided normal P, so |score| = the normal quantile of P / 2, computed on the log scale
# so that a very small P does not underflow. The sign is the test's (positive where r(D) > r(B)). NA stays NA.
signedNormalScore <- function(signed.log10P)
  sign(signed.log10P) * qnorm(-abs(signed.log10P) * log(10) - log(2), lower.tail = FALSE, log.p = TRUE)

# ---- Step 4. The effective number of T-ages from scores (matrix: markers x T-ages) ----------------------------------------------------
# Returns c(Tages, simpleM, pc95, LiJi, first.PC, adjacent.r): T-ages used, the three counts, the share of variance on the first
# component, and the mean correlation of T-ages 30 days apart.
effectiveTages <- function(scores){
  scores <- scores[, colMeans(!is.na(scores)) >= MIN.SHARE.TESTED, drop = FALSE]
  correlation <- cor(scores, use = "pairwise.complete.obs")                 # T-ages x T-ages
  eigenvalues <- pmax(eigen(correlation, symmetric = TRUE, only.values = TRUE)$values, 0)
  variance.share <- cumsum(eigenvalues) / sum(eigenvalues)
  c(Tages = ncol(scores), simpleM = which(variance.share >= VARIANCE.EXPLAINED)[1], pc95 = which(variance.share >= 0.95)[1],
    LiJi = sum((eigenvalues >= 1) + (eigenvalues - floor(eigenvalues))), first.PC = eigenvalues[1] / sum(eigenvalues),
    adjacent.r = mean(correlation[cbind(2:ncol(correlation), 1:(ncol(correlation) - 1))]))
}

# ---- Step 5. The real map and the scrambled maps ---------------------------------------------------------------------------------------
started <- Sys.time()
real.maps <- mapsOfOrder(seq_along(inp$strains))
scrambled.maps <- lapply(seq_len(N.SCRAMBLED.MAPS), function(i) mapsOfOrder(permuteStrains(inp$stratum, SEED + i)))
minutes <- as.numeric(difftime(Sys.time(), started, units = "mins"))

# ---- Step 6. The report -------------------------------------------------------------------------------------------------------------
sink(OUTPUT.FILE, split = TRUE)
cat("Effective number of T-ages in a CTL scan (", length(Tages), " T-ages, ", min(Tages), " to ", max(Tages), " days), from the correlation\n", sep = "")
cat("of the signed test scores among T-ages, over markers. Scrambled: ", N.SCRAMBLED.MAPS, " maps with genotypes scrambled among strains\n", sep = "")
cat("(no CTL). simpleM at 99.5%, components for 95%, Li & Ji. first PC: share of variance on the first component; adjacent r: mean\n")
cat("correlation of T-ages 30 days apart. Tests: MARKER.TESTS (", MARKER.TESTS, ") x effective T-ages, and the Bonferroni 5% line.\n\n", sep = "")
for(diet in c("CD", "HF")) for(test in c("mice as n", "standard")){
  scrambled.scores <- do.call(rbind, lapply(scrambled.maps, function(m) signedNormalScore(m[[diet]][[test]])))   # the maps stacked
  null <- effectiveTages(scrambled.scores); real <- effectiveTages(signedNormalScore(real.maps[[diet]][[test]]))
  cat(sprintf("%-8s %-9s scrambled: simpleM %2d (95%%: %2d), Li & Ji %4.1f of %d T-ages; first PC %.0f%%; adjacent r %.2f | real: simpleM %2d (95%%: %2d), Li & Ji %4.1f\n",
              c(CD = "Chow", HF = "High fat")[diet], test, null["simpleM"], null["pc95"], null["LiJi"], null["Tages"], 100 * null["first.PC"],
              null["adjacent.r"], real["simpleM"], real["pc95"], real["LiJi"]))
  for(count in c("simpleM", "pc95", "LiJi")){
    tests <- MARKER.TESTS * null[[count]]
    cat(sprintf("%22s %-7s: %6.0f tests, Bonferroni 5%% line -log10 P %.2f\n", "", count, tests, -log10(0.05 / tests)))
  }
}
sink()

# ---- Step 7. The run record ---------------------------------------------------------------------------------------------------------
writeLines(c(paste("Run:", format(Sys.time(), "%Y-%m-%d %H:%M %Z"), "on", Sys.info()[["nodename"]], "-", R.version.string, "- Rcpp", as.character(packageVersion("Rcpp"))),
             paste("Settings: N.SCRAMBLED.MAPS", N.SCRAMBLED.MAPS, "SEED", SEED, "VARIANCE.EXPLAINED", VARIANCE.EXPLAINED, "MARKER.TESTS", MARKER.TESTS,
                   "STRAIN.MIN.MICE", STRAIN.MIN.MICE, "MIN.SHARE.TESTED", MIN.SHARE.TESTED),
             paste("Inputs (md5):", paste(c("mice.txt", "genotypes.txt"), md5sum(file.path(INPUT.DIR, c("mice.txt", "genotypes.txt"))), collapse = "; ")),
             paste("Code (md5):", paste(c("ctl_functions.R", "effective_Tages.R"), md5sum(c("ctl_functions.R", "effective_Tages.R")), collapse = "; ")),
             paste("Scans:", length(scans), "; minutes:", round(minutes, 1))), RUN.INFO.FILE)

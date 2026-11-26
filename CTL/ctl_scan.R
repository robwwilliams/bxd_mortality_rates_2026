#
# ctl_scan.R - Danny Arends's CTL scan of weight against lifespan in BXD mice, tested by permuting whole strains
#
# Rob Williams's fork, 26 November 2026. Written by Claude (Opus 5.5) at Danny's request; it replaces ctl_permutations.R. Exploratory.
# Run from the fork's root, after ctl_inputs.R, with no arguments: Rscript ctl_scan.R. Every setting is below and is written to the output.
#
# The approach (functions in ctl_functions.R, checked by ctl_tests.R):
#  1. Inputs: adjusted lifespans and weights of the BXD mice on chow or high fat, and the strains' genotypes (ctl_inputs.R).
#  2. Scans: a scan is one diet, one survivorship age T and one weighing age W, with the mice on the diet by W and alive at T. Danny's
#     design ("actuarial") weighs at T. The grid designs ("W80" to "W740") weigh at one age W and follow T from W to 770 days.
#  3. Map: at each marker and scan, Danny's CTL test, a signed -log10 P.
#  3b. The same map with strains as the units (added 26 November 2026, exploratory, after the mouse-level results were seen; Rob and
#     Danny asked why the mice give such small P values): Spearman correlation of strain means within B and within D strains, n = strains.
#  4. Two statistics per design, diet and level (mice, strains), each a separate test:
#     max     the largest -log10 P over all markers and T-ages;
#     cauchy  at each marker, its T-ages' P values joined by Danny's cauchycombination(); then the largest over markers.
#  5. Permutations: each strain takes the genotypes of another strain of its stratum. The same assignment serves every scan, diet and
#     design, and the whole map is rescanned. Mice keep their weights, lifespans and strain mates.
#  6. Each statistic of the real map is judged against the same statistic of the permuted maps (5% threshold, genome-wide P).
#
# Writes, in output/ctl_scan/: summary.txt (the results), maxima.txt (one row per map; perm 0 is the real data), scan_maxima.txt (the
# largest -log10 P of each scan, per map), real_maps_actuarial.txt and real_maps_actuarial_strains.txt (the real -log10 P of every marker
# in Danny's design, mice and strains) and run_info.txt.
#

source("ctl_functions.R")
library(parallel); library(tools)

# ---- Settings ------------------------------------------------------------------------------------------------------------------------
N.PERM  <- 1000                                                            # permutations
CORES   <- 8                                                               # about 0.5 GB each; the results do not depend on it (map i uses SEED + i)
SEED    <- 20261124
DIR     <- "output/ctl_scan"                                               # inputs and outputs
STRAIN.MIN.MICE <- 2                                                       # strain-level map: mice a strain needs in a scan
DESIGNS <- c(actuarial = NA, setNames(seq(80, 740, 30), paste0("W", seq(80, 740, 30))))   # NA: weight at T (Danny's CTL.R)

# ---- 1-2. Inputs and scans -------------------------------------------------------------------------------------------------------------
inp <- readInputs(DIR)
Tages <- as.numeric(sub("^w", "", grep("^w[0-9]+$", colnames(inp$mice), value = TRUE)))
scans <- buildScans(inp$mice, inp$strains, DESIGNS, Tages, STRAIN.MIN.MICE)
cat(nrow(inp$mice), "mice,", length(inp$strains), "strains,", length(inp$pat), "markers (", ncol(inp$G), "distinct patterns ),", length(scans), "scans\n")

# ---- 3-5. The real map and the permuted maps ---------------------------------------------------------------------------------------
t0 <- Sys.time()
real <- runMap(0, inp, scans, SEED)
perms <- mclapply(1:N.PERM, function(i){ r <- runMap(i, inp, scans, SEED); r$L <- NULL; r$LS <- NULL; r }, mc.cores = CORES)
if(any(sapply(perms, inherits, "try-error"))) stop("a permutation failed: ", perms[sapply(perms, inherits, "try-error")][[1]])
minutes <- as.numeric(difftime(Sys.time(), t0, units = "mins"))

maxima <- data.frame(perm = 0:N.PERM, rbind(real$summary, t(sapply(perms, `[[`, "summary"))), check.names = FALSE)
scanmax <- data.frame(perm = 0:N.PERM, rbind(real$scanmax, t(sapply(perms, `[[`, "scanmax"))), check.names = FALSE)
a <- sapply(scans, `[[`, "design") == "actuarial"                         # real maps of Danny's design (all designs would pass 100 MB)
maps <- data.frame(inp$map, round(real$L[inp$pat, a], 4), check.names = FALSE)
maps.strain <- data.frame(inp$map, round(real$LS[inp$pat, a], 4), check.names = FALSE)
write.table(cbind(maxima[1], round(maxima[-1], 4)), file.path(DIR, "maxima.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(cbind(scanmax[1], round(scanmax[-1], 4)), file.path(DIR, "scan_maxima.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(maps, file.path(DIR, "real_maps_actuarial.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(maps.strain, file.path(DIR, "real_maps_actuarial_strains.txt"), sep = "\t", quote = FALSE, row.names = FALSE)

# ---- 6. Results ---------------------------------------------------------------------------------------------------------------------
null <- maxima[-1, ]; obs <- maxima[1, ]
res <- do.call(rbind, lapply(c(mice = "", strains = ".strain"), function(level) do.call(rbind, lapply(names(DESIGNS), function(dn) do.call(rbind, lapply(c("CD", "HF"), function(diet){
  k <- paste0(dn, ".", diet, level); if(!paste0(k, ".max") %in% colnames(maxima)) return(NULL)
  f <- function(s) obs[[paste0(k, ".", s)]]; g <- function(s) null[[paste0(k, ".", s)]]
  data.frame(level = if(level == "") "mice" else "strains", design = dn, diet = diet, scans = sum(sapply(scans, function(d) d$design == dn && d$diet == diet)),
             max = f("max"), max.P05 = quantile(g("max"), .95), max.P = permP(f("max"), g("max")),
             cauchy = f("cauchy"), cauchy.P05 = quantile(g("cauchy"), .95), cauchy.P = permP(f("cauchy"), g("cauchy")),
             Bonf = f("Bonf"), Bonf.perm.pct = 100 * mean(g("Bonf") > 0), lambda = f("lambda"), lambda.perm = median(g("lambda")))
}))))))
grid <- do.call(c, lapply(c(mice = "", strains = ".strain"), function(level) lapply(c("CD", "HF"), function(diet){   # grid designs together
  k <- paste0(grep("^W", names(DESIGNS), value = TRUE), ".", diet, level, ".max"); k <- k[k %in% colnames(maxima)]
  m <- apply(maxima[, k], 1, max); data.frame(level = if(level == "") "mice" else "strains", diet = diet,
    scans = sum(res$scans[res$diet == diet & res$design != "actuarial" & res$level == "mice"]), max = m[1], max.P05 = quantile(m[-1], .95), max.P = permP(m[1], m[-1])) })))

sink(file.path(DIR, "summary.txt"), split = TRUE)
cat("CTL of weight and lifespan in BXD mice (Danny Arends's test), judged by", N.PERM, "permutations of whole strains within strata\n")
cat("level mice: Danny's test, n = mice. level strains: strain means, n = strains (exploratory, added 26 November 2026).\n")
cat("max: largest -log10 P over markers and T-ages. cauchy: largest Cauchy-combined -log10 P over markers. P05: 5% permutation threshold.\n")
cat("P: genome-wide P. Bonf: Bonferroni calls over all markers and T-ages; Bonf.perm.pct: % of permuted maps with at least one.\n")
cat("lambda: median chi-square / expected, real and median over permuted maps.\n\n")
options(width = 200); num <- sapply(res, is.numeric); res[num] <- round(res[num], 3); print(res, row.names = FALSE)
if(any(grepl("^W", names(DESIGNS)))){
  cat("\nThe grid designs (W80 to W740) together: the largest -log10 P over all weighing ages, T-ages and markers\n")
  g <- do.call(rbind, grid); g[-(1:2)] <- round(g[-(1:2)], 3); print(g, row.names = FALSE)
}
sink()

info <- c(paste("Run:", format(Sys.time(), "%Y-%m-%d %H:%M %Z"), "on", Sys.info()[["nodename"]], "-", R.version.string, "- Rcpp", as.character(packageVersion("Rcpp"))),
          paste("Settings: N.PERM", N.PERM, "CORES", CORES, "SEED", SEED, "DIR", DIR, "STRAIN.MIN.MICE", STRAIN.MIN.MICE),
          paste("Designs:", paste(names(DESIGNS), ifelse(is.na(DESIGNS), "weight at T", paste0("weight at ", DESIGNS, " days")), collapse = "; ")),
          paste("Inputs (md5):", paste(c("mice.txt", "genotypes.txt"), md5sum(file.path(DIR, c("mice.txt", "genotypes.txt"))), collapse = "; ")),
          paste("Code (md5):", paste(c("ctl_functions.R", "ctl_scan.R"), md5sum(c("ctl_functions.R", "ctl_scan.R")), collapse = "; ")),
          paste("Scans:", length(scans), "; minutes:", round(minutes, 1)))
writeLines(info, file.path(DIR, "run_info.txt"))

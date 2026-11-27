#
# ctl_strain_subsets.R - With no CTL, how much does the difference between two groups' correlations vary when the groups are sets of
# real BXD strains? Measured on the real data, against what each version of the CTL test assumes.
#
# Rob Williams's fork, 26 November 2026. Exploratory. Claude (Opus 5.5) had written that with no CTL a correlation across 23 genomes
# varies by about 1/sqrt(20) "whether each mean comes from 1 mouse or 100". Rob: "We also know that this is not true from h2 estimates",
# and later "Not more stable than 1/sq root of n". Rob and Danny Arends also doubt that a permutation threshold can be stricter than
# their Bonferroni count of about 2,000 tests, as 20 scrambled maps suggested. Claude proposed this check and wrote it before any
# result; Rob: "Yes, queue both". It measures, on the real data and with no genotypes involved, whether the tests' P values are right,
# in the bulk and in the tail; effective_Tages.R, run with it, measures the count of tests. BXD mice, Danny's design (weight at T).
# Run from the fork's root after ctl_inputs.R, with no arguments: Rscript ctl_strain_subsets.R. The settings are below.
#
# The approach. A random split of a scan's strains into two groups acts as a marker with no CTL: no genotype is involved, so the two
# groups' correlations differ only by chance. For each scan (diet, T-age) and each split, the Fisher z of the Spearman correlation of
# weight with lifespan is computed in each group, and the difference zB - zD is divided by the standard deviation the test assumes:
#   mice as n      Danny's CTL.R: all mice, each weighted 1 / (mice of its strain); sd = sqrt(1 / (mice B - 1) + 1 / (mice D - 1))
#   strain means   each strain is the mean of all its mice; the standard test: sd = sqrt(1.06 / (strains B - 3) + 1.06 / (strains D - 3))
#   one mouse      one mouse drawn at random per strain, in place of the mean; the same sd as strain means
# The square of a standardized difference is the test's chi-square. If the test's P values are right, its mean over the splits is 1
# (comparable to lambda in the Q-Q plots), P < 0.001 happens in 0.1% of splits and P < 1e-4 in 0.01%; the pooled tail rates over
# all scans (about a million splits per diet) show whether the smallest P values are right.
# Also per scan: the heritability of weight and of lifespan (share of variance between strains, one-way ANOVA) and the reliability of
# the strain means, mice.per.strain * h2 / (1 + (mice.per.strain - 1) * h2).
# Two split sizes: 23 strains and the rest (Danny's example) and half and half. Strains: those with at least STRAIN.MIN.MICE mice in the
# scan, the same strains for all three versions. A split is used only if each group has at least MIN.STRAINS strains.
# Writes output/ctl_strain_subsets.txt and output/ctl_strain_subsets_run_info.txt
#

source("ctl_functions.R"); library(tools)

# ---- Settings ------------------------------------------------------------------------------------------------------------------------
INPUT.DIR <- "output/ctl_scan"                                             # mice.txt and genotypes.txt (ctl_inputs.R)
OUTPUT.FILE <- "output/ctl_strain_subsets.txt"
RUN.INFO.FILE <- "output/ctl_strain_subsets_run_info.txt"
N.SPLITS <- 10000                                                          # random splits per scan and split size
N.MOUSE.DRAWS <- 100                                                       # one-mouse version: a new draw of mice every N.SPLITS / N.MOUSE.DRAWS splits
FIRST.GROUP.SIZE <- c(`23 and the rest` = 23, `half and half` = NA)        # strains in the first group; NA: half of the strains (rounded down)
STRAIN.MIN.MICE <- 2                                                       # as in ctl_scan.R
MIN.STRAINS <- 20                                                          # strains each group needs, as in ctlTestStandard()
SEED <- 20261126                                                           # split size j of scan k uses seed SEED + 1000 * j + k

# ---- Step 1. Inputs and the scans of Danny's design (weight at T) --------------------------------------------------------------------
inp <- readInputs(INPUT.DIR)
Tages <- as.numeric(sub("^w", "", grep("^w[0-9]+$", colnames(inp$mice), value = TRUE)))    # numeric vector: the 25 T-ages, days
scans <- buildScans(inp$mice, inp$strains, c(actuarial = NA), Tages, STRAIN.MIN.MICE)         # list of scans (ctl_functions.R, step 4)

# ---- Step 2. Random splits, coded as genotypes -----------------------------------------------------------------------------------------
# Returns an integer matrix, strains x splits, as ctlCor() takes genotypes: 1 first group, 2 second group, 0 strain not in the scan.
# strain.rows: integer vector, the rows (strains, from 1) of the scan's strains.
randomSplits <- function(strain.rows, first.group.size, n.splits){
  splits <- matrix(0L, length(inp$strains), n.splits)
  for(k in seq_len(n.splits)){
    in.first.group <- seq_along(strain.rows) %in% sample.int(length(strain.rows), first.group.size)   # logical, one per scan strain
    splits[strain.rows, k] <- ifelse(in.first.group, 1L, 2L)
  }
  splits
}

# ---- Step 3. One mouse per strain, in the form strainUnits() gives -------------------------------------------------------------------
# d: one scan; strain.indices: integer vector, the scan's strains (from 0, as d$s). Each strain is represented by one of its mice, drawn
# at random. Returns a list like strainUnits()'s: s, wt (all 1), nall, w and y (the drawn mice's weight and lifespan), ow/tw, oy/ty.
oneMousePerStrain <- function(d, strain.indices){
  drawn.mouse <- sapply(strain.indices, function(k){ mice.of.strain <- which(d$s == k); mice.of.strain[sample.int(length(mice.of.strain), 1)] })
  weight <- d$w[drawn.mouse]; lifespan <- d$y[drawn.mouse]; ow <- order(weight); oy <- order(lifespan)
  list(s = strain.indices, wt = rep(1, length(strain.indices)), nall = d$nall, w = weight, y = lifespan,
       ow = ow - 1L, tw = match(weight[ow], unique(weight[ow])), oy = oy - 1L, ty = match(lifespan[oy], unique(lifespan[oy])))
}

# ---- Step 4. The standardized difference of the two groups' correlations -------------------------------------------------------------
# correlations: ctlCor()'s output, splits x (rB, rD, nB, nD); n are mice for the mouse-level version and strains for the others.
# Fisher's z is Danny's expression (as in ctlTest()). Returns a numeric vector, one per split: (zB - zD) / the sd the test assumes.
fisherZ <- function(r) 0.5 * log((1 + r) / (1 - r))
differenceMiceAsN <- function(correlations)
  (fisherZ(correlations[, 1]) - fisherZ(correlations[, 2])) / sqrt(1 / (correlations[, 3] - 1) + 1 / (correlations[, 4] - 1))
differenceStandard <- function(correlations)
  (fisherZ(correlations[, 1]) - fisherZ(correlations[, 2])) / sqrt(1.06 / (correlations[, 3] - 3) + 1.06 / (correlations[, 4] - 3))

# Returns c(chisq, P001, P1e4, splits): the mean squared difference (1 if valid), the percentages of splits with P < 0.001 (0.1 if
# valid) and with P < 1e-4 (0.01 if valid), and the number of splits with a test
summarizeDifferences <- function(difference){
  difference <- difference[is.finite(difference)]
  c(chisq = mean(difference^2), P001 = 100 * mean(abs(difference) > qnorm(0.001 / 2, lower.tail = FALSE)),
    P1e4 = 100 * mean(abs(difference) > qnorm(1e-4 / 2, lower.tail = FALSE)), splits = length(difference))
}

# ---- Step 5. Heritability: the share of variance between strains (one-way ANOVA, unequal numbers of mice) ---------------------------
# value: numeric vector, one per mouse; strain: the mouse's strain. Returns the share (0 to 1).
strainShare <- function(value, strain){
  mice.per.strain <- table(strain); n.strains <- length(mice.per.strain); n.mice <- length(value)
  strain.mean <- tapply(value, strain, mean)
  between <- sum(mice.per.strain * (strain.mean - mean(value))^2) / (n.strains - 1)            # mean square between strains
  within <- sum((value - strain.mean[as.character(strain)])^2) / (n.mice - n.strains)            # mean square within strains
  mice.per.strain.adjusted <- (n.mice - sum(mice.per.strain^2) / n.mice) / (n.strains - 1)
  variance.between <- max((between - within) / mice.per.strain.adjusted, 0)
  variance.between / (variance.between + within)
}
reliability <- function(h2, mice.per.strain) mice.per.strain * h2 / (1 + (mice.per.strain - 1) * h2)

# ---- Step 6. One scan and one split size ----------------------------------------------------------------------------------------------
# Returns a one-row data frame, or NULL when the scan has too few strains for the split.
checkScan <- function(d, split.name, scan.number, split.number){
  units <- d$strain.units; strain.rows <- units$s + 1L                     # the scan's strains with at least STRAIN.MIN.MICE mice
  first.group.size <- if(is.na(FIRST.GROUP.SIZE[[split.name]])) floor(length(strain.rows) / 2) else FIRST.GROUP.SIZE[[split.name]]
  if(first.group.size < MIN.STRAINS || length(strain.rows) - first.group.size < MIN.STRAINS) return(NULL)
  RNGkind("L'Ecuyer-CMRG", "Inversion", "Rejection"); set.seed(SEED + 1000 * split.number + scan.number)
  splits <- randomSplits(strain.rows, first.group.size, N.SPLITS)
  in.scan.strains <- d$s %in% units$s                                       # logical, one per mouse: its strain is one of the scan's strains
  mice.as.n <- differenceMiceAsN(ctlCor(splits, d$s, d$wt, d$ow, d$tw, d$oy, d$ty, d$nall))
  strain.means <- differenceStandard(ctlCor(splits, units$s, units$wt, units$ow, units$tw, units$oy, units$ty, units$nall))
  splits.per.draw <- N.SPLITS / N.MOUSE.DRAWS
  one.mouse <- unlist(lapply(seq_len(N.MOUSE.DRAWS), function(draw){
    drawn <- oneMousePerStrain(d, units$s); columns <- (draw - 1) * splits.per.draw + seq_len(splits.per.draw)
    differenceStandard(ctlCor(splits[, columns, drop = FALSE], drawn$s, drawn$wt, drawn$ow, drawn$tw, drawn$oy, drawn$ty, drawn$nall)) }))
  mice.per.strain <- sum(in.scan.strains) / length(units$s)
  h2.weight <- strainShare(d$w[in.scan.strains], d$s[in.scan.strains]); h2.lifespan <- strainShare(d$y[in.scan.strains], d$s[in.scan.strains])
  data.frame(diet = d$diet, Tage = d$Tage, split = split.name, strains = length(units$s), first.group = first.group.size,
             mice = sum(in.scan.strains), mice.per.strain = mice.per.strain, h2.weight = h2.weight, h2.lifespan = h2.lifespan,
             reliability.weight = reliability(h2.weight, mice.per.strain), reliability.lifespan = reliability(h2.lifespan, mice.per.strain),
             r.strain.means = cor(units$w, units$y, method = "spearman"),
             t(setNames(summarizeDifferences(mice.as.n), paste0("mice.as.n.", c("chisq", "P001", "P1e4", "splits")))),
             t(setNames(summarizeDifferences(strain.means), paste0("strain.means.", c("chisq", "P001", "P1e4", "splits")))),
             t(setNames(summarizeDifferences(one.mouse), paste0("one.mouse.", c("chisq", "P001", "P1e4", "splits")))))
}

# ---- Step 7. All scans and split sizes ------------------------------------------------------------------------------------------------
started <- Sys.time()
results <- do.call(rbind, lapply(seq_along(scans), function(k) do.call(rbind, lapply(seq_along(FIRST.GROUP.SIZE), function(j)
  checkScan(scans[[k]], names(FIRST.GROUP.SIZE)[j], k, j)))))
minutes <- as.numeric(difftime(Sys.time(), started, units = "mins"))

# ---- Step 8. The report -------------------------------------------------------------------------------------------------------------
sink(OUTPUT.FILE, split = TRUE)
cat("With no CTL: random splits of each scan's strains (", N.SPLITS, " per scan and split size). BXD mice, Danny's design (weight at T).\n", sep = "")
cat("chisq: mean squared standardized difference of the two groups' Fisher z (1 if the test's P values are right).\n")
cat("P001, P1e4: % of splits with P < 0.001 (0.1 if right) and P < 1e-4 (0.01 if right). mice.as.n: Danny's test on all mice.\n")
cat("strain.means: the standard test on strain means of all mice. one.mouse: the standard test with one random mouse per strain.\n")
cat("h2: share of variance between strains. reliability: of the strain means.\n\n")
options(width = 300); shown <- results[, !grepl("splits$", names(results))]
numeric.columns <- sapply(shown, is.numeric) & !names(shown) %in% c("Tage", "strains", "first.group", "mice")
shown[numeric.columns] <- round(shown[numeric.columns], 3); print(shown, row.names = FALSE)
cat("\nMedians over T-ages\n")
medians <- aggregate(results[, c("strains", "mice.per.strain", "h2.weight", "h2.lifespan", "reliability.weight", "reliability.lifespan",
                                 "mice.as.n.chisq", "strain.means.chisq", "one.mouse.chisq")],
                     by = list(diet = results$diet, split = results$split), FUN = median)
medians[-(1:2)] <- round(medians[-(1:2)], 3); print(medians, row.names = FALSE)
cat("\nThe tail, pooled over all T-ages: % of splits with P < 0.001 (0.1 if right) and P < 1e-4 (0.01 if right)\n")
pooledRate <- function(rows, version, tail) 100 * sum(rows[[paste0(version, ".", tail)]] / 100 * rows[[paste0(version, ".splits")]]) / sum(rows[[paste0(version, ".splits")]])
pooled <- do.call(rbind, lapply(split(results, list(results$diet, results$split), drop = TRUE), function(rows)
  data.frame(diet = rows$diet[1], split = rows$split[1], splits = sum(rows$strain.means.splits),
             mice.as.n.P001 = pooledRate(rows, "mice.as.n", "P001"), strain.means.P001 = pooledRate(rows, "strain.means", "P001"), one.mouse.P001 = pooledRate(rows, "one.mouse", "P001"),
             mice.as.n.P1e4 = pooledRate(rows, "mice.as.n", "P1e4"), strain.means.P1e4 = pooledRate(rows, "strain.means", "P1e4"), one.mouse.P1e4 = pooledRate(rows, "one.mouse", "P1e4"))))
pooled[-(1:3)] <- round(pooled[-(1:3)], 4); print(pooled, row.names = FALSE)
sink()

# ---- Step 9. The run record ---------------------------------------------------------------------------------------------------------
writeLines(c(paste("Run:", format(Sys.time(), "%Y-%m-%d %H:%M %Z"), "on", Sys.info()[["nodename"]], "-", R.version.string, "- Rcpp", as.character(packageVersion("Rcpp"))),
             paste("Settings: N.SPLITS", N.SPLITS, "N.MOUSE.DRAWS", N.MOUSE.DRAWS, "FIRST.GROUP.SIZE", paste(names(FIRST.GROUP.SIZE), FIRST.GROUP.SIZE, collapse = "; "),
                   "STRAIN.MIN.MICE", STRAIN.MIN.MICE, "MIN.STRAINS", MIN.STRAINS, "SEED", SEED),
             paste("Inputs (md5):", paste(c("mice.txt", "genotypes.txt"), md5sum(file.path(INPUT.DIR, c("mice.txt", "genotypes.txt"))), collapse = "; ")),
             paste("Code (md5):", paste(c("ctl_functions.R", "ctl_strain_subsets.R"), md5sum(c("ctl_functions.R", "ctl_strain_subsets.R")), collapse = "; ")),
             paste("Scans:", length(scans), "; rows:", nrow(results), "; minutes:", round(minutes, 1))), RUN.INFO.FILE)

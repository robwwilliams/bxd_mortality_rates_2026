#
# test_alignment.R - Tests that qtl2_individualsF1_perm.R lines up mice, units, genotypes, kinship and phenotypes
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams and Danny Arends, 24 November 2026. Danny asked what the
# expansion code means; Rob: "How can we guarantee there is not 'off by one' type problems?" No test guarantees it; these are
# the ones that a misaligned index would fail.
#   1. Every mouse's expanded genotype row equals its donor unit's row (the unit it should take), looked up by name and
#      not by the code's own index; under the real assignment and under permutations.
#   2. The same for every pair of mice in the expanded kinship.
#   3. A permutation is a bijection of the units that keeps each unit in its group.
#   4. Shuffling the order of the mice, so positions change and names do not, leaves the scan unchanged.
#   5. A spike-in: a phenotype made from the D dosage at one known marker (as each mouse really carries it) plus noise. The
#      scan of the real assignment must peak at that marker's block; with a permuted assignment the peak must go away.
#   6. scan1's LODs equal LODs recomputed without it, by unit and marker name, and differ when markers slip by one.
#   7. The genotype probabilities agree with the raw calls by marker and strain name, and not when slipped by one.
# Tests 4 to 7 include deliberate off-by-one errors, to show that they would be caught. Tests 4 and 5 were revised after their first
# run failed: 4 had a tolerance (1e-6) below the numerical noise of shuffling (up to 3e-6), and 5 asked for a genotype identical
# to 1e-8 where the peak ties with neighbors correlated at 1. Tests 6 and 7 were added to settle what that failure left open.
# They cover this script, not the other mapping scripts.
#   Rscript QTL/test_alignment.R        (about 10 seconds)
#

source("QTL/qtl2_individualsF1_perm.R")                                            # defines everything; runs nothing when sourced
set.seed(20261128)
fail <- 0
check <- function(what, ok){ cat(if(isTRUE(ok)) "ok    " else "FAILED", what, "\n"); if(!isTRUE(ok)) fail <<- fail + 1 }
id <- setNames(units, units)
perms <- c(list(real = id), lapply(1:3, function(i) drawPerm()))
unit.of <- setNames(as.character(mice[, "strain"]), mice[, "id"])

### 1 and 2: genotypes and kinship, by name
expand <- function(o, chr, ids){                                                   # the code under test
  donor <- match(o[mice[, "strain"]], units); names(donor) <- mice[, "id"]; idx <- donor[ids]
  apm <- AP[, chr]; g <- apm[[chr]][idx, , , drop = FALSE]; dimnames(g)[[1]] <- ids
  list(g = g, K = `dimnames<-`(K[[chr]][idx, idx], list(ids, ids)))
}
ids <- sample(mice[, "id"], 300)
for(p in seq_along(perms)){ o <- perms[[p]]; nm <- if(p == 1) "real data" else paste("permutation", p - 1)
  for(chr in c("1", "7", "X")){
    e <- expand(o, chr, ids)
    want <- AP[[chr]][o[unit.of[ids]], , ]
    check(sprintf("genotype rows, %s, chr %s", nm, chr), all.equal(unname(e$g), unname(want), tolerance = 0) == TRUE && identical(dimnames(e$g)[[1]], ids))
    wK <- K[[chr]][o[unit.of[ids]], o[unit.of[ids]]]
    check(sprintf("kinship entries, %s, chr %s", nm, chr), all.equal(unname(e$K), unname(wK), tolerance = 0) == TRUE && isSymmetric(unname(e$K)))
  }
}

### 3: the permutations themselves
ok3 <- sapply(1:200, function(i){ o <- drawPerm(); setequal(o, units) && all(group[o] == group[names(o)]) && !anyDuplicated(o) && identical(names(o), units) })
check("200 permutations: bijections of the units, each within its group", all(ok3))
check("permutations move units (fewer than half stay in place)", mean(sapply(1:200, function(i) mean(drawPerm() == units))) < 0.5)

### 4: the order of the mice does not matter (chr 1, T500, chow)
cm0 <- cv.all[mice[, "age"] >= 500 & mice[, "diet"] == "CD", ]
one <- function(ord, o, chr = "1"){
  cm <- cm0[ord, ]; ids <- rownames(cm); X <- covars(cm, "CD"); Y <- matrix(mice[ids, "age"], dimnames = list(ids, "age"))
  e <- expand(o, chr, ids); ap <- AP[, chr]; ap[[chr]] <- e$g
  scan1(ap, Y, kinship = decomp_kinship(list(e$K)), addcovar = X)[, 1]
}
a <- one(seq_len(nrow(cm0)), id); b <- one(sample.int(nrow(cm0)), id)
slip <- function(){ ids <- rownames(cm0); X <- covars(cm0, "CD"); e <- expand(id, "1", ids); e$g[] <- e$g[c(length(ids), 1:(length(ids) - 1)), , , drop = FALSE]   # deliberate: mice off by one
  ap <- AP[, "1"]; ap[["1"]] <- e$g; scan1(ap, matrix(mice[ids, "age"], dimnames = list(ids, "age")), kinship = decomp_kinship(list(e$K)), addcovar = X)[, 1] }
check(sprintf("shuffled mice: largest LOD difference %.1e (numerical); one mouse slipped: %.1f", max(abs(a - b)), max(abs(a - slip()))), max(abs(a - b)) < 1e-4 && max(abs(a - slip())) > 0.1)

### 5: spike-in at a known marker (chr 5), for mice on chow alive at T500
cm <- cm0; ids <- rownames(cm); X <- covars(cm, "CD"); e <- expand(id, "5", ids); ap <- AP[, "5"]; ap[["5"]] <- e$g
mk <- dimnames(AP[["5"]])[[3]]; m0 <- mk[floor(length(mk) * 0.6)]
dose <- AP[["5"]][unit.of[ids], "D", m0]                                             # what each mouse truly carries at m0, by its unit's name
Y <- matrix(60 * dose + rnorm(length(ids), 0, 60), dimnames = list(ids, "spike"))
lod <- scan1(ap, Y, kinship = decomp_kinship(list(e$K)), addcovar = X)[, 1]
pk <- names(lod)[which.max(lod)]; near <- cor(AP[["5"]][unit.of[ids], "D", m0], AP[["5"]][unit.of[ids], "D", pk])
check(sprintf("spike-in: the peak (LOD %.1f) is at a marker whose genotypes correlate %.3f with the spiked one", max(lod), near), near > 0.95)
o <- drawPerm(); e2 <- expand(o, "5", ids); ap2 <- AP[, "5"]; ap2[["5"]] <- e2$g
lod2 <- scan1(ap2, Y, kinship = decomp_kinship(list(e2$K)), addcovar = X)[, 1]
check(sprintf("spike-in: permuted assignment loses the peak (LOD %.1f against %.1f)", max(lod2), max(lod)), max(lod2) < 0.5 * max(lod))

### 6: scan1 against LODs recomputed without it: generalized least squares with genotypes and kinship looked up by unit and marker
### name (R/qtl2 doubles the kinship). Equal at lag 0, and not when the markers are slipped by one either way.
u <- unit.of[ids]; y <- mice[ids, "age"]
for(chr in c("1", "5", "9", "14", "19")){
  e <- expand(id, chr, ids); ap <- AP[, chr]; ap[[chr]] <- e$g; s1 <- scan1(ap, matrix(y, dimnames = list(ids, "y")), kinship = decomp_kinship(list(e$K)), addcovar = X)
  h <- attr(s1, "hsq")[1, 1]; C <- chol(h * 2 * K[[chr]][u, u] + (1 - h) * diag(length(u))); w <- function(m) backsolve(C, m, transpose = TRUE); mk <- dimnames(AP[[chr]])[[3]]; n <- length(mk)
  q0 <- qr(w(cbind(1, X))); r0 <- qr.resid(q0, w(y)); Gr <- qr.resid(q0, w(sapply(mk, function(m) AP[[chr]][u, "D", m])))
  gl <- length(y) / 2 * log10(sum(r0^2) / (sum(r0^2) - colSums(Gr * as.vector(r0))^2 / colSums(Gr^2))); L <- s1[mk, 1]
  d0 <- max(abs(L - gl)); up <- max(abs(L[-1] - gl[-n])); dn <- max(abs(L[-n] - gl[-1]))
  check(sprintf("scan1 = independent GLS, chr %s: lag 0 %.0e; markers slipped by one %.2f and %.2f", chr, d0, up, dn), d0 < 1e-6 && min(up, dn) > 0.1 && identical(rownames(s1), mk))
}

### 7: genotype probabilities against the raw calls, by marker and strain name; and slipped by one marker either way
raw <- read.csv("QTL/inputs/bxd_risib/geno.csv", check.names = FALSE, row.names = 1, na.strings = c("-", "NA")); bad <- up <- dn <- tot <- 0
for(chr in as.character(1:19)){ mk <- dimnames(AP[[chr]])[[3]]; P <- AP[[chr]][strains, "D", ]; R <- as.matrix(raw[strains, mk]); R <- matrix(ifelse(R == "D", 1, ifelse(R == "B", 0, NA)), nrow(R)); n <- ncol(R)
  bad <- bad + sum(abs(P - R) > 0.5, na.rm = TRUE); tot <- tot + sum(!is.na(R)); up <- up + sum(abs(P[, -n] - R[, -1]) > 0.5, na.rm = TRUE); dn <- dn + sum(abs(P[, -1] - R[, -n]) > 0.5, na.rm = TRUE) }
check(sprintf("probabilities against raw calls: %d of %d disagree; slipped by one marker %d and %d", bad, tot, up, dn), bad < 0.05 * min(up, dn))
cat(if(fail == 0) "\nAll alignment tests passed\n" else sprintf("\n%d TESTS FAILED\n", fail))

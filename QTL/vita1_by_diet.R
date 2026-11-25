#
# vita1_by_diet.R - Genotype x diet at the Vita1 loci themselves: BXD strains and BXD x BXD F1 hybrids, with whole strains permuted
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 24 November 2026, after the maps were seen. Rob asks for the Results to
# "step through the mapping to get to the locus-by-diet mapping analysis". The genome-wide interaction map must clear about 21,000
# markers; once a locus is defined, the test at that locus need not (Rob: "Once the locus is defined, then the testing burden is
# reduced"). The markers were chosen from main-effect maps of the same mice, so the P values here are pointwise and the loci
# are not independent of the data; the diet contrast was not used to choose Vita1a (chow) or Vita1b and Vita1y (high fat), but a
# locus picked on one diet tends to look larger on that diet, so an excess on the diet it was picked on is biased upward.
#   - Markers: Vita1a (5.02 Mb), Vita1b (23.52 Mb) and the distal high-fat peak, Vita1y (35.73 Mb).
#   - Model: that of the individual-mouse maps with F1s (QTL/qtl2_individualsF1_perm.R): age at death of mice alive at the T-age, with
#     diet, vivarium, set-up class, F1 class and F1 class x diet, LOCO kinship, heritability estimated once without the locus.
#   - Tests: D effect on chow, D effect on high fat (DD - BB, in days), and their difference, HF - CD.
#   - P: 1,000 permutations of the marker's genotypes among units within strata (Taylor's strains, newer strains, and F1 types within
#     class), so the strain or F1 type is the unit. A mouse-level P is given beside it.
# Writes output/Vita1_by_diet.txt
#   Rscript QTL/vita1_by_diet.R
#

source("QTL/qtl2_individualsF1_perm.R")                                              # defines everything; runs nothing when sourced
set.seed(20261124)
loci <- c(Vita1a = "rsm10000000010", Vita1b = "rsm10000000521")
mk <- dimnames(AP[["1"]])[[3]]
gf <- read.table("../BxDLifeSpan/data/BXD_current_rev050423.geno", sep = "\t", skip = 23, header = TRUE, check.names = FALSE)   # positions, mm10
pm <- setNames(gf[, "Mb"], gf[, "Locus"])[mk]
stopifnot(all(is.finite(pm)))
loci["Vita1y"] <- mk[which.min(abs(pm - 35.73))]
out <- c()
for(T in c(20, 200, 380, 500)){
  cv <- cv.all[mice[, "age"] >= T, ]; ids <- rownames(cv); u <- as.character(mice[ids, "strain"]); y <- mice[ids, "age"]
  X <- cbind(1, covars(cv, "main")); hf <- X[, "dietHF"]
  Ks <- K[["1"]][u, u]; dimnames(Ks) <- list(ids, ids)
  h <- est_herit(matrix(y, dimnames = list(ids, "y")), kinship = Ks, addcovar = X[, -1])[1]
  V <- 2 * h * Ks + (1 - h) * diag(length(u)); W <- chol(V); w <- function(m) backsolve(W, m, transpose = TRUE)
  wX <- w(X); q0 <- qr(wX); wy <- qr.resid(q0, w(y)); wh <- w(diag(length(u)))                  # wh: the whitening matrix itself
  U <- sapply(units, function(k) as.numeric(u == k))                                     # mice x units
  A <- qr.resid(q0, wh %*% (U * (1 - hf))); B <- qr.resid(q0, wh %*% (U * hf))             # each unit's columns on CD and on HF, whitened
  fit <- function(d){                                                                     # d: D dosage of each unit (0 to 1)
    G <- cbind(CD = as.vector(A %*% d), HF = as.vector(B %*% d))
    XtX <- crossprod(G); bh <- solve(XtX, crossprod(G, wy)); rss <- sum((wy - G %*% bh)^2); df <- length(y) - ncol(X) - 2
    s2 <- rss / df; C <- s2 * solve(XtX); v <- C[1, 1] + C[2, 2] - 2 * C[1, 2]
    c(CD = bh[1], HF = bh[2], diff = bh[2] - bh[1], se = sqrt(v), se.CD = sqrt(C[1, 1]), se.HF = sqrt(C[2, 2]), df = df)
  }
  for(l in names(loci)){
    d <- AP[["1"]][units, "D", loci[l]]
    f <- fit(d); z <- function(x) c(x["CD"] / x["se.CD"], x["HF"] / x["se.HF"], x["diff"] / x["se"])
    null <- replicate(1000, z(fit(d[drawPerm()])))
    p <- (1 + rowSums(abs(null) >= abs(z(f)))) / 1001
    ml <- 2 * pt(-abs(z(f)), f["df"])
    out <- rbind(out, data.frame(T = T, locus = l, Mb = round(unname(pm[loci[l]]), 2), mice = length(y), F1 = sum(u %in% types), D.CD = f["CD"], se.CD = f["se.CD"], P.CD = p[1], D.HF = f["HF"], se.HF = f["se.HF"], P.HF = p[2],
                                 diff = f["diff"], se.diff = f["se"], P.diff = p[3], P.diff.mouse = ml[3], row.names = NULL))
  }
}
options(width = 220)
o2 <- out; for(k in c("D.CD", "se.CD", "D.HF", "se.HF", "diff", "se.diff")) o2[, k] <- round(o2[, k], 0); for(k in grep("^P", colnames(o2))) o2[, k] <- signif(o2[, k], 2)
print(o2, row.names = FALSE)
write.table(o2, "output/Vita1_by_diet.txt", sep = "\t", quote = FALSE, row.names = FALSE)

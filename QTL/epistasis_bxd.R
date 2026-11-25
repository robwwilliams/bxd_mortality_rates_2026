#
# epistasis_bxd.R - A targeted search for epistasis in BXD and BXD x BXD F1 females, as set out in notes/PLAN_epistasis_BXD.md
#
# Written by Claude (Opus 5.5) for Rob Williams, 25 November 2026. The plan was committed (9ee0d4f) before this was run.
#   Search 1: Vita1a and Vita1b with their UM-HET3 female partners (Arends et al. 2026, Table 2)
#   Search 2: the BXD hot spots at genome-wide P < 0.1, in pairs
# Model: age at death ~ covariates + d1 + d2 + d1 d2 + polygenic effect (kinship without the two chromosomes), by generalized least squares
# with the variance estimated once without loci. d is the D dosage (0 to 1). The unit is the strain or F1 type: 2,000 hierarchical permutations
# of the genotypes (Taylor's strains, newer strains, each F1 class apart), both loci together and the same at every T-age. P is for the
# interaction, d1 d2: 'P' from the permutation, 'P.mouse' from the t statistic.
# Writes output/epistasis_bxd.txt
#   Rscript QTL/epistasis_bxd.R
#

source("QTL/qtl2_individualsF1_perm.R")                                              # defines everything; runs nothing when sourced
set.seed(20261125)
nperm <- 2000
gf <- read.table("../BxDLifeSpan/data/BXD_current_rev050423.geno", sep = "\t", skip = 23, header = TRUE, check.names = FALSE)
pos <- setNames(gf[, "Mb"], gf[, "Locus"]); chr.of <- setNames(as.character(gf[, "Chr"]), gf[, "Locus"])
near <- function(chr, mb){ m <- names(AP[[chr]][1, 1, ]); m[which.min(abs(pos[m] - mb))] }
S <- lapply(AP, function(a){ m <- matrix(a, nrow = dim(a)[1]); tcrossprod(m) })
kinWithout <- function(chrs){ k <- (Reduce(`+`, S) - Reduce(`+`, S[chrs])) / (sum(nm) - sum(nm[chrs])); dimnames(k) <- list(units, units); k }

mk <- c(Vita1a = near("1", 5.02), Vita1b = near("1", 23.52), Vita1y = near("1", 35.73), Vita6b = near("6", 132.8), Vita9a = near("9", 29.9), Vita9b = near("9", 104.1), Vita11a = near("11", 5.6),
        Chr2 = near("2", 156.7), Chr9 = near("9", 106.9), Chr15 = near("15", 14.3))
cat("Markers:\n"); print(data.frame(locus = names(mk), marker = mk, chr = chr.of[mk], Mb = round(pos[mk], 2), row.names = NULL), row.names = FALSE)
dose <- sapply(mk, function(m) AP[[chr.of[m]]][units, "D", m]); rownames(dose) <- units
part <- list(S1 = list(c("Vita1a", "Vita6b"), c("Vita1a", "Vita9a"), c("Vita1a", "Vita11a"), c("Vita1b", "Vita6b"), c("Vita1b", "Vita9a"), c("Vita1b", "Vita9b")),
             S2 = { h <- c("Vita1a", "Vita1b", "Vita1y", "Chr2", "Chr9", "Chr15"); p <- combn(h, 2, simplify = FALSE); Filter(function(x) chr.of[mk[x[1]]] != chr.of[mk[x[2]]], p) })
perms <- lapply(1:nperm, function(i) drawPerm())
mode.cov <- c(CD = "CD", HF = "HF", both = "main")

# One data set (diet, T) and one set of left-out chromosomes: the cross products that every test needs, by unit
prep <- function(diet, T, chrs){
  cv <- cv.all[mice[, "age"] >= T & (diet == "both" | mice[, "diet"] == diet), ]; ids <- rownames(cv); u <- as.character(mice[ids, "strain"]); y <- mice[ids, "age"]
  X <- cbind(1, covars(cv, mode.cov[diet])); K0 <- kinWithout(chrs)[u, u]; dimnames(K0) <- list(ids, ids)
  h <- est_herit(matrix(y, dimnames = list(ids, "y")), kinship = K0, addcovar = X[, -1])[1]
  W <- chol(2 * h * K0 + (1 - h) * diag(length(u))); w <- function(m) backsolve(W, m, transpose = TRUE)
  q0 <- qr(w(X)); ry <- qr.resid(q0, w(y)); R <- qr.resid(q0, w(sapply(units, function(k) as.numeric(u == k))))
  list(M = crossprod(R), v = as.vector(crossprod(R, ry)), yy = sum(ry^2), df = length(y) - q0$rank - 3, n = length(y), units = length(unique(u)), h = h, u = u)
}
zInt <- function(P, g1, g2){ G <- cbind(g1, g2, g1 * g2); A <- crossprod(G, P$M %*% G); b <- crossprod(G, P$v); s <- tryCatch(solve(A), error = function(e) NULL); if(is.null(s)) return(c(NA, NA, NA))
  bh <- s %*% b; s2 <- (P$yy - sum(bh * b)) / P$df; c(z = bh[3] / sqrt(s2 * s[3, 3]), beta = bh[3], se = sqrt(s2 * s[3, 3])) }
cells <- function(g1, g2, P){ pr <- units %in% P$u & !units %in% types; table(factor(round(g1[pr]), 0:1), factor(round(g2[pr]), 0:1)) }

run <- function(pairs, diets, tps, windows = FALSE){
  out <- c(); null <- list()
  for(diet in diets) for(T in tps){ cache <- list()
    for(pp in pairs){
      ch <- sort(unique(chr.of[mk[pp]])); id <- paste(ch, collapse = "+"); if(is.null(cache[[id]])) cache[[id]] <- prep(diet, T, ch); P <- cache[[id]]
      cand <- mk[pp[2]]; if(windows){ m <- names(AP[[chr.of[mk[pp[2]]]]][1, 1, ]); cand <- m[abs(pos[m] - pos[mk[pp[2]]]) <= 5] }
      Gk <- AP[[chr.of[mk[pp[2]]]]][units, "D", cand, drop = FALSE][, 1, , drop = TRUE]; if(is.null(dim(Gk))) Gk <- matrix(Gk, ncol = 1)
      Gk <- Gk[, !duplicated(t(round(Gk, 4))), drop = FALSE]
      stat <- function(o){ g1 <- dose[match(o, units), pp[1]]; z <- apply(Gk[match(o, units), , drop = FALSE], 2, function(g) zInt(P, g1, g)["z"]); z[which.max(abs(z))] }
      o0 <- units; names(o0) <- units; z0 <- stat(o0); e <- zInt(P, dose[, pp[1]], if(windows){ z <- apply(Gk, 2, function(g) zInt(P, dose[, pp[1]], g)["z"]); Gk[, which.max(abs(z))] } else dose[, pp[2]])
      ct <- cells(dose[, pp[1]], dose[, pp[2]], P)
      nz <- if(min(ct) < 5) NA else sapply(perms, stat)
      key <- paste(diet, T, paste(pp, collapse = "x")); null[[key]] <- nz
      out <- rbind(out, data.frame(diet = diet, T = T, pair = paste(pp, collapse = " x "), mice = P$n, cells = paste(ct[1, 1], ct[1, 2], ct[2, 1], ct[2, 2], sep = "/"), beta = e[2], se = e[3], z = unname(z0), P.mouse = 2 * pt(-abs(z0), P$df), P = if(all(is.na(nz))) NA else (1 + sum(abs(nz) >= abs(z0))) / (nperm + 1), null.sd = if(all(is.na(nz))) NA else sd(nz), row.names = NULL))
    } }
  list(out = out, null = null)
}
fam <- function(r, keys){ m <- do.call(cbind, r$null[keys]); mx <- apply(abs(m), 1, max); sapply(keys, function(k) (1 + sum(mx >= abs(r$out[match(k, names(r$null)), "z"]))) / (nperm + 1)) }
show <- function(r, label, famkeys){
  cat("\n====", label, "\n"); o <- r$out; o$P.fam <- NA; kk <- names(r$null); if(length(famkeys)) o$P.fam[match(famkeys, kk)] <- fam(r, famkeys)
  o$mde80 <- NA; if(length(famkeys)){ mx <- apply(abs(do.call(cbind, r$null[famkeys])), 1, max); th <- quantile(mx, .95); o$mde80 <- (th + 0.84 * o$null.sd) * o$se; cat("family-wise 5% threshold for |z|:", round(th, 2), "\n") }
  p <- o; for(k in c("beta", "se", "mde80")) p[, k] <- round(p[, k], 0); for(k in c("z", "null.sd")) p[, k] <- round(p[, k], 2); for(k in c("P.mouse", "P", "P.fam")) p[, k] <- signif(p[, k], 2)
  print(p, row.names = FALSE); invisible(o) }
options(width = 220); sink("output/epistasis_bxd.txt", split = TRUE)
cat("Epistasis in BXD and F1 females, following notes/PLAN_epistasis_BXD.md;", nperm, "hierarchical permutations\n")
cat("cells: strains that are BB/BB, BB/DD, DD/BB, DD/DD at the two loci (rounded dosage). beta: days, DD/DD against the sum of the two main effects. mde80: interaction found with 80% power at the family-wise 5% threshold\n")
s1 <- part$S1; s2 <- part$S2
a <- run(s1, "CD", 50); show(a, "SEARCH 1, PRIMARY: six pairs, chow, T50", names(a$null))
b <- run(s2, c("CD", "HF"), 50); show(b, "SEARCH 2, PRIMARY: 12 pairs, chow and high fat, T50", names(b$null))
c1 <- run(s1, c("HF", "both"), 50); show(c1, "Search 1, secondary: high fat and both diets, T50", names(c1$null))
d1 <- run(s1, c("CD", "HF", "both"), c(290, 560)); show(d1, "Search 1, secondary: T290 and T560 (match T365 and T740)", names(d1$null))
c2 <- run(s2, "both", 50); show(c2, "Search 2, secondary: both diets, T50", names(c2$null))
d2 <- run(s2, c("CD", "HF", "both"), c(290, 560)); show(d2, "Search 2, secondary: T290 and T560", names(d2$null))
w1 <- run(s1, "CD", 50, windows = TRUE); show(w1, "Search 1, secondary: best partner marker within 5 Mb, chow, T50", names(w1$null))
sink()

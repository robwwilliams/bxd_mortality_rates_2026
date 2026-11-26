#
# ctl_functions.R - the functions of ctl_scan.R, one per step. Sourcing this file defines them and runs nothing else.
#
# Rob Williams's fork, 26 November 2026. Written by Claude (Opus 5.5) at Danny Arends's request: one path through the code, BXD mice
# only, each step a named function. ctl_tests.R checks every function here. Exploratory.
#

library(Rcpp)

# ==== 0. Inputs (made by ctl_inputs.R) =================================================================================================
# Genotypes are coded per strain as 1 (B), 2 (D) or 0 (other or unknown). Markers whose strain pattern repeats an earlier one are computed
# once: G holds the distinct patterns (strains x patterns) and pat gives each marker its pattern. Strata for the permutations: Taylor's
# strains (BXD1 to BXD42) and the newer ones.
readInputs <- function(dir){
  mice <- read.delim(file.path(dir, "mice.txt"), check.names = FALSE, colClasses = c(mouse = "character"))
  gt <- read.delim(file.path(dir, "genotypes.txt"), check.names = FALSE, colClasses = "character")
  strains <- colnames(gt)[-(1:3)]
  G0 <- matrix(match(as.matrix(gt[, strains]), c("B", "D"), nomatch = 0L), nrow(gt), dimnames = list(gt$Locus, strains))
  key <- apply(G0, 1, paste, collapse = ""); u <- !duplicated(key)
  list(mice = mice, strains = strains, map = data.frame(Locus = gt$Locus, Chr = gt$Chr, Mb = as.numeric(gt$Mb)), G = t(G0[u, ]), pat = match(key, key[u]),
       stratum = ifelse(as.numeric(sub("^BXD([0-9]+).*$", "\\1", strains)) <= 42, "Taylor", "newer"))
}

# ==== 1. The statistic at one marker (Danny's CTL.R) ===================================================================================
# Within the B mice and within the D mice of one scan, rank weight and lifespan (ties averaged) and take the Pearson correlation of the
# ranks, each mouse weighted 1 / (mice of its strain). ctlCorR() is Danny's own line from CTL.R, for one marker; ctlCor() does the same
# arithmetic in C++ for all markers at once. ctl_tests.R checks that the two agree.

ctlCorR <- function(w, y, strain, g){                                       # one marker; g per mouse: 1 B, 2 D, 0 neither
  sapply(1:2, function(k){
    i <- which(g == k); n <- table(strain[i]); weights <- as.numeric(1 / n[as.character(strain[i])])
    cov.wt(apply(cbind(w[i], y[i]), 2, rank), wt = weights, cor = TRUE)$cor[1, 2]
  })
}

sourceCpp(code = '
#include <Rcpp.h>
using namespace Rcpp;

// Ranks within one genotype group. The mice are visited in increasing order of the value (ord), tie[] numbers the distinct values in
// that order, and a group member gets the average of the ranks its tied values take within the group, as rank() gives.
static void groupRanks(const IntegerVector& ord, const IntegerVector& tie, const std::vector<int>& g, int k, std::vector<double>& r){
  int n = ord.size(), i = 0, seen = 0;
  while(i < n){
    int j = i, c = 0;
    while(j < n && tie[j] == tie[i]){ if(g[ord[j]] == k) c++; j++; }         // c: group members among these tied values
    for(int q = i; q < j; q++) if(g[ord[q]] == k) r[ord[q]] = seen + (c + 1) / 2.0;
    seen += c; i = j;
  }
}

// G: strains x markers (1 B, 2 D, 0 neither). strain, wt: per mouse (strain index from 0; weight 1 / mice of the strain).
// ow/tw and oy/ty: order and tie numbers of weight and of lifespan. nall: mice per strain before weights are required (for the rule of 20).
// Returns per marker: rB, rD, nB, nD. A marker with fewer than 20 B or 20 D mice is NA, as in CTL.R.
// [[Rcpp::export]]
NumericMatrix ctlCor(const IntegerMatrix& G, const IntegerVector& strain, const NumericVector& wt, const IntegerVector& ow,
                     const IntegerVector& tw, const IntegerVector& oy, const IntegerVector& ty, const IntegerVector& nall){
  int nm = G.ncol(), n = strain.size(); NumericMatrix out(nm, 4); std::vector<int> g(n); std::vector<double> a(n), b(n);
  for(int m = 0; m < nm; m++){
    int nB = 0, nD = 0;
    for(int s = 0; s < nall.size(); s++){ if(G(s, m) == 1) nB += nall[s]; else if(G(s, m) == 2) nD += nall[s]; }
    if(nB < 20 || nD < 20){ for(int k = 0; k < 4; k++) out(m, k) = NA_REAL; continue; }
    for(int i = 0; i < n; i++) g[i] = G(strain[i], m);
    for(int k = 1; k <= 2; k++){                                             // k = 1: B mice, k = 2: D mice
      groupRanks(ow, tw, g, k, a); groupRanks(oy, ty, g, k, b);
      double sw = 0, ma = 0, mb = 0; int c = 0;                              // weighted means of the ranks
      for(int i = 0; i < n; i++) if(g[i] == k){ sw += wt[i]; ma += wt[i] * a[i]; mb += wt[i] * b[i]; c++; }
      ma /= sw; mb /= sw; double va = 0, vb = 0, cv = 0;
      for(int i = 0; i < n; i++) if(g[i] == k){ va += wt[i] * (a[i] - ma) * (a[i] - ma); vb += wt[i] * (b[i] - mb) * (b[i] - mb); cv += wt[i] * (a[i] - ma) * (b[i] - mb); }
      out(m, k - 1) = cv / std::sqrt(va * vb); out(m, k + 1) = c;
    }
  }
  return out;
}')

# ==== 2. The test of the two correlations (Danny's CTL.R) ==============================================================================
# Fisher's z = 0.5 log((1 + r) / (1 - r)) of each correlation, weighted by n - 1, and Danny's heterogeneity chi-square on 1 d.f.
# Returns the signed -log10 P: positive where r(D) > r(B). Edge cases (ctl_tests.R): r = 0 gives z = 0 and a valid test; |r| = 1 gives an
# infinite z, and the test is NA (in CTL.R it is NaN); NA gives NA.
ctlTest <- function(rB, rD, nB, nD){
  zB <- 0.5 * log((1 + rB) / (1 - rB)); zD <- 0.5 * log((1 + rD) / (1 - rD))
  dfB <- nB - 1; dfD <- nD - 1
  Cv <- (dfB * zB^2 + dfD * zD^2) - (dfB * zB + dfD * zD)^2 / (dfB + dfD)
  ifelse(is.finite(zB) & is.finite(zD), sign(rD - rB) * -log10(pchisq(Cv, 1, lower.tail = FALSE)), NA)
}

# The standard version (added 26 November 2026, exploratory, at Rob's and Danny's request after the strain-level results): each Fisher z
# weighted (n - 3) / 1.06, the inverse of the variance of a Spearman correlation's z (Fieller, Hartley & Pearson 1957), in place of n - 1;
# and a group needs at least min.n units (strains), so that the normal approximation holds. ctl_fisher_simulation.R and ctl_tests.R
# check that it is calibrated where there is no CTL.
ctlTestStandard <- function(rB, rD, nB, nD, min.n = 20){
  zB <- 0.5 * log((1 + rB) / (1 - rB)); zD <- 0.5 * log((1 + rD) / (1 - rD))
  wB <- (nB - 3) / 1.06; wD <- (nD - 3) / 1.06
  Cv <- (wB * zB^2 + wD * zD^2) - (wB * zB + wD * zD)^2 / (wB + wD)
  ifelse(is.finite(zB) & is.finite(zD) & nB >= min.n & nD >= min.n, sign(rD - rB) * -log10(pchisq(Cv, 1, lower.tail = FALSE)), NA)
}

# ==== 3. The Cauchy combination over T-ages (Danny's Cauchy.R) =========================================================================
# Danny's cauchycombination(): the P values of one marker, one per T-age, become Cauchy quantiles; their mean is turned back into one P.
# Here per row of P (markers x T-ages), leaving out T-ages without a test. Returns -log10 of the combined P.
cauchyCombine <- function(P){
  -log10(pcauchy(rowMeans(qcauchy(P, lower.tail = FALSE), na.rm = TRUE), lower.tail = FALSE))
}

# ==== 4. The mice of one scan ==========================================================================================================
# A scan is one diet, one survivorship age T and one weighing age W (W = T in Danny's design). Its mice: on the diet by W (set-up age
# <= W), alive at T, of a genotyped BXD strain. Weight is the adjusted weight at W; lifespan the adjusted lifespan.
scanMice <- function(mice, strains, diet, Tage, Wage){
  x <- mice[which(mice$diet == diet & mice$setup <= Wage & mice$age >= Tage), ]
  s <- match(x$strain, strains); nall <- tabulate(s, length(strains))          # all mice, for the rule of 20
  w <- x[, paste0("w", Wage)]; y <- x$lifespan; ok <- !is.na(w) & !is.na(y)
  w <- w[ok]; y <- y[ok]; s <- s[ok]; n <- tabulate(s, length(strains)); ow <- order(w); oy <- order(y)
  list(diet = diet, Tage = Tage, Wage = Wage, nmice = sum(nall), id = x$mouse[ok], w = w, y = y,
       s = s - 1L, wt = 1 / n[s], nall = nall, ow = ow - 1L, tw = match(w[ow], unique(w[ow])), oy = oy - 1L, ty = match(y[oy], unique(y[oy])))
}

# The same scan with strains as the units (added 26 November 2026, exploratory, after the mouse-level results: Rob and Danny asked
# why mice give such small P values). Each strain with at least min.mice mice in the scan becomes one unit: the mean adjusted weight and
# mean adjusted lifespan of those mice, weight 1. ctlCor() then gives the Spearman correlation of strain means within the B strains and
# within the D strains, with n = strains. The rule of 20 mice is kept (nall), so the same markers are tested.
# Returns a list like scanMice()'s: s (strain index from 0), wt, ow/tw, oy/ty, nall, and w, y (the strain means).
strainUnits <- function(d, min.mice){
  mice.per.strain <- tabulate(d$s + 1L, length(d$nall))                    # strain -> weighed mice in this scan
  kept <- which(mice.per.strain >= min.mice) - 1L                           # strain indices (from 0)
  mean.weight <- as.numeric(tapply(d$w, d$s, mean)[as.character(kept)])
  mean.lifespan <- as.numeric(tapply(d$y, d$s, mean)[as.character(kept)])
  ow <- order(mean.weight); oy <- order(mean.lifespan)
  list(s = kept, wt = rep(1, length(kept)), nall = d$nall, w = mean.weight, y = mean.lifespan,
       ow = ow - 1L, tw = match(mean.weight[ow], unique(mean.weight[ow])), oy = oy - 1L, ty = match(mean.lifespan[oy], unique(mean.lifespan[oy])))
}

# All scans of the designs. designs: named weighing ages, NA for Danny's design (weight at T). A scan with fewer than 40 mice is left
# out, as it cannot have 20 B and 20 D mice at any marker. Each scan also carries its strain-level version (strainUnits()).
buildScans <- function(mice, strains, designs, Tages, strain.min.mice){
  scans <- list()
  for(dn in names(designs)) for(diet in c("CD", "HF")) for(Tage in Tages){
    Wage <- if(is.na(designs[[dn]])) Tage else designs[[dn]]
    if(Tage < Wage) next
    d <- scanMice(mice, strains, diet, Tage, Wage); d$design <- dn
    d$strain.units <- strainUnits(d, strain.min.mice)
    if(d$nmice >= 40) scans[[paste(dn, diet, paste0("T", Tage))]] <- d
  }
  scans
}

# ==== 5. All scans, for one assignment of genotypes to strains =========================================================================
# G: strains x distinct marker patterns. Returns distinct patterns x scans of signed -log10 P.
scanAll <- function(G, scans){
  sapply(scans, function(d){ r <- ctlCor(G, d$s, d$wt, d$ow, d$tw, d$oy, d$ty, d$nall); ctlTest(r[, 1], r[, 2], r[, 3], r[, 4]) })
}

# The same, with strains as the units (strainUnits()): n in Fisher's z is the number of strains. Returns a list of two maps (distinct
# patterns x scans): coded, Danny's test (weights n - 1; a group with fewer than 5 strains is NA), and standard, ctlTestStandard().
scanAllStrains <- function(G, scans){
  per.scan <- lapply(scans, function(d){ u <- d$strain.units; r <- ctlCor(G, u$s, u$wt, u$ow, u$tw, u$oy, u$ty, u$nall)
    coded <- ctlTest(r[, 1], r[, 2], r[, 3], r[, 4]); coded[which(r[, 3] < 5 | r[, 4] < 5)] <- NA
    list(coded = coded, standard = ctlTestStandard(r[, 1], r[, 2], r[, 3], r[, 4])) })
  list(coded = sapply(per.scan, `[[`, "coded"), standard = sapply(per.scan, `[[`, "standard"))
}

# ==== 6. One permutation: each strain takes the genotypes of another strain of its stratum =============================================
# The same order serves every scan, both diets and every design, so a mouse keeps its weight, lifespan and strain mates.
permuteStrains <- function(stratum, seed){
  RNGkind("L'Ecuyer-CMRG", "Inversion", "Rejection"); set.seed(seed); o <- seq_along(stratum)
  for(k in unique(stratum)){ j <- which(stratum == k); o[j] <- j[sample.int(length(j))] }
  o
}

# ==== 7. What one map (or permuted map) gives, for one design and diet =================================================================
# L: distinct patterns x scans (one design, one diet); pat: the pattern of each marker. P values count per marker, as in Danny's
# corrections; a marker x scan without a test (fewer than 20 B or D mice) counts as P = 1.
#   max          the largest -log10 P over all markers and T-ages
#   cauchy       the largest Cauchy-combined -log10 P over markers; cauchy.Bonf and cauchy.BH: markers called at 5% over markers
#   Bonf, BH     calls at 5% over all markers and T-ages (Bonferroni; Benjamini & Hochberg)
#   lambda       inflation: median chi-square (1 d.f.) over all markers and T-ages / its expected value
summarizeMap <- function(L, pat){
  A <- abs(L); P <- 10^-A[pat, , drop = FALSE]; P[is.na(P)] <- 1
  cc <- cauchyCombine(10^-A)[pat]; cp <- 10^-cc[is.finite(cc)]
  c(max = max(A, na.rm = TRUE), cauchy = max(cc[is.finite(cc)]), cauchy.Bonf = sum(cp <= 0.05 / length(cp)), cauchy.BH = sum(p.adjust(cp, "BH") <= 0.05),
    Bonf = sum(P <= 0.05 / length(P)), BH = sum(p.adjust(as.vector(P), "BH") <= 0.05), lambda = median(qchisq(P, 1, lower.tail = FALSE)) / qchisq(0.5, 1))
}

# ==== 8. One map, real (i = 0) or permuted (permutation i uses seed + i) ===============================================================
# Three tests from the same permutation: mice (Danny's), strains (Danny's formula on strain means) and standard (strain means,
# ctlTestStandard()). Returns
#   summary  the summaries of step 7: "<design>.<diet>.<summary>" for mice, ".strain.<summary>" and ".standard.<summary>" for the others
#   scanmax  the largest -log10 P of each scan (mice, then names starting "strain " and "standard ")
#   maps     the three maps (distinct patterns x scans): mice, strain, standard
runMap <- function(i, inp, scans, seed){
  o <- if(i == 0) seq_along(inp$strains) else permuteStrains(inp$stratum, seed + i)
  G <- inp$G[o, , drop = FALSE]; strain.maps <- scanAllStrains(G, scans)
  maps <- list(mice = scanAll(G, scans), strain = strain.maps$coded, standard = strain.maps$standard)
  sets <- split(seq_along(scans), paste(sapply(scans, `[[`, "design"), sapply(scans, `[[`, "diet"), sep = "."))
  s <- do.call(c, lapply(names(maps), function(level) setNames(lapply(sets, function(j) summarizeMap(maps[[level]][, j, drop = FALSE], inp$pat)),
                                                              paste0(names(sets), if(level == "mice") "" else paste0(".", level)))))
  scanMax <- function(M){ m <- suppressWarnings(apply(abs(M), 2, max, na.rm = TRUE)); m[!is.finite(m)] <- NA; m }
  list(summary = setNames(unlist(s, use.names = FALSE), paste(rep(names(s), lengths(s)), unlist(lapply(s, names)), sep = ".")),
       scanmax = c(scanMax(maps$mice), setNames(scanMax(maps$strain), paste("strain", colnames(maps$strain))),
                   setNames(scanMax(maps$standard), paste("standard", colnames(maps$standard)))), maps = maps)
}

# Genome-wide P from a permutation distribution: (1 + permutations at least as large) / (permutations + 1)
permP <- function(real, null) (1 + sum(null >= real)) / (length(null) + 1)

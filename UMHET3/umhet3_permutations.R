#
# umhet3_permutations.R
#
# copyright (c) 2026 - Rob Williams
#
# Permutation thresholds for the actuarial LOD maps of Arends et al. 2026 (Nature 654:437), to settle which Vita loci
# pass once the LODs' 3 degrees of freedom are respected (notes/Cauchy_review_2026-11-21.md). Rob, 21 November 2026:
# "Yes, run them". Exploratory.
#   - The scan is Danny Arends's (ProgressiveMapping.R, DannyArends/UM-HET3 132ca3f): at each T-age, the mice alive at it,
#     lm(longevity ~ sex + site + cohort + treatment + genotype probabilities + 0), LOD = (n/2) log10(RSS0 / RSS1), on
#     the published cross (Supplementary Table 7) with calc.genoprob(step = 0) and his adjustXprobs(). Sex is left out of
#     the male and female maps. The algebra is faster than one lm() per marker (covariates are projected out once per
#     T-age) but gives the same LOD; the check against Supplementary Table 9 below shows it.
#   - The permutations are his (stratifiedPerms.R): lifespans shuffled within sex x site, then the whole actuarial stack
#     rerun, since which mice are alive at each T-age follows the shuffled lifespans. Each permutation records the
#     largest LOD over markers at each T-age, and over markers and all T-ages together.
#   - Two thresholds follow: per scan (one T-age, as the paper's 3.65, 3.95 and 4.65 are used), and actuarial (any marker
#     at any T-age, which also corrects for the 72 survivorships).
#   - The permutations are drawn in advance from one seed, so results do not depend on the number of cores.
#
# Inputs not in git, in data/local/Arends_Supplementary_Tables_10Apr2026/: S_Table_7 (cross) and S_Table_9 (LODs)
# Run from the repository root:  Rscript UMHET3/umhet3_permutations.R [permutations, default 1000] [cores, default 12]
# Writes output/UMHET3_permutations.txt and output/UMHET3_permutation_maxima.txt (one row per permutation and map)
#

library(qtl)
library(parallel)
library(readxl)

args <- commandArgs(trailingOnly = TRUE)
nperm <- if(length(args) >= 1) as.numeric(args[1]) else 1000
cores <- if(length(args) >= 2) as.numeric(args[2]) else 12
dir <- "data/local/Arends_Supplementary_Tables_10Apr2026"
msequence <- seq(35, 1100, 15)                                                      # the T-ages of Supplementary Table 9

adjustXprobs <- function(cross){                                                    # Danny's, from ActuarialMapping/adjustXprobs.R
  sex <- getsex(cross)$sex
  pr <- cross$geno[["X"]]$prob
  for(i in 1:ncol(pr)){
    pr[sex == 0, i, 3:4] <- 0
    pr[sex == 1, i, 1:2] <- 0
    pr[, i, ] <- pr[, i, ] / rowSums(pr[, i, ])
  }
  cross$geno[["X"]]$prob <- pr
  invisible(cross)
}

mcross <- read.cross(format = "csvr", dir = dir, file = "S_Table_7_R:qtl_v1_cross-object_for_mapping_18Aug2025.csvr", genotypes = NULL, na.strings = c("-", "NA"))
mcross <- calc.genoprob(mcross, step = 0)
mcross <- adjustXprobs(mcross)
gtsp <- pull.genoprob(mcross)
# The published LODs (Supplementary Table 9), for the check below; the paper mapped 891 of the cross's markers
f9 <- file.path(dir, "S_Table_9_Vita_mapping_results_18Aug2025.xlsx")
readLODs <- function(sheet){
  x <- as.data.frame(suppressMessages(read_excel(f9, sheet = sheet, col_names = FALSE)))
  i <- which(!is.na(suppressWarnings(as.numeric(x[, 3]))))[1]
  m <- suppressWarnings(sapply(x[i:nrow(x), -(1:2)], as.numeric))
  dimnames(m) <- list(x[i:nrow(x), 2], unlist(x[i - 1, -(1:2)]))
  m
}
maps <- c(both = "S_Table_9.1_Combined", male = "S_Table_9.2_Male", female = "S_Table_9.3_Female")
published <- lapply(maps, readLODs)
markers <- colnames(pull.geno(mcross))
markers <- markers[markers %in% colnames(published[["both"]])]
cols <- lapply(markers, function(m) which(sub(":.*", "", colnames(gtsp)) == m))      # the four columns of each marker, matched exactly
G3 <- gtsp[, unlist(lapply(cols, function(i) i[1:3]))]                                # three suffice: the four sum to 1, and the covariates span a constant
ph <- pull.pheno(mcross)
cdata <- data.frame(longevity = as.numeric(ph[, "longevity"]), sex = as.factor(ph[, "sex"]), site = as.factor(ph[, "site"]),
                    cohort = as.factor(ph[, "cohort"]), treatment = as.factor(ph[, "treatment"]))

# LOD at every marker for the mice in idx, Danny's model, with longevity y
scanLOD <- function(y, idx, sexes){
  d <- cdata[idx, ]
  X <- model.matrix(if(sexes == "both") ~ sex + site + cohort + treatment + 0 else ~ site + cohort + treatment + 0, droplevels(d))
  qx <- qr(X)
  r0 <- qr.resid(qx, y[idx]); rss0 <- sum(r0^2)
  Gr <- qr.resid(qx, G3[idx, , drop = FALSE])
  n <- length(idx)
  sapply(seq_along(markers), function(j){
    q <- qr(Gr[, (3 * j - 2):(3 * j), drop = FALSE])
    if(q$rank == 0) return(0)
    rss1 <- rss0 - sum(qr.qty(q, r0)[1:q$rank]^2)
    (n / 2) * log10(rss0 / rss1)
  })
}
members <- function(sexes){ if(sexes == "both") rep(TRUE, nrow(cdata)) else cdata[, "sex"] == c(female = "0", male = "1")[sexes] }
stack <- function(y, sexes){ sapply(msequence, function(x){ idx <- which(y >= x & members(sexes)); scanLOD(y, idx, sexes) }) }   # markers x T-ages

sink("output/UMHET3_permutations.txt", split = TRUE)
cat("Permutation thresholds for the actuarial LOD maps of Arends et al. 2026 (exploratory)\n")
cat("Cross:", nind(mcross), "mice,", length(markers), "markers; T-ages", min(msequence), "to", max(msequence), "in 15-day steps (", length(msequence), ")\n\n")
### 1. Check against the published LODs at four T-ages
cat("Check: our LODs against Supplementary Table 9 (rounded to 0.01 there)\n")
for(s in names(maps)){
  for(x in c(35, 365, 725, 1100)){
    idx <- which(cdata[, "longevity"] >= x & members(s))
    l <- scanLOD(cdata[, "longevity"], idx, s)
    p <- published[[s]][paste0("> ", x), markers]
    cat(sprintf("  %-6s T%-4d n = %d: largest |ours - published| %.3f, r = %.5f\n", s, x, length(idx), max(abs(l - p), na.rm = TRUE), cor(l, p, use = "complete")))
  }
}

### 2. Permutations, drawn in advance from one seed
set.seed(20261121)
strata <- interaction(cdata[, "sex"], cdata[, "site"], drop = TRUE)
perms <- lapply(1:nperm, function(p){ o <- seq_len(nrow(cdata)); for(s in levels(strata)){ i <- which(strata == s); o[i] <- i[sample.int(length(i))] }; o })
t0 <- Sys.time()
res <- NULL
for(s in names(maps)){
  m <- do.call(rbind, mclapply(1:nperm, function(p){
    L <- stack(cdata[perms[[p]], "longevity"], s)
    c(perm = p, apply(L, 2, max, na.rm = TRUE))
  }, mc.cores = cores))
  res <- rbind(res, data.frame(map = s, m))
  cat(sprintf("\n%s: %d permutations done after %.1f minutes\n", s, nperm, as.numeric(difftime(Sys.time(), t0, units = "mins"))))
}
colnames(res) <- c("map", "perm", paste0("T", msequence))
write.table(res, "output/UMHET3_permutation_maxima.txt", sep = "\t", quote = FALSE, row.names = FALSE)

### 3. Thresholds, and the Vita loci against them
q <- c(0.90, 0.95, 0.99)
cat("\nThresholds (LOD) at genome-wide 10%, 5% and 1%; the paper used 3.65, 3.95 and 4.65 for every scan\n")
th <- list()
for(s in names(maps)){
  r <- as.matrix(res[res[, "map"] == s, -(1:2)])
  per.scan <- apply(r, 2, quantile, q)
  actuarial <- quantile(apply(r, 1, max), q)
  th[[s]] <- list(per.scan = per.scan, actuarial = actuarial)
  cat(sprintf("  %-6s per scan, median over T-ages: %.2f, %.2f, %.2f (range of the 5%% threshold %.2f to %.2f); actuarial (any T-age): %.2f, %.2f, %.2f\n", s,
              median(per.scan[1, ]), median(per.scan[2, ]), median(per.scan[3, ]), min(per.scan[2, ]), max(per.scan[2, ]), actuarial[1], actuarial[2], actuarial[3]))
}
# Each Vita locus by its interval in Table 1a (Chr, proximal and distal Mb), scored by the largest published LOD in it
t1 <- as.data.frame(suppressMessages(read_excel("data/local/Table1_Vita_Loci_Expanded_clean_2026-10-26.xlsx", sheet = "Table_1a_Vita_Summary", col_names = FALSE)))
t1 <- t1[grepl("^Vita", t1[, 2]), ]
loci <- data.frame(Locus = t1[, 2], table.peak = round(as.numeric(t1[, 4]), 2), chr = t1[, 6], prox = as.numeric(t1[, 7]), distal = as.numeric(t1[, 9]))
mchr <- sub("_.*", "", markers); mpos <- as.numeric(sub(".*_", "", markers)) / 1e6
out <- loci[, c("Locus", "table.peak")]
for(s in names(maps)){
  P <- published[[s]][, markers, drop = FALSE]
  best <- t(sapply(seq_len(nrow(loci)), function(i){
    k <- which(mchr == loci[i, "chr"] & mpos >= loci[i, "prox"] - 1e-6 & mpos <= loci[i, "distal"] + 1e-6)
    w <- which(P[, k, drop = FALSE] == max(P[, k], na.rm = TRUE), arr.ind = TRUE)[1, ]
    c(lod = unname(P[w[1], k[w[2]]]), at = unname(w[1]))
  }))
  at <- sub("> ", "T", rownames(P)[best[, "at"]])
  out[, paste0(s, ".peak")] <- round(best[, "lod"], 2)
  out[, paste0(s, ".at")] <- at
  out[, paste0(s, ".scan5")] <- round(th[[s]]$per.scan[2, at], 2)
  out[, paste0(s, ".pass.scan5")] <- best[, "lod"] >= th[[s]]$per.scan[2, at]
  out[, paste0(s, ".pass.act5")] <- best[, "lod"] >= th[[s]]$actuarial[2]
  out[, paste0(s, ".pass.act10")] <- best[, "lod"] >= th[[s]]$actuarial[1]
}
cat("\nVita loci (Table 1a): the largest published LOD in each locus interval in each map, at the T-age where it occurs, against the\n")
cat("5% per-scan threshold at that T-age, and against the 5% and 10% actuarial thresholds (any marker at any T-age). table.peak: Table 1a\n")
print(out, row.names = FALSE)
cat("\nLoci passing in at least one map: per-scan 5%", sum(apply(out[, grep("pass.scan5", colnames(out))], 1, any)), "; actuarial 5%",
    sum(apply(out[, grep("pass.act5", colnames(out))], 1, any)), "; actuarial 10%", sum(apply(out[, grep("pass.act10", colnames(out))], 1, any)), "of", nrow(out), "\n")
sink()

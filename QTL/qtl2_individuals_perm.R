#
# qtl2_individuals_perm.R - Genome-wide thresholds for the individual-mouse lifespan maps, by permuting strains within
# epochs, in chunks for Squirm (tools/squirm/README.md)
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 21 November 2026, from qtl2_individuals_perm.R in
# robwwilliams/BxDLifeSpan, after the strain-mean thresholds were seen. Rob: "what are the exchangable units? Do you need a
# hierarchical permutation? Important not to over-randomize across the intrinsic structure of the cross or the P values
# will be way too lenient." And: "200 permutations is good enough to get a sense of the 0.1 genome wide level and a crude
# sense of 0.05."
#   - The maps: each mouse's age at death, in the survivorship at each T-age from 20 to 770 days in 30-day steps, with its
#     strain's genotype probabilities and LOCO kinship (R/qtl2 scan1). Covariates are vivarium and set-up age in 180-day
#     classes, plus diet when both diets are mapped together. Four maps: chow (CD), high fat (HF), both diets (main), and
#     genotype x diet (int, the LOD of the interaction model minus that of the main model).
#   - The exchangeable unit is the strain, not the mouse. In each permutation every strain takes the genotypes (and so the
#     kinship) of another strain, and keeps all its mice, on both diets, at every T-age, with their covariates. Strains are
#     permuted only within two strata: Taylor's strains (BXD1 to BXD42) and the newer ones.
#   - Each permutation records the largest -log10 P (LOD on 1 d.f.) over markers, for each map and T-age.
#   - Chunk k draws its permutations from seed + k, so the result does not depend on the number of cores. Each chunk is
#     written as it finishes and skipped if its file exists. When all chunks are there, they are combined into the maxima
#     and the thresholds: per scan (one T-age) and any T-age, at genome-wide P = 0.05, 0.10 and 0.63 (suggestive).
# Inputs (QTL/inputs, written by squirm_inputs.R in the fork): bxd_risib/ (the cross) and mice.txt.
#   Rscript QTL/qtl2_individuals_perm.R --out DIR [--workers 6] [--chunks 100] [--per-chunk 2] [--seed 20261123]
#                                        [--only 1,2] [--tps 20,500]
# Writes in DIR: chunk_001.txt ...; and, once all chunks are done, maxima.txt and thresholds.txt
#

library(qtl2)
library(parallel)

opt <- list(out = "output/qtl2_individuals_perm", workers = 6, chunks = 100, `per-chunk` = 2, seed = 20261123, only = "", tps = "")
a <- commandArgs(trailingOnly = TRUE)
for(i in seq_len(length(a) / 2) * 2 - 1) opt[[sub("^--", "", a[i])]] <- a[i + 1]
nchunk <- as.numeric(opt$chunks); per <- as.numeric(opt$`per-chunk`); seed <- as.numeric(opt$seed)
tps <- if(opt$tps == "") seq(20, 770, 30) else as.numeric(strsplit(opt$tps, ",")[[1]])
dir.create(opt$out, recursive = TRUE, showWarnings = FALSE)

cross <- suppressWarnings(read_cross2("QTL/inputs/bxd_risib/control.yaml"))      # warns that no chromosome is the X
pr <- calc_genoprob(cross, error_prob = 0.002)
K <- calc_kinship(pr, "loco")
strains <- rownames(pr[[1]])
mice <- read.delim("QTL/inputs/mice.txt", colClasses = c(id = "character"))
rownames(mice) <- mice[, "id"]
stratum <- tapply(mice[, "stratum"], mice[, "strain"], unique)[strains]
cv.all <- data.frame(diet = mice[, "diet"], vivarium = as.factor(mice[, "vivarium"]), row.names = mice[, "id"],
                     setup = as.factor(cut(mice[, "setup.age"], seq(0, 1000, 180))))
lp <- function(lod) -pchisq(2 * log(10) * pmax(lod, 0), 1, lower.tail = FALSE, log.p = TRUE) / log(10)

# One permutation of strains within strata: o[s] is the strain whose genotypes strain s takes
drawPerm <- function(){ o <- strains; for(s in unique(stratum)){ i <- which(stratum == s); o[i] <- strains[i][sample.int(length(i))] }; names(o) <- strains; o }

# The four maps at every T-age under one permutation: the largest -log10 P over markers
scanPerm <- function(o){
  donor <- match(o[mice[, "strain"]], strains); names(donor) <- mice[, "id"]
  res <- matrix(NA, 4, length(tps), dimnames = list(c("main", "int", "CD", "HF"), paste0("T", tps)))
  for(j in seq_along(tps)){
    cv <- cv.all[mice[, "age"] >= tps[j], ]; cv <- cv[complete.cases(cv), ]
    for(m in c("main", "CD", "HF")){
      cm <- if(m == "main") cv else cv[cv[, "diet"] == m, ]
      ids <- rownames(cm); idx <- donor[ids]
      X <- model.matrix(if(m == "main") ~ diet + vivarium + setup else ~ vivarium + setup, cm)[, -1, drop = FALSE]
      X <- X[, colSums(X) > 0, drop = FALSE]
      Y <- matrix(mice[ids, "age"], dimnames = list(ids, "age"))
      best <- c(main = 0, int = 0)
      for(chr in names(pr)){                                                         # one chromosome at a time, to keep memory small
        prm <- pr[, chr]; g <- prm[[chr]][idx, , , drop = FALSE]; dimnames(g)[[1]] <- ids; prm[[chr]] <- g
        Kd <- decomp_kinship(list(`dimnames<-`(K[[chr]][idx, idx], list(ids, ids))))
        out <- scan1(prm, Y, kinship = Kd, addcovar = X)
        best["main"] <- max(best["main"], lp(out[, 1]))
        if(m == "main"){
          out.int <- scan1(prm, Y, kinship = Kd, addcovar = X, intcovar = X[, "dietHF", drop = FALSE])
          best["int"] <- max(best["int"], lp(out.int[, 1] - out[, 1]))
        }
      }
      res[m, j] <- best["main"]
      if(m == "main") res["int", j] <- best["int"]
      rm(prm, Kd); gc(verbose = FALSE)
    }
  }
  res
}

chunkFile <- function(k) file.path(opt$out, sprintf("chunk_%03d.txt", k))
runChunk <- function(k){
  set.seed(seed + k)
  perms <- lapply(1:per, function(p) drawPerm())
  r <- do.call(rbind, lapply(1:per, function(p) data.frame(perm = (k - 1) * per + p, chunk = k, seed = seed + k, map = c("main", "int", "CD", "HF"),
                                                           scanPerm(perms[[p]]), check.names = FALSE)))
  write.table(r, paste0(chunkFile(k), ".part"), sep = "\t", quote = FALSE, row.names = FALSE)
  file.rename(paste0(chunkFile(k), ".part"), chunkFile(k))                              # a chunk file is always whole
  cat(format(Sys.time(), "%H:%M:%S"), "chunk", k, "done\n")
  invisible(k)
}

if(sys.nframe() == 0){
  ks <- if(opt$only == "") 1:nchunk else as.numeric(strsplit(opt$only, ",")[[1]])
  todo <- ks[!file.exists(chunkFile(ks))]
  cat(length(mice[, "id"]), "mice of", length(strains), "strains;", length(tps), "T-ages;", length(ks) - length(todo), "chunks already done,",
      length(todo), "to run (", per, "permutations each ) on", opt$workers, "workers\n")
  t0 <- Sys.time()
  r <- mclapply(todo, runChunk, mc.cores = as.numeric(opt$workers), mc.preschedule = FALSE)
  bad <- sapply(r, inherits, "try-error")
  if(any(bad)) cat("Failed chunks:", todo[bad], "\n", as.character(r[bad][[1]]))
  cat("Ran for", round(as.numeric(difftime(Sys.time(), t0, units = "hours")), 2), "hours\n")
  if(opt$only == "" && all(file.exists(chunkFile(1:nchunk)))){
    x <- do.call(rbind, lapply(1:nchunk, function(k) read.delim(chunkFile(k), check.names = FALSE)))
    write.table(x, file.path(opt$out, "maxima.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
    levels <- c(`P 0.05` = 0.95, `P 0.10` = 0.90, `suggestive P 0.63` = 0.37)
    th <- do.call(rbind, lapply(c("main", "int", "CD", "HF"), function(m){
      y <- as.matrix(x[x[, "map"] == m, paste0("T", tps)])
      do.call(rbind, lapply(names(levels), function(l) data.frame(map = m, level = l, t(apply(y, 2, quantile, levels[l], names = FALSE)),
                                                                   any.T = quantile(apply(y, 1, max), levels[l], names = FALSE), check.names = FALSE)))
    }))
    write.table(cbind(th[, 1:2], round(th[, -(1:2)], 3)), file.path(opt$out, "thresholds.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
    cat("Thresholds from", length(unique(x[, "perm"])), "permutations written to", file.path(opt$out, "thresholds.txt"), "\n")
  }
}

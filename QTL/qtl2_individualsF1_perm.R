#
# qtl2_individualsF1_perm.R - Genome-wide thresholds for the individual-mouse lifespan maps with the BXD x BXD F1 mice
# (Fig. 2 b-d), by permuting strains within epochs and F1 types within class, in chunks for Squirm (tools/squirm/README.md)
#
# Exploratory. Written by Claude (Opus 5.5) for Rob Williams, 23 November 2026, for the maps of qtl2_individualsF1.R in
# robwwilliams/BxDLifeSpan, after those maps were seen. It extends qtl2_individuals_perm.R (same chunks, seeds, levels and
# outputs) to the F1 mice. Rob, on Fig. 2: "b. individuals with F1s stratified by CD and HFD; c. individuals with F1s, all
# combined, all cofactors, main effect only; d. individuals all combined, diet x locus interaction effect only".
#   - The maps: each mouse's age at death, BXD and F1 mice together, in the survivorship at each T-age from 20 to 770
#     days in 30-day steps. Each mouse takes its unit's allele probabilities (strain, or F1 type from both parents) and
#     its unit's LOCO kinship (allele sharing over strains and F1 types). Covariates: vivarium (the F1s were all housed
#     at TSRB, vivarium 3), set-up age in 180-day classes, and F1 class (short x short, long x long); for the maps of both
#     diets, also diet and F1 class x diet. Four maps: CD, HF, main, and int (the LOD of the interaction model minus that
#     of the main model).
#   - The exchangeable units are strains and F1 types, not mice. In each permutation every strain takes the genotypes
#     and kinship of another strain of its stratum (Taylor's strains or the newer ones), and every F1 type those of
#     another F1 type of its class. Every mouse keeps its lifespan and covariates.
#   - Each permutation records the largest -log10 P over markers, for each map and T-age. It also records the largest
#     Cauchy combination over markers (Liu & Xie 2020; notes/Cauchy_review_2026-11-21.md): at each marker the P values of
#     all its T-ages are combined into one, and its -log10 is taken; over T20-T770 and over T20-T620. P values are exact,
#     on 1 d.f., and kept below 1 - 1e-10 so that none is infinite. Chunk k draws from seed + k.
#   - --check yes runs the real data (no permutation) at the T-ages given, to compare with qtl2_individualsF1.R.
# Inputs: QTL/inputs (bxd_risib/ and mice.txt, from squirm_inputs.R in the fork) and the F1 table in data/corrected/.
#   Rscript QTL/qtl2_individualsF1_perm.R --out DIR [--workers 4] [--chunks 100] [--per-chunk 2] [--seed 20261124]
#                                          [--only 1,2] [--tps 20,500] [--check yes]
# Writes in DIR: chunk_001.txt ...; and, once all chunks are done, maxima.txt and thresholds.txt
#

library(qtl2)
library(parallel)

opt <- list(out = "output/qtl2_individualsF1_perm", workers = 4, chunks = 100, `per-chunk` = 2, seed = 20261124, only = "", tps = "", check = "")
a <- commandArgs(trailingOnly = TRUE)
for(i in seq_len(length(a) / 2) * 2 - 1) opt[[sub("^--", "", a[i])]] <- a[i + 1]
nchunk <- as.numeric(opt$chunks); per <- as.numeric(opt$`per-chunk`); seed <- as.numeric(opt$seed)
tps <- if(opt$tps == "") seq(20, 770, 30) else as.numeric(strsplit(opt$tps, ",")[[1]])
dir.create(opt$out, recursive = TRUE, showWarnings = FALSE)

cross <- suppressWarnings(read_cross2("QTL/inputs/bxd_risib/control.yaml"))      # warns that no chromosome is the X
pr <- calc_genoprob(cross, error_prob = 0.002)
strains <- rownames(pr[[1]])
bxd <- read.delim("QTL/inputs/mice.txt", colClasses = c(id = "character"))
stratum <- tapply(bxd[, "stratum"], bxd[, "strain"], unique)[strains]

### F1 types and mice (as strainF1_setup.R and qtl2_individualsF1.R in the fork)
short <- c("BXD9", "BXD170", "BXD172", "BXD197"); long <- c("BXD65", "BXD73b", "BXD77", "BXD102")
f1 <- read.delim("data/corrected/AgingBXD_F1_24Nov2026_corrected.txt", check.names = FALSE)
f1 <- f1[f1[, "CauseOfDeath"] == "Natural" & f1[, "DietCode"] %in% c("CD", "HF"), ]
types <- sort(unique(f1[, "StrainName"]))
parents <- t(sapply(types, function(x) c(sub("x.*", "", x), paste0("BXD", sub(".*x", "", x)))))
stopifnot(all(parents %in% strains))
f1class <- ifelse(parents[, 1] %in% short & parents[, 2] %in% short, "short", "long"); names(f1class) <- types
units <- c(strains, types)
group <- c(stratum, f1class); names(group) <- units                               # permutation groups

AP <- pr
for(chr in names(pr)){
  p <- pr[[chr]]; pD <- p[, "DD", ]; pB <- p[, "BB", ]; p1 <- parents[, 1]; p2 <- parents[, 2]
  het <- pB[p1, ] * pD[p2, ] + pD[p1, ] * pB[p2, ]
  a <- array(0, c(length(units), 2, dim(p)[3]), list(units, c("B", "D"), dimnames(p)[[3]]))
  a[strains, "B", ] <- pB[strains, ]; a[strains, "D", ] <- pD[strains, ]
  a[types, "B", ] <- pB[p1, ] * pB[p2, ] + het / 2; a[types, "D", ] <- pD[p1, ] * pD[p2, ] + het / 2
  AP[[chr]] <- a
}
attr(AP, "alleleprobs") <- TRUE
S <- lapply(AP, function(a){ m <- matrix(a, nrow = dim(a)[1]); tcrossprod(m) })
nm <- sapply(AP, function(a) dim(a)[3])
K <- lapply(names(AP), function(chr){ k <- (Reduce(`+`, S) - S[[chr]]) / (sum(nm) - nm[chr]); dimnames(k) <- list(units, units); k })
names(K) <- names(AP); rm(S)

fm <- data.frame(id = paste0("F1_", f1[, "EarTagNumberCurrent"]), strain = f1[, "StrainName"], diet = f1[, "DietCode"], age = f1[, "AgeAtDeath (days)"],
                 vivarium = 3, setup.age = as.numeric(f1[, "AgeAtSet Up (days)"]), stratum = f1class[f1[, "StrainName"]])   # TSRB
mice <- rbind(bxd, fm)
mice <- mice[complete.cases(mice[, c("age", "vivarium", "setup.age")]), ]
rownames(mice) <- mice[, "id"]
cls <- ifelse(mice[, "strain"] %in% types, f1class[mice[, "strain"]], "inbred")
cv.all <- data.frame(diet = mice[, "diet"], vivarium = as.factor(mice[, "vivarium"]), setup = as.factor(cut(mice[, "setup.age"], seq(0, 1000, 180))),
                     short = as.numeric(cls == "short"), long = as.numeric(cls == "long"), row.names = mice[, "id"])
lp <- function(lod) -pchisq(2 * log(10) * pmax(lod, 0), 1, lower.tail = FALSE, log.p = TRUE) / log(10)
covars <- function(cm, m){
  f <- if(m == "main") ~ diet + vivarium + setup + short + long + short:diet + long:diet else ~ vivarium + setup + short + long
  cm$vivarium <- droplevels(cm$vivarium); cm$setup <- droplevels(cm$setup)
  X <- model.matrix(f, cm)[, -1, drop = FALSE]
  X <- X[, colSums(X) > 0, drop = FALSE]
  q <- qr(X); X[, q$pivot[seq_len(q$rank)], drop = FALSE]
}

# One permutation of units within groups: o[u] is the unit whose genotypes unit u takes
drawPerm <- function(){ o <- units; for(g in unique(group)){ i <- which(group == g); o[i] <- units[i][sample.int(length(i))] }; names(o) <- units; o }

# The four maps at every T-age under one permutation: the largest -log10 P over markers
scanPerm <- function(o){
  donor <- match(o[mice[, "strain"]], units); names(donor) <- mice[, "id"]
  res <- matrix(NA, 4, length(tps), dimnames = list(c("main", "int", "CD", "HF"), paste0("T", tps)))
  P <- lapply(c(main = 1, int = 2, CD = 3, HF = 4), function(i) matrix(NA, sum(nm), length(tps)))   # -log10 P, markers x T-ages
  for(j in seq_along(tps)){
    cv <- cv.all[mice[, "age"] >= tps[j], ]
    for(m in c("main", "CD", "HF")){
      cm <- if(m == "main") cv else cv[cv[, "diet"] == m, ]
      ids <- rownames(cm); idx <- donor[ids]
      X <- covars(cm, m)
      Y <- matrix(mice[ids, "age"], dimnames = list(ids, "age"))
      best <- c(main = 0, int = 0); pm <- c(); pint <- c()
      for(chr in names(AP)){                                                         # one chromosome at a time, to keep memory small
        apm <- AP[, chr]; g <- apm[[chr]][idx, , , drop = FALSE]; dimnames(g)[[1]] <- ids; apm[[chr]] <- g
        Kd <- decomp_kinship(list(`dimnames<-`(K[[chr]][idx, idx], list(ids, ids))))
        out <- scan1(apm, Y, kinship = Kd, addcovar = X)
        best["main"] <- max(best["main"], lp(out[, 1])); pm <- c(pm, lp(out[, 1]))
        if(m == "main"){
          out.int <- scan1(apm, Y, kinship = Kd, addcovar = X, intcovar = X[, "dietHF", drop = FALSE])
          best["int"] <- max(best["int"], lp(out.int[, 1] - out[, 1])); pint <- c(pint, lp(out.int[, 1] - out[, 1]))
        }
      }
      res[m, j] <- best["main"]; P[[m]][, j] <- pm
      if(m == "main"){ res["int", j] <- best["int"]; P[["int"]][, j] <- pint }
      rm(apm, Kd); gc(verbose = FALSE)
    }
  }
  cauchyMax <- function(x, T){ p <- pmin(10^-x[, tps <= T, drop = FALSE], 1 - 1e-10); -log10(pcauchy(rowMeans(tan((0.5 - p) * pi)), lower.tail = FALSE)) }
  cbind(res, `cauchy.T20-T770` = sapply(P[rownames(res)], function(x) max(cauchyMax(x, 770))), `cauchy.T20-T620` = sapply(P[rownames(res)], function(x) max(cauchyMax(x, 620))))
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
  if(opt$check == "yes"){                                                          # the real data, for comparison with qtl2_individualsF1.R
    o <- units; names(o) <- units
    r <- data.frame(map = c("main", "int", "CD", "HF"), scanPerm(o), check.names = FALSE)
    write.table(r, file.path(opt$out, "check_real_data.txt"), sep = "\t", quote = FALSE, row.names = FALSE); print(r)
    quit(save = "no")
  }
  ks <- if(opt$only == "") 1:nchunk else as.numeric(strsplit(opt$only, ",")[[1]])
  todo <- ks[!file.exists(chunkFile(ks))]
  cat(nrow(mice), "mice (", sum(cls != "inbred"), "F1 ) of", length(strains), "strains and", length(types), "F1 types;", length(tps), "T-ages;",
      length(ks) - length(todo), "chunks already done,", length(todo), "to run (", per, "permutations each ) on", opt$workers, "workers\n")
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
      cy <- as.matrix(x[x[, "map"] == m, c("cauchy.T20-T770", "cauchy.T20-T620")])
      do.call(rbind, lapply(names(levels), function(l) data.frame(map = m, level = l, t(apply(y, 2, quantile, levels[l], names = FALSE)),
                                                                   any.T = quantile(apply(y, 1, max), levels[l], names = FALSE),
                                                                   t(apply(cy, 2, quantile, levels[l], names = FALSE)), check.names = FALSE)))
    }))
    write.table(cbind(th[, 1:2], round(th[, -(1:2)], 3)), file.path(opt$out, "thresholds.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
    cat("Thresholds from", length(unique(x[, "perm"])), "permutations written to", file.path(opt$out, "thresholds.txt"), "\n")
  }
}

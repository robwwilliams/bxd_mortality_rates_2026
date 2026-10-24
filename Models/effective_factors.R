#
# effective_factors.R
#
# copyright (c) 2026 - Rob Williams
#
# Exploratory model, not an analysis of the data.
#
# Sewall Wright's question for the BXD F1 experiment: do 10 or 200 unlinked loci predict different lifespan gains
# for short x short and long x long F1s over their inbred parents?
#
# Genetics: m loci, 90% deleterious recessives, 10% additive. At each locus the bad allele is B or D at random.
# A BXD strain is homozygous B or D at each locus (p = 0.5). Load = number of loci at which a genotype expresses the
# bad allele (an F1 expresses a recessive only where both parents carry it; an additive locus counts half when
# heterozygous).
#
# Two ways for load to act on mortality, each with intrinsic aging h0(t) = a0 * 2^(t / 100):
#   A, proportional: h(t) = h0(t) * r^load              load multiplies the Gompertz hazard: MRDT stays 100 d
#   B, added:        h(t) = h0(t) + k * (r^load - 1) * 2^(t / 300)
#                    load adds its own deaths, which also rise with age but more slowly (doubling every 300 d): the
#                    "hard knocks". A load-free genotype dies of intrinsic aging alone, and lives 1,050 d.
#                    (A load hazard linear in load cannot spread inbreds from 400 to 950 d with 200 loci: every inbred
#                    carries 100 +- 7 bad alleles, so it must grow faster than linearly.)
# Each model is calibrated so that inbred strains at the 2.5% and 97.5% quantiles of load live 950 and 400 days
# (mean age at death of mice alive at 200 d).
#
# Each replicate: 150 BXD strains; 4 short-lived parents drawn from the shortest 30 and 4 long-lived parents from the
# longest 30; all 6 F1s within each set; 25 mice per genotype, fitted from 200 d with a level for each genotype and
# one MRDT per group (as in the exploratory refit of the data).
#
# Run from the repository root:  Rscript Models/effective_factors.R   (about 40 s)
#

source("Gompertz/gompertz.R")
set.seed(20261024)
grid <- 0:3000; T0 <- 200; M0 <- 100; Mload <- 300

meanlife <- function(h) {                       # mean age at death of mice alive at T0, from daily hazards on grid
  H <- cumsum(h); S <- exp(-(H - H[T0 + 1]))
  T0 + sum(S[(T0 + 1):length(S)])
}
h0 <- function(a0) a0 * 2^(grid / M0)
hazard <- function(model, load, p) if (model == "A") h0(p$a0) * p$r^load else h0(p$a0) + p$k * (p$r^load - 1) * 2^(grid / Mload)

calibrate <- function(model, m) {
  lo <- qbinom(0.025, m, 0.5); hi <- qbinom(0.975, m, 0.5)
  if (model == "A") {
    fa <- function(target) exp(uniroot(function(la) meanlife(h0(exp(la))) - target, c(-30, -1))$root)
    a.lo <- fa(950); a.hi <- fa(400)
    r <- (a.hi / a.lo)^(1 / (hi - lo))
    return(list(a0 = a.lo / r^lo, r = r, lo = lo, hi = hi))
  }
  # B: a0 gives the load-free genotype 1,050 d; for a given r, k makes load 'hi' live 400 d; r makes load 'lo' live 950 d
  a0 <- exp(uniroot(function(la) meanlife(h0(exp(la))) - 1050, c(-30, -1))$root)
  k.for <- function(r) exp(uniroot(function(lk) meanlife(h0(a0) + exp(lk) * (r^hi - 1) * 2^(grid / Mload)) - 400, c(-300, 50))$root)
  r <- exp(uniroot(function(lr) { r <- exp(lr); meanlife(h0(a0) + k.for(r) * (r^lo - 1) * 2^(grid / Mload)) - 950 }, c(1e-5, 0.7))$root)
  list(a0 = a0, k = k.for(r), r = r, lo = lo, hi = hi)
}

draw.ages <- function(h, n) {                   # ages at death of n mice alive at T0
  H <- cumsum(h); target <- H[T0 + 1] - log(runif(n))
  grid[pmin(findInterval(target, H) + 1, length(grid))]
}

one.replicate <- function(model, m, p) {
  rec <- seq_len(m) <= round(0.9 * m)                       # recessive loci; the rest additive
  ri <- matrix(rbinom(150 * m, 1, 0.5), 150, m)              # 1 = carries the bad allele at that locus (homozygous)
  load.ri <- rowSums(ri)
  life.ri <- sapply(load.ri, function(L) meanlife(hazard(model, L, p)))
  ord <- order(life.ri)
  S <- sample(ord[1:30], 4); Lg <- sample(ord[121:150], 4)
  f1.load <- function(i, j) sum(ri[i, rec] & ri[j, rec]) + sum((ri[i, !rec] + ri[j, !rec]) / 2)
  res <- c(); mice <- c()
  for (set in c("Short", "Long")) {
    par.idx <- if (set == "Short") S else Lg
    pairs <- combn(par.idx, 2)
    for (q in seq_len(ncol(pairs))) {
      i <- pairs[1, q]; j <- pairs[2, q]
      L <- f1.load(i, j); life <- meanlife(hazard(model, L, p))
      res <- rbind(res, data.frame(set = set, load.mid = (load.ri[i] + load.ri[j]) / 2, load.f1 = L,
                                   life.mid = (life.ri[i] + life.ri[j]) / 2, life.f1 = life))
      mice <- rbind(mice, data.frame(set = set, class = "F1", geno = paste(i, j), age = draw.ages(hazard(model, L, p), 25)))
    }
    for (i in par.idx) mice <- rbind(mice, data.frame(set = set, class = "Parents", geno = as.character(i),
                                                      age = draw.ages(hazard(model, load.ri[i], p), 25)))
  }
  mrdt <- sapply(c("Short.Parents", "Short.F1", "Long.Parents", "Long.F1"), function(g) {
    s <- paste(mice$set, mice$class, sep = ".") == g
    gompertz.cells.fit(mice$age[s], rep(T0, sum(s)), mice$geno[s])$MRDT
  })
  gain <- res$life.f1 - res$life.mid
  c(gain.SxS = mean(gain[res$set == "Short"]), gain.LxL = mean(gain[res$set == "Long"]),
    sd.gain.SxS = sd(gain[res$set == "Short"]), sd.gain.LxL = sd(gain[res$set == "Long"]),
    life.S = mean(res$life.mid[res$set == "Short"]), life.L = mean(res$life.mid[res$set == "Long"]),
    F1.SxS = mean(res$life.f1[res$set == "Short"]), F1.LxL = mean(res$life.f1[res$set == "Long"]),
    F1.over.best.inbred = mean(res$life.f1 > max(life.ri)),
    load.drop.SxS = mean(res$load.mid[res$set == "Short"] - res$load.f1[res$set == "Short"]),
    load.drop.LxL = mean(res$load.mid[res$set == "Long"] - res$load.f1[res$set == "Long"]),
    setNames(mrdt, paste0("MRDT.", names(mrdt))))
}

out <- c()
for (model in c("A", "B")) for (m in c(10, 200)) {
  p <- calibrate(model, m)
  cat(sprintf("Model %s, %d loci: load %d -> 950 d, load %d -> 400 d; load-0 genotype lives %.0f d\n",
              model, m, p$lo, p$hi, meanlife(hazard(model, 0, p))))
  reps <- t(replicate(200, one.replicate(model, m, p)))
  q <- apply(reps, 2, quantile, c(0.1, 0.5, 0.9), na.rm = TRUE)
  out <- rbind(out, data.frame(model = model, loci = m, stat = colnames(reps), median = q[2, ], p10 = q[1, ], p90 = q[3, ]))
}
rownames(out) <- NULL
write.table(out, "output/Model_effective_factors.txt", sep = "\t", quote = FALSE, row.names = FALSE)
w <- reshape(out[, c("model", "loci", "stat", "median")], idvar = "stat", timevar = c("model"), direction = "wide", v.names = "median")
for (mm in c(10, 200)) { cat("\nloci =", mm, "\n"); x <- out[out$loci == mm, ]
  print(data.frame(stat = unique(x$stat), A = round(x$median[x$model == "A"]), A.range = paste0(round(x$p10[x$model == "A"]), "..", round(x$p90[x$model == "A"])),
                   B = round(x$median[x$model == "B"]), B.range = paste0(round(x$p10[x$model == "B"]), "..", round(x$p90[x$model == "B"])))) }

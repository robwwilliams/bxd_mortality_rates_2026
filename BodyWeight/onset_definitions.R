#
# onset_definitions.R
#
# copyright (c) 2026 - Rob Williams
#
# Are the Part 4 conclusions sensitive to how the onset of morbidity is defined? As set out in
# notes/PLAN_morbidity_definitions.md (approved by Rob on 27 October 2026; exploratory). Every definition of the plan
# (BodyWeight/morbidity_functions.R) is run against conclusions C1-C4, in days and as a share of life, with the
# statistics of Part 4 (BodyWeight/terminal_decline.R). Each definition is also scored on how well the version that
# could be known at the time predicts death before the next weighing (Cox model on age).
#   C1  BXD strains: slope of strain-mean decline on strain-mean lifespan, from split halves (chow, high fat)
#   C2  short x short F1s minus their parents (cell means ~ type + diet; exact permutation over genotypes)
#   C3  long x long F1s minus their parents
#   C4  high fat minus chow within BXD strains (sign flips)
#
# Run from the repository root:  Rscript BodyWeight/onset_definitions.R
# Writes output/Onset_definitions_*.txt
#

library(readxl)
library(survival)
library(parallel)
source("BodyWeight/morbidity_functions.R")

set.seed(20261027)
cores <- max(1, detectCores() - 2)
star <- "P1.K1.O1.T1.L1"
oat <- c(star, "P2.K1.O1.T1.L1", "P3.K1.O1.T1.L1", "P4.K1.O1.T1.L1", "P1.K2.O1.T1.L1", "P1.K1.O2.T1.L1", "P1.K1.O3.T1.L1",
         "P1.K1.O4.T1.L1", "P1.K1.O5.T1.L1", "P1.K1.O6.L1", "P1.K1.O7.T1.L1", "K1.O8.L1", "P1.K1.O9.L1", "P1.K1.O10.T1.L1",
         "P1.K1.O1.T2.L1", "P1.K1.O1.T1.L2", "P1.K1.O1.T1.L3", "P1.K1.O1.T1.L4", "P1.K1.G1.L2", "P1.K1.G2.L2")

num <- function(v) suppressWarnings(as.numeric(v))
long.weights <- function(x, tag, base.w, base.age, nw) {          # one row per weighing
  do.call(rbind, c(list(data.frame(EarTag = tag, age = num(x[, base.age]), w = num(x[, base.w]))),
                   lapply(seq_len(nw), function(j) data.frame(EarTag = tag, age = num(x[, sprintf("AgeAtWeight%02d", j)]),
                                                               w = num(x[, sprintf("Weight%02d", j)])))))
}

# Mice and weighings, as in BodyWeight/terminal_decline.R
m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:7]
colnames(m) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
m <- m[!is.na(m[, "EarTag"]) & m[, "Diet"] %in% c("CD", "HF"), ]
b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females",
                                               .name_repair = "minimal")))
b <- b[match(m[, "EarTag"], b[, "EarTagNumberCurrent"]), ]
mice.bxd <- data.frame(EarTag = m[, "EarTag"], Genotype = m[, "Strain"], Diet = m[, "Diet"], Status = b[, "Status"], Death = m[, "Age"],
                       Type = ifelse(m[, "Strain"] %in% c("C57BL/6J", "DBA/2J"), "B6 and D2",
                              ifelse(m[, "Strain"] %in% c("B6D2F1", "D2B6F1"), "B6D2 F1s", "BXD")), Workbook = "BXD")
w.bxd <- long.weights(b, b[, "EarTagNumberCurrent"], "Weight00 Baseline", "AgeAtSetUp", 20)
f <- read.delim("data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt", check.names = FALSE, quote = "")
f <- f[f[, "CauseOfDeath"] %in% "Natural" & !is.na(num(f[, "AgeAtDeath (days)"])), ]
f[, "StrainName"] <- sub("^BXD([0-9]+[a-wyz]?)x([0-9]+[a-wyz]?)$", "BXD\\1xBXD\\2", f[, "StrainName"])
mice.f1 <- data.frame(EarTag = f[, "EarTagNumberCurrent"], Genotype = f[, "StrainName"], Diet = f[, "DietCode"], Status = f[, "CauseOfDeath"],
                      Death = num(f[, "AgeAtDeath (days)"]), Type = "F1", Workbook = "F1")
w.f1 <- long.weights(f, f[, "EarTagNumberCurrent"], "Weight00 Baseline", "AgeAtSet Up (days)", 18)
short.parents <- c("BXD9", "BXD170", "BXD172", "BXD197"); long.parents <- c("BXD65", "BXD73b", "BXD77", "BXD102")
mice <- rbind(mice.bxd, mice.f1)
mice[, "Set"] <- sapply(seq_len(nrow(mice)), function(i) {
  g <- mice[i, "Genotype"]; p <- if (mice[i, "Type"] == "F1") strsplit(g, "x")[[1]] else g
  if (all(p %in% short.parents)) "Short" else if (all(p %in% long.parents)) "Long" else NA
})
mice[, "group"] <- ifelse(mice[, "Type"] == "F1" | mice[, "Diet"] == "HF", "hf", "chow")
weights <- rbind(cbind(w.bxd, Workbook = "BXD"), cbind(w.f1, Workbook = "F1"))
weights <- weights[!is.na(weights[, "age"]) & !is.na(weights[, "w"]), ]
fl <- read.delim("qc/BodyWeight_flags.txt", quote = "")                           # K2 drops rules A, B, E and G
fl <- fl[grepl("(^|; )[ABEG] ", fl[, "Rule"]), ]
weights[, "flagged"] <- paste(weights[, "Workbook"], weights[, "EarTag"], weights[, "age"]) %in% paste(fl[, "Workbook"], fl[, "EarTag"], fl[, "Age"])
wl <- split(weights, paste(weights[, "Workbook"], weights[, "EarTag"]))

# Every definition for every mouse; a mouse counts only if both weighing settings give it a peak
cat("Mice:", nrow(mice), "\n")
res <- mclapply(seq_len(nrow(mice)), function(i) {
  z <- wl[[paste(mice[i, "Workbook"], mice[i, "EarTag"])]]
  if (is.null(z)) return(NULL)
  k1 <- morbidity.all(z[, "age"], z[, "w"], mice[i, "Death"], mice[i, "group"], "K1")
  k2 <- morbidity.all(z[!z[, "flagged"], "age"], z[!z[, "flagged"], "w"], mice[i, "Death"], mice[i, "group"], "K2")
  if (is.null(k1) || is.null(k2)) NULL else c(k1, k2)
}, mc.cores = cores)
keep <- !sapply(res, is.null)
S <- do.call(rbind, res[keep]); d <- mice[keep, ]
cat("Mice with a peak at least 120 days before death under both weighing settings:", nrow(d), "\n")
cat("Weighings flagged and dropped under K2:", sum(weights[, "flagged"]), "\n")
defs <- colnames(S); cat("Definitions:", length(defs), "\n")
stopifnot(all(oat %in% defs))

# Check: Part 4's definition reproduces Part 4's spans
p4 <- read.delim("output/Terminal_decline_by_mouse.txt")
k <- match(paste(d[, "Workbook"], d[, "EarTag"]), paste(ifelse(p4[, "Type"] == "F1", "F1", "BXD"), p4[, "EarTag"]))
cat("Part 4 spans reproduced:", sum(abs(S[!is.na(k), star] - p4[k[!is.na(k)], "span"]) < 1e-6), "of", sum(!is.na(k)), "mice\n")

write.table(cbind(d[, c("Workbook", "EarTag", "Genotype", "Diet", "Type", "Set", "Status", "Death")], round(S[, oat], 2)),
            "output/Onset_definitions_by_mouse.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# ---- Fixed random draws, reused for every definition -------------------------------------------------------------
jack.se <- function(loo) { n <- length(loo); sqrt((n - 1) / n * sum((loo - mean(loo))^2)) }
q1.setup <- lapply(c(CD = "CD", HF = "HF"), function(diet) {
  i <- which(d[, "Type"] == "BXD" & d[, "Diet"] == diet)
  g <- split(i, d[i, "Genotype"]); g <- g[sapply(g, length) >= 6]
  splits <- lapply(1:200, function(k) lapply(g, function(ii) { h <- if (length(ii) == 2) ii[1] else sample(ii, floor(length(ii) / 2)); list(a = h, b = setdiff(ii, h)) }))
  LA <- sapply(splits, function(sp) sapply(sp, function(z) mean(d[z$a, "Death"])))
  list(g = g, splits = splits, LA = LA, perms = replicate(2000, sample(length(g))))
})
q2.setup <- lapply(c(Short = "Short", Long = "Long"), function(set) {
  i <- which(!is.na(d[, "Set"]) & d[, "Set"] == set & d[, "Type"] %in% c("F1", "BXD"))
  cell <- paste(d[i, "Genotype"], d[i, "Type"], d[i, "Diet"])
  n <- table(cell); i <- i[cell %in% names(n)[n >= 3]]; cell <- paste(d[i, "Genotype"], d[i, "Type"], d[i, "Diet"])
  cells <- unique(d[i, c("Genotype", "Type", "Diet")]); rownames(cells) <- paste(cells[, "Genotype"], cells[, "Type"], cells[, "Diet"])
  geno <- unique(cells[, c("Genotype", "Type")])
  list(i = i, cell = cell, cells = cells, geno = geno, combos = combn(nrow(geno), sum(geno[, "Type"] == "F1")))
})
q3.setup <- local({
  i <- which(d[, "Type"] == "BXD"); nn <- table(d[i, "Genotype"], d[i, "Diet"])
  ok <- rownames(nn)[nn[, "CD"] >= 3 & nn[, "HF"] >= 3]
  list(i = i[d[i, "Genotype"] %in% ok], ok = ok, flips = matrix(sample(c(-1, 1), 10000 * length(ok), replace = TRUE), 10000))
})

# ---- The tests, for one outcome vector v (days in decline or burden; or its share of life) ------------------------
test.q1 <- function(v, s) {
  SB <- sapply(s$splits, function(sp) sapply(sp, function(z) mean(v[z$b])))
  slope <- function(L, B) { Lc <- sweep(L, 2, colMeans(L)); sum(Lc * B / rep(colSums(Lc^2), each = nrow(L))) / ncol(L) }
  est <- slope(s$LA, SB)
  se <- jack.se(sapply(seq_len(nrow(SB)), function(u) slope(s$LA[-u, , drop = FALSE], SB[-u, , drop = FALSE])))
  Lc <- sweep(s$LA, 2, colMeans(s$LA)); Wt <- Lc / rep(colSums(Lc^2), each = nrow(Lc)) / ncol(Lc)
  null <- apply(s$perms, 2, function(p) sum(Wt * SB[p, ]))
  tq <- qt(0.975, nrow(SB) - 1)
  c(estimate = est, lo = est - tq * se, hi = est + tq * se, p = mean(abs(null) >= abs(est)), units = nrow(SB))
}
test.q2 <- function(v, s) {
  y <- tapply(v[s$i], s$cell, mean)[rownames(s$cells)]
  eff <- function(type, keep = rep(TRUE, length(y))) {
    X <- cbind(1, type[keep] == "F1", s$cells[keep, "Diet"] == "HF")
    if (length(unique(X[, 2])) < 2) return(NA)
    .lm.fit(X, y[keep])$coefficients[2]
  }
  est <- eff(s$cells[, "Type"])
  se <- jack.se(sapply(s$geno[, "Genotype"], function(u) eff(s$cells[, "Type"], s$cells[, "Genotype"] != u)))
  null <- apply(s$combos, 2, function(k) { ty <- setNames(ifelse(seq_len(nrow(s$geno)) %in% k, "F1", "BXD"), s$geno[, "Genotype"]); eff(ty[s$cells[, "Genotype"]]) })
  tq <- qt(0.975, nrow(s$geno) - 1)
  c(estimate = est, lo = est - tq * se, hi = est + tq * se, p = mean(abs(null) >= abs(est) - 1e-9), units = nrow(s$geno))
}
test.q3 <- function(v, s) {
  mm <- tapply(v[s$i], list(d[s$i, "Genotype"], d[s$i, "Diet"]), mean)[s$ok, ]
  dif <- mm[, "HF"] - mm[, "CD"]; est <- mean(dif); se <- sd(dif) / sqrt(length(dif))
  null <- s$flips %*% dif / length(dif); tq <- qt(0.975, length(dif) - 1)
  c(estimate = est, lo = est - tq * se, hi = est + tq * se, p = mean(abs(null) >= abs(est)), units = length(dif))
}
run.tests <- function(def) {
  out <- c()
  for (form in c("days", "share")) {
    v <- if (form == "days") S[, def] else S[, def] / d[, "Death"]
    out <- rbind(out,
      data.frame(definition = def, form = form, conclusion = "C1 chow", t(test.q1(v, q1.setup$CD))),
      data.frame(definition = def, form = form, conclusion = "C1 high fat", t(test.q1(v, q1.setup$HF))),
      data.frame(definition = def, form = form, conclusion = "C2 short x short", t(test.q2(v, q2.setup$Short))),
      data.frame(definition = def, form = form, conclusion = "C3 long x long", t(test.q2(v, q2.setup$Long))),
      data.frame(definition = def, form = form, conclusion = "C4 high fat - chow", t(test.q3(v, q3.setup))))
  }
  out
}
cat("Running the tests for", length(defs), "definitions on", cores, "cores\n")
tests <- do.call(rbind, mclapply(defs, run.tests, mc.cores = cores))
tests[, "family"] <- ifelse(grepl("\\.G[12]\\.", tests[, "definition"]), "graded", ifelse(grepl("\\.T2\\.", tests[, "definition"]), "T2", "T1"))
tests[, "one.at.a.time"] <- tests[, "definition"] %in% oat
num.cols <- c("estimate", "lo", "hi", "p")
tests[, num.cols] <- signif(tests[, num.cols], 4)
write.table(tests, "output/Onset_definitions_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nPart 4's definition:\n"); print(tests[tests[, "definition"] == star, ], row.names = FALSE)

# ---- Validity: the version of each rule that could be known at the time ------------------------------------------
prospective <- function(a, w, death) {
  o <- order(a); a <- a[o]; w <- w[o]; keep <- a <= death; a <- a[keep]; w <- w[keep]; n <- length(a)
  if (n < 2) return(NULL)
  rows <- which(a >= 300 & seq_len(n) >= 2); if (!length(rows)) return(NULL)
  do.call(rbind, lapply(rows, function(j) {
    ww <- w[1:j]; aa <- a[1:j]; ipj <- which.max(ww)
    pl <- c(Pmax = max(ww), P3 = median(sort(ww, decreasing = TRUE)[1:min(3, j)]),
            P4 = { k <- which(aa >= aa[j] - 240 & aa <= aa[j] - 120); if (length(k)) mean(ww[k]) else max(ww) })
    st <- c()
    for (P in names(pl)) {
      r <- ww / pl[[P]]; rate <- (ww[j - 1] - ww[j]) / pl[[P]] * 30 / max(aa[j] - aa[j - 1], 1)
      since <- ipj:j; loss <- (c(ww[1], ww[-j]) - ww) / pl[[P]]
      st[paste(P, c("O1", "O2", "O3", "O4"), sep = ".")] <- r[j] < theta[c("O1", "O2", "O3", "O4")]
      st[paste(P, "O5", sep = ".")] <- any(r[since] < 0.90)
      st[paste(P, "O6", sep = ".")] <- rate >= 0.02
      st[paste(P, "O7", sep = ".")] <- r[j] < 0.90 || rate >= 0.05
      st[paste(P, "O9", sep = ".")] <- any(loss[since[-1]] > 0.10)
      st[paste(P, "O10.chow", sep = ".")] <- r[j] < theta.equal.risk("chow")
      st[paste(P, "O10.hf", sep = ".")] <- r[j] < theta.equal.risk("hf")
      st[paste(P, "G", sep = ".")] <- max(0, 1 - r[j] - 0.05)
    }
    st["O8"] <- !is.na(change.point(aa[ipj:j], ww[ipj:j]))
    data.frame(start = a[j], stop = if (j < n) a[j + 1] else max(death, a[j] + 0.5), event = as.integer(j == n), t(st))
  }))
}
pv <- mclapply(seq_len(nrow(d)), function(i) {
  z <- wl[[paste(d[i, "Workbook"], d[i, "EarTag"])]]
  out <- c()
  for (K in c("K1", "K2")) {
    zz <- if (K == "K1") z else z[!z[, "flagged"], ]
    x <- prospective(zz[, "age"], zz[, "w"], d[i, "Death"])
    if (!is.null(x)) out <- rbind(out, cbind(K = K, row = i, x))
  }
  out
}, mc.cores = cores)
pv <- do.call(rbind, pv); pv <- pv[pv[, "stop"] > pv[, "start"], ]
pv[, "Genotype"] <- d[pv[, "row"], "Genotype"]
pv[, "vgroup"] <- ifelse(d[pv[, "row"], "Type"] == "F1", "F1s", ifelse(d[pv[, "row"], "Diet"] == "HF", "High-fat BXDs", "Chow BXDs"))
covs <- setdiff(colnames(pv), c("K", "row", "start", "stop", "event", "Genotype", "vgroup"))
validity <- do.call(rbind, lapply(c("K1", "K2"), function(K) do.call(rbind, lapply(covs, function(v) do.call(rbind, lapply(c("Chow BXDs", "High-fat BXDs", "F1s"), function(g) {
  x <- pv[pv[, "K"] == K & pv[, "vgroup"] == g, ]
  if (grepl("O10", v) && ((g == "Chow BXDs") != grepl("chow", v))) return(NULL)            # each group gets its own line
  x[, "z"] <- as.numeric(x[, v])
  if (length(unique(x[, "z"])) < 2) return(NULL)
  fit <- coxph(Surv(start, stop, event) ~ z, x, cluster = Genotype)
  data.frame(K = K, rule = sub("\\.(chow|hf)$", "", v), group = g, intervals = nrow(x), share.in.state = round(mean(x[, "z"] > 0), 3),
             HR = signif(exp(coef(fit)), 3), concordance = round(unname(fit$concordance["concordance"]), 3))
}))))))
write.table(validity, "output/Onset_definitions_validity.txt", sep = "\t", quote = FALSE, row.names = FALSE)
vm <- aggregate(concordance ~ K + rule, validity, mean); vm <- vm[order(-vm[, "concordance"]), ]
cat("\nValidity: mean concordance over chow BXDs, high-fat BXDs and F1s (top 15)\n"); print(head(vm, 15), row.names = FALSE)
best <- vm[1, ]
best.def <- local({
  P <- sub("\\..*$", "", best[, "rule"]); O <- sub("^.*\\.", "", best[, "rule"]); K <- best[, "K"]
  if (best[, "rule"] == "O8") paste(K, "O8.L1", sep = ".")
  else { P <- if (P == "Pmax") "P1" else P
         if (O == "G") paste(P, K, "G1.L2", sep = ".") else if (O %in% c("O6", "O9")) paste(P, K, O, "L1", sep = ".") else paste(P, K, O, "T1.L1", sep = ".") }
})
cat("Definition that best predicts death:", best[, "K"], best[, "rule"], "->", best.def, "\n")

# ---- Summary for each conclusion -----------------------------------------------------------------------------------
sig <- function(x) x[, "lo"] > 0 | x[, "hi"] < 0
summary <- do.call(rbind, lapply(split(tests, paste(tests[, "conclusion"], tests[, "form"])), function(x) {
  s0 <- x[x[, "definition"] == star, ]; null <- !sig(s0); dir0 <- sign(s0[, "estimate"])
  o <- x[x[, "one.at.a.time"], ]; bd <- x[x[, "definition"] == best.def, ]
  same.dir <- sign(x[, "estimate"]) == dir0; same.verdict <- sig(x) == sig(s0)
  crit <- c(oat.direction = if (null) NA else all(sign(o[, "estimate"]) == dir0),
            grid.direction = if (null) NA else mean(same.dir) >= 0.95,
            grid.verdict = mean(same.verdict) >= 0.90, best.verdict = sig(bd) == sig(s0))
  data.frame(conclusion = s0[, "conclusion"], form = s0[, "form"], part4.estimate = s0[, "estimate"], part4.lo = s0[, "lo"], part4.hi = s0[, "hi"],
             part4.p = s0[, "p"], claim = if (null) "no difference" else if (dir0 > 0) "positive" else "negative",
             definitions = nrow(x), share.same.direction = round(mean(same.dir), 3), share.same.verdict = round(mean(same.verdict), 3),
             oat.same.direction = paste0(sum(sign(o[, "estimate"]) == dir0), "/", nrow(o)), oat.same.verdict = paste0(sum(sig(o) == sig(s0)), "/", nrow(o)),
             best.estimate = bd[, "estimate"], best.lo = bd[, "lo"], best.hi = bd[, "hi"],
             estimate.min = min(x[, "estimate"]), estimate.max = max(x[, "estimate"]),
             verdict = if (all(crit, na.rm = TRUE)) "robust" else "sensitive")
}))
write.table(summary, "output/Onset_definitions_summary.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nSummary:\n"); print(summary, row.names = FALSE)

# Which choice moves a sensitive conclusion: share agreeing in verdict, by setting of each choice
setting <- function(def, key) { p <- strsplit(def, ".", fixed = TRUE)[[1]]; v <- grep(key, p, value = TRUE); if (length(v)) v[1] else "-" }
by.choice <- do.call(rbind, lapply(split(tests, paste(tests[, "conclusion"], tests[, "form"])), function(x) {
  s0 <- x[x[, "definition"] == star, ]; agree <- sig(x) == sig(s0)
  do.call(rbind, lapply(c(P = "^P[1-4]$", K = "^K[12]$", O = "^(O[0-9]+|G[12])$", T = "^T[12]$", L = "^L[1-4]$"), function(key) {
    st <- sapply(x[, "definition"], setting, key = key)
    a <- tapply(agree, st, mean); data.frame(conclusion = s0[, "conclusion"], form = s0[, "form"], setting = names(a), share.same.verdict = round(as.numeric(a), 3),
                                             mean.estimate = signif(as.numeric(tapply(x[, "estimate"], st, mean)), 3))
  }))
}))
write.table(by.choice, "output/Onset_definitions_by_choice.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# ---- C5: weight aligned on death, for each plateau (descriptive) ---------------------------------------------------
bins <- c(0, 15, 30, 60, 90, 120, 180, 300)
aligned <- do.call(rbind, lapply(c("P1", "P2", "P3", "P4"), function(P) do.call(rbind, lapply(c("CD", "HF"), function(diet) {
  i <- which(d[, "Type"] == "BXD" & d[, "Diet"] == diet)
  x <- do.call(rbind, lapply(i, function(k) {
    z <- wl[[paste(d[k, "Workbook"], d[k, "EarTag"])]]; z <- z[order(z[, "age"]), ]; z <- z[z[, "age"] <= d[k, "Death"], ]
    pre <- which(z[, "age"] <= d[k, "Death"] - 120); ip <- pre[which.max(z[pre, "w"])]
    pl <- plateau(P, z[, "age"], z[, "w"], d[k, "Death"], ip, pre)
    data.frame(before = d[k, "Death"] - z[, "age"], rel = z[, "w"] / pl)
  }))
  x <- x[x[, "before"] < 300, ]
  med <- tapply(x[, "rel"], cut(x[, "before"], bins, right = FALSE), median)
  data.frame(plateau = P, diet = diet, window = names(med), median.rel = round(as.numeric(med), 3))
}))))
write.table(aligned, "output/Onset_definitions_aligned.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nC5: median weight / plateau by days before death\n"); print(reshape(aligned, idvar = c("diet", "window"), timevar = "plateau", direction = "wide"), row.names = FALSE)

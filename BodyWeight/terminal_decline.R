#
# terminal_decline.R
#
# copyright (c) 2026 - Rob Williams
#
# Terminal weight loss and the per diem cost of late life, as set out in notes/PLAN_terminal_decline.md (approved by
# Rob on 26 October 2026; exploratory). Rob's model: a mouse is free until 500 days; after that the investigator pays
# a per diem, plus a surcharge while the mouse is in terminal decline.
#   Peak:     the highest weight at least 120 days before death.
#   Decline:  weighings below 90% of the peak with no later weighing back at 90% or more. Onset is halfway between the
#             last weighing at 90% or more and the first below; morbidity span = age at death - onset. A mouse with no
#             observed decline gets half the days from its last weighing to death (bounds: 0 and all of them).
#   Cost:     pension days (alive after 500 d) + s x decline days after 500 d, s = 1, 4, 10; and a rate-based surcharge,
#             100 x (loss per 30 days as a fraction of peak - 0.02) per day, over weighed intervals after 500 d.
#   Q1  BXD strains: does the morbidity span rise with lifespan? Split halves (lifespan from one half of each strain's
#       mice, span from the other), averaged over 200 splits; jackknife CI over strains; permutation P.
#   Q2  F1s against their parents, short x short and long x long: genotype x diet cell means ~ type + diet;
#       jackknife CI over genotypes; exact permutation P.
#   Q3  High fat against chow within BXD strains: mean of HF - CD; sign-flip P; jackknife CI.
#   Q4  Per diem cost by group. Every question for all deaths and for natural deaths only.
#
# Changes on 27 October 2026, at Rob's instruction, after the first results were seen. The F1s come from the corrected
# table written by BodyWeight/F1_weights_corrected.R (run it first):
#   - Six F1s labeled BXD73 x BXD65 or BXD73 x BXD77 are BXD73b crosses ("Please do combine and labeled all as BXD73b").
#   - Euthanized F1s count as natural deaths ("Relabeled them a natural deaths for purposes of analysis"): they were
#     euthanized within a week or two of natural death, judged by frailty, to harvest organs. The recorded cause of
#     death stays in the column Recorded. Euthanized BXD family mice stay euthanized.
#
# Run from the repository root:  Rscript BodyWeight/terminal_decline.R
# Writes output/Terminal_decline_by_mouse.txt, _weighings.txt, _tests.txt and _cost.txt
#

library(readxl)

X <- 500                                     # free until this age (days)
set.seed(20261026)

num <- function(v) suppressWarnings(as.numeric(v))
long.weights <- function(x, tag, base.w, base.age, nw) {          # one row per weighing
  do.call(rbind, c(list(data.frame(EarTag = tag, age = num(x[, base.age]), w = num(x[, base.w]))),
                   lapply(seq_len(nw), function(j) data.frame(EarTag = tag, age = num(x[, sprintf("AgeAtWeight%02d", j)]),
                                                               w = num(x[, sprintf("Weight%02d", j)])))))
}

# BXD family: the 1,934 mapping mice, with ages at death from the mapping file
m <- as.data.frame(read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal"))[, 1:7]
colnames(m) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
m <- m[!is.na(m[, "EarTag"]) & m[, "Diet"] %in% c("CD", "HF"), ]
b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females",
                                               .name_repair = "minimal")))
b <- b[match(m[, "EarTag"], b[, "EarTagNumberCurrent"]), ]
mice.bxd <- data.frame(EarTag = m[, "EarTag"], Genotype = m[, "Strain"], Diet = m[, "Diet"], Status = b[, "Status"], Recorded = b[, "Status"],
                       Death = m[, "Age"],
                       Type = ifelse(m[, "Strain"] %in% c("C57BL/6J", "DBA/2J"), "B6 and D2",
                              ifelse(m[, "Strain"] %in% c("B6D2F1", "D2B6F1"), "B6D2 F1s", "BXD")))
w.bxd <- long.weights(b, b[, "EarTagNumberCurrent"], "Weight00 Baseline", "AgeAtSetUp", 20)

# BXD x BXD F1s that died (natural, or euthanized at end of life and counted as natural), from the corrected table
f <- read.delim("data/corrected/AgingBXD_F1_BodyWeight_NaturalDeath_corrected.txt", check.names = FALSE, quote = "")
f <- f[f[, "CauseOfDeath"] %in% "Natural" & !is.na(num(f[, "AgeAtDeath (days)"])), ]
f[, "StrainName"] <- sub("^BXD([0-9]+[a-wyz]?)x([0-9]+[a-wyz]?)$", "BXD\\1xBXD\\2", f[, "StrainName"])
mice.f1 <- data.frame(EarTag = f[, "EarTagNumberCurrent"], Genotype = f[, "StrainName"], Diet = f[, "DietCode"], Status = f[, "CauseOfDeath"],
                      Recorded = f[, "CauseOfDeath_recorded"], Death = num(f[, "AgeAtDeath (days)"]), Type = "F1")
w.f1 <- long.weights(f, f[, "EarTagNumberCurrent"], "Weight00 Baseline", "AgeAtSet Up (days)", 18)

short.parents <- c("BXD9", "BXD170", "BXD172", "BXD197"); long.parents <- c("BXD65", "BXD73b", "BXD77", "BXD102")
mice <- rbind(mice.bxd, mice.f1)
mice[, "Set"] <- sapply(seq_len(nrow(mice)), function(i) {
  g <- mice[i, "Genotype"]
  p <- if (mice[i, "Type"] == "F1") strsplit(g, "x")[[1]] else g
  if (all(p %in% short.parents)) "Short" else if (all(p %in% long.parents)) "Long" else NA
})
weights <- rbind(cbind(w.bxd, Source = "BXD"), cbind(w.f1, Source = "F1"))
weights <- weights[!is.na(weights[, "age"]) & !is.na(weights[, "w"]), ]
cat("Mice:", nrow(mice), "(BXD file", nrow(mice.bxd), "; F1s", nrow(mice.f1), "of", length(unique(mice.f1[, "Genotype"])), "types)\n")
cat("F1 types by set:\n"); print(table(mice.f1[, "Genotype"], mice[mice[, "Type"] == "F1", "Set"], useNA = "ifany"))

# Each mouse: peak, decline, morbidity span, per diem cost
per.mouse <- function(a, w, death) {
  o <- order(a); a <- a[o]; w <- w[o]
  late <- sum(a > death); keep <- a <= death; a <- a[keep]; w <- w[keep]
  pre <- which(a <= death - 120)
  if (length(pre) == 0) return(c(after.death = late))
  ip <- pre[which.max(w[pre])]; peak <- w[ip]; n <- length(a)
  above <- ip - 1 + which(w[ip:n] >= 0.9 * peak); ia <- max(above)
  if (ia == n) { lo <- 0; hi <- death - a[n] } else { lo <- death - a[ia + 1]; hi <- death - a[ia] }
  span <- (lo + hi) / 2
  sur <- 0                                                         # rate-based surcharge over weighed intervals after X
  for (j in seq_len(n - 1)) {
    d <- a[j + 1] - max(a[j], X)
    if (d > 0 && a[j + 1] > a[j]) sur <- sur + d * 100 * max(0, 30 * (w[j] - w[j + 1]) / peak / (a[j + 1] - a[j]) - 0.02)
  }
  c(after.death = late, peak = peak, age.peak = a[ip], n.weigh = n, last.weigh = a[n], last.rel = w[n] / peak,
    declined = ia < n, span = span, span.lo = lo, span.hi = hi, rate.surcharge = sur)
}
res <- do.call(rbind, lapply(seq_len(nrow(mice)), function(i) {
  ww <- weights[weights[, "EarTag"] == mice[i, "EarTag"] & weights[, "Source"] == ifelse(mice[i, "Type"] == "F1", "F1", "BXD"), ]
  r <- per.mouse(ww[, "age"], ww[, "w"], mice[i, "Death"])
  out <- setNames(rep(NA, 11), c("after.death", "peak", "age.peak", "n.weigh", "last.weigh", "last.rel", "declined", "span", "span.lo",
                                 "span.hi", "rate.surcharge"))
  out[names(r)] <- r; out
}))
d <- cbind(mice, res)
cat("Weighings dated after death, dropped:", sum(d[, "after.death"], na.rm = TRUE), "\n")
cat("Mice with a peak at least 120 days before death:", sum(!is.na(d[, "span"])), "of", nrow(d), "\n")
d <- d[!is.na(d[, "span"]), ]
for (v in c("", ".lo", ".hi")) {                                   # decline days after X and cost, for the span and its bounds
  onset <- d[, "Death"] - d[, paste0("span", v)]
  d[, paste0("decline", v)] <- pmax(0, d[, "Death"] - pmax(onset, X)) * (d[, "Death"] > X)
}
d[, "pension"] <- pmax(0, d[, "Death"] - X)
for (s in c(1, 4, 10)) d[, paste0("cost", s)] <- d[, "pension"] + s * d[, "decline"]
d[, "cost.rate"] <- d[, "pension"] + d[, "rate.surcharge"]
write.table(d, "output/Terminal_decline_by_mouse.txt", sep = "\t", quote = FALSE, row.names = FALSE)
# Every weighing of these mice, as days before death and a fraction of the mouse's peak (for Fig. 12a)
key <- paste(ifelse(d[, "Type"] == "F1", "F1", "BXD"), d[, "EarTag"])
ww <- weights[paste(weights[, "Source"], weights[, "EarTag"]) %in% key, ]
i <- match(paste(ww[, "Source"], ww[, "EarTag"]), key)
ww <- data.frame(EarTag = ww[, "EarTag"], Source = ww[, "Source"], Genotype = d[i, "Genotype"], Diet = d[i, "Diet"], Type = d[i, "Type"],
                 Set = d[i, "Set"], before = d[i, "Death"] - ww[, "age"], rel = round(ww[, "w"] / d[i, "peak"], 4))
write.table(ww[ww[, "before"] >= 0, ], "output/Terminal_decline_weighings.txt", sep = "\t", quote = FALSE, row.names = FALSE)

# Are euthanized mice end-of-life deaths? Compare with natural deaths of the same group.
d[, "Group"] <- ifelse(d[, "Type"] == "F1", paste("F1", d[, "Set"]), ifelse(!is.na(d[, "Set"]), paste("Parents", d[, "Set"]), d[, "Type"]))
cat("\nNatural against euthanized deaths: median age at death, median last weight / peak, share in observed decline\n")
eu <- aggregate(cbind(Death, last.rel, declined) ~ Group + Recorded, d[d[, "Recorded"] %in% c("Natural", "Euthanized"), ],
                function(v) c(n = length(v), med = median(v), mean = mean(v)))
print(data.frame(eu[, 1:2], n = eu$Death[, "n"], death = eu$Death[, "med"], last.rel = round(eu$last.rel[, "med"], 2),
                 declined = round(eu$declined[, "mean"], 2)), row.names = FALSE)

tests <- c()
add <- function(q, subset, measure, est, lo, hi, p, units, note = "") {
  tests <<- rbind(tests, data.frame(question = q, subset = subset, measure = measure, estimate = round(est, 3), lo = round(lo, 3),
                                    hi = round(hi, 3), p = signif(p, 2), units = units, note = note))
}
jack <- function(stat, units) {                                    # delete-one-unit jackknife s.e.
  loo <- sapply(units, stat); n <- length(units)
  sqrt((n - 1) / n * sum((loo - mean(loo))^2))
}

for (subset in c("all", "natural")) {
  dd <- if (subset == "all") d else d[d[, "Status"] == "Natural", ]

  # Q1: across BXD strains, morbidity span against lifespan, from split halves
  for (diet in c("CD", "HF")) {
    x <- dd[dd[, "Type"] == "BXD" & dd[, "Diet"] == diet, ]
    for (v in c("span", "span.lo", "span.hi")) {
      ok <- names(which(table(x[, "Genotype"]) >= 6)); x1 <- x[x[, "Genotype"] %in% ok, ]
      g <- split(seq_len(nrow(x1)), x1[, "Genotype"])
      splits <- lapply(1:200, function(k) lapply(g, function(i) { h <- sample(i, floor(length(i) / 2)); list(a = h, b = setdiff(i, h)) }))
      LA <- sapply(splits, function(sp) sapply(sp, function(z) mean(x1[z$a, "Death"])))
      SB <- sapply(splits, function(sp) sapply(sp, function(z) mean(x1[z$b, v])))
      slope <- function(L, S) mean(colSums(sweep(L, 2, colMeans(L)) * sweep(S, 2, colMeans(S))) / colSums(sweep(L, 2, colMeans(L))^2))
      est <- slope(LA, SB)
      se <- jack(function(u) { k <- rownames(LA) != u; slope(LA[k, , drop = FALSE], SB[k, , drop = FALSE]) }, rownames(LA))
      null <- replicate(2000, { pi <- sample(nrow(SB)); slope(LA, SB[pi, , drop = FALSE]) })
      prop <- mean(x1[, v]) / mean(x1[, "Death"])
      add("Q1 span ~ lifespan, BXD strains (days per day)", subset, paste(v, diet), est, est - qt(0.975, length(g) - 1) * se,
          est + qt(0.975, length(g) - 1) * se, mean(abs(null) >= abs(est)), length(g), sprintf("proportional change predicts %.3f", prop))
    }
  }

  # Q2: F1s against their parents
  for (set in c("Short", "Long")) {
    x <- dd[!is.na(dd[, "Set"]) & dd[, "Set"] == set & dd[, "Type"] %in% c("F1", "BXD"), ]
    cells <- aggregate(cbind(span, span.lo, span.hi, decline, pension, cost4, cost1, cost10, cost.rate, Death, last.rel) ~ Genotype + Type + Diet, x,
                       mean)
    nn <- aggregate(span ~ Genotype + Type + Diet, x, length); cells <- cells[nn[, "span"] >= 3, ]
    geno <- unique(cells[, c("Genotype", "Type")])
    for (v in c("span", "span.lo", "span.hi", "decline", "pension", "cost4", "cost1", "cost10", "cost.rate", "Death", "last.rel")) {
      eff <- function(cc) { if (length(unique(cc[, "Type"])) < 2) return(NA); unname(coef(lm(cc[, v] ~ cc[, "Type"] + cc[, "Diet"]))[2]) }  # F1 minus parents (BXD is the reference level)
      est <- eff(cells)
      se <- jack(function(u) eff(cells[cells[, "Genotype"] != u, ]), geno[, "Genotype"])
      combos <- combn(nrow(geno), sum(geno[, "Type"] == "F1"))       # exact permutation of the type labels across genotypes
      null <- apply(combos, 2, function(k) { ty <- setNames(ifelse(seq_len(nrow(geno)) %in% k, "F1", "BXD"), geno[, "Genotype"])
                                             cc <- cells; cc[, "Type"] <- ty[cc[, "Genotype"]]; eff(cc) })
      add(paste("Q2 F1 minus parents,", set), subset, v, est, est - qt(0.975, nrow(geno) - 1) * se, est + qt(0.975, nrow(geno) - 1) * se,
          mean(abs(null) >= abs(est) - 1e-9), nrow(geno), sprintf("%d F1 types, %d parents", sum(geno[, "Type"] == "F1"), sum(geno[, "Type"] == "BXD")))
    }
  }

  # Q3: high fat against chow, within BXD strains
  x <- dd[dd[, "Type"] == "BXD", ]
  for (v in c("span", "span.lo", "span.hi", "decline", "pension", "cost4", "Death", "last.rel")) {
    mm <- tapply(x[, v], list(x[, "Genotype"], x[, "Diet"]), mean); nn <- table(x[, "Genotype"], x[, "Diet"])
    ok <- rownames(nn)[nn[, "CD"] >= 3 & nn[, "HF"] >= 3]; dif <- mm[ok, "HF"] - mm[ok, "CD"]
    est <- mean(dif); se <- sd(dif) / sqrt(length(dif))
    null <- replicate(10000, mean(dif * sample(c(-1, 1), length(dif), replace = TRUE)))
    add("Q3 HF minus CD, within BXD strains", subset, v, est, est - qt(0.975, length(dif) - 1) * se, est + qt(0.975, length(dif) - 1) * se,
        mean(abs(null) >= abs(est)), length(dif))
  }
}
write.table(tests, "output/Terminal_decline_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\n"); print(tests, row.names = FALSE)

# Q4: per diem cost by group (means over mice), and the euthanasia rate
d[, "GroupDiet"] <- paste(d[, "Group"], d[, "Diet"])
cost <- do.call(rbind, lapply(split(d, d[, "GroupDiet"]), function(x) data.frame(
  group = x[1, "Group"], diet = x[1, "Diet"], mice = nrow(x), genotypes = length(unique(x[, "Genotype"])),
  euthanized = round(mean(x[, "Recorded"] == "Euthanized"), 2), died.before.X = round(mean(x[, "Death"] < X), 2),
  median.death = median(x[, "Death"]), median.span = median(x[, "span"]), declined = round(mean(x[, "declined"]), 2),
  last.weigh.to.death = median(x[, "Death"] - x[, "last.weigh"]),
  pension = round(mean(x[, "pension"])), decline.days = round(mean(x[, "decline"])), cost1 = round(mean(x[, "cost1"])),
  cost4 = round(mean(x[, "cost4"])), cost10 = round(mean(x[, "cost10"])), cost.rate = round(mean(x[, "cost.rate"])),
  surcharge.share4 = round(mean(4 * x[, "decline"]) / mean(x[, "cost4"]), 2))))
write.table(cost, "output/Terminal_decline_cost.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nPer diem cost by group (means per mouse; s = 4 unless named):\n"); print(cost, row.names = FALSE)

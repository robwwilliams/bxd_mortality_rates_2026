#
# MRDT_Secondary.R
#
# copyright (c) 2026 - Rob Williams
#
# The two pre-registered secondary tests (notes/PREREGISTRATION_secondary.md, registered 24 October 2026):
#   H1: BXD strains D across proximal Chr 1 (3-30 Mb) against strains B across it. Two-tailed, alpha 0.025.
#   H2: BXD x BXD F1 hybrids, pooled, against their inbred parents, pooled. One-tailed (F1 MRDT longer), alpha 0.025.
# and the pre-specified secondary analyses S1-S6 and the gamma-Gompertz sensitivity analysis.
#
# Model: each class has one MRDT, shared by its diets; each class x diet cell has its own level, reported as the
# hazard at 600 d. Females that survived to 200 d; each mouse is at risk from the later of its set-up age and 200 d.
# delta = log2(MRDT of the second class / MRDT of the first). Its s.e. comes from a delete-one-strain jackknife
# (for H2, delete one genotype: an F1 type or a parental strain), and P from t = delta / s.e. on (units - 1) df.
#
# Run from the repository root:  Rscript Gompertz/MRDT_Secondary.R
#

library(readxl)

source("Gompertz/gompertz.R")

# Suheeta Roy's curated file: BXD strains, parents and B6D2 F1s, with set-up ages
mdata <- read_excel("data/original/BXD_Mortality_for_Mapping_Arends.xlsx", skip = 9, .name_repair = "minimal")
mdata <- as.data.frame(mdata[, 1:7])
colnames(mdata) <- c("Index", "EarTag", "Diet", "Strain", "Age", "SetupAge", "Vivarium")
mdata <- mdata[!is.na(mdata[, "EarTag"]), ]

# Chr 1 haplotype calls, fixed at registration
hap <- read.delim("output/Chr1_haplotypes.txt")
hap <- hap[!duplicated(hap[, "Strain"]), ]
mdata[, "Chr1"] <- hap[match(mdata[, "Strain"], hap[, "Strain"]), "Chr1.0to30Mb"]
mdata[, "Pair"] <- paste0(hap[match(mdata[, "Strain"], hap[, "Strain"]), "Vita1a.4.5Mb"], "-",
                          hap[match(mdata[, "Strain"], hap[, "Strain"]), "Vita1b.24Mb"])

# BXD x BXD F1s from the GeneNetwork export (no set-up ages: all were set up at weaning)
export <- read_excel("data/original/BDL_10002.xlsx", skip = 10, col_types = "text", .name_repair = "minimal")
export <- as.data.frame(export)
f1 <- export[grepl("^BXD.*[xX]BXD.*F1$", export[, "Strain"]) & export[, "Sex"] == "F" & export[, "Tx"] %in% c("CD", "HF"), ]
f1[, "Strain"] <- sub("XBXD", "xBXD", f1[, "Strain"])            # one spelling variant: BXD065XBXD102F1
f1 <- data.frame(Strain = f1[, "Strain"], Diet = f1[, "Tx"], Age = suppressWarnings(as.numeric(f1[, "Value"])), SetupAge = 21)   # harvested: x
f1 <- f1[!is.na(f1[, "Age"]), ]

short.parents <- c("BXD9", "BXD170", "BXD172", "BXD197")
long.parents <- c("BXD65", "BXD73b", "BXD77", "BXD102")
f1.parents <- function(s) sub("^BXD0*", "BXD", regmatches(s, gregexpr("BXD0*[0-9]+[a-wyz]?", s))[[1]])   # not x: it joins the parents
f1[, "Group"] <- sapply(f1[, "Strain"], function(s) {
  p <- f1.parents(s)
  if (all(p %in% short.parents)) "Short" else if (all(p %in% long.parents)) "Long" else NA
})
cat("F1 females by type:\n"); print(table(f1[, "Strain"], f1[, "Diet"]))
stopifnot(!any(is.na(f1[, "Group"])))

parents <- mdata[mdata[, "Strain"] %in% c(short.parents, long.parents) & mdata[, "Diet"] %in% c("CD", "HF"), ]
parents[, "Group"] <- ifelse(parents[, "Strain"] %in% short.parents, "Short", "Long")

# Keep mice alive at 'from'; each is at risk from the later of its set-up age and 'from'
from.age <- function(d, from) {
  d <- d[d[, "Age"] >= from, ]
  d[, "entry"] <- pmax(d[, "SetupAge"], from)
  d
}

# One comparison of two classes. d needs Age, entry, Diet, Class (factor: first level is the reference) and Unit.
# tails = 2, or 1 for the one-tailed prediction delta > 0. jack = FALSE when there are too few units.
compare.row <- function(name, d, from, tails = 2, jack = TRUE) {
  cmp <- gompertz.classes.compare(d[, "Age"], d[, "entry"], d[, "Diet"], d[, "Class"])
  lv <- levels(d[, "Class"]); f1 <- cmp$fits[[1]]; f2 <- cmp$fits[[2]]
  units <- tapply(d[, "Unit"], d[, "Class"], function(x) length(unique(x)))
  row <- data.frame(test = name, from = from, class1 = lv[1], class2 = lv[2],
                    n1 = f1$n, n2 = f2$n, units1 = units[lv[1]], units2 = units[lv[2]],
                    MRDT1 = f1$MRDT, MRDT1.lo = f1$MRDT.lo, MRDT1.hi = f1$MRDT.hi,
                    MRDT2 = f2$MRDT, MRDT2.lo = f2$MRDT.lo, MRDT2.hi = f2$MRDT.hi,
                    delta = cmp$delta, delta.se.wald = cmp$delta.se, p.lrt = unname(cmp$lrt["p"]))
  if (jack) {
    jk <- gompertz.jackknife(d[, "Age"], d[, "entry"], d[, "Diet"], d[, "Class"], d[, "Unit"])
    t <- cmp$delta / jk$se; df <- jk$n - 1
    row <- cbind(row, data.frame(delta.se.jack = jk$se, delta.lo = cmp$delta - qt(0.975, df) * jk$se,
                                 delta.hi = cmp$delta + qt(0.975, df) * jk$se, t = t, df = df,
                                 p = if (tails == 2) 2 * pt(-abs(t), df) else pt(t, df, lower.tail = FALSE)))
    attr(row, "loo") <- jk$loo
  } else {
    row <- cbind(row, data.frame(delta.se.jack = NA, delta.lo = cmp$delta - 1.96 * cmp$delta.se,
                                 delta.hi = cmp$delta + 1.96 * cmp$delta.se, t = NA, df = NA, p = NA))
  }
  attr(row, "levels") <- rbind(data.frame(class = lv[1], cell = names(f1$h.ref), n = as.numeric(f1$n.cell),
                                          h600.per1000 = 1000 * as.numeric(f1$h.ref)),
                               data.frame(class = lv[2], cell = names(f2$h.ref), n = as.numeric(f2$n.cell),
                                          h600.per1000 = 1000 * as.numeric(f2$h.ref)))
  return(row)
}

# The two data sets of the primary tests, at a given starting age
h1.data <- function(from, diets = c("CD", "HF")) {
  d <- mdata[grepl("^BXD", mdata[, "Strain"]) & mdata[, "Chr1"] %in% c("B", "D") & mdata[, "Diet"] %in% diets, ]
  d <- from.age(d, from)
  d[, "Class"] <- factor(d[, "Chr1"], levels = c("B", "D")); d[, "Unit"] <- d[, "Strain"]
  d
}
h2.data <- function(from, groups = c("Short", "Long")) {
  p <- parents[parents[, "Group"] %in% groups, c("Strain", "Diet", "Age", "SetupAge", "Group")]
  f <- f1[f1[, "Group"] %in% groups, c("Strain", "Diet", "Age", "SetupAge", "Group")]
  d <- rbind(data.frame(p, Class = "Parents"), data.frame(f, Class = "F1"))
  d <- from.age(d, from)
  d[, "Class"] <- factor(d[, "Class"], levels = c("Parents", "F1")); d[, "Unit"] <- d[, "Strain"]
  d
}

tests <- c(); levels.out <- c(); loo.out <- c()
add <- function(row, label = row[1, "test"]) {
  tests <<- rbind(tests, row)
  levels.out <<- rbind(levels.out, data.frame(test = label, from = row[1, "from"], attr(row, "levels")))
  if (!is.null(attr(row, "loo"))) loo.out <<- rbind(loo.out, data.frame(test = label, from = row[1, "from"],
                                                                          dropped = names(attr(row, "loo")),
                                                                          delta = as.numeric(attr(row, "loo"))))
}

# Primary tests (from 200 d), and S6: the same from 0 d and from 365 d
for (from in c(200, 0, 365)) {
  add(compare.row("H1 Chr1 D vs B", h1.data(from), from, tails = 2))
  add(compare.row("H2 F1 vs parents", h2.data(from), from, tails = 1))
}

# S1: short-by-short F1s against the short-lived parents; long-by-long against the long-lived parents
add(compare.row("S1 short F1 vs short parents", h2.data(200, "Short"), 200))
add(compare.row("S1 long F1 vs long parents", h2.data(200, "Long"), 200))

# S2: B6D2F1 and D2B6F1 against C57BL/6J and DBA/2J (four genotypes: Wald interval, no jackknife)
s2 <- mdata[mdata[, "Strain"] %in% c("C57BL/6J", "DBA/2J", "B6D2F1", "D2B6F1") & mdata[, "Diet"] %in% c("CD", "HF"), ]
s2 <- from.age(s2, 200)
s2[, "Class"] <- factor(ifelse(s2[, "Strain"] %in% c("B6D2F1", "D2B6F1"), "F1", "Parents"), levels = c("Parents", "F1"))
s2[, "Unit"] <- s2[, "Strain"]
add(compare.row("S2 B6D2 F1s vs B6 and D2", s2, 200, jack = FALSE))

# S3: recombinant strains by genotype near the Vita1a (4.5 Mb) and Vita1b (24 Mb) peaks
rec <- mdata[grepl("^BXD", mdata[, "Strain"]) & mdata[, "Chr1"] %in% "Recombinant" & mdata[, "Diet"] %in% c("CD", "HF"), ]
rec <- from.age(rec, 200)
rec[, "Unit"] <- rec[, "Strain"]
for (pr in c("B-D", "D-B")) {
  d <- rbind(h1.data(200)[h1.data(200)[, "Chr1"] == "B", ], transform(rec[rec[, "Pair"] == pr, ], Chr1 = pr, Class = NA))
  d[, "Class"] <- factor(d[, "Chr1"], levels = c("B", pr))
  add(compare.row(paste0("S3 recombinant ", pr, " vs B"), d, 200))
}

# S4: haplotype x diet. delta on each diet alone, and their difference with a strain jackknife over both diets
for (diet in c("CD", "HF")) add(compare.row(paste0("S4 Chr1 D vs B, ", diet, " only"), h1.data(200, diet), 200))
d4 <- h1.data(200)
inter <- function(d) {
  dl <- sapply(c("CD", "HF"), function(x) { s <- d[, "Diet"] == x
    gompertz.classes.compare(d[s, "Age"], d[s, "entry"], d[s, "Diet"], d[s, "Class"])$delta })
  unname(dl["HF"] - dl["CD"])
}
i.est <- inter(d4)
i.loo <- sapply(unique(d4[, "Unit"]), function(u) inter(d4[d4[, "Unit"] != u, ]))
i.n <- length(i.loo); i.se <- sqrt((i.n - 1) / i.n * sum((i.loo - mean(i.loo))^2))
interaction <- data.frame(test = "S4 haplotype x diet: delta(HF) - delta(CD)", estimate = i.est, se.jack = i.se,
                          lo = i.est - qt(0.975, i.n - 1) * i.se, hi = i.est + qt(0.975, i.n - 1) * i.se, units = i.n)
print(interaction, digits = 3)

# S5: HF + 1% NAM females by haplotype (descriptive)
add(compare.row("S5 NAM: Chr1 D vs B", h1.data(200, "NAM"), 200))

# Sensitivity: gamma-Gompertz refit of H1 and H2 (from 200 d)
gg <- c()
for (nm in c("H1 Chr1 D vs B", "H2 F1 vs parents")) {
  d <- if (grepl("^H1", nm)) h1.data(200) else h2.data(200)
  sep <- gammagompertz.fit(d[, "Age"], d[, "entry"], d[, "Diet"], d[, "Class"])
  shr <- gammagompertz.fit(d[, "Age"], d[, "entry"], d[, "Diet"], d[, "Class"], shared.b = TRUE)
  gomp <- gompertz.classes.compare(d[, "Age"], d[, "entry"], d[, "Diet"], d[, "Class"])
  x2 <- 2 * (sep$logLik - shr$logLik)
  lv <- levels(d[, "Class"])
  gg <- rbind(gg, data.frame(test = nm, class1 = lv[1], class2 = lv[2],
                             MRDT1.individual = sep$MRDT[lv[1]], MRDT2.individual = sep$MRDT[lv[2]],
                             s2.1 = sep$s2[lv[1]], s2.2 = sep$s2[lv[2]],
                             delta = log2(sep$MRDT[lv[2]] / sep$MRDT[lv[1]]), p.lrt = pchisq(x2, 1, lower.tail = FALSE),
                             logLik.gamma = sep$logLik, logLik.gompertz = gomp$fits[[1]]$logLik + gomp$fits[[2]]$logLik,
                             converged = sep$convergence == 0 && shr$convergence == 0))
}

# Exploratory, added after the registered results were seen (not part of the registration): the same comparisons with
# a level for each genotype x diet cell rather than each class x diet cell. Pooling strains of different levels into
# one class flattens its curve, and the inbred parents differ from one another more than the F1 types do.
pergeno <- function(name, d, tails = 2) {
  d[, "Diet"] <- paste(d[, "Strain"], d[, "Diet"])
  compare.row(name, d, 200, tails)[, c("test", "from", "class1", "class2", "n1", "n2", "units1", "units2", "MRDT1", "MRDT1.lo",
                                       "MRDT1.hi", "MRDT2", "MRDT2.lo", "MRDT2.hi", "delta", "delta.lo", "delta.hi", "p", "p.lrt")]
}
exploratory <- rbind(pergeno("E1 H1 with a level for each strain", h1.data(200)),
                     pergeno("E1 H2 with a level for each genotype", h2.data(200), tails = 1),
                     pergeno("E1 S1 short, a level for each genotype", h2.data(200, "Short")),
                     pergeno("E1 S1 long, a level for each genotype", h2.data(200, "Long")))
rownames(exploratory) <- NULL
print(exploratory[, c("test", "MRDT1", "MRDT2", "delta", "delta.lo", "delta.hi", "p")], digits = 3)

# Occurrence/exposure rates in 60-day bins from 200 d, by class and diet, for the figures
binned <- c()
for (nm in c("H1", "H2")) {
  d <- if (nm == "H1") h1.data(200) else h2.data(200)
  for (k in levels(d[, "Class"])) for (diet in c("CD", "HF")) {
    s <- d[, "Class"] == k & d[, "Diet"] == diet
    binned <- rbind(binned, data.frame(test = nm, class = k, diet = diet,
                                       gompertz.binned(d[s, "Age"], d[s, "entry"], width = 60, from = 200, to = 1200)))
  }
}

rownames(tests) <- NULL; rownames(gg) <- NULL
print(tests[, c("test", "from", "n1", "n2", "units1", "units2", "MRDT1", "MRDT2", "delta", "delta.lo", "delta.hi", "p", "p.lrt")], digits = 3)
print(gg, digits = 3)

write.table(tests, "output/MRDT_secondary_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(levels.out, "output/MRDT_secondary_levels.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(loo.out, "output/MRDT_secondary_jackknife.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(interaction, "output/MRDT_secondary_interaction.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(gg, "output/MRDT_secondary_gammagompertz.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(exploratory, "output/MRDT_exploratory_pergenotype.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(binned, "output/MRDT_secondary_binned_60d.txt", sep = "\t", quote = FALSE, row.names = FALSE)

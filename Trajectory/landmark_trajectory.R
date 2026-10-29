#
# landmark_trajectory.R
#
# copyright (c) 2026 - Rob Williams
#
# Do early body-weight trajectories predict survival in BXD females once the weight loss before death is kept out?
# As set out in notes/PLAN_landmark_trajectory.md, written by Claude before any model was fitted (29 October 2026);
# Rob asked for it to be run on the full BXD data without reviewing the plan first.
#   Class model: lcmm::hlme of weight (g); common fixed effects diet, diet x t, diet x t^2, t = (age - 365) / 365;
#                class-specific intercept, t and t^2; random intercept and t (unstructured, proportional across
#                classes); 1-4 classes, gridsearch from the one-class fit; lowest BIC with every class >= 5%.
#   A1  landmark L = 365 d, gap g = 120 d (primary); A2  L = 365 d, no gap; A3  L = 545 d, g = 120 d.
#       P1 class, Cox stratified by diet, robust by strain; P2 class within strain x diet strata; P3 class over the
#       last weight before L; P4 posterior probability of the high-gain class split into strain x diet mean
#       (delete-one-strain jackknife) and deviation (robust).
#   B1  classes from whole weight records; B2  the same without weighings in the last 120 days before the end age.
#   S1  A1 with Other and LowOutlier mice excluded rather than censored.
#   E1, E2 (exploratory, added after the first results were seen): the B1 and B2 classes tested in the A1 mice, with
#       survival counted from 485 days.
#
# Run from the repository root:  Rscript Trajectory/landmark_trajectory.R > output/Landmark_trajectory.log
# Writes output/Landmark_models.txt, _classes.txt, _tests.txt and _mice.txt (one row per mouse per analysis)
#

library(readxl)
library(survival)
library(lcmm)
library(parallel)

seed <- 20261029
num <- function(v) suppressWarnings(as.numeric(v))

# Mice and weighings
b <- suppressWarnings(as.data.frame(read_excel("data/original/AgingBXD_BodyWeightData_updated31Dec2024.xlsx", sheet = "BXD_Females",
                                               .name_repair = "minimal")))
b <- b[!is.na(b[, "EarTagNumberCurrent"]), ]
mice <- data.frame(EarTag = b[, "EarTagNumberCurrent"], Genotype = b[, "StrainName"], Diet = b[, "Diet"], Status = b[, "Status"],
                   Setup = num(b[, "AgeAtSetUp"]), End = num(b[, "AgeAtDeath"]))
mice[, "event"] <- as.integer(mice[, "Status"] %in% c("Natural", "Euthanized"))
W <- do.call(rbind, c(list(data.frame(EarTag = mice[, "EarTag"], age = num(b[, "AgeAtSetUp"]), wt = num(b[, "Weight00 Baseline"]))),
                      lapply(1:20, function(j) data.frame(EarTag = mice[, "EarTag"], age = num(b[, sprintf("AgeAtWeight%02d", j)]),
                                                         wt = num(b[, sprintf("Weight%02d", j)])))))
W <- W[!is.na(W[, "age"]) & !is.na(W[, "wt"]), ]
fl <- read.delim("qc/BodyWeight_flags.txt", quote = "")
fl <- fl[fl[, "Workbook"] == "BXD", ]
flagged <- paste(W[, "EarTag"], W[, "age"]) %in% paste(fl[, "EarTag"], fl[, "Age"])
W[, "End"] <- mice[match(W[, "EarTag"], mice[, "EarTag"]), "End"]
W[, "Diet"] <- mice[match(W[, "EarTag"], mice[, "EarTag"]), "Diet"]
cat("Mice:", nrow(mice), "; deaths:", sum(mice[, "event"]), "; status:\n"); print(table(mice[, "Status"]))
cat("Weighings:", nrow(W), "; flagged and dropped:", sum(flagged), "; outside 10-100 g:", sum(!flagged & (W[, "wt"] < 10 | W[, "wt"] > 100)),
    "; after the end age:", sum(!flagged & W[, "wt"] >= 10 & W[, "wt"] <= 100 & W[, "age"] > W[, "End"]), "\n")
W <- W[!flagged & W[, "wt"] >= 10 & W[, "wt"] <= 100 & !is.na(W[, "End"]) & W[, "age"] <= W[, "End"], ]

# Class model: 1-4 classes, lowest BIC among converged fits with every class >= 5%
# gridsearch evaluates its call in the global environment, so the data and the one-class fit are put there
fit.classes <- function(w) {
  w <- w[order(w[, "id"], w[, "age"]), ]
  w[, "t"] <- (w[, "age"] - 365) / 365; w[, "t2"] <- w[, "t"]^2; w[, "hf"] <- as.numeric(w[, "Diet"] == "HF")
  assign("lc.data", w, envir = .GlobalEnv)
  set.seed(seed)
  m1 <- hlme(wt ~ t + t2 + hf + hf:t + hf:t2, random = ~ 1 + t, subject = "id", ng = 1, data = lc.data, verbose = FALSE)
  assign("lc.m1", m1, envir = .GlobalEnv)
  fits <- list(m1)
  for (G in 2:4) {
    set.seed(seed + G)
    fits[[G]] <- tryCatch(eval(substitute(gridsearch(rep = 20, maxiter = 30, minit = lc.m1,
                   hlme(wt ~ t + t2 + hf + hf:t + hf:t2, mixture = ~ t + t2, random = ~ 1 + t, subject = "id", ng = GG, nwg = TRUE,
                        data = lc.data, verbose = FALSE)), list(GG = G)), envir = .GlobalEnv), error = function(e) NULL)
  }
  tab <- do.call(rbind, lapply(1:4, function(G) {
    m <- fits[[G]]
    if (is.null(m)) return(data.frame(G = G, conv = NA, loglik = NA, BIC = NA, min.share = NA))
    data.frame(G = G, conv = m$conv, loglik = round(m$loglik, 1), BIC = round(m$BIC, 1),
               min.share = round(min(tabulate(m$pprob[, "class"], G)) / nrow(m$pprob), 3))
  }))
  ok <- which(tab[, "conv"] %in% 1 & tab[, "min.share"] >= 0.05)
  best <- ok[which.min(tab[ok, "BIC"])]
  tab[, "selected"] <- seq_len(4) == best
  list(model = fits[[best]], table = tab, data = w)
}

# Mean chow trajectory of each class, at the given ages
class.curves <- function(m, ages) {
  nd <- data.frame(t = (ages - 365) / 365); nd[, "t2"] <- nd[, "t"]^2; nd[, "hf"] <- 0
  p <- predictY(m, newdata = nd, var.time = "t")$pred
  matrix(p, nrow = length(ages), dimnames = list(ages, paste0("class", seq_len(ncol(as.matrix(p))))))
}

# Cox tests of class (P1-P4) on per-mouse data d with entry, End, event, cls, Genotype, Diet, wz, phg
cox.tests <- function(d, label) {
  d[, "cls"] <- relevel(factor(d[, "cls"]), ref = names(which.max(table(d[, "cls"]))))
  G <- nlevels(d[, "cls"])
  out <- data.frame(analysis = label, mice = nrow(d), deaths = sum(d[, "event"]), strains = length(unique(d[, "Genotype"])), classes = G)
  if (G < 2) return(list(tests = out, hr = NULL))
  f1 <- coxph(Surv(entry, End, event) ~ cls + strata(Diet), d, cluster = Genotype)
  bb <- coef(f1); wald <- as.numeric(t(bb) %*% solve(vcov(f1)) %*% bb)
  out[, c("P1.wald", "P1.df", "P1.P", "concordance")] <- list(round(wald, 2), G - 1, signif(pchisq(wald, G - 1, lower.tail = FALSE), 3),
                                                               round(unname(f1$concordance["concordance"]), 3))
  f2 <- coxph(Surv(entry, End, event) ~ cls + strata(Genotype, Diet), d)
  lr2 <- 2 * diff(f2$loglik)
  out[, c("P2.LR", "P2.P")] <- list(round(lr2, 2), signif(pchisq(lr2, G - 1, lower.tail = FALSE), 3))
  f3a <- coxph(Surv(entry, End, event) ~ wz + strata(Diet), d); f3b <- coxph(Surv(entry, End, event) ~ wz + cls + strata(Diet), d)
  lr3 <- 2 * (f3b$loglik[2] - f3a$loglik[2])
  out[, c("weight.HR.perSD", "weight.P", "P3.LR", "P3.P")] <- list(round(exp(coef(f3a)), 3), signif(summary(f3a)$coefficients[, "Pr(>|z|)"], 3),
                                                                   round(lr3, 2), signif(pchisq(lr3, G - 1, lower.tail = FALSE), 3))
  if (!is.null(d[["phg"]])) {
    d[, "xb"] <- ave(d[, "phg"], d[, "Genotype"], d[, "Diet"]); d[, "xw"] <- d[, "phg"] - d[, "xb"]
    f4 <- coxph(Surv(entry, End, event) ~ xb + xw + strata(Diet), d, cluster = Genotype)
    s <- unique(d[, "Genotype"]); n <- length(s)
    th <- sapply(s, function(g) coef(coxph(Surv(entry, End, event) ~ xb + xw + strata(Diet), d[d[, "Genotype"] != g, ]))["xb"])
    se <- sqrt((n - 1) / n * sum((th - mean(th))^2)); est <- coef(f4)["xb"]; q <- qt(0.975, n - 1)
    out[, c("P4.between.HR", "P4.between.lo", "P4.between.hi", "P4.between.P")] <- list(round(exp(est), 3), round(exp(est - q * se), 3),
                                                                                   round(exp(est + q * se), 3), signif(2 * pt(-abs(est / se), n - 1), 3))
    sw <- summary(f4)$coefficients["xw", ]
    out[, c("P4.within.HR", "P4.within.lo", "P4.within.hi", "P4.within.P")] <- list(round(exp(sw["coef"]), 3), round(exp(sw["coef"] - 1.96 * sw["robust se"]), 3),
                                                                                round(exp(sw["coef"] + 1.96 * sw["robust se"]), 3), signif(sw["Pr(>|z|)"], 3))
  }
  sc <- summary(f1)$coefficients
  hr <- data.frame(analysis = label, class = sub("^cls", "", rownames(sc)), ref = levels(d[, "cls"])[1], HR = round(exp(sc[, "coef"]), 3),
                   lo = round(exp(sc[, "coef"] - 1.96 * sc[, "robust se"]), 3), hi = round(exp(sc[, "coef"] + 1.96 * sc[, "robust se"]), 3),
                   P = signif(sc[, "Pr(>|z|)"], 3))
  list(tests = out, hr = hr)
}

# Class sizes, deaths, Kaplan-Meier medians from entry and mean chow trajectories
class.table <- function(d, m, label, ages) {
  km <- summary(survfit(Surv(entry, End, event) ~ cls, d))$table
  cc <- class.curves(m, ages)
  do.call(rbind, lapply(seq_len(m$ng), function(k) {
    i <- d[, "cls"] == k
    r <- data.frame(analysis = label, class = k, mice = sum(i), share = round(mean(i), 3), deaths = sum(d[i, "event"]),
                    KM.median = if (m$ng > 1) km[paste0("cls=", k), "median"] else km["median"])
    cbind(r, t(setNames(round(cc[, k], 1), paste0("w", ages))))
  }))
}

# One landmark analysis
landmark <- function(label, L, g, gain.to, mm = mice) {
  pre <- W[W[, "age"] < L & W[, "EarTag"] %in% mm[, "EarTag"], ]
  n.pre <- table(pre[, "EarTag"])
  use <- mm[mm[, "EarTag"] %in% names(n.pre)[n.pre >= 3] & mm[, "End"] > L + g, ]
  pre <- pre[pre[, "EarTag"] %in% use[, "EarTag"], ]
  pre[, "id"] <- match(pre[, "EarTag"], use[, "EarTag"])
  fc <- fit.classes(pre); m <- fc$model
  d <- use; d[, "entry"] <- L + g; d[, "cls"] <- m$pprob[match(seq_len(nrow(use)), m$pprob[, "id"]), "class"]
  last <- pre[order(pre[, "id"], -pre[, "age"]), ]; last <- last[!duplicated(last[, "id"]), ]
  d[, "wlast"] <- last[match(seq_len(nrow(use)), last[, "id"]), "wt"]
  d[, "wz"] <- ave(d[, "wlast"], d[, "Diet"], FUN = function(x) (x - mean(x)) / sd(x))
  if (m$ng > 1) {
    cc <- class.curves(m, c(120, gain.to)); hg <- which.max(cc[2, ] - cc[1, ])
    d[, "phg"] <- m$pprob[match(seq_len(nrow(use)), m$pprob[, "id"]), paste0("prob", hg)]
  }
  ct <- cox.tests(d, label)
  if (m$ng > 1) ct$tests[, "high.gain.class"] <- hg
  list(models = cbind(analysis = label, fc$table), tests = ct$tests, hr = ct$hr, mice = cbind(analysis = label, d),
       classes = class.table(d, m, label, sort(unique(c(120, 240, L, gain.to)))))
}

# One whole-record analysis, optionally without the last 120 days before the end age
whole <- function(label, trim) {
  w <- W
  if (trim) w <- w[w[, "age"] <= w[, "End"] - 120, ]
  n.w <- table(w[, "EarTag"])
  use <- mice[which(mice[, "EarTag"] %in% names(n.w)[n.w >= 3] & mice[, "End"] > mice[, "Setup"]), ]   # two mice lack a set-up age
  w <- w[w[, "EarTag"] %in% use[, "EarTag"], ]
  w[, "id"] <- match(w[, "EarTag"], use[, "EarTag"])
  fc <- fit.classes(w); m <- fc$model
  d <- use; d[, "entry"] <- d[, "Setup"]; d[, "cls"] <- m$pprob[match(seq_len(nrow(use)), m$pprob[, "id"]), "class"]
  first <- w[order(w[, "id"], w[, "age"]), ]; first <- first[!duplicated(first[, "id"]), ]
  d[, "wz"] <- ave(first[match(seq_len(nrow(use)), first[, "id"]), "wt"], d[, "Diet"], FUN = function(x) (x - mean(x)) / sd(x))
  ct <- cox.tests(d, label)
  if (m$ng > 1) {
    ages <- seq(60, 1300, 5); cc <- class.curves(m, ages)
    peak <- ages[apply(cc, 2, which.max)]; ep <- which.min(peak)
    ct$tests[, "early.peak.class"] <- ep
    ct$tests[, "class.peak.ages"] <- paste(peak, collapse = "/")
  }
  list(models = cbind(analysis = label, fc$table), tests = ct$tests, hr = ct$hr, mice = cbind(analysis = label, d),
       classes = class.table(d, m, label, c(120, 365, 545, 730, 900)))
}

runs <- list(A1 = function() landmark("A1 L365 g120", 365, 120, 365),
             A2 = function() landmark("A2 L365 g0", 365, 0, 365),
             A3 = function() landmark("A3 L545 g120", 545, 120, 545),
             S1 = function() landmark("S1 A1 without Other/LowOutlier", 365, 120, 365, mice[!mice[, "Status"] %in% c("Other", "LowOutlier"), ]),
             B1 = function() whole("B1 whole record", FALSE),
             B2 = function() whole("B2 whole record minus last 120 d", TRUE))
res <- mclapply(runs, function(f) tryCatch(f(), error = function(e) list(error = conditionMessage(e))), mc.cores = length(runs))
for (k in names(res)) if (!is.null(res[[k]]$error)) cat("ERROR in", k, ":", res[[k]]$error, "\n")
res <- res[sapply(res, function(r) is.null(r$error))]

# Exploratory, added on 29 October 2026 after the first results were seen: classes from whole records (B1) and from
# whole records without the last 120 days (B2), tested in the A1 mice with survival counted from 485 days, so that the
# mice and the outcome window match A1 and only the weighings used for the classes differ
for (k in c("B1", "B2")) {
  d <- res[[k]]$mice; d <- d[d[, "EarTag"] %in% res$A1$mice[, "EarTag"], ]; d[, "entry"] <- 365 + 120
  d[, "wz"] <- res$A1$mice[match(d[, "EarTag"], res$A1$mice[, "EarTag"]), "wz"]; d[["phg"]] <- NULL
  ct <- cox.tests(d, paste0("E", substring(k, 2), " ", k, " classes, A1 mice from 485 d"))
  res[[paste0("E", substring(k, 2))]] <- list(tests = ct$tests, hr = ct$hr)
}

bind <- function(part) { x <- lapply(res, `[[`, part); x <- x[!sapply(x, is.null)]; nm <- unique(unlist(lapply(x, names)))
  do.call(rbind, lapply(x, function(y) { y[setdiff(nm, names(y))] <- NA; y[nm] })) }
models <- bind("models"); tests <- bind("tests"); hr <- bind("hr"); classes <- bind("classes")
write.table(bind("mice")[, c("analysis", "EarTag", "Genotype", "Diet", "Status", "entry", "End", "event", "cls", "wz", "phg")],
            "output/Landmark_mice.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(models, "output/Landmark_models.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(classes, "output/Landmark_classes.txt", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(merge(tests, hr, all = TRUE), "output/Landmark_tests.txt", sep = "\t", quote = FALSE, row.names = FALSE)
cat("\nClass models\n"); print(models, row.names = FALSE)
cat("\nClasses\n"); print(classes, row.names = FALSE)
cat("\nTests\n"); print(t(tests))
cat("\nHazard ratios against the largest class (robust 95% CI)\n"); print(hr, row.names = FALSE)
cat("\nR", R.version$major, R.version$minor, "; lcmm", as.character(packageVersion("lcmm")), "; survival", as.character(packageVersion("survival")), "\n")

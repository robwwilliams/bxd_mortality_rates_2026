#
# gompertz.R
#
# copyright (c) 2026 - Rob Williams
#
# Functions to fit the Gompertz (and Gompertz-Makeham) mortality law to ages at death by maximum likelihood.
# Each animal is at risk only from the age it entered the study (left truncation), so ages at set up are used.
#
#   hazard:   h(t) = a * exp(b * t) + c        (c = 0 for plain Gompertz; t in days)
#   MRDT:     log(2) / b                       (mortality rate doubling time, days)
#   base 2:   h(t) = R0 * 2^(t / MRDT) + c     (the same law; R0 = a, and mortality doubles every MRDT days)
#
# Parameters are fitted on the log scale, p = c(log(a), log(b)[, log(c)]), so a, b and c stay positive.
#

# Cumulative hazard from 0 to t
gompertz.H <- function(t, a, b, c = 0) {
  (a / b) * expm1(b * t) + c * t       # expm1 keeps H accurate when b * t is tiny
}

# Negative log-likelihood of ages at death (all deaths observed), left truncated at entry
gompertz.nll <- function(p, age, entry, makeham = FALSE) {
  a <- exp(p[1]); b <- exp(p[2]); c <- if (makeham) exp(p[3]) else 0
  h <- a * exp(b * age) + c
  -sum(log(h) - (gompertz.H(age, a, b, c) - gompertz.H(entry, a, b, c)))
}

# Gradient of gompertz.nll with respect to p (analytic, so BFGS never relies on finite differences)
gompertz.gr <- function(p, age, entry, makeham = FALSE) {
  a <- exp(p[1]); b <- exp(p[2]); c <- if (makeham) exp(p[3]) else 0
  et <- exp(b * age); ee <- exp(b * entry)
  h <- a * et + c
  dH.db <- function(t) a * (t * exp(b * t) / b - expm1(b * t) / b^2)   # derivative of H(t) with respect to b
  g.loga <- a * sum(et / h - (expm1(b * age) - expm1(b * entry)) / b)
  g.logb <- b * sum(a * age * et / h - (dH.db(age) - dH.db(entry)))
  g <- c(g.loga, g.logb)
  if (makeham) g <- c(g, c * sum(1 / h - (age - entry)))
  return(-g)
}

# Occurrence / exposure mortality rates in fixed age intervals (deaths per animal-day at risk)
gompertz.binned <- function(age, entry, width = 30, from = 0, to = max(age)) {
  breaks <- seq(from, to + width, width)
  res <- c()
  for (i in 1:(length(breaks) - 1)) {
    lo <- breaks[i]; hi <- breaks[i + 1]
    exposure <- sum(pmax(0, pmin(age, hi) - pmax(entry, lo)))
    deaths <- sum(age >= lo & age < hi & entry <= age)
    atrisk <- sum(entry <= lo & age >= lo)
    res <- rbind(res, c(start = lo, mid = (lo + hi) / 2, atrisk = atrisk, deaths = deaths, exposure = exposure,
                        rate = ifelse(exposure > 0, deaths / exposure, NA)))
  }
  return(as.data.frame(res))
}

# Classic estimate (de Magalhaes et al. 2005, 2018): weighted regression of log(rate) on age, weighted by deaths
gompertz.regression <- function(binned, from = 0) {
  use <- binned[binned[, "deaths"] > 0 & binned[, "mid"] >= from, ]
  fit <- lm(log(rate) ~ mid, data = use, weights = deaths)
  b <- unname(coef(fit)["mid"]); se <- summary(fit)$coefficients["mid", "Std. Error"]
  return(c(a = unname(exp(coef(fit)[1])), b = b, b.se = se, MRDT = log(2) / b,
           MRDT.lo = log(2) / (b + 1.96 * se), MRDT.hi = log(2) / (b - 1.96 * se), r2 = summary(fit)$r.squared))
}

# Starting values for the optimizer from the classic regression
gompertz.start <- function(age, entry) {
  reg <- gompertz.regression(gompertz.binned(age, entry), from = 200)
  return(unname(c(log(reg["a"]), log(max(reg["b"], 1e-4)))))
}

# Fit one group. Returns a, b, (c), MRDT with Wald 95% CI on the log(b) scale, log-likelihood and vcov
gompertz.fit <- function(age, entry = rep(0, length(age)), makeham = FALSE, start = NULL) {
  if (is.null(start)) start <- gompertz.start(age, entry)
  if (makeham) start <- c(start, log(1e-6))
  opt <- optim(start, gompertz.nll, gompertz.gr, age = age, entry = entry, makeham = makeham,
               method = "BFGS", hessian = TRUE, control = list(maxit = 5000, reltol = 1e-12))
  vc <- solve(opt$hessian)
  se.logb <- sqrt(vc[2, 2])
  b <- exp(opt$par[2])
  return(list(par = opt$par, vcov = vc, logLik = -opt$value, n = length(age), convergence = opt$convergence,
              a = exp(opt$par[1]), b = b, c = if (makeham) exp(opt$par[3]) else 0,
              MRDT = log(2) / b, MRDT.lo = log(2) / exp(opt$par[2] + 1.96 * se.logb),
              MRDT.hi = log(2) / exp(opt$par[2] - 1.96 * se.logb)))
}

# Two groups (grp = 1/2) with a shared slope b and separate a: p = c(log(a1), log(a2), log(b))
gompertz.nll.sharedb <- function(p, age, entry, grp) {
  gompertz.nll(c(p[1], p[3]), age[grp == 1], entry[grp == 1]) + gompertz.nll(c(p[2], p[3]), age[grp == 2], entry[grp == 2])
}
gompertz.gr.sharedb <- function(p, age, entry, grp) {
  g1 <- gompertz.gr(c(p[1], p[3]), age[grp == 1], entry[grp == 1]); g2 <- gompertz.gr(c(p[2], p[3]), age[grp == 2], entry[grp == 2])
  c(g1[1], g2[1], g1[2] + g2[2])
}

# Two groups with a shared a and separate b: p = c(log(a), log(b1), log(b2))
gompertz.nll.shareda <- function(p, age, entry, grp) {
  gompertz.nll(c(p[1], p[2]), age[grp == 1], entry[grp == 1]) + gompertz.nll(c(p[1], p[3]), age[grp == 2], entry[grp == 2])
}
gompertz.gr.shareda <- function(p, age, entry, grp) {
  g1 <- gompertz.gr(c(p[1], p[2]), age[grp == 1], entry[grp == 1]); g2 <- gompertz.gr(c(p[1], p[3]), age[grp == 2], entry[grp == 2])
  c(g1[1] + g2[1], g1[2], g2[2])
}

# Likelihood ratio tests between two groups: is the slope (MRDT) different? is the intercept (R0) different?
gompertz.compare <- function(age, entry, group) {
  lv <- levels(factor(group)); g <- as.numeric(factor(group, levels = lv))
  f1 <- gompertz.fit(age[g == 1], entry[g == 1]); f2 <- gompertz.fit(age[g == 2], entry[g == 2])
  ll.sep <- f1$logLik + f2$logLik
  sb <- optim(c(f1$par[1], f2$par[1], mean(c(f1$par[2], f2$par[2]))), gompertz.nll.sharedb, gompertz.gr.sharedb,
              age = age, entry = entry, grp = g,  # not 'g =': it would match optim's 'gr'
              method = "BFGS", hessian = TRUE, control = list(maxit = 5000, reltol = 1e-12))
  sa <- optim(c(mean(c(f1$par[1], f2$par[1])), f1$par[2], f2$par[2]), gompertz.nll.shareda, gompertz.gr.shareda,
              age = age, entry = entry, grp = g,
              method = "BFGS", control = list(maxit = 5000, reltol = 1e-12))
  one <- gompertz.fit(age, entry)
  if (-sb$value > ll.sep + 1e-6 || -sa$value > ll.sep + 1e-6) warning("constrained fit beats the separate fits: optimizer failure")
  lrt <- function(ll0, df, ll1 = ll.sep) { x2 <- 2 * (ll1 - ll0); c(chisq = x2, df = df, p = pchisq(x2, df, lower.tail = FALSE)) }
  se.loghr <- sqrt(c(-1, 1, 0) %*% solve(sb$hessian) %*% c(-1, 1, 0))
  return(list(fits = setNames(list(f1, f2), lv),
              slope = lrt(-sb$value, 1),        # H0: same b (same MRDT), separate a
              intercept = lrt(-sa$value, 1),    # H0: same a (same R0), separate b
              any = lrt(one$logLik, 2),         # H0: one curve for both groups
              R0 = lrt(one$logLik, 1, -sb$value),  # H0: same a, given the shared slope
              sharedb = c(a1 = exp(sb$par[1]), a2 = exp(sb$par[2]), b = exp(sb$par[3]), MRDT = log(2) / exp(sb$par[3]),
                          HR = exp(sb$par[2] - sb$par[1]), HR.lo = exp(sb$par[2] - sb$par[1] - 1.96 * se.loghr),
                          HR.hi = exp(sb$par[2] - sb$par[1] + 1.96 * se.loghr))))
}

# Nonparametric bootstrap of the per-group fits (animals resampled within group)
gompertz.bootstrap <- function(age, entry, group, B = 1000, seed = 1) {
  set.seed(seed)
  lv <- levels(factor(group))
  res <- c()
  for (i in 1:B) {
    row <- c()
    for (l in lv) {
      idx <- which(group == l)
      s <- idx[sample.int(length(idx), replace = TRUE)]
      f <- gompertz.fit(age[s], entry[s])
      row <- c(row, f$par[1], f$par[2], f$MRDT)
    }
    res <- rbind(res, row)
  }
  colnames(res) <- paste0(rep(c("loga.", "logb.", "MRDT."), length(lv)), rep(lv, each = 3))
  return(as.data.frame(res))
}

# ---- Classes of animals whose cells share one slope -------------------------------------------------------------
# A class (for example, the D strains) has one slope b; each of its cells (for example, D on chow and D on high fat)
# has its own level a_c. For a fixed b the best a_c has a closed form, a_c = deaths_c / S_c(b), with
# S_c(b) = sum over the cell of (exp(b * age) - exp(b * entry)) / b. The fit is then a one-dimensional search over b
# (a profile likelihood). event = 1 for a death, 0 for an animal censored at 'age' (alive at the data freeze).

# Profile log-likelihood of log(b), with each cell's level at its best value
gompertz.profile <- function(lb, age, entry, cell, event = rep(1, length(age))) {
  b <- exp(lb)
  S <- tapply(exp(b * entry) * expm1(b * (age - entry)) / b, cell, sum)
  d <- tapply(event, cell, sum)
  sum(ifelse(d > 0, d * log(d / S) - d, 0)) + b * sum(age[event == 1])
}

# Fit one class. Levels are reported as the hazard at the reference age (h.ref, per day) as well as a = R0.
gompertz.cells.fit <- function(age, entry, cell, event = rep(1, length(age)), ref = 600) {
  cell <- factor(cell)
  pf <- function(lb) gompertz.profile(lb, age, entry, cell, event)
  opt <- optimize(pf, c(log(1e-4), log(0.05)), maximum = TRUE, tol = 1e-10)
  lb <- opt$maximum; b <- exp(lb); eps <- 1e-3
  se.logb <- sqrt(-1 / ((pf(lb + eps) - 2 * opt$objective + pf(lb - eps)) / eps^2))   # curvature of the profile
  a <- tapply(event, cell, sum) / tapply(exp(b * entry) * expm1(b * (age - entry)) / b, cell, sum)
  return(list(b = b, se.logb = se.logb, MRDT = log(2) / b, MRDT.lo = log(2) / exp(lb + 1.96 * se.logb),
              MRDT.hi = log(2) / exp(lb - 1.96 * se.logb), logLik = opt$objective, n = length(age),
              deaths = sum(event), n.cell = table(cell), a = a, h.ref = a * exp(b * ref)))
}

# Two classes (levels of 'class', in order). delta = log2(MRDT of class 2 / MRDT of class 1), with a Wald s.e.
# from the two profiles, and the likelihood-ratio test of one slope for both classes.
gompertz.classes.compare <- function(age, entry, cell, class, event = rep(1, length(age))) {
  lv <- levels(factor(class))
  f <- lapply(lv, function(k) { s <- class == k; gompertz.cells.fit(age[s], entry[s], cell[s], event[s]) })
  shared <- gompertz.cells.fit(age, entry, paste(class, cell), event)
  x2 <- 2 * (f[[1]]$logLik + f[[2]]$logLik - shared$logLik)
  return(list(fits = setNames(f, lv), shared = shared,
              delta = log2(f[[2]]$MRDT / f[[1]]$MRDT),
              delta.se = sqrt(f[[1]]$se.logb^2 + f[[2]]$se.logb^2) / log(2),
              lrt = c(chisq = x2, df = 1, p = pchisq(x2, 1, lower.tail = FALSE))))
}

# Delete-one-unit jackknife of delta: each unit (a strain, or an F1 type) is dropped in turn and both classes refitted.
# The s.e. carries unit-to-unit variation, so mice of one strain are not treated as independent replicates.
gompertz.jackknife <- function(age, entry, cell, class, unit, event = rep(1, length(age))) {
  units <- unique(unit)
  loo <- sapply(units, function(u) {
    s <- unit != u
    gompertz.classes.compare(age[s], entry[s], cell[s], class[s], event[s])$delta
  })
  n <- length(units)
  return(list(loo = setNames(loo, units), n = n, se = sqrt((n - 1) / n * sum((loo - mean(loo))^2))))
}

# ---- Gamma-Gompertz -----------------------------------------------------------------------------------------------
# Each animal's hazard is z * a * exp(b * t), with z gamma-distributed (mean 1, variance s2) across the animals of a
# class. In the population the hazard then bends below the Gompertz line at late ages, as high-risk animals die first:
#   mu(t) = a exp(b t) / G(t),   S(t) = G(t)^(-1 / s2),   G(t) = 1 + s2 (a / b) (exp(b t) - 1)
# b is the slope of each animal's own hazard. Parameters: log a for each cell, then log b and log s2 for each class
# (or one log b shared by the classes when shared.b = TRUE).
gammagompertz.nll <- function(p, age, entry, event, cellidx, classidx, ncell, nclass, shared.b) {
  la <- p[1:ncell]
  lb <- if (shared.b) rep(p[ncell + 1], nclass) else p[ncell + 1:nclass]
  ls <- p[ncell + (if (shared.b) 1 else nclass) + 1:nclass]
  a <- exp(la[cellidx]); b <- exp(lb[classidx]); s2 <- exp(ls[classidx])
  logG <- function(t) log1p(s2 * (a / b) * expm1(b * t))
  -sum(event * (log(a) + b * age - logG(age)) - (logG(age) - logG(entry)) / s2)
}

gammagompertz.fit <- function(age, entry, cell, class, event = rep(1, length(age)), shared.b = FALSE) {
  cl <- factor(class); cellf <- factor(paste(class, cell))
  classidx <- as.numeric(cl); cellidx <- as.numeric(cellf)
  nclass <- nlevels(cl); ncell <- nlevels(cellf)
  # start from the Gompertz fit of each class, with a small frailty variance
  g <- lapply(levels(cl), function(k) { s <- cl == k; gompertz.cells.fit(age[s], entry[s], cell[s], event[s]) })
  cell.class <- as.numeric(factor(sub(" .*$", "", levels(cellf)), levels = levels(cl)))
  la0 <- log(unlist(lapply(g, function(x) x$a)))
  lb0 <- log(sapply(g, function(x) x$b))
  start <- c(la0, if (shared.b) mean(lb0) else lb0, rep(log(0.1), nclass))
  opt <- optim(start, gammagompertz.nll, age = age, entry = entry, event = event, cellidx = cellidx, classidx = classidx,
               ncell = ncell, nclass = nclass, shared.b = shared.b, method = "BFGS",
               control = list(maxit = 10000, reltol = 1e-12))
  lb <- if (shared.b) rep(opt$par[ncell + 1], nclass) else opt$par[ncell + 1:nclass]
  ls <- opt$par[ncell + (if (shared.b) 1 else nclass) + 1:nclass]
  return(list(logLik = -opt$value, convergence = opt$convergence, MRDT = setNames(log(2) / exp(lb), levels(cl)),
              s2 = setNames(exp(ls), levels(cl))))
}

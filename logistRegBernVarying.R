################################################################################
# Lecture notes: test of logistReg Stan code (adaptive priors: varying effects)
# Mo, 10.08.2020
# Data: bank loan
################################################################################

graphics.off()
rm(list=ls())

#-------------------------------------------------------------------------------
# Load packages
#-------------------------------------------------------------------------------
library(rstan)
rstan_options("required" = FALSE)
library(bayesplot)
library(loo)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
Sys.setenv(LOCAL_CPPFLAGS = "-march=corei7 -mtune=corei7")
stan_version()

#-------------------------------------------------------------------------------
# Load data
#-------------------------------------------------------------------------------
load("bankloan.RData")
attach(bankloan)
str(bankloan)
head(bankloan)

# Omit missing data
any( is.na(bankloan) ) # check for missing values
dat <- na.omit(bankloan) # Delete cases with missing values
rm(bankloan)
attach(dat)
str(dat)
head(dat)

# Standardisation of data
Z = scale(
  x = dat[, c(1, 3:8)] ,
  center = TRUE ,
  scale = TRUE
)
class(Z)
head(Z)

#-------------------------------------------------------------------------------
# Design matrix
#-------------------------------------------------------------------------------
X <- unname(
  model.matrix(
    object = dat$default ~ 1 + age + employ + address + income +
      debtinc + creddebt + othdebt ,
    data = as.data.frame(Z)
  )
) # "stats"
attr( X , "assign" ) <- NULL
head( X , n = 10 )

#-------------------------------------------------------------------------------
# Specify data list for Stan simulation
#-------------------------------------------------------------------------------
dataList <- list(
  N = nrow(X) ,
  M = ncol(X) ,
  K = length( unique(dat$ed) ) ,
  L = 1L ,
  u = matrix(
    data = rep(1.0, length(unique(dat$ed))),
    nrow = length(unique(dat$ed)),
    ncol = 1L
  ) ,
  X = X ,
  y = as.integer(dat$default) ,
  gp = as.integer(dat$ed)
)
rm( dat , X , Z )

#-------------------------------------------------------------------------------
# Fitting a Stan model: Bernoulli likelihood w/ logit link and adaptive priors
#   (non-centred)
#-------------------------------------------------------------------------------
modelStan <- stan(
  file = "logistRegBernVarying.stan" ,
  data = dataList ,
  chains = 4 ,
  iter = 5000 ,
  warmup = 1000 ,
  thin = 1 ,
  init = "random" ,
  algorithm = "NUTS" ,
  control = list( adapt_delta = 0.99 ,
                  max_treedepth = 15 ) ,
  cores = 3
)

class(modelStan)
dim(modelStan)

#-------------------------------------------------------------------------------
# Summary and MCMC diagnostics
#-------------------------------------------------------------------------------
print(
  x = modelStan ,
  pars = c("beta", "R_beta", "lp__") ,
  probs = c(0.015, 0.25, 0.50, 0.75, 0.985)
)

check_hmc_diagnostics(modelStan)
stan_trace(
  object = modelStan ,
  pars = c("beta", "R_beta", "lp__") ,
  inc_warmup = TRUE
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("beta") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("R_beta") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_dens(
  object = modelStan ,
  pars = c("beta", "R_beta", "lp__")
)  # "rstan"

plot_title <- ggtitle( "Posterior marginal distributions" ,
                       "with medians and 89% intervals")
mcmc_areas(
  x = modelStan ,
  regex_pars = c("beta") ,
  prob = 0.89
) + plot_title
# bayesplot"

np <- nuts_params(modelStan)
mcmc_nuts_energy(np) + ggtitle("NUTS Energy Diagnostic")
# bayesplot"

pairs(
  x = modelStan ,
  pars = c("beta")
)  # "rstan"

mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("beta[1,3]", "beta[2,1]")
)  # bayesplot"
mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("beta[2,3]", "beta[3,2]")
)  # bayesplot"

mcmc_hex(
  x = as.matrix(modelStan) ,
  pars = c("beta[1,2]", "beta[3,3]")
)  # bayesplot"

#-------------------------------------------------------------------------------
# Posterior predictive checks
#-------------------------------------------------------------------------------
draws <- as.matrix(
  modelStan ,
  pars = "yrep"
)
class(draws)
dim(draws)
print( colnames(draws) )

color_scheme_set("brightblue")
ppc_dens_overlay(
  y = dataList$y ,
  yrep = draws[1:100,]
)  # "bayesplot"
ppc_hist(
  y = dataList$y ,
  yrep = draws[11:15,] ,
  binwidth = 0.5
)  # "bayesplot"

ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "max" ,
  binwidth = 0.1
)  # bayesplot"
ppc_stat_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  stat = "max" ,
  binwidth = 0.1
)  # "bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "mean" ,
  binwidth = 0.5
)  # bayesplot"
ppc_stat_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  stat = "mean" ,
  binwidth = 0.5
)  # "bayesplot"
ppc_intervals(
  y = dataList$y ,
  yrep = draws , 
  prob = 0.5,
  prob_outer = 0.89 ,
  size = 1 ,
  fatten = 3
)  # "bayesplot"
ppc_intervals_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  prob = 0.5,
  prob_outer = 0.89 ,
  size = 1 ,
  fatten = 3
)  # "bayesplot"

#-------------------------------------------------------------------------------
# Pareto-smoothed importance-sampling leave-one-out cross-validation (PSIS-LOO)
#-------------------------------------------------------------------------------
looModelStan <- loo(
  x = modelStan ,
  pars = "log_lik"
)  # "loo"
print(x = looModelStan)
plot(
  x = looModelStan ,
  label_points = TRUE
)

################################################################################
################################################################################
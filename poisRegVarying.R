################################################################################
# Lecture notes: test of poisReg Stan code (adaptive priors: varying effects)
# Do, 06.08.2020
# Data: plane touch down numbers
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
load("poissonData.RData")
attach(poissonData)
str(poissonData)
head(poissonData)

# Omit missing data
any( is.na(poissonData) ) # check for missing values

# Standardisation of data
Z <- scale(
  x = poissonData[,2:4] ,
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
    object = poissonData$y ~ 1 + x1 + x2 + x3 ,
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
  K = length( unique(poissonData$gp) ) ,
  L = 1L ,
  u = matrix(
    data = rep(1.0, length(unique(poissonData$gp))),
    nrow = length(unique(poissonData$gp)),
    ncol = 1L
  ) ,
  X = X ,
  y = poissonData$y ,
  gp = poissonData$gp
)
rm( poissonData , X , Z )

#-------------------------------------------------------------------------------
# Fitting a Stan model: Poisson likelihood w/ log link and adaptive priors
#   (non-centered)
#-------------------------------------------------------------------------------
modelStan <- stan(
  file = "poisRegVarying.stan" ,
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
  pars = c("beta", "gamma", "R", "lp__") ,
  probs = c(0.015, 0.25, 0.50, 0.75, 0.985)
)

check_hmc_diagnostics(modelStan)
stan_trace(
  object = modelStan ,
  pars = c("beta", "gamma", "R", "lp__") ,
  inc_warmup = TRUE
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("beta", "gamma") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("R") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_dens(
  object = modelStan ,
  pars = c("beta", "gamma", "R", "lp__")
)  # "rstan"

plot_title <- ggtitle( "Posterior marginal distributions" ,
                       "with medians and 89% intervals")
mcmc_areas(
  x = modelStan ,
  regex_pars = c("beta", "gamma") ,
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
  pars = c("beta[3,1]", "beta[3,4]")
)  # bayesplot"

mcmc_hex(
  x = as.matrix(modelStan) ,
  pars = c("beta[1,1]", "beta[1,4]")
)  # bayesplot"

#-------------------------------------------------------------------------------
# Posterior predictive checks (re-using predictor data)
#-------------------------------------------------------------------------------
draws <- as.matrix(
  x = modelStan ,
  pars = "yrep"
)
class(draws)
dim(draws)
print( colnames(draws) )

color_scheme_set("brightblue")
ppc_dens_overlay(
  y = dataList$y ,
  yrep = draws[2150:2250,]
) # "bayesplot"
ppc_hist(
  y = dataList$y ,
  yrep = draws[6:10,] ,
  binwidth = 0.5
)  # "bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "max" ,
  binwidth = 0.5
)  # "bayesplot"
ppc_stat_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  stat = "max" ,
  binwidth = 0.5
)  # "bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "mean" ,
  binwidth = 0.1
)  # "bayesplot"
ppc_stat_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  stat = "mean" ,
  binwidth = 0.1
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
ppc_rootogram(
  y = dataList$y ,
  yrep = draws ,
  style = "standing" ,
  prob = 0.89 ,
  size = 1
)  # "bayesplot"

#-------------------------------------------------------------------------------
# Pareto-smoothed importance-sampling leave-one-out cross-validation (PSIS-LOO)
#-------------------------------------------------------------------------------
loo(
  x = modelStan ,
  pars = "log_lik"
)  # "loo"
looModelStan <- loo(
  x = modelStan ,
  pars = "log_lik"
)  # "loo"
plot(looModelStan)

################################################################################
################################################################################
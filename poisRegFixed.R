################################################################################
# Lecture notes: test of poisReg Stan code (fixed priors)
# Mi, 05.08.2020
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
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
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
  X = X ,
  y = poissonData$y
)
rm( poissonData , X , Z )

#-------------------------------------------------------------------------------
# Fitting a Stan model: Poisson likelihood w/ log link and fixed priors
#-------------------------------------------------------------------------------
modelStan <- stan(
  file = "poisRegFixed.stan" ,
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
  pars = c("beta", "lp__") ,
  probs = c(0.015, 0.25, 0.50, 0.75, 0.985)
)

check_hmc_diagnostics(modelStan)
stan_trace(
  object = modelStan ,
  pars = c("beta", "lp__") ,
  inc_warmup = TRUE
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("beta") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_dens(
  object = modelStan ,
  pars = c("beta", "lp__")
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
  pars = c("beta[1]", "beta[2]")
)  # bayesplot"
mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("beta[3]", "beta[4]")
)  # bayesplot"

mcmc_hex(
  x = as.matrix(modelStan) ,
  pars = c("beta[3]", "beta[4]")
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
) + xlim(0, 12)  # "bayesplot"
ppc_hist(
  y = dataList$y ,
  yrep = draws[11:15,] ,
  binwidth = 1
)  # "bayesplot"

ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "max" ,
  binwidth = 1
)  # bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "mean" ,
  binwidth = 0.1
)  # bayesplot"
ppc_intervals(
  y = dataList$y ,
  yrep = draws , 
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

################################################################################
################################################################################
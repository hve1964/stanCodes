################################################################################
# Lecture notes: test of LinReg Stan code (fixed priors)
# Mo, 03.08.2020
# Data: Ashenfelter, Ashmore and Lalonde, http://www.liquidasset.com/
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
Sys.setenv(LOCAL_CPPFLAGS = "-march=corei7 -mtune=corei7")
stan_version()

#-------------------------------------------------------------------------------
# Load data
#-------------------------------------------------------------------------------
load("ashenfelter.RData")
attach(ashenfelter)
str(ashenfelter)
head(ashenfelter)

# Omit missing data
any( is.na(ashenfelter) ) # check for missing values
dat <- na.omit(ashenfelter) # Delete cases with missing values
rm(ashenfelter)
attach(dat)
str(dat)
head(dat)

# Standardisation of data
Z <- scale(
  x = dat[,3:7] ,
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
    object = LPRICE2 ~ 1 + WRAIN + DEGREES + HRAIN + TIME_SV ,
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
  y = as.numeric(Z[,"LPRICE2"])
)
rm( dat , X , Z )

#-------------------------------------------------------------------------------
# Fitting a Stan model: Gauss likelihood and fixed priors
#-------------------------------------------------------------------------------
modelStan <- stan(
  file = "linRegNormFixed.stan" ,
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
  pars = c("beta", "sigma", "lp__") ,
  probs = c(0.015, 0.25, 0.50, 0.75, 0.985)
)

check_hmc_diagnostics(modelStan)
stan_trace(
  object = modelStan ,
  pars = c("beta", "sigma", "lp__") ,
  inc_warmup = TRUE
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("beta", "sigma") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_dens(
  object = modelStan ,
  pars = c("beta", "sigma", "lp__")
)  # "rstan"

plot_title <- ggtitle( "Posterior marginal distributions" ,
                       "with medians and 89% intervals")
mcmc_areas(
  x = modelStan ,
  regex_pars = c("beta", "sigma") ,
  prob = 0.89
) + plot_title

np <- nuts_params(modelStan)
mcmc_nuts_energy(np) + ggtitle("NUTS Energy Diagnostic")

pairs(
  x = modelStan ,
  pars = c("beta", "sigma")
)  # "rstan"

mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("sigma", "beta[2]")
)  # bayesplot"
mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("beta[3]", "beta[4]")
)  # bayesplot"

mcmc_hex(
  x = as.matrix(modelStan) ,
  pars = c("beta[2]", "beta[4]")
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
  binwidth = 0.1
)  # "bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "max" ,
  binwidth = 0.1
)  # "bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws ,
  stat = "mean" ,
  binwidth = 0.05
)  # "bayesplot"
ppc_intervals(
  y = dataList$y ,
  yrep = draws , 
  prob = 0.5,
  prob_outer = 0.89 ,
  size = 1 ,
  fatten = 3
)  # "bayesplot"

################################################################################
################################################################################
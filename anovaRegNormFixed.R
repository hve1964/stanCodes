################################################################################
# R code for massMonitoring data modelling using Stan
# Mo, 03.08.2020
# Data set: massMonitoring.csv
# Comparison of two alternative ANOVA-like models
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
d <- read.csv( file="massMonitoring.csv" )
attach(d)
head(d)
str(d)
any( is.na(d) ) # Checking for missing values in the data matrix

#-------------------------------------------------------------------------------
# Specify data list for Stan simulation
#-------------------------------------------------------------------------------
dataList <- list(
  N = as.integer(nrow(d)) ,
  K = length(unique(d$X2)) ,
  gp = d$X2 ,
  y = d$X1
)

rm(d)

#-------------------------------------------------------------------------------
# Fitting a Stan model: Gauss likelihood, homogeneous variances
#-------------------------------------------------------------------------------
modelStan <- stan(
  file = "anovaRegNormFixed.stan" ,
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
  pars = c("mu", "sigma", "lp__") ,
  probs = c(0.015, 0.25, 0.50, 0.75, 0.985)
)

check_hmc_diagnostics(modelStan)
stan_trace(
  object = modelStan ,
  pars = c("mu", "sigma", "lp__") ,
  inc_warmup = TRUE
)  # "rstan"
stan_plot(
  object = modelStan ,
  pars = c("mu") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_dens(
  object = modelStan ,
  pars = c("mu", "sigma", "lp__")
)  # "rstan"

plot_title <- ggtitle( "Posterior marginal distributions" ,
                       "with medians and 89% intervals")
mcmc_areas(
  x = modelStan ,
  regex_pars = c("mu") ,
  prob = 0.89
) + plot_title
# bayesplot"

np <- nuts_params(modelStan)
mcmc_nuts_energy(np) + ggtitle("NUTS Energy Diagnostic")
# bayesplot"

pairs(
  x = modelStan ,
  pars = c("mu")
)  # "rstan"

mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("sigma", "mu[4]")
)  # bayesplot"
mcmc_scatter(
  x = as.matrix(modelStan) ,
  pars = c("mu[3]", "mu[4]")
)  # bayesplot"

mcmc_hex(
  x = as.matrix(modelStan) ,
  pars = c("mu[2]", "mu[4]")
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
  yrep = draws[1:50,]
) # "bayesplot"
ppc_hist(
  y = dataList$y ,
  yrep = draws[11:15,] ,
  binwidth = 0.1
)  # "bayesplot"
ppc_stat_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  stat = "max" ,
  binwidth = 0.05
) # "bayesplot"
ppc_stat_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  stat = "mean" ,
  binwidth = 0.05
) # "bayesplot"
ppc_intervals_grouped(
  y = dataList$y ,
  yrep = draws ,
  group = dataList$gp ,
  prob = 0.5 ,
  prob_outer = 0.89 ,
  size = 1 ,
  fatten = 3
) # "bayesplot"

################################################################################
################################################################################
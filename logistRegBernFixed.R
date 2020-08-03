################################################################################
# Lecture notes: test of logistReg Stan code (fixed priors)
# Mo, 03.08.2020
# Data: "urine" from boot package
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

#-------------------------------------------------------------------------------
# Load data
#-------------------------------------------------------------------------------
library(boot)
data("urine")
attach(urine)
str(urine)
head(urine)
any( is.na(urine) ) # Checking for missing values in the data matrix
dat = na.omit(urine) # Delete cases with missing values
rm(urine)
dim(dat) # Number of remaining cases
pairs(dat) # Generate pairwise scatter plots
head(dat)

# Standardisation of data
Z = scale(
  x = dat[, 2:7] ,
  center = TRUE ,
  scale = TRUE
)
class(Z)
head(Z)

#-------------------------------------------------------------------------------
# Design matrix
#-------------------------------------------------------------------------------
X <- unname( model.matrix(
  object = dat$r ~ 1 + gravity + ph + osmo + cond + urea + calc ,
  data = as.data.frame(Z)
)
) # "stats"
attr( X , "assign" ) <- NULL
head( X , n = 10 )

#-------------------------------------------------------------------------------
# Specify data list for Stan simulation
#-------------------------------------------------------------------------------
y <- as.integer(dat$r)

dataList <- list(
  N = nrow(X) ,
  M = ncol(X) ,
  X = X ,
  y = y
)
rm( dat , X , Z )

#-------------------------------------------------------------------------------
# Fitting a Stan model: Bernoulli likelihood w/ logit link and fixed priors
#-------------------------------------------------------------------------------
mod1.stan <- stan(
  file = "logistRegBernFixed.stan" ,
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

class(mod1.stan)
dim(mod1.stan)

#-------------------------------------------------------------------------------
# Summary and MCMC diagnostics
#-------------------------------------------------------------------------------
print(
  x = mod1.stan ,
  pars = c("beta", "lp__") ,
  probs = c(0.015, 0.25, 0.50, 0.75, 0.985)
)

check_hmc_diagnostics(mod1.stan)
stan_trace(
  object = mod1.stan ,
  pars = c("beta", "lp__") ,
  inc_warmup = TRUE
)  # "rstan"
stan_plot(
  object = mod1.stan ,
  pars = c("beta") ,
  ci_level = 0.89 ,
  outer_level = 0.97
)  # "rstan"
stan_dens(
  object = mod1.stan ,
  pars = c("beta", "lp__")
)  # "rstan"

plot_title <- ggtitle( "Posterior marginal distributions" ,
                       "with medians and 89% intervals")
mcmc_areas(
  x = mod1.stan ,
  regex_pars = c("beta") ,
  prob = 0.89
) + plot_title

np <- nuts_params(mod1.stan)
mcmc_nuts_energy(np) + ggtitle("NUTS Energy Diagnostic")

pairs(
  x = mod1.stan ,
  pars = c("beta")
)  # "rstan"

mcmc_scatter(
  x = as.matrix(mod1.stan) ,
  pars = c("beta[2]", "beta[4]")
)  # bayesplot"
mcmc_scatter(
  x = as.matrix(mod1.stan) ,
  pars = c("beta[4]", "beta[5]")
)  # bayesplot"

mcmc_hex(
  x = as.matrix(mod1.stan) ,
  pars = c("beta[2]", "beta[4]")
)  # bayesplot"

#-------------------------------------------------------------------------------
# Posterior predictive checks
#-------------------------------------------------------------------------------
draws <- as.matrix(
  x = mod1.stan ,
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
  yrep = draws[6:10, 8:84] ,
  binwidth = 0.1
)  # "bayesplot"
ppc_stat(
  y = dataList$y ,
  yrep = draws[, 8:84] ,
  stat = "max" ,
  binwidth = 0.1
)
ppc_stat(
  y = dataList$y ,
  yrep = draws[, 8:84] ,
  stat = "mean" ,
  binwidth = 0.05
)
ppc_intervals(
  y = dataList$y ,
  yrep = draws[, 8:84] , 
  prob = 0.5,
  prob_outer = 0.89 ,
  size = 1 ,
  fatten = 3
)

################################################################################
################################################################################
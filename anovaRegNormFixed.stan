/* Vectorised Stan model code for fixed effects homoscedastic ANOVA-like
   regression */
data {
  /* Dimensions */
  int<lower=1> N;    // number of sampling units
  int<lower=1> K;    // number of groups
    
  /* Observed variables */
  int<lower=1,upper=K> gp[N];    // group indicator
  vector[N] y;                   // outcome
}

parameters {
  /* Unobserved variables */
  vector[K] mu;           // group means
  real<lower=0> sigma;    // common stdev (homogeneous)
}

model {
  /* Fixed log-priors */
  target += normal_lpdf( mu | 0 , 100 );
  target += exponential_lpdf( sigma | 1 );
    
  /* Gauss log-likelihood */
  target += normal_lpdf( y | mu[gp] , sigma );
}

generated quantities {
  /* Posterior predictive distribution (re-using predictor data) */
  vector[N] yrep;
  
  for ( i in 1:N ) {
    yrep[i] = normal_rng( mu[gp[i]] , sigma );
  }
}


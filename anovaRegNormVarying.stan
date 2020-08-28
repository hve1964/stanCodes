/* Vectorised Stan model code for varying effects heteroscedastic ANOVA-like
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
  real mu_mu;                  // mean of distribution of group means
  real<lower=0> sigma_mu;      // stdev of distribution of group means
  vector[K] mu;                // group means
  real<lower=0> beta_sigma;    // parameter of distribution of group stdevs
  vector<lower=0>[K] sigma;    // group stdevs (inhomogeneous)
}

model {
  /* Fixed log-priors (weakly informative, regularising) */
  target += normal_lpdf( mu_mu | 90 , 2 );
  target += exponential_lpdf( sigma_mu | 1 );
  target += exponential_lpdf( beta_sigma | 1 );

  /* Adaptive log-priors */
  target += normal_lpdf( mu | mu_mu , sigma_mu );
  target += exponential_lpdf( sigma | beta_sigma );

  /* Gauss log-likelihood */
  target += normal_lpdf( y | mu[gp] , sigma[gp] );
}

generated quantities {
  vector[N] yrep;
  vector[N] log_lik;

  /* Posterior predictive distribution (re-using predictor data)
     and calculation of pointwise log-likelihood */
  for ( i in 1:N ) {
    yrep[i] = normal_rng( mu[gp[i]] , sigma[gp[i]] );
    
    log_lik[i] = normal_lpdf( y[i] | mu[gp[i]] , sigma[gp[i]] );
  }
}


/* Vectorised Stan model code for fixed effects multiple linear regression */
data {
  /* Dimensions */
  int<lower=1> N;   // number of sampling units
  int<lower=1> M;   // number of predictors plus one
    
  /* Observed variables */
  matrix[N, M] X;   // design matrix: predictors
  vector[N] y;      // outcome
}

parameters {
  /* Unobserved variables */
  vector[M] beta;
  real<lower=0> sigma;
}

model {
  /* Fixed log-priors (regularising) */
  target += normal_lpdf ( beta | 0 , 1 );
  target += exponential_lpdf( sigma | 1 );
    
  /* Gauss log-likelihood w/ identity link */
  target += normal_lpdf( y | X * beta , sigma );
}

generated quantities {
  /* Posterior predictive distribution (re-using predictor data) */
  vector[N] yrep;
  
  for ( i in 1:N ) {
    yrep[i] = normal_rng( (X * beta)[i] , sigma );
  }
}


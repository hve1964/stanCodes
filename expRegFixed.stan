/* Vectorised Stan model code for fixed effects exponential regression */
data {
  /* Dimensions */
  int<lower=1> N;   // number of sampling units
  int<lower=1> M;   // number of predictors plus one
      
  /* Observed variables */
  matrix[N, M] X;        // design matrix: predictors
  real<lower=0> y[N];    // outcome
}

parameters {
  /* Unobserved variables */
  vector[M] beta;
}

model {
  /* Fixed log-priors (regularising) */
  target += normal_lpdf ( beta | 0 , 1 );
    
  /* Exponential log-likelihood w/ exponential inverse link */
  target += exponential_lpdf( y | exp(X * beta) );
}

generated quantities {
  /* Posterior predictive distribution (re-using predictor data) */
  real<lower=0> yrep[N];
    
  for ( i in 1:N ) {
    yrep[i] = exponential_rng( exp((X * beta)[i]) );
  }
}


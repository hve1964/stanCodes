/* Vectorised Stan model code for fixed effects Poisson regression */
data {
  /* Dimensions */
  int<lower=1> N;   // number of sampling units
  int<lower=1> M;   // number of predictors plus one
      
  /* Observed variables */
  matrix[N, M] X;       // design matrix: predictors
  int<lower=0> y[N];    // outcome
}

parameters {
  /* Unobserved variables */
  vector[M] beta;
}

model {
  /* Fixed log-priors (regularising) */
  target += normal_lpdf ( beta | 0 , 1 );
    
  /* Poisson log-likelihood w/ log link */
  target += poisson_log_lpmf( y | X * beta );
}

generated quantities {
  /* Posterior predictive distribution (re-using predictor data) */
  int<lower=0> yrep[N];
    
  for ( i in 1:N ) {
    if ( (X * beta)[i] > 20 ) {
      yrep[i] = poisson_log_rng( 20 );
    } else {
        yrep[i] = poisson_log_rng( (X * beta)[i] );
    }
  }
}


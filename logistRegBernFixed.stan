/* Vectorised Stan model code for fixed effects logistic regression */
data {
  /* Dimensions */
  int<lower=1> N;   // number of sampling units
  int<lower=1> M;   // number of predictors plus one
      
  /* Observed variables */
  matrix[N, M] X;               // design matrix: predictors
  int<lower=0,upper=1> y[N];    // outcome
}

parameters {
  /* Unobserved variables */
  vector[M] beta;
}

model {
  /* Fixed log-priors (regularising) */
  target += normal_lpdf ( beta | 0 , 1 );
    
  /* Bernoulli log-likelihood w/ logit link */
  target += bernoulli_logit_lpmf( y | X * beta );
}

generated quantities {
  /* Posterior predictive distribution (re-using predictor data) */
  int<lower=0,upper=1> yrep[N];
    
  for ( i in 1:N ) {
    yrep[i] = bernoulli_logit_rng( (X * beta)[i] );
  }
}


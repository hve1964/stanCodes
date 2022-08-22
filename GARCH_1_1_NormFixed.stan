/* Vectorised Stan model code for fixed effects GARCH(1,1) regression */
data {
  int<lower=0> T;
  real<lower=0> sigma1;
  vector[T] y;
}

parameters {
  real mu;
  real<lower=0> alpha0;
  real<lower=0,upper=1> alpha1;
  real<lower=0,upper=(1-alpha1)> beta1;
}

transformed parameters {
  real<lower=0> sigma[T];
  sigma[1] = sigma1;
  
  for ( t in 2:T ) {
    sigma[t] = sqrt( alpha0 + alpha1 * (y[t-1] - mu) ^ 2
                     + beta1 * (sigma[t-1]) ^ 2 );
  }
}

model {
  /* Fixed log-priors */
  target += normal_lpdf( mu | 0 , 1.5 );     // prior for mean of likelihood
  target += exponential_lpdf( alpha0 | 1 );  // prior for positive intercept
  target += beta_lpdf( alpha1 | 1 , 1 );     // prior for positive slope1
  target += beta_lpdf( beta1 | 1 , 1 );      // prior for positive slope2
  
  /* Gauss log-likelihood */
  target += normal_lpdf( y | mu , sigma );
}

generated quantities {
  vector[T] yrep;
  vector[T] log_lik;

  /* Posterior predictive distribution (re-using predictor data)
  and calculation of pointwise log-likelihood */
  for ( i in 1:T ) {
    yrep[i] = normal_rng( mu , sigma[i] );
      
    log_lik[i] = normal_lpdf( y[i] | mu , sigma[i] );
  }
}


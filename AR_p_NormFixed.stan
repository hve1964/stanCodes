/* Vectorised Stan model code for fixed effects AR(p) regression. Ali (2017)
  URL: https://imadali.net/projects/bsss/rstan/generated-quantities/ */
data {
  int<lower=0> T;         // length of time series
  int<lower=1,upper=T> P; // number of lags
  vector[T] y;            // time series data
}

transformed data {
  /* Transform data to accommodate P-lag process */
  vector[T-P] y_trans;    // outcome of time series
  matrix[T-P, P] Ymat;    // matrix of (lagged) predictors
  
  for ( i in 1:(T-P) ) {
    y_trans[i] = y[i+P];
    
    for ( p in 1:P ) {
      Ymat[i, p] = y[(P + i) - p];
    }
  }
}

parameters {
  real alpha;                         // intercept
  vector<lower=-1,upper=1>[P] beta;   // slopes w/ stationarity constraints
  real<lower=0> sigma;                // sd of error
}

model {
  /* Fixed log-priors (regularising) */
  target += normal_lpdf( alpha | 0 , 1 );
  target += normal_lpdf( beta | 0 , 1 );
  target += exponential_lpdf( sigma | 1 );

  /* Gauss log-likelihood */
  target += normal_lpdf( y_trans | alpha + Ymat * beta , sigma );
}

generated quantities {
  vector[T-P] yrep;
  vector[T-P] log_lik;

  /* Posterior predictive distribution (re-using predictor data) and
    calculation of pointwise log-likelihood */
  for ( i in 1:(T-P) ) {
    yrep[i] = normal_rng( alpha + Ymat[i, ] * beta , sigma );
    
    log_lik[i] = normal_lpdf( y_trans[i] | alpha + Ymat[i, ] * beta , sigma );
  }
}


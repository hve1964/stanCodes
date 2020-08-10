/* Vectorised Stan model code for varying effects exponential regression */
data {
  /* Dimensions */
  int<lower=1> N;    // number of sampling units
  int<lower=1> M;    // number of predictors plus one
  int<lower=1> K;    // number of groups
  int<lower=1> L;    // number of group predictors
      
  /* Observed variables */
  matrix[N, M] X;                // design matrix: predictors
  matrix[K, L] u;                // matrix of group predictors
  int<lower=1,upper=K> gp[N];    // group indicator
  real<lower=0> y[N];            // outcome
}

parameters {
  /* Unobserved variables */
  matrix[L, M] gamma_beta;    // group coefficients
  matrix[M, K] z_beta;

  /* Cholesky decomposition of covariance matrix */
  vector<lower=0>[M] sigma_beta;
  cholesky_factor_corr[M] L_R_beta;
}

transformed parameters {
  matrix[K, M] beta;

  /* Correlated varying intercepts and slopes */
  beta = u * gamma_beta +
    ( diag_pre_multiply( sigma_beta , L_R_beta ) * z_beta )';
}

model {
  /* Fixed log-priors for unobserved variables (regularising) */
  target += normal_lpdf( to_vector(gamma_beta) | 0 , 1 );
  target += normal_lpdf( to_vector(z_beta) | 0 , 1 );

  /* Fixed log-priors for Cholesky decomposition of covariance matrix */
  target += exponential_lpdf( sigma_beta | 1 );
  target += lkj_corr_cholesky_lpdf( L_R_beta | 2 );  

  /* Exponential log-likelihood w/ exponential inverse link */
  target += exponential_lpdf( y | exp( rows_dot_product( beta[gp] , X ) ) );
}

generated quantities {
  real<lower=0> yrep[N];
  vector[N] log_lik;
  matrix[M, M] R_beta;

  /* Reconstruction of correlation matrix */
  R_beta = multiply_lower_tri_self_transpose(L_R_beta);

  /* Posterior predictive distribution (re-using predictor data)
     and calculation of pointwise log-likelihood */
  for ( i in 1:N ) {
    yrep[i] = exponential_rng( exp( rows_dot_product( beta[gp] , X )[i] ) );
    
    log_lik[i] = exponential_lpdf( y[i] |
      exp( rows_dot_product( beta[gp] , X )[i] ) );
  }
}


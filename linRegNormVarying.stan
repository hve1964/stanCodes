/* Vectorised Stan model code for varying effects multiple linear regression */
data {
  /* Dimensions */
  int<lower=1> N;   // number of sampling units
  int<lower=1> M;   // number of predictors plus one
  int<lower=1> K;   // number of groups
  int<lower=1> L;   // number of group predictors
      
  /* Observed variables */
  matrix[N, M] X;                // design matrix: predictors
  matrix[K, L] u;                // matrix of group predictors
  int<lower=1,upper=K> gp[N];    // group indicator
  vector[N] y;                   // outcome
}

parameters {
  /* Unobserved variables */
  matrix[L, M] gamma;    // group coefficients
  real<lower=0> sigma;

  /* Cholesky decomposition of covariance matrix */
  vector<lower=0>[M] sigma_beta;
  cholesky_factor_corr[M] L_Rho;
  matrix[M, K] z_beta;
}

transformed parameters {
  matrix[K, M] beta;

  /* Correlated varying intercepts and slopes */
  beta = u * gamma + ( diag_pre_multiply( sigma_beta , L_Rho ) * z_beta )';
}

model {
  /* Fixed log-priors for unobserved variables (regularising) */
  target += normal_lpdf( to_vector(gamma) | 0 , 1 );
  target += exponential_lpdf( sigma | 1 );

  /* Fixed log-priors for Cholesky decomposition of covariance matrix */
  target += exponential_lpdf( sigma_beta | 1 );
  target += lkj_corr_cholesky_lpdf( L_Rho | 2 );
  target += normal_lpdf( to_vector(z_beta) | 0 , 1 );
    
  /* Gauss log-likelihood w/ identity link */
  target += normal_lpdf( y | rows_dot_product( beta[gp] , X ) , sigma );
}

generated quantities {
  vector[N] yrep;
  vector[N] log_lik;
  matrix[M, M] Rho;

  /* Reconstruction of correlation matrix */
  Rho = multiply_lower_tri_self_transpose(L_Rho);

  /* Posterior predictive distribution (re-using predictor data)
     and calculation of pointwise log-likelihood */
  for ( i in 1:N ) {
    yrep[i] = normal_rng( rows_dot_product( beta[gp] , X )[i] , sigma );
    
    log_lik[i] = normal_lpdf( y[i] | rows_dot_product( beta[gp] , X )[i] ,
      sigma );
  }
}


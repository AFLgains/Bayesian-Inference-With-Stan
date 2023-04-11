
data {
  //data size
  int<lower=0> N; // number of data points
  int<lower=0> C; // number of covariates
  //x-data
  matrix[N,C] X_train; // training data
  //y-data
  int<lower=0,upper=1> match_outcome[N];

  // out of sample, test data
  int<lower=0> N_test;
  matrix[N_test,C] X_test;
}

parameters {
  //unknown_parameters
  vector[C] coeffs;
  real intercept;
}

transformed parameters {
  vector[N] y_prob;
  y_prob = inv_logit(X_train*coeffs + intercept);
}

model {
  //prior
  intercept ~ normal(0,10);
  coeffs ~ normal(0,10);

  //likelihood
   match_outcome ~ bernoulli(y_prob);

}

generated quantities{
  real y_pred_test[N_test];
  for (i in 1:N_test){
    y_pred_test[i] = inv_logit(X_test[i,]*coeffs + intercept);
  }

}










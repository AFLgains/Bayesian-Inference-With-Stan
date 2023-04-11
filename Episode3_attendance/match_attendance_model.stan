data {
  //data size
  int<lower=0> N;
  int<lower=0> C;

  //y-data
  vector<lower=0>[N] match_attendance;

  //x-data
  matrix[N,C] X;

}


parameters {
  //unknown parameters
  vector[C] coeffs;
  real intercept;
  real<lower=0> sigma;
}

model {
  //prior
  intercept ~ normal(0,10);
  coeffs ~ normal(0,10); // will broadcast the definition across each element of coeffs
  sigma ~ normal(0,10);

  //likelihood
  match_attendance ~ normal(X*coeffs + intercept,sigma);//will broadcast this definition across each combination of C and match attendance
}


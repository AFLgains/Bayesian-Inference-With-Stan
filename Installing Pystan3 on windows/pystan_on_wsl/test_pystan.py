import stan

test_code = """
parameters {
  real y; 
model {
  y~normal(0,1);
}
"""

posterior = stan.build(test_code, random_seed=1)
fit = posterior.sample(num_chains=4, num_samples=1000)
print(fit)
eta = fit["y"] 
print(eta)

function r = rewardfunc(obs)
% Returns the reward value given the vector of observations

mu_obs = sum(obs)/size(obs, 1);
obs_max = max(obs);
std_obs = std(obs);

mu_ideal = 2e-4;
std_ideal = 5e-5;

x = mu_obs*10000;
y = std_obs*10000;

r = exp(-8*x^2) + exp(-3*y); % reward function

end
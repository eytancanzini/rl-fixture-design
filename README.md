# Optimal Fixture Design using Expert-informed Reinforcement Learning
GitHub repository for the code in MATLAB and/or Python that is used to generate optimal fixture plans for aerostructure assembly using reinforcement learning.

## To-Do List
- [ ] Finish using the cartpole environment and get an agent that can sustain 200 steps reliably
- [ ] Create a `gym` environment that is capable of providing a context (the drilling hole) and sending back a reward (based on the deformation)
- [ ] Create a basic DQN approach for this problem. This will work as you just have tasks (the state) and the action but no future reward, therefore you can disregard the value of $\gamma$ as it will have no effect on the value of the regret
- [ ] Minimise the total regret $R_{\mathcal{G}}$ of the system 

%% Reinforcement Learning for Fixture Layout Planning
% This file will introduce reinforcement learning (RL) as a method of
% generating optimal fixture plans for a component. This approach treats
% the fixture planning as a control problem rather than a dynamic
% programming problem.

%% Create the agent, action and observation spaces
% This section is used to setup the reinforcement learning agent that is
% acting in this environment. The current method that seems to work best is
% the State-Action-Reward-State-Action (SARSA) as it has a discrete action
% space and a continous observation space.

% Generate the action space
actInfo = rlFiniteSetSpec(fixtureVertices);

% Provide the observation space
obsInfo = rlNumericSpec([1 1]);
obsInfo.Name = 'observations';

% Define the environment (need to add reset and step functions here)
env = rlFunctionEnv( ...
    obsInfo, actInfo, ...
    @myStepFunction);


%% Train the policy
% The policy is trained for a certain number of episodes. In each episode,
% the drill position is applied for a set number of iterations (here marked
% for 10, leading to 190 timesteps). The problem is considered 'solved' if
% the algorithm lasts until the 
num_episodes = 100;
num_iterations = 10;



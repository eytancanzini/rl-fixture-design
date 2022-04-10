%% Reinforcement Learning for Fixture Layout Planning
% This file will introduce reinforcement learning (RL) as a method of
% generating optimal fixture plans for a component. This approach treats
% the fixture planning as a control problem rather than a dynamic
% programming problem.

%% Model Preparation
% Load the model into the workspace and initialise the structural boundary
% constraints
model = loadModel('../models/front_wing_spar.stl');
disp(model)

fixtureVertices = generateGrid(-990, -20, 10, 180, 20, 10);
drill_list = -950:50:-50;
drillingVertices = zeros(size(drill_list,2), 3);
for i=1:size(drill_list,2)
    drillingVertices(i, :) = [20 drill_list(i) 200];
end

%% Variable Preparation
% First initialise empty datasets that are used to store the meshes and the
% values of deformation at each screw position
drilling_results_z = {};
drilling_results_x = {};
drilling_meshes = {};

%% Create the agent, action and observation spaces
% This section is used to setup the reinforcement learning agent that is
% acting in this environment. The current method that seems to work best is
% the State-Action-Reward-State-Action (SARSA) as it has a discrete action
% space and a continous observation space.

average_value = 0; % Average value across the entire mesh for the stresses, can be supplied as the ensemble average(?)

%% Train the policy
% The policy is trained for a certain number of episodes. In each episode,
% the drill position is applied for a set number of iterations (here marked
% for 10, leading to 190 timesteps). The problem is considered 'solved' if
% the algorithm lasts until the 
num_episodes = 100;
num_iterations = 10;

for i=1:num_episodes
    for j=1:size(drill_pos,1)
        for k=1:num_iterations

        end
    end
end

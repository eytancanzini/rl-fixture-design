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

[fixtureVertices, drill_pos] = generateVertex(45); % Generate fixture positions and the holes for the drilling positions

%% Variable Preparation
% First initialise empty datasets that are used to store the meshes and the
% values of deformation at each screw position
drilling_results_z = {};
drilling_results_x = {};
drilling_meshes = {};

%% Create the agent, action and observation spaces
% This section is used to setup the reinforcement learning agent that is
% acting in this environment. The current methods that seem to work best
% Proximal Policy Optimisation (PPO) and State-Action-Reward-State-Action
% (SARSA) as these methods work well in discrete environments. You will
% need to convert the environment into a Markov Decision Process (MDP)
% environment

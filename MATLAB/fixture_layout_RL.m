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

% Create an environment variable
model_env = rlFixturePlanning();

% Create the observation and action spaces
obsInfo = rlNumericSpec([3 1]);
actInfo = rlFiniteSetSpec(linspace(1, 100, 100));

nI = obsInfo.Dimension(1);
nL = 100;
nO = numel(actInfo.Elements);

% Create a deep neural network that is used as the function approximation
% for the Q-learning function
dnn = [
    featureInputLayer(nI,'Normalization','none','Name','state')
    fullyConnectedLayer(nL,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(nL,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(nO,'Name','fc3')];
net = dlnetwork(dnn);

% % Create the critic neural network for the Q-agent
% % Create the observation path
% obsPath = [
%     featureInputLayer(3, 'Name', 'obs')
%     fullyConnectedLayer(100, 'Name', 'hiddenobs')
%     reluLayer("Name", 'reluobs')
%     fullyConnectedLayer(100, 'Name', 'fcobs')
% ];
% 
% % Create the action path
% actPath = [
%     featureInputLayer(1, 'Name', 'act')
%     fullyConnectedLayer(100, 'Name', 'hiddenact')
%     reluLayer("Name", 'reluact')
%     fullyConnectedLayer(100, 'Name', 'fcact')
% ];
% 
% % Link the paths together
% joinedPath = [
%     additionLayer(2, 'Name', 'add')
%     reluLayer('Name', 'relu')
%     fullyConnectedLayer(1, 'Name', 'fc')
% ];
% 
% net = layerGraph(obsPath);
% net = addLayers(net, actPath);
% net = addLayers(net, joinedPath);
% 
% % Connect the layers
% net = connectLayers(net, 'fcobs', 'add/in1');
% net = connectLayers(net, 'fcact', 'add/in2');

% Initialise the Q-agent
repopts = rlRepresentationOptions( ...
    "LearnRate", 0.001, "GradientThreshold", 1);
opts = rlQAgentOptions( ...
    "DiscountFactor", 1);
opts.EpsilonGreedyExploration.EpsilonDecay = 0.001;
critic = rlVectorQValueFunction( ...
    net, obsInfo, actInfo, ...
    'Observation', 'state');

agent = rlQAgent(critic, opts);

%% Train the policy
% The policy is trained for a certain number of episodes. In each episode,
% the drill position is applied for a set number of iterations (here marked
% for 10, leading to 190 timesteps). The problem is considered 'solved' if
% the algorithm lasts until the 

x = "Press 'Enter' to begin training the agent";
disp(x)
pause

opt = rlTrainingOptions(...
    'MaxEpisodes',2,...
    'MaxStepsPerEpisode',100,...
    'StopTrainingCriteria',"AverageReward",...
    'StopTrainingValue',480);

results = train(agent, model_env, opt);





classdef rlFixturePlanning < rl.env.MATLABEnvironment
    % Class for defining new fixture planning 
    % To-Do:
    % - Fix the observation and state functions
    % - Setup the action and reward functions
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties 
        drill_list = -950:50:-50;
        drillingVertices = drillingVerticesGenerator(drill_list);

        % Set some parameters for timestepping
        timestep = 1; % Each hole is performed for 100 timesteps
        State = 1; % State refers to the hole being drilled
        
        % Distance at which to fail the episode
        DisplacementThreshold = 1e-3;
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end

    %% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = rlFixturePlanning(file_addr)
            % Initialize FEA PDE model
            model = loadModel(file_addr);            
            
            % Initialise observation states
            obsInfo = rlNumericSpec([1 1]);
            obsInfo.Name = 'Observation States';
            obsInfo.Description = 'Vector of observation states. Current just a single observation';
            
            % Initialize Action settings  
            fixtureVertices = num2cell(generateGrid(-990, -20, 10, 180, 20, 10), 2);
            actInfo = rlFiniteSetSpec(fixtureVertices);
            actInfo.Name = 'Fixture Position Action';
            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(obsInfo,actInfo);
            
            % Initialize property values and pre-compute necessary values
            updateActionInfo(this);
        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];
            
            % Get action for this timestep
            fixtureLocation = getForce(this,Action);            

            % Apply motion equations            
            ThetaDotDot = (this.Gravity * SinTheta - CosTheta* temp) / (this.HalfPoleLength * (4.0/3.0 - this.PoleMass * CosTheta * CosTheta / SystemMass));
            XDotDot  = temp - this.PoleMass*this.HalfPoleLength * ThetaDotDot * CosTheta / SystemMass;
            
            % Generate the observation of the system
            Observation = this.State + this.Ts.*[XDot;XDotDot;ThetaDot;ThetaDotDot];

            % Update system states
            this.State = Observation;
            
            % Check terminal condition
            X = Observation(1);
            Theta = Observation(3);
            IsDone = abs(X) > this.DisplacementThreshold || abs(Theta) > this.AngleThreshold;
            this.IsDone = IsDone;
            
            % Get reward
            Reward = getReward(this);
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            this.timestep = 1;
            this.State = 1;
            
            InitialObservation = [X0;Xd0;T0;Td0];
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Helper methods to create the environment
        % Discrete force 1 or 2
        function force = getForce(this,action)
            if ~ismember(action,this.ActionInfo.Elements)
                error('Action must be %g for going left and %g for going right.',-this.MaxForce,this.MaxForce);
            end
            force = action;           
        end
        % update the action info based on max force
        function updateActionInfo(this)
            this.ActionInfo.Elements = this.MaxForce*[-1 1];
        end
        
        % Reward function
        function Reward = getReward(this)
            if ~this.IsDone
                Reward = this.RewardForNotFalling;
            else
                Reward = this.PenaltyForFalling;
            end          
        end
        
        % (optional) Visualization method
        function plot(this)
            % Initiate the visualization
            
            % Update the visualization
            envUpdatedCallback(this)
        end
        
    end
    
    methods (Access = protected)
        % (optional) update visualization everytime the environment is updated 
        % (notifyEnvUpdated is called)
        function envUpdatedCallback(this)
        end
    end
end

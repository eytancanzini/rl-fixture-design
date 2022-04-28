classdef rlFixturePlanning < rl.env.MATLABEnvironment
    % Class for defining new fixture planning 
    % To-Do:
    % - Change the observation matrix to include the state (drilling hole)
    % and the stress in the direction
    % - Implement a different RL policy - PPO or SARSA seem good, both can
    % deal with discrete action spaces and continuous observation spaces
    % - Change the reward function to be more discrete
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties 
        drillList = linspace(-950, 50, 100)

        % Set some parameters for timestepping
        timestep = 1 % Each hole is performed for 100 timesteps
        State = 1 % State refers to the hole being drilled
        
        % Distance at which to fail the episode
        DisplacementThreshold = 1e-3
        StressThreshold = 276

        % Cumulative Displacement threshold at which to fail the epsiode
        ResidualStresses = 0;

        PenaltyForFailing = -1

        % Set of fixture locations
        fixtureVertices = num2cell(generateGrid(-990, -20, 10, 180, 20, 10), 2);

        model = loadModel('../models/front_wing_spar.stl')
        F_drill = rivetingForce(4e-3, 0, 3e+8)

    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end

    %% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = rlFixturePlanning()
            
            % Initialise observation states
            obsInfo = rlNumericSpec([3 1]);
            obsInfo.Name = 'Observation States';
            obsInfo.Description = ['Vector of observation states. Format is:' ...
                '\nStress - Von Mises Stress' ...
                '\nX Displacement - Displacement in X' ...
                '\nZ Displacement - Displacement in Z'];
            
            % Initialize Action settings
            actInfo = rlFiniteSetSpec(linspace(1, 100, 100));
            actInfo.Name = 'Fixture Position Action';
            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(obsInfo,actInfo);
        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];
            drillingVertices = drillingVerticesGenerator(this.drillList);
            
            % Get action for this timestep
            [Stress, Displacement_x, Displacement_z] = getForce(this, Action, this.State, drillingVertices);            
            
            % Generate the observation of the system. This observes the
            % stress through the system
            Observation = [max(Stress); max(Displacement_x); max(Displacement_z)];

            % Update system states. This moves the drilling position to the
            % next frame along the path
            this.State = this.State+1;
            
            % Check terminal condition
            this.ResidualStresses = this.ResidualStresses + max(Stress);
            IsDone = max(Displacement_x) > this.DisplacementThreshold || max(Displacement_z) > this.DisplacementThreshold;
            this.IsDone = IsDone;
            
            % Get reward
            Reward = getReward(this, Observation);
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            this.timestep = 1;
            this.State = 1;
            this.ResidualStresses = 0;

            InitialObservation = [0;0;0];
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
    end

    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Determine the stress and displacement from the selected action by
        % the agent
        function [stress, displacement_x, displacement_z] = getForce(this, action, State, vertices)
            if ~ismember(action,this.ActionInfo.Elements)
                error('Action must be part of the action space specified by the component list');
            end

            temp_model = this.model;
            fprintf('Action taken: %d\n', action)
            fixtureVertexID = addVertex(temp_model.Geometry, "Coordinates", cell2mat(this.fixtureVertices ...
                (action)));
            drillVertexID = addVertex(temp_model.Geometry, 'Coordinates', vertices(State,:));
            structuralBoundaryLoad(temp_model, 'Vertex', drillVertexID, 'Force', [0 0 this.F_drill]);
            structuralBoundaryLoad(temp_model, 'Vertex',fixtureVertexID, 'Force', calculateMagneticForce(0.4, 'x'));
            generateMesh(temp_model);
            results = solve(temp_model);
            displacement_x = results.Displacement.x;
            displacement_z = results.Displacement.z;
            stress = results.VonMisesStress;
        end
        
        % Reward function
        function Reward = getReward(this, obs)
            if ~this.IsDone
                x = obs(2);
                z = obs(3);

                if x < this.DisplacementThreshold && z < this.DisplacementThreshold
                    Reward = 1;
                else
                    Reward = exp(-8*(xmat-0.2).^2) + exp(-8*(ymat-0.2).^2)/3;
                end
            else
                Reward = this.PenaltyForFailing;
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

import abc
import numpy as np
import tensorflow as tf
from tf_agents.environments import py_environment
from tf_agents.trajectories import time_step as ts
import gym
from gym import spaces, utils, error
from sympy import symbols
import matlab
import calculateDeformation

class BanditEnvironment(py_environment.PyEnvironment):
    
    def __init__(self, observation_spec, action_spec):
        self._observation_spec = observation_spec
        self._action_spec = action_spec
        super(BanditEnvironment, self).__init__()
        
    def action_spec(self):
        return self._action_spec
    
    def observation_spec(self):
        return self._observation_spec
    
    def _empty_observation(self):
        return tf.nest.map_structure(lambda x: np.zeros(x.shape, x.dtype),
                                 self.observation_spec())
    
    # These two functions should not be overridden by subclasses
    def _reset(self):
        """
        Returns a time step containing an observation
        """
        return ts.restart(self._observe(), batch_size=self.batch_size)
    
    def _step(self, action):
        """
        Returns a time step containing the reward for the action taken

        Args:
            action (_action_spec): Action taken by the agent 
        """
        reward = self._apply_action(action)
        return ts.termination(self._observe(), reward)
    
    #These two functions can be implemented in the subclasses
    @abc.abstractmethod
    def _observe(self):
        """
        Return an observation
        """
        
    @abc.abstractmethod
    def _apply_action(self, action):
        """
        Applies `action` to the environment and returns the corresponding reward

        Args:
            action (_action_spec): Action taken by the agent
        """
       
       
class SimplePyEnvironment(BanditEnvironment):
    
    def __init__(self, observation_spec, action_spec):
        """
        Generate a simple environment by extending the BanditEnvironment Class

        Args:
            observation_spec (array_spec): Variable containing information about the observation space
            action_spec (array_spec): Variable containing information about the action space
        """
        super(SimplePyEnvironment, self).__init__(observation_spec, action_spec)
        
    def _observe(self):
        """
        Generate a random observation of the environment

        Returns:
            int32: Observation presented to the system
        """
        self._observation = np.random.randint(-2, 3, (1,), dtype='int32')
        return self._observation
    
    def _apply_action(self, action):
        return action * self._observation
    
    
class FixtureBandit(gym.Env):
    
    def __init__(self, contexts, actions):
        """
        Defines an environment that takes in a fixturing position and applies is the wing panel model. This environment is designed to work with a specific model of wing panel, so be wary when applying it to other models.

        Args:
            contexts (np.ndarray): Array of contexts that define the drilling positions 
            actions (np.ndarray): Array of actions that translate into positions for the fixtures
        """
        assert type(contexts) is np.ndarray and type(actions) is np.ndarray
        low = np.array([
            0,0
        ]).astype(np.float32)
        
        high = np.array([
            10, 10
        ]).astype(np.float32)
        
        self.viewer = None
        self.num_contexts = len(contexts)
        self.num_actions = len(actions)
        
        self.action_space = spaces.Discrete(self.num_actions)
        self.observation_space = spaces.Box(low, high)
        
        self._seed()
        self._reset()
        self.xvec, self.zvec = symbols('x z')
        self.eq_coefficients = {
            'a': 1,
            'b': 1,
            'c': 0
        }
        
    def _reset(self):
        self.state = np.random.randint(self.num_contexts)
        return np.array(self.state)
    
    def _seed(self, seed=None):
        self.np_random, seed = seeding.np_random(seed)
        return [seed]
    
    def _render(self, mode='human', close=False):
        """
        Function is not needed as the environment is not rendered to the screen. Edit for your requirements
        """
        pass
    
    def step(self, action):
        """
        Steps through the environment based on the state and with the selected action

        Args:
            action (np.ndarray): Action identifier that chooses which action to take

        Returns:
            Returns the state, reward, 'done' identifier and any other additional information
        """
        
        assert self.action_space.contains(action)
        
        reward = 0
        done = True
        observation = self._get_observation(action, self.state)
        
        reward = self._get_reward(observation)
        
        if self.state == 0:
            self.state = 1
        else:
            self.state = 0
            
        return np.array(self.state), reward, done, {}
    
    def _get_observation(self, action, context):
        """
        Calls the MATLAB function and receives the deformation from the MATLAB script

        Args:
            action (np.ndarray): Action locator that is provided as coordinates
            context (np.ndarray): Specific context that relates to the drilling

        Returns:
            np.ndarray: N-dimensional array of the deformations and residual stresses of the component
        """
        
        my_calculate = calculateDeformation.initialize()
        fixture_pos = matlab.double(action, size=(1,3))
        drill_pos = matlab.double(context, size(1, 3))
        
        z_out, x_out = my_calculate.calculateDeformation(fixture_pos, drill_pos, nargout=2)
        
        my_calculate.terminate()
        
        return np.append(
            np.asarray(z_out),
            np.asarray(x_out),
            axis=1)
    
    def _get_reward(self, observation=None):
        """
        Calculates the reward based on the fuzzy reward scheme for the X- and Z-dimension. Reward scheme is based on the paper by Chen et al. (https://doi.org/10.1109/TCSII.2019.2947682) 

        Args:
            observation (np.ndarray, optional): N-dimensional array that contains the X-,Y-,Z-dimension deformations and the residual . Defaults to None.

        Returns:
            np.ndarray: Returns an array of a singular reward based on the X- and Z-dimension deformation values
        """
        if observation == None:
            return 0
        else:
            x = max(observation[:,0])
            z = max(observation[:,1])
            
            R = (1/(1 + ((self.xvec-self.c)/self.a)**(2*self.b)) + 1/(1 + ((self.zvec-self.c)/self.a)**(2*self.b)))/2
            return np.array(R.subs(self.xvec, x).subs(self.zvec, z)).astype(np.float32)
            
                
    
    



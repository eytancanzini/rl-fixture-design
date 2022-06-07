import abc
import numpy as np
import tensorflow as tf
from tf_agents.environments import py_environment
from tf_agents.trajectories import time_step as ts

class BanditEnvironment(py_environment.PyEnvironment):
    
    def __init__(self, observation_spec, action_spec):
        self._observation_spec = observation_spec
        self._action_spec = action_spec
        super(BanditEnvironment, self).__init__()
        
    def action_spec(self):
        return self._action_spec
    
    def observation_spec(self):
        return self._observation_spec
    
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
        return ts.termination(self.observe(), reward)
    
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
        



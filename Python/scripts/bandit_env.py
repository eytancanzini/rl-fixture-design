import abc
import numpy as np
import tensorflow as tf
from tf_agents.environments import py_environment

class BanditEnvironment(py_environment.PyEnvironment):
    
    def __init__(self, observation_spec, action_spec):
        self._observation_spec = observation_spec
        self._action_spec = action_spec
        


